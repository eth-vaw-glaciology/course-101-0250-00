<!--This file was generated, do not modify it.-->
## Exercise 2 - **Performance implementation: Acoustic 2D**

👉 See [Logistics](/logistics/#submission) for submission details.

The goal of this exercise is to:
- Apply the optimisation steps done for the diffusion 2D to the acoustic wave propagation 2D code (velocity-pressure formulation)

For this second exercise, you will implement a performance oriented implementation of the 2D acoustic scripts from lecture 5.

👉 If needed, download the [`acoustic_2D.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/) to get you started.

### Task 1

In the folder in your GitHub repository for this week's (lecture 5) exercises, create a new subfolder `acoustic2D` where you will add following script:
- `acousitc_2D_Teff.jl`
  - Implement the `T_eff` metric to the acoustic wave in 2D. Since we are using the velocity-pressure formulation, think about how many arrays are updated at every iterations and define `A_Eff` accordingly.
  - Use `@printf()` to report `t_toc`, `T_eff` and `niter`.
  - Boost number of grid points to `nx = ny = 512`.
  - Implement a flag to deactivate visualisation using kwargs.
- `acousitc_2D_perf.jl`
  - Replace divisions by multiplications.
  - When possible, fuse scalar computations as preprocessing.
- `acousitc_2D_loop.jl`
  - Perform the computations of `Vx`, `Vy` and `P` in nested loops. Take care of the staggering and loop range.
- `acousitc_2D_loop_fun.jl`
  - Move the physics computations into functions (kernels) and call them within the time loop. Use the minimal amount of functions that would ensure correct results.
  - Implement multi-threading using both `Threads.@threads` and `@tturbo` (the latter from [LoopVectorization.jl](https://github.com/JuliaSIMD/LoopVectorization.jl)).

\note{Refer to [this section](#timer_and_performance) in lecture 5 to capture the starting point describing which features are specific to each version of the diffusion 2D codes.}

