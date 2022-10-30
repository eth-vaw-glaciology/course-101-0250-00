md"""
## Exercise 1 - **2D thermal porous convection xPU implementation**
"""

#md # 👉 See [Logistics](/logistics/#submission) for submission details.

md"""
The goal of this exercise is to:
- Finalise the xPU implementation of the 2D fluid diffusion solver started in class
- Familiarise with xPU programming, `@parallel` and `@parallel_indices`
- Port your 2D thermal porous convection code to xPU implementation
"""

md"""
In this exercise, you will finalise the 2D fluid diffusion solver started during lecture 7 and use the new xPU scripts as starting point to port your 2D thermal porous convection code.
"""

#src Create a new folder in your GitHub repository for this week's (lecture 7) exercises. In there, create a new subfolder `diffusion2D_xpu` where you will add following script:
#src - `diffusion_2D_xpu.jl`
#src - `diffusion_2D_perf_xpu.jl`
#src 
#src ### Task 1
#src 
#src Finalise the `diffusion_2D_xpu.jl` script from class.
#src - This version should contain compute functions (kernels) definitions using `@parallel` approach together with using `ParallelStencil.FiniteDifferences2D` submodule.
#src - Include the kwarg `do_visu` to allow disabling plotting when assessing performance.
#src - Also, make sure to include and update the performance evaluation section at the end of the script (as in the previous GPU and CPU script versions).
#src 
#src You can get started looking at the [`diffusion_2D_perf_gpu.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/) script (available in the [scripts/](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/) folder in case you don't have it at hand from lecture 6).
#src 
#src ### Task 2
#src 
#src Finalise the `diffusion_2D_perf_xpu.jl` script from class.
#src - This version should contain compute functions (kernels) definitions using `@parallel_indices` approach.
#src - Use a macros for the flux definition to avoid unnecessary memory accesses. Also, make sure to adapt the array you initialise.
#src - Include the kwarg `do_visu` to allow disabling plotting when assessing performance.
#src - Also, make sure to include and update the performance evaluation section at the end of the script (as in the previous GPU and CPU script versions).
#src 
#src ### Task 3
#src 
#src Create a `README.md` file in your lecture 7 GitHub folder, adding a first section about "Diffusion 2D XPU performance".
#src 
#src In this section, include a figure reporting the performance of both the `diffusion_2D_xpu.jl` and `diffusion_2D_perf_xpu.jl` implementation of the diffusion 2D solver using the $T_\mathrm{eff}$ metric.
#src 
#src Vary the number of grid points `nx = ny = 16 * 2 .^ (1:8)` (or until you run out of memory on the GPU). Report as well the value for memory copy $T_\mathrm{peak}$ of the given GPU (and arithmetic precision) you are using. Make sure to including figure axis labels and add a short figure caption or description to the `README`.


