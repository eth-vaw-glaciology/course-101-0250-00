<!--This file was generated, do not modify it.-->
## Exercise 3 - **Performance evaluation**

👉 See [Logistics](/logistics/#submission) for submission details.

The goal of this exercise is to:
- Create a script to assess $T_\mathrm{peak}$, using memory-copy
- Assess $T_\mathrm{peak}$ of your CPU
- Perform a strong-scaling test: assess $T_\mathrm{eff}$ for the diffusion 2D as function of number of grid points and implementation

For this exercise, you will write a code to assess the peak memory throughput of your CPU and run a strong scaling benchmark using the diffusion 2D codes and report performance.

### Task 1

In the `diffusion2D` folder, create a new script named `memcopy.jl`. You can use as starting point the `diffusion_2D_loop_fun.jl` script from lecture 5 (or exercise 1).

1. Rename the "main" function `memcopy`
2. Modify the script to only keep following in the initialisation:
  ```julia
  # Numerics
  nx, ny  = 512, 512
  nt      = 10000
  # Array initialisation
  C       = rand(Float64, nx, ny)
  C2      = copy(C)
  A       = copy(C)
  ```
3. Modify the `compute!()` function to perform the following operation `C2 = C + A`, replacing the previous calculations.
4. Update the `A_eff` formula accordingly.

Then, create a `README.md` file in the `diffusion2D` folder to report the results for each of the following tasks (including a .png of the figure when instructed)

\note{Use `![fig_name](./<relative-path>/my_fig.png)` to insert a .png figure in the `README.md`.}

### Task 2

Report on a figure $T_\mathrm{eff}$ of your `memcopy.jl` code as function of number of grid points `nx × ny` for the simple `for` loop, the `Threads.@threads`, and the `@tturbo` implementations. Vary `nx`and `ny` such that `nx = ny = 16 * 2 .^ (1:8)`.

_($T_\mathrm{eff}$ of your `memcopy.jl` code represents $T_\mathrm{peak}$, the peak memory throughput you can achieve on your CPU for a given implementation.)_

Add the above figure in a new section of the `diffusion2D/README.md`, and provide a minimal description of 1) the performed test, and 2) a short description of the result. Figure out the vendor-announced peak memory bandwidth for your CPU, add it to the figure and use it to discuss your results.

### Task 3

Repeat the strong scaling benchmark you just realised in Task 2 using the `memcopy.jl` code on the various diffusion 2D codes (`perf2`, `perf_loop`, `perf_loop_fun` - `for`, `Threads.@threads`, `@tturbo` for the latter).

Report on a figure $T_\mathrm{eff}$ of the 5 diffusion 2D code implementations as function of number of grid points `nx × ny`. Vary `nx`and `ny` such that `nx = ny = 16 * 2 .^ (1:8)`.

On the same figure, report also the memory copy values for the `for`, `Threads.@threads`, `@tturbo` implementation (as, e.g, dashed lines).

Add this second figure in a new section of the `diffusion2D/README.md`, and provide a minimal description of 1) the performed test, and 2) a short description of the result.

