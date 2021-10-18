<!--This file was generated, do not modify it.-->
# Parallel computing (on CPUs) and performance assessment

### The goal of this lecture 5 is to introduce:
- Performance limiters
- Effective memory throughput metric $T_\mathrm{eff}$

- Parallel computing on CPUs
- Shared memory parallelisation

## Performance limiters

### Hardware
- Multi-core CPUs (and GPUs) are throughput-oriented systems
- They use their massive parallelism to hide latency

*Recall from [lecture 1](lecture1/#why_we_do_it) ...*

Use **parallel computing** (to address this):
- The "memory wall" in ~ 2004
- Single-core to multi-core devices

![mem_wall](../assets/literate_figures/mem_wall.png)

GPUs are massively parallel devices
- SIMD machine (programmed using threads - SPMD) ([more](https://safari.ethz.ch/architecture/fall2020/lib/exe/fetch.php?media=onur-comparch-fall2020-lecture24-simdandgpu-afterlecture.pdf))
- Further increases the Flop vs Bytes gap

![cpu_gpu_evo](../assets/literate_figures/cpu_gpu_evo.png)

If we look at an
- Nvidia Tesla A100 GPU
- AMD EPYC "Rome" 7282 (16 cores) CPU

| Device | TFLOPS (FP64) | Memory BW TB/s | Ratio |
| :------: | :-----: | :------: | :------: |
| Tesla A100 | 9.7 | 1.55 | 6.23
| AMD EPYC 7282 | 0.7 | 0.085 | 8.23

➡ Memory bound: requires to re-think the numerical implementation and solution strategies

### On the scientific application side

- Most algorithms require only a few operations or flops ...
- ... compared to the amount of numbers or bytes accessed from main memory.

First derivative example

If we "naively" compare the "cost" of evaluating a finite-difference first derivative, e.g., computing a flux $q$:

$$q = -D~\frac{∂A}{∂x}~,$$

which in the discrete form reads `q[ix] = -D*(A[ix+1]-A[ix])/dx`.

The cost of evaluating `q[ix] = -D*(A[ix+1]-A[ix])/dx`:

2 reads + 1 write => $3 × 8$ = **24 bytes transferred**

1 (fused) addition and division => **1 (2) floating point operations**

assuming:
- $D$, $∂x$ are scalars
- $q$ and $A$ are arrays of `Float64` (read from global memory)

Comparing to the machine balances:

| Device | TFLOPS (FP64) | Memory BW TB/s | Ratio |
| :------: | :-----: | :------: | :------: |
| Tesla A100 | 9.7 | 1.55 | 6.23 |
| AMD EPYC 7282 | 0.7 | 0.085 | 8.23 |
| $∂A/∂x$ | 1 ($×10^{-12}$) | 24 ($×10^{-12}$) | 0.041 |

0.041 << 6.23 or 8.23, and so we are memory-bound

The Flop/s metric is no longer the most adequate for reporting the application performance of many modern applications.

## Effective memory throughput metric

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

Defining the $T_\mathrm{eff}$ metric, we assume that
1. we evaluate an iterative stencil-based solver,
2. the problem size is much larger than the cache sizes and
3. the usage of time blocking is not feasible or advantageous (reasonable for real-world applications).

\note{Fields within the effective memory access that do not depend on their own history; such fields can be re-computed on the fly or stored on-chip.}

As first task, we'll compute the $T_\mathrm{eff}$ for the 2D diffusion code [`diffusion_2D.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/) we are already familiar with (download the script if needed to get started).

We'll have to:
- copy `diffusion_2D.jl` and rename it to `diffusion_2D_Teff.jl`
- add a timer
- include the performance metric formulas
- deactivate visualisation

💻 Let's get started

### Timer and performance
- Use `Base.time()` to return the current timestamp
- Define `t_tic`, the starting time, after 11 time steps to allow for "warmup"
- Record the exact number of iterations (introduce e.g. `niter`)
- Compute the elapsed time `t_toc` at the end of the time loop and report:

```julia
t_toc = ...
A_eff = ...          # Effective main memory access per iteration [GB]
t_it  = ...          # Execution time per iteration [s]
T_eff = A_eff/t_it   # Effective memory throughput [GB/s]
```

- Report `t_toc`, `T_Eff` and `niter` at the end of the code, formatting output using `@printf()` macro.
- Round `T_eff` to the 3rd significant digit.

```julia
@printf("Time = %1.3f sec, ... \n", t_toc, ...)
```

### Deactivate visualisation
- Use keyword arguments ("kwargs") to allow for default behaviour
- Define a `do_visu` flag set to `false`

```julia
@views function diffusion_2D(; ??)

   ...

    return
end

diffusion_2D(; ??)
```

So far so good, we have now a timer.

Let's also boost resolution to `nx = ny = 512` and set `ttot = 0.1` to have the code running ~1 sec.

In the next part, we'll work on a multi-threading implementation.

## Parallel computing on CPUs

_Towards implementing shared memory parallelisation using multi-threading capabilities of modern multi-core CPUs._

We'll work it out in 4 steps:
1. Precomputing scalars, removing divisions and casual arrays
2. Replacing flux arrays by macros
3. Back to loops I
4. Back to loops II - compute functions (kernels)

### 1. Precomputing scalars, removing divisions and casual arrays

As first, duplicate `diffusion_2D_Teff.jl` and rename it as `diffusion_2D_perf.jl`

- First, replace `D/dx` and `D/dy` in the flux calculations by precomputed `D_dx = D/dx` and `D_dy = D/dy` in the fluxes.
- Then, replace divisions `/dx, /dy` by inverse multiplications `*_dx, *_dy` where `_dx, _dy = 1.0/dx, 1.0/dy`.
- Remove the `dCdt` array as we do not actually need it in the algorithm.

### 2. Replacing flux arrays by macros

As first, duplicate `diffusion_2D_perf.jl` and rename it as `diffusion_2D_perf2.jl`

Storing flux calculations in `qx` and `qy` arrays is not needed and produces additional read/write we want to avoid.

Let's create macros and call them in the time loop:

```julia
macro qx()  esc(:( ... )) end
macro qy()  esc(:( ... )) end
```

Macro will be expanded at preprocessing stage (copy-paste)

Advantages of using macros vs functions:
- easier syntax (no need to specify indices)
- there can be a performance advantage (if functions are not inlined)

Also, we now have to ensure `C` is not read and written back in the same (will become important when enabling multi-threading).

Define `C2`, a copy of `C`, modify the physics computation line, and implement a pointer swap

```julia
C2      = ...
# [...]
C2[2:end-1,2:end-1] .= C[2:end-1,2:end-1] .- dt.*( ... )
C, C2 = ... # pointer swap
```

### 3. Back to loops I

As first, duplicate `diffusion_2D_perf2.jl` and rename it as `diffusion_2D_perf_loop.jl`

The goal is now to write out the diffusion physics in a loop fashion over $x$ and $y$ dimensions.

Implement a nested loop, taking car of bounds and staggering.

```julia
for iy=1:??
    for ix=1:??
        C2[??] = C[??] - dt*( (@qx(ix+1,iy) - @qx(ix,iy))*_dx + (@qy(ix,iy+1) - @qy(ix,iy))*_dy )
    end
end
```

Note that macros can take arguments, here `ix,iy`, and need updated definition.

Macro argument can be used in definition appending `$`.

```julia
macro qx(ix,iy)  esc(:( ... C[$ix+1,$iy+1] ... )) end
macro qy(ix,iy)  ...
```

Performance is already quite better with the loop version. Reasons are that `diff()` are allocating tmp and that Julia is overall well optimised for executing loops.

Let's now implement the final step.

### 4. Back to loops II

Duplicate `diffusion_2D_perf2_loop.jl` and rename it as `diffusion_2D_perf_loop_fun.jl`

In this last step, the goal is to define a `compute` function to hold the physics calculations, and to call it within the time loop.

Create a `compute!()` function that takes input and output arrays and needed scalars as argument and returns nothing.

```julia
function compute!(...)
    ...
    return
end
```

\note{Function that modify arguments take a `!` in their name, a Julia convention.}

The `compute!()` function can then be called within the time loop

```julia
compute!(...)
```

This last implementation executes a bit faster as previous one, as functions allow Julia to further optimise during just-ahead-of-time compilation.

Let's now see how to implement multi-threading and advanced vector instructions (AVX)

### Multi-threading (native)

Julia ships with it's `base` feature the possibility to enable [multi-threading](https://docs.julialang.org/en/v1/manual/multi-threading/).

The only 2 modifications needed to enable it in our code are:

1. Place `Threads.@threads` in front of the outer loop definition
2. Export the desired amount of threads, e.g., `export JULIA_NUM_THREADS=4`, to be activate prior to launching Julia (or executing the script from the shell)

\note{For optimal performance, the numbers of threads should be identical to the  number of physical cores of the target CPU.}

### Multi-threading and AVX

Relying on Julia's [LoopVectorization.jl](https://github.com/JuliaSIMD/LoopVectorization.jl) package, it is possible to combine multi-threading with AVX optimisations to further exploit shared memory parallelisation capabilities of x86 type of CPUs.

To enable it in our code:

1. Add `using LoopVectorization` at the top of the script
2. Replace `Threads.@threads` by `@tturbo` in front of the outer loop in the `compute!()` kernel

And here we go 🚀

\note{For optimal performance assessment, bound-checking should be deactivated. This can be achieved by adding `@inbounds` in front of the compute statement, or running the scripts (or launching Julia) with the `--check-bounds=no` option.}

### Wrapping-up

- We discussed main performance limiters
- We implemented the effective memory throughput metric $T_\mathrm{eff}$
- We optimised the Julia 2D diffusion code (multi-threading and AVX)

Note that for problem sizes fitting in the cache, [LoopVectorization.jl](https://github.com/JuliaSIMD/LoopVectorization.jl)'s `@tturbo` permits to achieve effective memory throughput close to memory copy rates ($T_\mathrm{peak}$).

