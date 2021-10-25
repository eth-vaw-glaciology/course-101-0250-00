md"""
## Excercise 2 - **Solving PDEs on GPUs**
"""

#md # 👉 See [Logistics](/logistics/#submission) for submission details.

md"""
The goal of this exercise is to:
- Port the CPU diffusion 2D code to GPU
- Port the CPU acoustic 2D code to GPU
"""

md"""
For this exercise, you will port the loop version (with compute functions) of the diffusion and acoustic 2D solvers to GPU.
"""

md"""
### Task 1

Create a new folder in your GitHub repository for this week's (lecture 6) exercises.

In there, place the `diffusion_2D_loop_fun.jl` and `acoustic_2D_loop_fun.jl` scripts you realised for lecture 5 homework. Duplicate both scripts and rename them as `diffusion_2D_gpu.jl` and `acoustic_2D_gpu.jl`.

Getting inspiration from the lecture 6 and exercise 1, work on the necessary modifications needed in the `diffusion_2D_gpu.jl` and `acoustic_2D_gpu.jl` code in order to enable them to execute on the Titan Xm GPU you have on your assigned *octopus* node.

Use a kernel programming approach. Define the `# numerics` parameters to have the numbers of threads fixed to `cuthreads = (32,4)` and the number of blocks `cublocks` computed to match the number of grid points `nx, ny`.

### Task 2

Ensure the GPU codes produces similar results as the CPU loop code for `nx = ny = 128` number of grid points. To assess this, save the output (pressure and concentration) fields for both the CPU and GPU codes and make sure their difference is close to machine precision. You could use a testset for this task as well.

### Task 3

Report in a figure in the `README.md` the effective memory throughput $T_\mathrm{eff}$ for both acoustic and diffusion 2D GPU codes as function of number of grid points `nx = ny` in a weak scaling test, for `nx = ny = 32 .* 2 .^ (0:8)` (or until you run out of device memory).

Comment on the achieved $T_\mathrm{eff}$ values on the Titan Xm (with respect to what you achieved on the Tesla V100 GPUs).
"""

