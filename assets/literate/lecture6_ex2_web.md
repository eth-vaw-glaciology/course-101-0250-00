<!--This file was generated, do not modify it.-->
## Exercise 2 - **Solving PDEs on GPUs**

👉 See [Logistics](/logistics/#submission) for submission details.

The goal of this exercise is to:
- Port the diffusion 2D CPU code to GPU
- Port the acoustic 2D CPU code to GPU

For this exercise, you will port the (function-based) loop version diffusion and acoustic 2D codes to GPU.

### Task 1

Create a new folder in your GitHub repository for this week's (lecture 6) exercises.

In there, place the `diffusion_2D_loop_fun.jl` and `acoustic_2D_loop_fun.jl` scripts you created for lecture 5 homework. Duplicate both scripts and rename them as `diffusion_2D_gpu.jl` and `acoustic_2D_gpu.jl`.

Getting inspiration from the material presented in lecture 6 and exercise 1, work-out the necessary modifications in the `diffusion_2D_gpu.jl` and `acoustic_2D_gpu.jl` code in order to enable them to execute on the Nvidia Titan Xm GPU you have on your assigned *octopus* node.

_**Use a kernel programming approach**_. Define in the `# numerics` section the parameters to set the block and grid size such that the number of threads per blocks are fixed to `cuthreads = (32,4)` and the number of blocks `cublocks` computed to match the number of grid points `nx, ny`.

### Task 2

Ensure the GPU codes produces similar results as the reference CPU loop code for `nx = ny = 128` number of grid points. To assess this, save the output (pressure `P` and concentration `C`) fields for both the CPU and GPU codes and make sure their difference is close to machine precision. You could use Julia's unit testing functionalities, e.g., `testset`, for this task as well.

### Task 3

Assess $T_\mathrm{peak}$ of the Nvidia TitanXm GPU. To do so, embed the *triad* benchmark (kernel programming version) from lecture 6 in a Julia script and use it to assess $T_\mathrm{peak}$. Upload the script to your GitHub folder and save the $T_\mathrm{peak}$ value for next task.

### Task 4

Report in a figure you will insert in the `README.md` the effective memory throughput $T_\mathrm{eff}$ for both acoustic and diffusion 2D GPU codes as function of number of grid points `nx = ny`. Realise a weak scaling benchmark varying `nx = ny = 32 .* 2 .^ (0:8)` (or until you run out of device memory). On the same figure, report as well $T_\mathrm{peak}$ from Task 3.

Comment on the $T_\mathrm{eff}$ and $T_\mathrm{peak}$ values achieved on the Titan Xm (with respect to what you achieved on the Tesla V100 GPUs during the lecture).

