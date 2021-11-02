<!--This file was generated, do not modify it.-->
## Exercise 1 - **Diffusion 2D XPU implementation**

👉 See [Logistics](/logistics/#submission) for submission details.

The goal of this exercise is to:
- Finalise the XPU implementation of the 2D diffusion code started in class
- Familiarise with XPU programming, `@parallel` and `@parallel_indices`

In this exercise, you will finalise the diffusion 2D scripts started during lecture 7.

Create a new folder in your GitHub repository for this week's (lecture 7) exercises. In there, create a new subfolder `diffusion2D_xpu` where you will add following script:
- `diffusion_2D_xpu.jl`
- `diffusion_2D_perf_xpu.jl`

### Task 1

Finalise the `diffusion_2D_xpu.jl` script from class.
- This version should contain compute functions (kernels) definitions using `@parallel` approach together with using `ParallelStencil.FiniteDifferences2D` submodule.
- Include the kwarg `do_visu` to allow disabling plotting when assessing performance.
- Also, make sure to include and update the performance evaluation section at the end of the script (as in the previous GPU and CPU script versions).

You can get started looking at the [`diffusion_2D_perf_gpu.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/) script (available in the [scripts/](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/) folder in case you don't have it at hand from lecture 6).

### Task 2

Finalise the `diffusion_2D_perf_xpu.jl` script from class.
- This version should contain compute functions (kernels) definitions using `@parallel_indices` approach.
- Use a macros for the flux definition to avoid unnecessary memory accesses. Also, make sure to adapt the array you initialise.
- Include the kwarg `do_visu` to allow disabling plotting when assessing performance.
- Also, make sure to include and update the performance evaluation section at the end of the script (as in the previous GPU and CPU script versions).

### Task 3

Create a `README.md` file in your lecture 7 GitHub folder, adding a first section about "Diffusion 2D XPU performance".

In this section, include one figure that reporting the performance of both the `diffusion_2D_xpu.jl` and `diffusion_2D_perf_xpu.jl` implementation of the diffusion 2D solver using the $T_\mathrm{eff}$ metric.

Vary the number of grid points `nx = ny = 16 * 2 .^ (1:8)` (or until you run out of memory on the GPU). Report as well the value for memory copy $T_\mathrm{peak}$ of the given GPU (and arithmetic precision) you are using. Make sure to including figure axis labels and add a short figure caption or description to the `README`.

