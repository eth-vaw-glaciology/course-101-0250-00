<!--This file was generated, do not modify it.-->
# Parallel computing (on CPUs) and performance assessment

### The goal of this lecture 5 is to introduce:
- Performance limiters
- Effective memory throughput metric $T_\mathrm{eff}$

- Parallel computing on CPUs
- Shared memory parallelisation

## Performance limiters

### Hardware
- Recent processors (CPUs and GPUs) have multiple (or many) cores
- Recent processors use their parallelism to hide latency
- Multi-core CPUs and GPUs share similar challenges

*Recall from lecture 1 (**why we do it**) ...*

Use **parallel computing** (to address this):
- The "memory wall" in ~ 2004
- Single-core to multi-core devices

![mem_wall](../assets/literate_figures/l1_mem_wall.png)

GPUs are massively parallel devices
- SIMD machine (programmed using threads - SPMD) ([more](https://safari.ethz.ch/architecture/fall2020/lib/exe/fetch.php?media=onur-comparch-fall2020-lecture24-simdandgpu-afterlecture.pdf))
- Further increases the FLOPS vs Bytes gap

![cpu_gpu_evo](../assets/literate_figures/l1_cpu_gpu_evo.png)

Taking a look at a recent GPU and CPU:
- Nvidia Tesla A100 GPU
- AMD EPYC "Rome" 7282 (16 cores) CPU

| Device         | TFLOP/s (FP64) | Memory BW TB/s |
| :------------: | :------------: | :------------: |
| Tesla A100     | 9.7            | 1.55           |
| AMD EPYC 7282  | 0.7            | 0.085          |

Current GPUs (and CPUs) can do many more computations in a given amount of time than they can access numbers from main memory.

Quantify the imbalance:

$$ \frac{\mathrm{computation\;peak\;performance\;[TFLOP/s]}}{\mathrm{memory\;access\;peak\;performance\;[TB/s]}} × \mathrm{size\;of\;a\;number\;[Bytes]} $$

_(Theoretical peak performance values as specified by the vendors can be used)._

Back to our hardware:

| Device         | TFLOP/s (FP64) | Memory BW TB/s | Imbalance (FP64)     |
| :------------: | :------------: | :------------: | :------------------: |
| Tesla A100     | 9.7            | 1.55           | 9.7 / 1.55  × 8 = 50 |
| AMD EPYC 7282  | 0.7            | 0.085          | 0.7 / 0.085 × 8 = 66 |


_(here computed with double precision values)_

**Meaning:** we can do 50 (GPU) and 66 (CPU) floating point operations per number accessed from main memory. Floating point operations are "for free" when we work in memory-bounded regimes

➡ Requires to re-think the numerical implementation and solution strategies

### On the scientific application side

- Most algorithms require only a few operations or FLOPS ...
- ... compared to the amount of numbers or bytes accessed from main memory.

First derivative example $∂A / ∂x$:

If we "naively" compare the "cost" of an isolated evaluation of a finite-difference first derivative, e.g., computing a flux $q$:

$$q = -D~\frac{∂A}{∂x}~,$$

which in the discrete form reads `q[ix] = -D*(A[ix+1]-A[ix])/dx`.

The cost of evaluating `q[ix] = -D*(A[ix+1]-A[ix])/dx`:

1 reads + 1 write => $2 × 8$ = **16 Bytes transferred**

1 (fused) addition and division => **1 floating point operation**

assuming:
- $D$, $∂x$ are scalars
- $q$ and $A$ are arrays of `Float64` (read from main memory)

GPUs and CPUs perform 50 - 60 floating-point operations per number accessed from main memory

First derivative evaluation requires to transfer 2 numbers per floating-point operations

The FLOPS metric is no longer the most adequate for reporting the application performance of many modern applications on modern hardware.

## Effective memory throughput metric $T_\mathrm{eff}$

Need for a memory throughput-based performance evaluation metric: $T_\mathrm{eff}$ [GB/s]

➡ Evaluate the performance of iterative stencil-based solvers.

The effective memory access $A_\mathrm{eff}$ [GB]

Sum of:
- twice the memory footprint of the unknown fields, $D_\mathrm{u}$, (fields that depend on their own history and that need to be updated every iteration)
- known fields, $D_\mathrm{k}$, that do not change every iteration.

The effective memory access divided by the execution time per iteration, $t_\mathrm{it}$ [sec], defines the effective memory throughput, $T_\mathrm{eff}$ [GB/s]:

$$ A_\mathrm{eff} = 2~D_\mathrm{u} + D_\mathrm{k} $$

$$ T_\mathrm{eff} = \frac{A_\mathrm{eff}}{t_\mathrm{it}} $$

The upper bound of $T_\mathrm{eff}$ is $T_\mathrm{peak}$ as measured, e.g., by [McCalpin, 1995](https://www.researchgate.net/publication/51992086_Memory_bandwidth_and_machine_balance_in_high_performance_computers) for CPUs or a GPU analogue.

Defining the $T_\mathrm{eff}$ metric, we assume that:
1. we evaluate an iterative stencil-based solver,
2. the problem size is much larger than the cache sizes and
3. the usage of time blocking is not feasible or advantageous (reasonable for real-world applications).

\note{Fields within the effective memory access that do not depend on their own history; such fields can be re-computed on the fly or stored on-chip.}

As first task, we'll compute the $T_\mathrm{eff}$ for the 2D fluid pressure (diffusion) solver at the core of the porous convection algorithm from previous lecture.

👉 Download the script [`l5_Pf_diffusion_2D.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/) to get started.

**To-do list:**
- copy [`l5_Pf_diffusion_2D.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/), rename it to `Pf_diffusion_2D_Teff.jl`
- add a timer
- include the performance metric formulas
- deactivate visualisation

💻 Let's get started

### Timer and performance
- Use `Base.time()` to return the current timestamp
- Define `t_tic`, the starting time, after 11 iterations steps to allow for "warm-up"
- Record the exact number of iterations (introduce e.g. `niter`)
- Compute the elapsed time `t_toc` at the end of the time loop and report:

````julia:ex1
t_toc = ...
A_eff = ...          # Effective main memory access per iteration [GB]
t_it  = ...          # Execution time per iteration [s]
T_eff = A_eff/t_it   # Effective memory throughput [GB/s]
````

- Report `t_toc`, `T_eff` and `niter` at the end of the code, formatting output using `@printf()` macro.
- Round `T_eff` to the 3rd significant digit.

```julia
@printf("Time = %1.3f sec, ... \n", t_toc, ...)
```

### Deactivate visualisation (and error checking)
- Use keyword arguments ("kwargs") to allow for default behaviour
- Define a `do_check` flag set to `false`

````julia:ex2
function Pf_diffusion_2D(;??)
    ...
    return
end
````

So far so good, we have now a timer.

Let's also boost resolution to `nx = ny = 511` and set `maxiter = max(nx,ny)` to have the code running ~1 sec.

In the next part, we'll work on a multi-threading implementation.

## Parallel computing on CPUs

_Towards implementing shared memory parallelisation using multi-threading capabilities of modern multi-core CPUs._

We'll work it out in 3 steps:
1. Precomputing scalars, removing divisions (and non-necessary arrays)
2. Back to loops I
3. Back to loops II - compute functions (future "kernels")

### 1. Precomputing scalars, removing divisions and casual arrays

Let's duplicate `Pf_diffusion_2D_Teff.jl` and rename it as `Pf_diffusion_2D_perf.jl`.

- First, replace `k_ηf/dx` and `k_ηf/dy` in the flux calculations by inverse multiplications, such that

````julia:ex3
k_ηf_dx, k_ηf_dy = k_ηf/dx, k_ηf/dy
````

- Then, replace divisions `./(1.0 + θ_dτ)` by inverse multiplications `*_1_θ_dτ` such that

````julia:ex4
_1_θ_dτ = 1.0./(1.0 + θ_dτ)
````

- Then, replace `./dx` and `./dy` in the `Pf` update by inverse multiplications `*_dx, *_dy` where

````julia:ex5
_dx, _dy = 1.0/dx, 1.0/dy
````

- Finally, also apply the same treatment to `./β_dτ`

### 2. Back to loops I

As first, duplicate `Pf_diffusion_2D_perf.jl` and rename it as `Pf_diffusion_2D_perf_loop.jl`.

The goal is now to write out the diffusion physics in a loop fashion over $x$ and $y$ dimensions.

Implement a nested loop, taking car of bounds and staggering.

````julia:ex6
for iy=??
    for ix=??
        qDx[??] -= (qDx[??] + k_ηf_dx* ?? )*_1_θ_dτ
    end
end
for iy=??
    for ix=??
        qDy[??] -= (qDy[??] + k_ηf_dy* ?? )*_1_θ_dτ
    end
end
for iy=??
    for ix=??
        Pf[??]  -= ??
    end
end
````

We could now use macros to make the code nicer and clearer. Macro expression will be replaced during pre-processing (prior to compilation). Also, macro can take arguments by appending `$` in their definition.

Let's use macros to replace the derivative implementations

````julia:ex7
macro d_xa(A)  esc(:( $A[??]-$A[??] )) end
macro d_ya(A)  esc(:( $A[??]-$A[??] )) end
````

And update the code within the iteration loop:

````julia:ex8
for iy=??
    for ix=??
        qDx[??] -= (qDx[??] + k_ηf_dx* ?? )*_1_θ_dτ
    end
end
for iy=??
    for ix=??
        qDy[??] -= (qDy[??] + k_ηf_dy* ?? )*_1_θ_dτ
    end
end
for iy=??
    for ix=??
        Pf[??]  -= ??
    end
end
````

Performance is already quite better with the loop version 🚀.

Reasons are that `diff()` are allocating and that Julia is overall well optimised for executing loops.

Let's now implement the final step.

### 4. Back to loops II

Duplicate `Pf_diffusion_2D_perf_loop.jl` and rename it as `Pf_diffusion_2D_perf_loop_fun.jl`.

In this last step, the goal is to define `compute` functions to hold the physics calculations, and to call those within the time loop.

Create a `compute_flux!()` and `compute_Pf!()` functions that take input and output arrays and needed scalars as argument and return nothing.

````julia:ex9
function compute_flux!(...)
    nx,ny=size(Pf)
    ...
    return nothing
end

function update_Pf!(Pf,...)
    nx,ny=size(Pf)
    ...
    return nothing
end
````

\note{Functions that modify arguments take a `!` in their name, a Julia convention.}

The `compute_flux!()` and `compute_Pf!()` functions can then be called within the time loop.

This last implementation executes a bit faster as previous one, as functions allow Julia to further optimise during just-ahead-of-time compilation.

\note{For optimal performance assessment, bound-checking should be deactivated. This can be achieved by adding `@inbounds` in front of the compute statement, or running the scripts (or launching Julia) with the `--check-bounds=no` option.}

Various timing and benchmarking tools are available in Julia's ecosystem to [track performance issues](https://docs.julialang.org/en/v1/manual/performance-tips/). Julia's `Base` exposes the `@time` macro which returns timing and allocation estimation. [BenchmarkTools.jl](https://github.com/JuliaCI/BenchmarkTools.jl) package provides finer grained timing and benchmarking tooling, namely the `@btime`, `@belapsed` and `@benchmark` macros, among others.

Let's evaluate the performance of our code using `BenchmarkTools`. We will need to wrap the two compute kernels into a `compute!()` function in order to be able to call that one using `@belapsed`. Query `? @belapsed` in Julia's REPL to know more.

The `compute!()` function:

````julia:ex10
function compute!(Pf,qDx,qDy, ???)
    compute_flux!(...)
    update_Pf!(...)
    return nothing
end
````

can then be called using `@belapsed` to return elapsed time for a single iteration, letting `BenchmarkTools` taking car about sampling

````julia:ex11
t_toc = @belapsed compute!($Pf,$qDx,$qDy,???)
niter = ???
````

\note{Note that variables need to be interpolated into the function call, thus taking a `$` in front.}

## Shared memory parallelisation

Julia ships with it's `Base` feature the possibility to enable [multi-threading](https://docs.julialang.org/en/v1/manual/multi-threading/).

The only 2 modifications needed to enable it in our code are:
1. Place `Threads.@threads` in front of the outer loop definition
2. Export the desired amount of threads, e.g., `export JULIA_NUM_THREADS=4`, to be activate prior to launching Julia (or executing the script from the shell). You can also launch Julia with `-t` option setting the desired numbers of threads. Setting `-t auto` will most likely automatically use as many hardware threads as available on a machine.

The number of threads can be queried within a Julia session as following: `Threads.nthreads()`

\note{For optimal performance, the numbers of threads should be identical to the  number of physical cores of the target CPU (hardware threads).}

### Multi-threading and AVX (🚧 currently refactored)

Relying on Julia's [LoopVectorization.jl](https://github.com/JuliaSIMD/LoopVectorization.jl) package, it is possible to combine multi-threading with [advanced vector extensions (AVX)](https://en.wikipedia.org/wiki/Advanced_Vector_Extensions) optimisations, leveraging extensions to the x86 instruction set architecture.

To enable it:
1. Add `using LoopVectorization` at the top of the script
2. Replace `Threads.@threads` by `@tturbo`

And here we go 🚀

### Wrapping-up

- We discussed main performance limiters
- We implemented the effective memory throughput metric $T_\mathrm{eff}$
- We optimised the Julia 2D diffusion code (multi-threading and AVX)

