#src # This is needed to make this run as normal Julia file
using Markdown #src

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
#nb # _Lecture 8_
md"""
# Distributed computing in Julia
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### The goal of this lecture 8:

- Distributed computing
  - Fake parallelisation
  - Julia MPI (CPU + GPU)
  - Using `ParallelStencil.jl` together with `ImplicitGlobalGrid.jl`
  - Thermal porous convection 3D using GPU MPI
- Automatic documentation and CI
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## New to distributed computing?

"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
_If this is the case or not - hold-on, we certainly have some good stuff for everyone_
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### Distributed computing

Adds one additional layer of parallelisation:
- Global problem does no longer "fit" within a single compute node (or GPU)
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
- Local resources (mainly memory) are finite, e.g.,
  - CPUs: increase the number of cores beyond what a single CPU can offer
  - GPUs: overcome the device memory limitation
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Simply said:

_If one CPU or GPU is not sufficient to solve a problem, then use more than one and solve a subset of the global problem on each._
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Distributed (memory) computing permits to take advantage of computing "clusters", many similar compute nodes interconnected by high-throughput network. That's also what supercomputers are.
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### Parallel scaling

So here we go. Let's assume we want to solve a certain problem, which we will call the "global problem". This global problem, we split then into several local problems that execute concurrently.

Two scaling approaches exist:
- strong scaling
- weak scaling
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Increasing the amount of computing resources to resolve the same global problem would increase parallelism and may result in faster execution (wall-time). This parallelisation is called _**strong scaling**_; the resources are increased but the global problem size does not change, resulting in an increase in the number of (smaller) local problems that can be solved in parallel.
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
The _**strong scaling**_ approach is often used when parallelising legacy CPU codes, as increasing the number of parallel local problems can lead to some speed-up, reaching an optimum beyond which additional local processes is no longer be beneficial.
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
However, we won't follow that path when developing parallel multi-GPU applications from scratch. Why?

_Because GPUs' performance is very sensitive to the local problem size as we experienced when trying to tune the kernel launch parameters (threads, blocks, i.e., the local problem size)._
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
When developing multi-GPU applications from scratch, it is likely more suitably to approach distributed parallelisation from a _**weak scaling**_ perspective;
defining first the optimal local problem size to resolve on a single GPU and then increasing the number of optimal local problems (and the number of GPUs) until reaching the global problem one originally wants to solve.
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### Implicit Global Grid

We can thus replicate a local problem multiple times in each dimension of the Cartesian space to obtain a global grid, which is therefore defined implicitly. Local problems define each others local boundary conditions by exchanging internal boundary values using intra-node communication (e.g., message passing interface - [MPI](https://en.wikipedia.org/wiki/Message_Passing_Interface)), as depicted on the [figure](https://github.com/eth-cscs/ImplicitGlobalGrid.jl) hereafter:
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
![IGG](../assets/literate_figures/l8_igg.png)
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### Distributing computations - challenges

Many things could potentially go wrong in distributed computing. However, the ultimate goal (at least for us) is to keep up with _**parallel efficiency**_.
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
The parallel efficiency defines as the speed-up divided by the number of processors. The speed-up defines as the execution time using an increasing number of processors normalised by the single processor execution time. We will use the parallel efficiency in a weak scaling configuration.
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Ideally, the parallel efficiency should stay close to 1 while increasing the number of computing resources proportionally with the global problem size (i.e. keeping the constant local problem sizes), meaning no time is lost (no overhead) in due to, e.g., inter-process communication, network congestion, congestion of shared filesystem, etc... as shown in the [figure](https://github.com/eth-cscs/ImplicitGlobalGrid.jl) hereafter:
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
![Parallel scaling](../assets/literate_figures/l8_par_eff.png)
"""

#md # ---

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### Let's get started

we will explore distributed computing with Julia's MPI wrapper [MPI.jl](https://github.com/JuliaParallel/MPI.jl). This will enable our codes to run on multiple CPUs and GPUs in order to scale on modern multi-CPU/GPU nodes, clusters and supercomputers. In the proposed approach, each MPI process handles one CPU or GPU.
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
We're going to work out the following steps to tackle distributed parallelisation in this lecture (in 5 steps):
- [**Fake parallelisation** as proof-of-concept](#fake_parallelisation)
- [**Julia and MPI**](#julia_and_mpi)
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## Fake parallelisation
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
As a first step, we will look at the below 1-D diffusion code which solves the linear diffusion equations using a "fake-parallelisation" approach. We split the calculation on two distinct left and right domains, which requires left and right `C` arrays, `CL` and `CR`, respectively.
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
In this "fake parallelisation" code, the computations for the left and right domain are performed sequentially on one process, but they could be computed on two distinct processes if the needed boundary update (often referred to as halo update in literature) was done with MPI.
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
![1D Global grid](../assets/literate_figures/l8_1D_global_grid.png)
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
The idea of this fake parallelisation approach is the following:
```julia
# Compute physics locally
CL[2:end-1] .= CL[2:end-1] .+ dt*D*diff(diff(CL)/dx)/dx
CR[2:end-1] .= CR[2:end-1] .+ dt*D*diff(diff(CR)/dx)/dx
# Update boundaries (MPI)
CL[end] = CR[2]
CR[1]   = CL[end-1]
# Global picture
C .= [CL[1:end-1]; CR[2:end]]
```
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
We see that a correct boundary update will be the critical part for a successful implementation. In our approach, we need an overlap of 2 cells between `CL` and `CR` in order to avoid any wrong computations at the transition between the left and right domains.
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### Step 1 (fake parallelisation with 2 fake processes)

Run the "fake parallelisation" 1-D diffusion code [`l8_diffusion_1D_2procs.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/l8_scripts/), which is missing the boundary updates of the 2 fake processes and describe what you see in the visualisation.
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Then, add the required boundary update:

```julia
# Update boundaries (MPI)
CL[end] = CR[2]
CR[1]   = CL[end-1]
```

in order make the code work properly and run it again. Note what has changed in the visualisation.
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
#md # ~~~
# <center>
#   <video width="60%" autoplay loop controls src="../assets/literate_figures/l8_diff_1D_2procs.mp4"/>
# </center>
#md # ~~~

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
The next step will be to generalise the fake parallelisation with `2` fake processes to work with `n` fake processes. The idea of this generalised fake parallelisation approach is the following:

```julia
for ip = 1:np # compute physics locally
    C[2:end-1,ip] .= C[2:end-1,ip] .+ dt*D*diff(diff(C[:,ip])/dxg)/dxg
end
for ip = 1:np-1 # update boundaries
   C[end,ip  ] = C[    2,ip+1]
   C[  1,ip+1] = C[end-1,ip  ]
end
for ip = 1:np # global picture
    i1 = 1 + (ip-1)*(nx-2)
    Cg[i1:i1+nx-2] .= C[1:end-1,ip]
end
```
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
The array `C` contains now `n` local domains where each domain belongs to one fake process, namely the fake process indicated by the second index of `C` (ip). The boundary updates are to be adapted accordingly. All the physical calculations happen on the local chunks of the arrays.

We only need "global" knowledge in the definition of the initial condition.
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
The previous simple initial conditions can be easily defined without computing any Cartesian coordinates. To define other initial conditions we often need to compute global coordinates.

In the code below, which serves to define a Gaussian anomaly in the centre of the domain, Cartesian coordinates can be computed for each cell based on the process ID (`ip`), the cell ID (`ix`), the array size (`nx`), the overlap of the local domains (`2`) and the grid spacing of the global grid (`dxg`); moreover, the origin of the coordinate system can be moved to any position using the global domain length (`lx`):
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
```julia
# Initial condition
for ip = 1:np
    for ix = 1:nx
       x[ix,ip] = ( (ip-1)*(nx-2) + (ix-0.5) )*dxg - 0.5*lx
        C[ix,ip] = exp(-x[ix,ip]^2)
    end
    i1 = 1 + (ip-1)*(nx-2)
    xt[i1:i1+nx-2] .= x[1:end-1,ip]; if (ip==np) xt[i1+nx-1] = x[end,ip] end
    Ct[i1:i1+nx-2] .= C[1:end-1,ip]; if (ip==np) Ct[i1+nx-1] = C[end,ip] end
end
```
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### Step 2 (fake parallelisation with `n` fake processes)

Modify the initial condition in the 1-D diffusion code [`l8_diffusion_1D_nprocs.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/l8_scripts/) to a centred $(L_x/2)$ Gaussian anomaly.

Then run this code which is missing the boundary updates of the `n` fake processes and describe what you see in the visualisation. Then, add the required boundary update in order make the code work properly and run it again. Note what has changed in the visualisation.
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
#md # ~~~
# <center>
#   <video width="60%" autoplay loop controls src="../assets/literate_figures/l8_diff_1D_nprocs.mp4"/>
# </center>
#md # ~~~


#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## Julia and MPI

We are now ready to write a code that will truly distribute calculations on different processors using [MPI.jl](https://github.com/JuliaParallel/MPI.jl) for inter-process communication.
"""

#nb # > 💡 note: At this point, make sure to have a working Julia MPI environment. Head to [Julia MPI install](/software_install/#julia_mpi) to set-up Julia MPI. See [Julia MPI GPU on Piz Daint](/software_install/#julia_mpi_gpu_on_piz_daint) for detailed information on how to run MPI GPU (multi-GPU) applications on Piz Daint.
#md # \note{At this point, make sure to have a working Julia MPI environment. Head to [Julia MPI install](/software_install/#julia_mpi) to set-up Julia MPI. See [Julia MPI GPU on Piz Daint](/software_install/#julia_mpi_gpu_on_piz_daint) for detailed information on how to run MPI GPU (multi-GPU) applications on Piz Daint.}

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Let us see what are the somewhat minimal requirements that will allow us to write a distributed code in Julia using MPI.jl. We will solve the following linear diffusion physics (see [`l8_diffusion_1D_mpi.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/l8_scripts/)):
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
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
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
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Then, we need to (2.) implement a boundary update routine, which can have the following structure:
```julia
@views function update_halo!(A, neighbors_x, comm)
    # Send to / receive from neighbour 1 ("left neighbor")
    if neighbors_x[1] != MPI.MPI_PROC_NULL
        sendbuf = A[2]
        recvbuf = zeros(1)
        MPI.Send(sendbuf,  neighbors_x[1], 0, comm)
        MPI.Recv!(recvbuf, neighbors_x[1], 1, comm)
        A[1] = recvbuf[1]
    end
    # Send to / receive from neighbour 2 ("right neighbor")
    if neighbors_x[2] != MPI.MPI_PROC_NULL
        sendbuf = A[end-1]
        recvbuf = zeros(1)
        MPI.Recv!(recvbuf, neighbors_x[2], 0, comm)
        MPI.Send(sendbuf,  neighbors_x[2], 1, comm)
        A[end] = recvbuf[1]
    end
    return
end
```
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Then, we (3.) initialize `C` with a "global" initial Gaussian anomaly that spans correctly over all local domains. This can be achieved, e.g., as given here:
```julia
x0    = coords[1]*(nx-2)*dx
xc    = [x0 + ix*dx - dx/2 - 0.5*lx  for ix=1:nx]
C     = exp.(.-xc.^2)
```
where `x0` represents the first global x-coordinate on every process (computed in function of `coords`) and `xc` represents the local chunk of the global coordinates on each local process (this is analogue to the initialisation in the fake parallelisation).
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Last, we need to (4.) finalise MPI prior to returning from the main function:
```julia
MPI.Finalize()
```
All the above described is found in the code [`l8_diffusion_1D_mpi.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/l8_scripts/), except for the boundary updates (see 2.).
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### Step 3 (1-D parallelisation with MPI)

Run the code [`l8_diffusion_1D_mpi.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/l8_scripts/) which is still missing the boundary updates three times: with 1, 2 and 4 processes (replacing `np` by the number of processes):
```sh
mpiexecjl -n <np> julia --project <my_script.jl>
```
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Visualise the results after each run with the [`l8_vizme1D_mpi.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/l8_scripts/) code (_**adapt the variable `nprocs`!**_). Describe what you see in the visualisation. Then, add the required boundary update in order make the code work properly and run it again. Note what has changed in the visualisation.
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
#nb # > 💡 hint: For the boundary updates, you can use the following approach for the communication with each neighbour: 1) create a `sendbuffer` and `receive` buffer, storing the right value in the send buffer; 2) use `MPI.Send` and `MPI.Recv!` to send/receive the data; 3) store the received data in the right position in the array.
#md # \note{For the boundary updates, you can use the following approach for the communication with each neighbour: 1) create a `sendbuffer` and `receive` buffer, storing the right value in the send buffer; 2) use `MPI.Send` and `MPI.Recv!` to send/receive the data; 3) store the received data in the right position in the array.}

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Congratulations! You just did a distributed memory diffusion solver in only 70 lines of code.

Let us now do the same in 2D: there is not much new there, but it may be interesting to work out how boundary update routines can be defined in 2D as one now needs to exchange vectors instead of single values.

👉 You'll find a working 1D script in the [scripts/l8_scripts](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/l8_scripts/) folder after the lecture.
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### Step 4 (2-D parallelisation with MPI)

Run the code [`l8_diffusion_2D_mpi.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/l8_scripts/) which is still missing the boundary updates three times: with 1, 2 and 4 processes.

Visualise the results after each run with the [`l8_vizme2D_mpi.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/l8_scripts/) code (adapt the variable `nprocs`!). Describe what you see in the visualisation. Then, add the required boundary update in order make the code work properly and run it again. Note what has changed in the visualisation.
"""

#md # @@img-med
#md # ![diffusion 2D MPI](../assets/literate_figures/l8_diff_2D_mpi.png)
#md # @@

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
The last step is to create a multi-GPU solver out of the above multi-CPU solver. CUDA-aware MPI is of great help in this task, because it allows to directly pass GPU arrays to the MPI functions.

Besides facilitating the programming, it can leverage Remote Direct Memory Access (RDMA) which can be of great benefit in many HPC scenarios.
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### Step 5 (multi-GPU)

Translate the code `diffusion_2D_mpi.jl` from Step 4 to GPU using GPU array programming. Note what changes were needed to go from CPU to GPU in this distributed solver.

Use a similar approach as implemented in the CPU code to perform the boundary updates. You can use the `copyto!` function in order to copy the data from the GPU memory into the send buffers (CPU memory) or to copy the receive buffer data (CPU memory) baclk to the GPU array.
"""

#nb # > 💡 note: Have a look at the [`l8_hello_mpi_gpu.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/l8_scripts/) code to get an idea on how to select a GPU based on node-local MPI infos.
#md # \note{Have a look at the [`l8_hello_mpi_gpu.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/l8_scripts/) code to get an idea on how to select a GPU based on node-local MPI infos.}

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Head to the [exercise section](#exercises_-_lecture_8) for further directions on this step which is part of this week's homework assignments.
"""

#nb # > 💡 hint: As alternative, one could use the same approach as in the CPU code to perform the boundary updates thanks to CUDA-aware MPI (it allows to pass GPU arrays directly to the MPI functions). However, this requires MPI being specifically built for that purpose.
#md # \note{As alternative, one could use the same approach as in the CPU code to perform the boundary updates thanks to CUDA-aware MPI (it allows to pass GPU arrays directly to the MPI functions). However, this requires MPI being specifically built for that purpose.}

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
This completes the introduction to distributed parallelisation with Julia.

Note that high-level Julia packages as for example [ImplicitGlobalGrid.jl](https://github.com/eth-cscs/ImplicitGlobalGrid.jl) can render distributed parallelisation with GPU and CPU for HPC a very simple task. Let's check it out!
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## Using `ImplicitGlobalGrid.jl`

Let's have look at [ImplicitGlobalGrid.jl](https://github.com/eth-cscs/ImplicitGlobalGrid.jl)'s repository.

ImplicitGlobalGrid.jl can render distributed parallelisation with GPU and CPU for HPC a very simple task. Moreover, ImplicitGlobalGrid.jl elegantly combines with [ParallelStencil.jl](https://github.com/omlins/ParallelStencil.jl).
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Finally, the cool part: using both packages together enables to [hide communication behind computation](https://github.com/omlins/ParallelStencil.jl#seamless-interoperability-with-communication-packages-and-hiding-communication). This feature enables a parallel efficiency close to 1.
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
For this development, we'll start from the [`l8_diffusion_2D_perf_xpu.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/l8_scripts/) code.

Only a few changes are required to enable multi-xPU execution, namely:
1. Initialise the implicit global grid
2. Use global coordinates to compute the initial condition
3. Update halo (and overlap communication with computation)
4. Finalise the global grid
5. Tune visualisation
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
But before we start programming the multi-xPU implementation, let's get setup with GPU MPI on Piz Daint. Follow steps are needed:
- Launch a `salloc` on 4 nodes
- Install the required MPI-related packages
- Test your setup running [`l8_hello_mpi.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/l8_scripts/) and [`l8_hello_mpi_gpu.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/l8_scripts/) scripts on 1-4 nodes
"""

#nb # > 💡 note: See [Julia MPI GPU on Piz Daint](/software_install/#julia_mpi_gpu_on_piz_daint) for detailed information on how to run MPI GPU (multi-GPU) applications on Piz Daint.
#md # \note{See [Julia MPI GPU on Piz Daint](/software_install/#julia_mpi_gpu_on_piz_daint) for detailed information on how to run MPI GPU (multi-GPU) applications on Piz Daint.}

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
To (**1.**) initialise the global grid, one first needs to use the package
```julia
using ImplicitGlobalGrid
```
Then, one can add the global grid initialisation in the `# Derived numerics` section
```julia
me, dims = init_global_grid(nx, ny, 1)  # Initialization of MPI and more...
dx, dy  = Lx/nx_g(), Ly/ny_g()
```
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
#nb # > 💡 note: The function `init_global_grid` takes care of MPI GPU mapping based on node-local MPI infos. Have a look at the [`l8_hello_mpi_gpu.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/l8_scripts/) code to get an idea about the process.
#md # \note{The function `init_global_grid` takes care of MPI GPU mapping based on node-local MPI infos. Have a look at the [`l8_hello_mpi_gpu.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/l8_scripts/) code to get an idea about the process.}

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Then, for (**2.**), one can use `x_g()` and `y_g()` to compute the global coordinates in the initialisation (to correctly spread the Gaussian distribution over all local processes)
```julia
C       = @zeros(nx,ny)
C      .= Data.Array([exp(-(x_g(ix,dx,C)+dx/2 -Lx/2)^2 -(y_g(iy,dy,C)+dy/2 -Ly/2)^2) for ix=1:size(C,1), iy=1:size(C,2)])
```
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
The halo update (**3.**) can be simply performed adding following line after the `compute!` kernel
```julia
update_halo!(C)
```

Now, when running on GPUs, it is possible to hide MPi communication behind computations!
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
This option implements as:
```julia
@hide_communication (8, 2) begin
    @parallel compute!(C2, C, D_dx, D_dy, dt, _dx, _dy, size_C1_2, size_C2_2)
    C, C2 = C2, C # pointer swap
    update_halo!(C)
end
```
The `@hide_communication (8, 2)` will first compute the first and last 8 and 2 grid points in x and y dimension, respectively. Then, while exchanging boundaries the rest of the local domains computations will be perform (overlapping the MPI communication).
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
To (**4.**) finalise the global grid, 
```julia
finalize_global_grid()
```
needs to be added before the `return` of the "main".
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
The last changes to take care of is to (**5.**) handle visualisation in an appropriate fashion. Here, several options exists.
- One approach would for each local process to dump the local domain results to a file (with process ID `me` in the filename) in order to reconstruct to global grid with a post-processing visualisation script (as done in the previous examples). Libraries like, e.g., [ADIOS2](https://adios2.readthedocs.io/en/latest) may help out there.
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
- Another approach would be to gather the global grid results on a master process before doing further steps as disk saving or plotting.
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
To implement the latter and generate a `gif`, one needs to define a global array for visualisation:
```julia
if do_visu
    if (me==0) ENV["GKSwstype"]="nul"; if isdir("viz2D_mxpu_out")==false mkdir("viz2D_mxpu_out") end; loadpath = "./viz2D_mxpu_out/"; anim = Animation(loadpath,String[]); println("Animation directory: $(anim.dir)") end
    nx_v, ny_v = (nx-2)*dims[1], (ny-2)*dims[2]
    if (nx_v*ny_v*sizeof(Data.Number) > 0.8*Sys.free_memory()) error("Not enough memory for visualization.") end
    C_v   = zeros(nx_v, ny_v) # global array for visu
    C_inn = zeros(nx-2, ny-2) # no halo local array for visu
    xi_g, yi_g = LinRange(dx+dx/2, Lx-dx-dx/2, nx_v), LinRange(dy+dy/2, Ly-dy-dy/2, ny_v) # inner points only
end
```
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Then, the plotting routine can be adapted to first gather the inner points of the local domains into the global array (using `gather!` function) and then plot and/or save the global array (here `C_v`) from the master process `me==0`:
```julia
# Visualize
if do_visu && (it % nout == 0)
    C_inn .= Array(C)[2:end-1,2:end-1]; gather!(C_inn, C_v)
    if (me==0)
        opts = (aspect_ratio=1, xlims=(xi_g[1], xi_g[end]), ylims=(yi_g[1], yi_g[end]), clims=(0.0, 1.0), c=:turbo, xlabel="Lx", ylabel="Ly", title="time = $(round(it*dt, sigdigits=3))")
        heatmap(xi_g, yi_g, Array(C_v)'; opts...); frame(anim)
    end
end
```
To finally generate the `gif`, one needs to place the following after the time loop:
```julia
if (do_visu && me==0) gif(anim, "diffusion_2D_mxpu.gif", fps = 5)  end
```
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
#nb # > 💡 note: We here did not rely on CUDA-aware MPI. To use this feature set (and export) `IGG_CUDAAWARE_MPI=1`. Note that the examples using ImplicitGlobalGrid.jl would also work if `USE_GPU = false`; however, the communication and computation overlap feature is then currently not yet available as its implementation relies at present on leveraging CUDA streams.
#md # \note{We here did not rely on CUDA-aware MPI. To use this feature set (and export) `IGG_CUDAAWARE_MPI=1`. Note that the examples using ImplicitGlobalGrid.jl would also work if `USE_GPU = false`; however, the communication and computation overlap feature is then currently not yet available as its implementation relies at present on leveraging CUDA streams.}


#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### Wrapping up

Let's recall what we learned today about distributed computing in Julia using GPUs:
- We used fake parallelisation to understand the correct boundary exchange procedure.
- We implemented 1D and 2D diffusion solvers in Julia using MPI for distributed memory parallelisation on both CPUs and GPUs (using blocking communication).
- We combined `ParallelStencil.jl` with `ImplicitGlobalGrid.jl` to implement distributed memory parallelisation on multiple CPU and GPUs.
"""


