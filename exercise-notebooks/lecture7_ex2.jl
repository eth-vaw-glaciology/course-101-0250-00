md"""
## Exercise 2 - **Acoustic 2D XPU implementation**
"""

#md # 👉 See [Logistics](/logistics/#submission) for submission details.

md"""
The goal of this exercise is to:
- Create a XPU implementation of the 2D acoustic code
- Familiarise with XPU programming, `@parallel` and `@parallel_indices`
"""

md"""
In this exercise, you will create an acoustic 2D scripts, "merging" the multi-threaded CPU version `acoustic_2D_perf_loop_fun.jl` and the plain GPU version `acoustic_2D_perf_gpu.jl` from last week's lecture 6.

In this week's lecture 7 GitHub folder, create a new subfolder `acoustic2D_xpu` where you will add following script:
- `acoustic_2D_xpu.jl`
- `acoustic_2D_perf_xpu.jl`


### Task 1

Start working on the `acoustic_2D_xpu.jl` script.
- This version should contain compute functions (kernels) definitions using `@parallel` approach together with using `ParallelStencil.FiniteDifferences2D` submodule.
- Include the kwarg `do_visu` to allow disabling plotting when assessing performance.
- Also, make sure to include and update the performance evaluation section at the end of the script (as in the previous GPU and CPU script versions).

To get get started, get inspired by the `diffusion_2D_xpu.jl` script we mostly terminated in class during lecture 7 and the know-how you acquired finalising exercise 1.

If you still struggle getting started you'll find, after homework 6 due-date, the [`acoustic_2D_perf_gpu.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/) script in the [scripts/](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/) folder.

### Task 2

Create the `acoustic_2D_perf_xpu.jl` script.
- This version should contain compute functions (kernels) definitions using `@parallel_indices` approach.
- Include the kwarg `do_visu` to allow disabling plotting when assessing performance.
- Also, make sure to include and update the performance evaluation section at the end of the script (as in the previous GPU and CPU script versions).

### Task 3

Create a `README.md` file in your lecture 7 GitHub folder, adding a second section about "Acoustic 2D XPU performance".

In this section, include one figure that reporting the performance of both the `acoustic_2D_xpu.jl` and `acoustic_2D_perf_xpu.jl` implementation of the acoustic 2D solver using the $T_\mathrm{eff}$ metric.

Vary the number of grid points `nx = ny = 16 * 2 .^ (1:8)` (or until you run out of memory on the GPU). Report as well the value for memory copy $T_\mathrm{peak}$ of the given GPU (and arithmetic precision) you are using. Make sure to including figure axis labels and add a short figure caption or description to the `README`.

"""