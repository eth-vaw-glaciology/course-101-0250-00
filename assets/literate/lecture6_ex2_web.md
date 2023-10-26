<!--This file was generated, do not modify it.-->
## Exercise 2 - **Solving PDEs on GPUs**

👉 See [Logistics](/logistics/#submission) for submission details.

The goal of this exercise is to:
- Port the 2D fluid diffusion CPU code from Lecture 5 to GPU
- Assess the performance of the GPU solver

### Task 1

In there, place the `Pf_diffusion_2D_perf_loop_fun.jl` script you created for Lecture 5 homework (Exercise 1, Task 1). Duplicate the script and rename it `Pf_diffusion_2D_perf_gpu.jl`.

Getting inspiration from the material presented in lecture 6 and exercise 1, work-out the necessary modifications in the `Pf_diffusion_2D_perf_gpu.jl` code in order to enable it to execute on the Nvidia P100 GPU. For this task, _**use a kernel programming approach**_.

Hereafter, a step-wise list of changes you'll need to perform starting from your `Pf_diffusion_2D_perf_loop_fun.jl` code.

Add `using CUDA` at the top, in the packages.

Define, in the `# Numerics` section, the parameters to set the block and grid size such that the number of threads per blocks are fixed to `threads = (32,4)` (or to a better layout you could figure out from running the performance assessment you did). Define then the number of blocks `blocks` to be computed such that `nx = threads[1]*blocks[1]` and similarly for `ny`.

In the `# Array initialisation` section, make sure to now initialise CUDA arrays. You can use `CUDA.zeros(Float64,nx,ny)` as the GPU variant of `zeros(nx,ny)`. Also, you can use `CuArray()` to wrap and CPU array turning it into a GPU array; `CUDA.zeros(Float64,nx,ny)` would be equivalent to `CuArray(zeros(nx,ny))`. This may be useful to, e.g., define initial conditions using broadcasting operations on CPU arrays and wrapping them in a GPU array for further use.

Going to the compute functions (or "kernels"), remove the nested loop(s) and replace them by the CUDA-related vectorised indices unique to each thread:
```julia
ix = (blockIdx().x-1) * blockDim().x + threadIdx().x
iy = (blockIdx().y-1) * blockDim().y + threadIdx().y
```
Pay attention that you need to enforce array bound checking (this was previously done by the loop bounds). A convenient way of doing so is using `if` conditions:
```julia
if (ix<=nx && iy<=ny)  Pf[ix,iy] = ...  end
```

Moving to the `# Time loop`, you'll now have to add information in order to allow the compute function to execute on the GPU. This can be achieved by adding `@cuda blocks threads` prior to the function call, turning, e.g.,
```julia
compute!(...)
```
into
```julia
@cuda blocks blocks=blocks threads=threads compute!(...)
synchronize()
```
or alternatively
```julia
CUDA.@sync @cuda blocks=blocks threads=threads compute!(...)
```

\warn{Don't forget to synchronize the device to ensure all threads reached the barrier before the next iteration to avoid erroneous results.}

Finally, for visualisation, you'll need to "gather" information from the GPU array (`CuArray`) back to the CPU array (`Array`) in order to plot it. This can be achieved by calling `Array(Pf)` in your visualisation routine.

\note{`CuArray()` allows you to "transform" a CPU (or host) array to a GPU (or device) array, while `Array()` allows you to bring back the GPU (device) array to a CPU (host) array.}

### Task 2

Ensure the GPU code produces similar results as the reference CPU loop code for `nx = ny = 127` number of grid points. To assess this, save the output (pressure `Pf`) fields for both the CPU and GPU codes after e.g. 50 iterations, and make sure their difference is close to machine precision. You could use Julia's unit testing functionalities, e.g., `testset`, for this task as well.

### Task 3

Assess $T_\mathrm{peak}$ of the Nvidia Tesla P100 GPU. To do so, embed the *triad* benchmark (kernel programming version) from lecture 6 in a Julia script and use it to assess $T_\mathrm{peak}$. Upload the script to your GitHub folder and save the $T_\mathrm{peak}$ value for next task.

### Task 4

Report in a figure you will insert in the `README.md` the effective memory throughput $T_\mathrm{eff}$ for the 2D fluid pressure diffusion GPU code as function of number of grid points `nx = ny`. Realise a weak scaling benchmark varying `nx = ny = 32 .* 2 .^ (0:8) .- 1` (or until you run out of device memory). On the same figure, report as well $T_\mathrm{peak}$ from Task 3.

Comment on the $T_\mathrm{eff}$ and $T_\mathrm{peak}$ values achieved on the Tesla P100.

