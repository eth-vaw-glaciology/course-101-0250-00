<!--This file was generated, do not modify it.-->
## Exercise 3 - **Performance evaluation**

👉 See [Logistics](/logistics/#submission) for submission details.

The goal of this exercise is to:
- Create a script to assess $T_\mathrm{peak}$, aka memory-copy
- Assess $T_\mathrm{peak}$ of your CPU
- Perform a strong-scaling test: assess $T_\mathrm{eff}$ for the diffusion 2D as function of number of grid points and implementation

For this exercise, you will write a code to assess the peak memory throughput of your CPU and run a strong scaling benchmark using the diffusion 2D codes and report performance.

### Task 1

In the `diffusion2D` folder, create a new script names `memcopy.jl`. You can use as starting point the `diffusion_2D_loop_fun.jl` script from lecture 5 (or exercise 1).

1. Rename the "main" `memcopy`
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
3. Modify the `compute!()` function to perform the following operation `C2 = C + A`
4. Update the `A_eff` formula

Then, create a README.md file in the `diffusion2D` folder to report the results for each of the following tasks (including a .png of the figure when instructed)

\note{Use `![fig_name](./<relative-path>/my_fig.png)` to insert a figure in the README.md.}

### Task 2

Report on a figure $T_\mathrm{eff}$ of your memcopy code as function of number of grid points `nx × ny` for the simple `for` loop, the `Threads.@threads`, and the `@tturbo` implementations. Vary `nx = ny = 16 * 2 .^ (1:8)`.

_($T_\mathrm{eff}$ of your memcopy code represents $T_\mathrm{peak}$, the peak memory throughput you can achieve on your CPU for a given implementation.)_

Add that figure in a new section of the README, provide a minimal description of 1) the performed test, and 2) short description of the result. Figure out the vendor-announced peak memory bandwidth of your CPU, add it to the figure and use it to discuss your results.

### Task 3

Repeat the strong scaling benchmark you just realised using the memcopy.jl code on the various diffusion 2D codes (`perf2`, `perf_loop`, `perf_loop_fun` - `for`, `Threads.@threads`, `@tturbo` for the latter).

Report on a figure $T_\mathrm{eff}$ of the 5 implementations of the diffusion 2D code as function of number of grid points `nx × ny`. Vary `nx = ny = 16 * 2 .^ (1:8)`.

Report also on the same figure the memory copy values for the `for`, `Threads.@threads`, `@tturbo` implementation (as, e.g, dashed lines).

Add this second figure in a new section of the README, provide a minimal description of 1) the performed test, and 2) short description of the result.

