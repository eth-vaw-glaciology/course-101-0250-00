md"""
## Exercise 2 - **Multi-XPU computing**
"""

#md # 👉 See [Logistics](/logistics/#submission) for submission details.

md"""
The goal of this exercise is to:
- Familiarise with distributed computing
- Combine [ImplicitGlobalGrid.jl](https://github.com/eth-cscs/ImplicitGlobalGrid.jl) and [ParallelStencil.jl](https://github.com/omlins/ParallelStencil.jl)
- Learn about GPU MPI on the way
"""

md"""
In this exercise, you will:
- Create a 2D multi-XPU acoustic wave solver
- Make it XPU compatible using ParallelStencil.jl
- Deploy it on multiple XPUs using ImplicitGlobalGrid.jl

\warn{Because of an issue most probably with CUDA.jl, you'll need to rely on CUDA.jl v3.3.6 when using ImplicitGlobalGrid.jl without CUDA-aware MPI (as we are doing here). To enforce this compatibility, type `add CUDA@v3.3.6` whithin the REPL in package mode in your project (having ensured to launch Julia with the `--project` flag).}

### Task 1

Starting from the `acoustic_2D_perf_xpu.jl` script you developed for exercise 2 (lecture 7) (also available in the [scripts/](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/) folder after homework 7 due date), create a multi-XPU version adding ImplicitGlobalGrid features to run on multiple XPUs.

Follow the steps discussed in lecture 8 in the [Using `ImplicitGlobalGrid.jl`](#using_implicitglobalgridjl) Section.

Create a new `acoustic_2D_perf_mulixpu.jl` script with following physics and numerics parameters:

```julia
# Physics
Lx, Ly  = 10.0, 10.0
ρ       = 1.0
K       = 1.0
ttot    = 1e1
# Numerics
nx, ny  = 32, 32 # number of grid points (local domain)
nout    = 10
```

Add the "hide communication" feature using a a boundary width of `(8,2)` as such `@hide_communication (8, 2) begin ...`

Add the same visualisation routine as for the multi-XPU diffusion example from lecture 8, automatically creating a .gif (in this case for pressure `P` instead of concentration `C`). You can use the following plotting options
```julia
opts = (aspect_ratio=1, xlims=(Xi_g[1], Xi_g[end]), ylims=(Yi_g[1], Yi_g[end]), clims=(-0.25, 0.25), c=:davos, xlabel="Lx", ylabel="Ly", title="time = $(round(it*dt, sigdigits=3))")
heatmap(Xi_g, Yi_g, Array(P_v)'; opts...); frame(anim)
```

### Task 2

Execute the `acoustic_2D_perf_mulixpu.jl` on 4 GPUs (on your octopus node) to generate a .gif. Then, create a new section in the `README.md` of your lecture 8 GitHub repository and add the generated .gif. Including a short description of the results.

Here is a snapshot on what to expect:
"""

#md # @@img-med
#md # ![Acoustic 2D 4 procs](./figures/acoustic_2D_mxpu_2.gif)
#md # @@

md"""
### Task 3

Realise a weak scaling experiment on 1-4 Titan Xm GPUs on your node and report parallel efficiency.

Select the number of grid points for the local domain (`nx`, `ny`) to match the best $T_\mathrm{eff}$ values reported in [Lecture 7 - Task 3](/lecture7/#task_3__2). Make sure to deactivate visualisation and adapt the total time `ttot` or the number of time steps `nt` such that the code executes in about one second.

Report the execution time `t1 = t_toc` for the single GPU execution. Then, run the code on 1, 2, 3 and 4 GPUs saving the `t_toc` time for each run. Report the parallel efficiency by normalising the execution time `t_toc` for the 1-4 GPU runs by `t1`. Plot the results as function of number of GPUs.

Add the figure to a new section of the `README.md` and briefly discuss the results. Make sure to report to local problem size you used when performing the weak scaling test.

"""
