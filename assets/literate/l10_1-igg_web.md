<!--This file was generated, do not modify it.-->
# Using `ImplicitGlobalGrid.jl`

### The goal of this lecture 10:

- Distributed computing
  - learn about hiding MPI communication behind computations using asynchronous MPI calls
  - combine ImplicitGlobalGrid.jl and ParallelStencil.jl together

Let's have look at [ImplicitGlobalGrid.jl](https://github.com/eth-cscs/ImplicitGlobalGrid.jl)'s repository.

ImplicitGlobalGrid.jl can render distributed parallelisation with GPU and CPU for HPC a very simple task. Moreover, ImplicitGlobalGrid.jl elegantly combines with [ParallelStencil.jl](https://github.com/omlins/ParallelStencil.jl).

Finally, the cool part: using both packages together enables to [hide communication behind computation](https://github.com/omlins/ParallelStencil.jl#seamless-interoperability-with-communication-packages-and-hiding-communication). This feature enables a parallel efficiency close to 1.

For this development, we'll start from the [`l9_diffusion_2D_perf_xpu.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/l9_scripts/) code.

Only a few changes are required to enable multi-xPU execution, namely:
1. Initialise the implicit global grid
2. Use global coordinates to compute the initial condition
3. Update halo (and overlap communication with computation)
4. Finalise the global grid
5. Tune visualisation

But before we start programming the multi-xPU implementation, let's get setup with GPU MPI on Daint.Alps. Follow steps are needed:
- Launch a `salloc` on 4 nodes
- Install the required MPI-related packages
- Test your setup running [`l9_hello_mpi.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/l9_scripts/) and [`l9_hello_mpi_gpu.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/l9_scripts/) scripts on 1-4 nodes

\note{See [GPU computing on Alps](/software_install/#gpu_computing_on_alps) for detailed information on how to run MPI GPU (multi-GPU) applications on Daint.Alps.}

To (**1.**) initialise the global grid, one first needs to use the package
```julia
using ImplicitGlobalGrid
```
Then, one can add the global grid initialisation in the `# Derived numerics` section
```julia
me, dims = init_global_grid(nx, ny, 1)  # Initialization of MPI and more...
dx, dy  = Lx/nx_g(), Ly/ny_g()
```

\note{The function `init_global_grid` takes care of MPI GPU mapping based on node-local MPI infos. Have a look at the [`l9_hello_mpi_gpu.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/l9_scripts/) code to get an idea about the process.}

Then, for (**2.**), one can use `x_g()` and `y_g()` to compute the global coordinates in the initialisation (to correctly spread the Gaussian distribution over all local processes)
```julia
C       = @zeros(nx,ny)
C      .= Data.Array([exp(-(x_g(ix,dx,C)+dx/2 -Lx/2)^2 -(y_g(iy,dy,C)+dy/2 -Ly/2)^2) for ix=1:size(C,1), iy=1:size(C,2)])
```

The halo update (**3.**) can be simply performed adding following line after the `compute!` kernel
```julia
update_halo!(C)
```

Now, when running on GPUs, it is possible to hide MPI communication behind computations!

This option implements as:
```julia
@hide_communication (8, 2) begin
    @parallel compute!(C2, C, D_dx, D_dy, dt, _dx, _dy, size_C1_2, size_C2_2)
    C, C2 = C2, C # pointer swap
    update_halo!(C)
end
```
The `@hide_communication (8, 2)` will first compute the first and last 8 and 2 grid points in x and y dimension, respectively. Then, while exchanging boundaries the rest of the local domains computations will be perform (overlapping the MPI communication).

To (**4.**) finalise the global grid,
```julia
finalize_global_grid()
```
needs to be added before the `return` of the "main".

The last changes to take care of is to (**5.**) handle visualisation in an appropriate fashion. Here, several options exists.
- One approach would for each local process to dump the local domain results to a file (with process ID `me` in the filename) in order to reconstruct to global grid with a post-processing visualisation script (as done in the previous examples). Libraries like, e.g., [ADIOS2](https://adios2.readthedocs.io/en/latest) may help out there.

- Another approach would be to gather the global grid results on a master process before doing further steps as disk saving or plotting.

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

\note{We here did not rely on CUDA-aware MPI. To use this feature set (and export) `IGG_CUDAAWARE_MPI=1`. Note that the examples using ImplicitGlobalGrid.jl would also work if `USE_GPU = false`; however, the communication and computation overlap feature is then currently not yet available as its implementation relies at present on leveraging CUDA streams.}

