<!--This file was generated, do not modify it.-->
## Exercise 2 - **Performance evaluation**

👉 See [Logistics](/logistics/#submission) for submission details.

The goal of this exercise is to:
- Create a script to assess $T_\mathrm{peak}$, using memory-copy
- Assess $T_\mathrm{peak}$ of your CPU
- Perform a strong-scaling test: assess $T_\mathrm{eff}$ for the fluid pressure diffusion 2D solver as function of number of grid points and implementation

For this exercise, you will write a code to assess the peak memory throughput of your CPU and run a strong scaling benchmark using the fluid pressure diffusion 2D solver and report performance.

### Task 1

In the `Pf_diffusion_2D` folder, create a new script named `memcopy.jl`. You can use as starting point the `diffusion_2D_loop_fun.jl` script from lecture 5 (or exercise 1).

1. Rename the "main" function `memcopy()`
2. Modify the script to only keep following in the initialisation:

````julia:ex1
# Numerics
nx, ny  = 512, 512
nt      = 2e4
# array initialisation
C       = rand(Float64, nx, ny)
C2      = copy(C)
A       = copy(C)
````

3. Implement 2 compute functions to perform the following operation `C2 = C + A`, replacing the previous calculations:
    - create an "array programming"-based function called `compute_ap!()` that includes a broadcasted version of the memory copy operation;
    - create a second "kernel programming"-based function called `compute_kp!()` that uses a loop-based implementation with multi-threading.
4. Update the `A_eff` formula accordingly.
5. Implement a switch to monitor performance using either a manual approach or `BenchmarkTools` and pass the `bench` value as kwarg to the `memcopy()` main function including a default:

````julia:ex2
if bench == :loop
    # iteration loop
    t_tic = 0.0
    for iter=1:nt
      ...
    end
    t_toc = Base.time() - t_tic
elseif bench == :btool
    t_toc = @belapsed ...
end
````

Then, create a `README.md` file in the `Pf_diffusion_2D` folder to report the results for each of the following tasks (including a .png of the figure when instructed)

\note{Use `![fig_name](./<relative-path>/my_fig.png)` to insert a .png figure in the `README.md`.}

### Task 2

Report on a figure $T_\mathrm{eff}$ of your `memcopy.jl` code as function of number of grid points `nx × ny` for the array and kernel programming approaches, respectively, using the `BenchmarkTools` implementation. Vary `nx`and `ny` such that

````julia:ex3
nx = ny = 16 * 2 .^ (1:8)
````

_($T_\mathrm{eff}$ of your `memcopy.jl` code represents $T_\mathrm{peak}$, the peak memory throughput you can achieve on your CPU for a given implementation.)_

On the same figure, report the best value of memcopy obtained using the manual loop-based approach (manual timer) to assess $T_\mathrm{peak}$.

\note{For performance evaluation we only need the code to run a couple of seconds; adapt `nt` accordingly (you could also, e.g., make `nt` function of `nx, ny`). Ensure also to implement "warm-up" iterations.}

Add the above figure in a new section of the `Pf_diffusion_2D/README.md`, and provide a minimal description of 1) the performed test, and 2) a short description of the result. Figure out the vendor-announced peak memory bandwidth for your CPU, add it to the figure and use it to discuss your results.

### Task 3

Repeat the strong scaling benchmark you just realised in Task 2 using the various fluid pressure diffusion 2D codes (`Pf_diffusion_2D_Teff.jl`; `Pf_diffusion_2D_perf.jl`; `Pf_diffusion_2D_loop_fun.jl` - `for`, `Threads.@threads` for the latter).

Report on a figure $T_\mathrm{eff}$ of the 4 diffusion solvers' implementations as function of number of grid points `nx × ny`. Vary `nx`and `ny` such that `nx = ny = 16 * 2 .^ (1:8)`. **Use the `BenchmarlTools`-based evaluation approach.**

On the same figure, report also the best memory copy value (as, e.g, dashed lines) and vendor announced values (if available - optional).

Add this second figure in a new section of the `Pf_diffusion_2D/README.md`, and provide a minimal description of 1) the performed test, and 2) a short description of the result.

