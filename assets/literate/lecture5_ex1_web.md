<!--This file was generated, do not modify it.-->
## Exercise 1 - **Performance implementation: Diffusion 2D**

👉 See [Logistics](/logistics/#submission) for submission details.

The goal of this exercise is to:
- Finalise the script elaborated in class

In this first exercise, you will terminate the performance oriented implementation of the 2D diffusion scripts from lecture 5.

👉 If needed, download the [`diffusion_2D.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/) to get you started.

### Task 1

Create a new folder in your GitHub repository for this week's (lecture 5) exercises. In there, create a new subfolder `diffusion2D` where you will add following script:
- `diffusion_2D_Teff.jl` (`T_eff` implementation)
- `diffusion_2D_perf.jl` (scalar precomputations and removing `dCdt`)
- `diffusion_2D_perf2.jl` (flux computation as macros)
- `diffusion_2D_loop.jl` (loop version)
- `diffusion_2D_loop_fun.jl` (physics computations in `compute!()` function)

\note{Refer to [this section](#timer_and_performance) in lecture 5 to capture the starting point describing which features are specific to each version of the diffusion 2D codes.}
