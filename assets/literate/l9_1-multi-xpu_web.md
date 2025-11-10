<!--This file was generated, do not modify it.-->
# Distributed computing in Julia

### The goal of this lecture 9:

- Distributed computing
  - Fake parallelisation
  - Julia MPI (CPU + GPU)

## New to distributed computing?

_If this is the case or not - hold-on, we certainly have some good stuff for everyone_

### Distributed computing

Adds one additional layer of parallelisation:
- Global problem does no longer "fit" within a single compute node (or GPU)

- Local resources (mainly memory) are finite, e.g.,
  - CPUs: increase the number of cores beyond what a single CPU can offer
  - GPUs: overcome the device memory limitation

Simply said:

_If one CPU or GPU is not sufficient to solve a problem, then use more than one and solve a subset of the global problem on each._

Distributed (memory) computing permits to take advantage of computing "clusters", many similar compute nodes interconnected by high-throughput network. That's also what supercomputers are.

### Parallel scaling

So here we go. Let's assume we want to solve a certain problem, which we will call the "global problem". This global problem, we split then into several local problems that execute concurrently.

Two scaling approaches exist:
- strong scaling
- weak scaling

Increasing the amount of computing resources to resolve the same global problem would increase parallelism and may result in faster execution (wall-time). This is called _**strong scaling**_: the resources are increased but the global problem size does not change, resulting in an increase in the number of (smaller) local problems that can be solved in parallel.

The _**strong scaling**_ approach is often used when parallelising legacy CPU codes, as increasing the number of parallel local problems can lead to some speed-up, reaching an optimum beyond which additional local processes is no longer be beneficial.

However, we won't follow that path when developing parallel multi-GPU applications from scratch. Why?

_Because GPUs' performance is very sensitive to the local problem size as we experienced when trying to tune the kernel launch parameters (threads, blocks, i.e., the local problem size)._

When developing multi-GPU applications from scratch, it is likely more suitably to approach distributed parallelism from a _**weak scaling**_ perspective:
defining first the optimal local problem size to resolve on a single GPU and then increasing the number of local problems (and the number of GPUs) until reaching the global problem one originally wants to solve.

### Implicit Global Grid

We can thus replicate a local problem multiple times in each dimension of the Cartesian space to obtain a global grid, which is therefore defined implicitly. Local problems define each others local boundary conditions by exchanging internal boundary values using intra-node communication (e.g., message passing interface - [MPI](https://en.wikipedia.org/wiki/Message_Passing_Interface)), as depicted on the [figure](https://github.com/eth-cscs/ImplicitGlobalGrid.jl) hereafter:

![IGG](../assets/literate_figures/l9_igg.png)

### Distributing computations - challenges

Many things could potentially go wrong in distributed computing. However, the ultimate goal (at least for us) is to keep up with _**parallel efficiency**_.

The parallel efficiency defines as the speed-up divided by the number of processors. The speed-up defines as the execution time using an increasing number of processors normalised by the single processor execution time. We will use the parallel efficiency in a weak scaling configuration.

Ideally, the parallel efficiency should stay close to 1 while increasing the number of computing resources proportionally with the global problem size (i.e. keeping the constant local problem sizes), meaning no time is lost (no overhead) in due to, e.g., inter-process communication, network congestion, congestion of shared filesystem, etc... as shown in the [figure](https://github.com/eth-cscs/ImplicitGlobalGrid.jl) hereafter:

![Parallel scaling](../assets/literate_figures/l9_par_eff.png)

---

### Let's get started

We will explore distributed computing with Julia's MPI wrapper [MPI.jl](https://github.com/JuliaParallel/MPI.jl). This will enable our codes to run on multiple CPUs and GPUs in order to scale on modern multi-CPU/GPU nodes, clusters and supercomputers. In the proposed approach, each MPI process handles one CPU or GPU.

We're going to work out the following steps to tackle distributed parallelisation in this lecture (in 5 steps):
- [**Fake parallelisation** as proof-of-concept](#fake_parallelisation)
- [**Julia and MPI**](#julia_and_mpi)

## Fake parallelisation

As a first step, we will look at the below 1-D diffusion code which solves the linear diffusion equations using a "fake-parallelisation" approach. We split the calculation on two distinct left and right domains, which requires left and right `C` arrays, `CL` and `CR`, respectively.

In this "fake parallelisation" code, the computations for the left and right domain are performed sequentially on one process, but they could be computed on two distinct processes if the needed boundary update (often referred to as halo update in literature) was done with MPI.

![1D Global grid](../assets/literate_figures/l9_1D_global_grid.png)

The idea of this fake parallelisation approach is the following:
```julia
# Compute physics locally
CL[2:end-1] .= CL[2:end-1] .+ dt*D*diff(diff(CL)/dx)/dx
CR[2:end-1] .= CR[2:end-1] .+ dt*D*diff(diff(CR)/dx)/dx
# Update boundaries (MPI)
CL[end] = ...
CR[1]   = ...
# Global picture
C .= [CL[1:end-1]; CR[2:end]]
```

We see that a correct boundary update will be the critical part for a successful implementation. In our approach, we need an overlap of 2 cells between `CL` and `CR` in order to avoid any wrong computations at the transition between the left and right domains.

### Step 1 (fake parallelisation with 2 fake processes)

Run the "fake parallelisation" 1-D diffusion code [`l9_diffusion_1D_2procs.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/l9_scripts/), which is missing the boundary updates of the 2 fake processes and describe what you see in the visualisation.

Then, add the required boundary update:

```julia
# Update boundaries (MPI)
CL[end] = ...
CR[1]   = ...
```

in order make the code work properly and run it again. Note what has changed in the visualisation.

~~~
<center>
  <video width="60%" autoplay loop controls src="../assets/literate_figures/l9_diff_1D_2procs.mp4"/>
</center>
~~~

The next step will be to generalise the fake parallelisation with `2` fake processes to work with `n` fake processes. The idea of this generalised fake parallelisation approach is the following:

```julia
for ip = 1:np # compute physics locally
    C[2:end-1,ip] .= C[2:end-1,ip] .+ dt*D*diff(diff(C[:,ip])/dxg)/dxg
end
for ip = 1:np-1 # update boundaries
   # ...
end
for ip = 1:np # global picture
    i1 = 1 + (ip-1)*(nx-2)
    Cg[i1:i1+nx-2] .= C[1:end-1,ip]
end
```

The array `C` contains now `n` local domains where each domain belongs to one fake process, namely the fake process indicated by the second index of `C` (ip). The boundary updates are to be adapted accordingly. All the physical calculations happen on the local chunks of the arrays.

We only need "global" knowledge in the definition of the initial condition.

The previous simple initial conditions can be easily defined without computing any Cartesian coordinates. To define other initial conditions we often need to compute global coordinates.

In the code below, which serves to define a Gaussian anomaly in the centre of the domain, Cartesian coordinates can be computed for each cell based on the process ID (`ip`), the cell ID (`ix`), the array size (`nx`), the overlap of the local domains (`2`) and the grid spacing of the global grid (`dxg`); moreover, the origin of the coordinate system can be moved to any position using the global domain length (`lx`):

```julia
# Initial condition
for ip = 1:np
    for ix = 1:nx
        x[ix,ip] = ...
        C[ix,ip] = exp(-x[ix,ip]^2)
    end
    i1 = 1 + (ip-1)*(nx-2)
    xt[i1:i1+nx-2] .= x[1:end-1,ip]; if (ip==np) xt[i1+nx-1] = x[end,ip] end
    Ct[i1:i1+nx-2] .= C[1:end-1,ip]; if (ip==np) Ct[i1+nx-1] = C[end,ip] end
end
```

### Step 2 (fake parallelisation with `n` fake processes)

Modify the initial condition in the 1-D diffusion code [`l9_diffusion_1D_nprocs.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/l9_scripts/) to a centred $(L_x/2)$ Gaussian anomaly.

Then run this code which is missing the boundary updates of the `n` fake processes and describe what you see in the visualisation. Then, add the required boundary update in order make the code work properly and run it again. Note what has changed in the visualisation.

~~~
<center>
  <video width="60%" autoplay loop controls src="../assets/literate_figures/l9_diff_1D_nprocs.mp4"/>
</center>
~~~

## Julia and MPI

We are now ready to write a code that will truly distribute calculations on different processors using [MPI.jl](https://github.com/JuliaParallel/MPI.jl) for inter-process communication.

\note{At this point, make sure to have a working Julia MPI environment. Head to [Julia MPI install](/software_install/#julia_mpi) to set-up Julia MPI. See [GPU computing on Alps](/software_install/#gpu_computing_on_alps) for detailed information on how to run MPI GPU (multi-GPU) applications on Daint.Alps.}

Let us see what are the somewhat minimal requirements that will allow us to write a distributed code in Julia using MPI.jl. We will solve the following linear diffusion physics (see [`l9_diffusion_1D_mpi.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/l9_scripts/)):
```julia
for it = 1:nt
    qx         .= .-D*diff(C)/dx
    C[2:end-1] .= C[2:end-1] .- dt*diff(qx)/dx
end
```
To enable distributed parallelisation, we will do the following steps:
1. Initialise MPI and set up a Cartesian communicator
2. Implement a boundary exchange routine
3. Create a "global" initial condition
4. Finalise MPI

To (1.) initialise MPI and prepare the Cartesian communicator, we do (upon `import MPI`):
```julia
import MPI

MPI.Init()
dims        = [0]
comm        = MPI.COMM_WORLD
nprocs      = MPI.Comm_size(comm)
MPI.Dims_create!(nprocs, dims)
comm_cart   = MPI.Cart_create(comm, dims, [0], 1)
me          = MPI.Comm_rank(comm_cart)
coords      = MPI.Cart_coords(comm_cart)
neighbors_x = MPI.Cart_shift(comm_cart, 0, 1)
```
where `me` represents the process ID unique to each MPI process (the analogue to `ip` in the fake parallelisation).

Then, we need to (2.) implement a boundary update routine, which can have the following structure:
```julia
@views function update_halo!(A, neighbors_x, comm)
    # Send to / receive from neighbour 1 ("left neighbor")
    if neighbors_x[1] != MPI.PROC_NULL
        sendbuf = ??
        recvbuf = ??
        MPI.Send(??,  neighbors_x[?], 0, comm)
        MPI.Recv!(??, neighbors_x[?], 1, comm)
        A[1] = ??
    end
    # Send to / receive from neighbour 2 ("right neighbor")
    if neighbors_x[2] != MPI.PROC_NULL
        sendbuf = ??
        recvbuf = ??
        MPI.Recv!(??, neighbors_x[?], 0, comm)
        MPI.Send(??,  neighbors_x[?], 1, comm)
        A[end] = ??
    end
    return
end
```

Then, we (3.) initialize `C` with a "global" initial Gaussian anomaly that spans correctly over all local domains. This can be achieved, e.g., as given here:
```julia
x0    = coords[1]*(nx-2)*dx
xc    = [x0 + ix*dx - dx/2 - 0.5*lx  for ix=1:nx]
C     = exp.(.-xc.^2)
```
where `x0` represents the first global x-coordinate on every process (computed in function of `coords`) and `xc` represents the local chunk of the global coordinates on each local process (this is analogue to the initialisation in the fake parallelisation).

Last, we need to (4.) finalise MPI prior to returning from the main function:
```julia
MPI.Finalize()
```
All the above described is found in the code [`l9_diffusion_1D_mpi.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/l9_scripts/), except for the boundary updates (see 2.).

### Step 3 (1-D parallelisation with MPI)

Run the code [`l9_diffusion_1D_mpi.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/l9_scripts/) which is still missing the boundary updates three times: with 1, 2 and 4 processes (replacing `np` by the number of processes):
```sh
mpiexecjl -n <np> julia --project <my_script.jl>
```

Visualise the results after each run with the [`l9_vizme1D_mpi.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/l9_scripts/) code (_**adapt the variable `nprocs`!**_). Describe what you see in the visualisation. Then, add the required boundary update in order make the code work properly and run it again. Note what has changed in the visualisation.

\note{For the boundary updates, you can use the following approach for the communication with each neighbour: 1) create a `sendbuffer` and `receive` buffer, storing the right value in the send buffer; 2) use `MPI.Send` and `MPI.Recv!` to send/receive the data; 3) store the received data in the right position in the array.}

Congratulations! You just did a distributed memory diffusion solver in only 70 lines of code.

Let us now do the same in 2D: there is not much new there, but it may be interesting to work out how boundary update routines can be defined in 2D as one now needs to exchange vectors instead of single values.

👉 You'll find a working 1D script in the [scripts/l9_scripts](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/l9_scripts/) folder after the lecture.

### Step 4 (2-D parallelisation with MPI)

Run the code [`l9_diffusion_2D_mpi.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/l9_scripts/) which is still missing the boundary updates three times: with 1, 2 and 4 processes.

Visualise the results after each run with the [`l9_vizme2D_mpi.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/l9_scripts/) code (adapt the variable `nprocs`!). Describe what you see in the visualisation. Then, add the required boundary update in order make the code work properly and run it again. Note what has changed in the visualisation.

@@img-med
![diffusion 2D MPI](../assets/literate_figures/l10_diff_2D_mpi.png)
@@

The last step is to create a multi-GPU solver out of the above multi-CPU solver. CUDA-aware MPI is of great help in this task, because it allows to directly pass GPU arrays to the MPI functions.

Besides facilitating the programming, it can leverage Remote Direct Memory Access (RDMA) which can be of great benefit in many HPC scenarios.

### Step 5 (multi-GPU)

Translate the code `diffusion_2D_mpi.jl` from Step 4 to GPU using GPU array programming. Note what changes were needed to go from CPU to GPU in this distributed solver.

Use a similar approach as implemented in the CPU code to perform the boundary updates. You can use the `copyto!` function in order to copy the data from the GPU memory into the send buffers (CPU memory) or to copy the receive buffer data (CPU memory) baclk to the GPU array.

\note{Have a look at the [`l9_hello_mpi_gpu.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/l9_scripts/) code to get an idea on how to select a GPU based on node-local MPI infos.}

Head to the [exercise section](#exercises_-_lecture_9) for further directions on this step which is part of this week's homework assignments.

\note{As alternative, one could use the same approach as in the CPU code to perform the boundary updates thanks to CUDA-aware MPI (it allows to pass GPU arrays directly to the MPI functions). However, this requires MPI being specifically built for that purpose.}

This completes the introduction to distributed parallelisation with Julia.

Note that high-level Julia packages as for example [ImplicitGlobalGrid.jl](https://github.com/eth-cscs/ImplicitGlobalGrid.jl) can render distributed parallelisation with GPU and CPU for HPC a very simple task. We'll check it out in the next lecture.

### Wrapping up

Let's recall what we learned today about distributed computing in Julia using GPUs:
- We used fake parallelisation to understand the correct boundary exchange procedure.
- We implemented 1D and 2D diffusion solvers in Julia using MPI for distributed memory parallelisation on both CPUs and GPUs (using blocking communication).

