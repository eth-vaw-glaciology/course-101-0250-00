### A Pluto.jl notebook ###
# v1.0.3

#> [frontmatter]
#> chapter = "2"
#> section = "1"
#> order = "1"
#> title = "Parallel computing"
#> date = "2026-10-06"
#> tags = ["module2"]
#> layout = "layout.jlhtml"
#> 
#>     [[frontmatter.author]]
#>     name = "Ivan Utkin"
#>     [[frontmatter.author]]
#>     name = "Ludovic Räss"
#>     [[frontmatter.author]]
#>     name = "Mauro Werder"
#>     [[frontmatter.author]]
#>     name = "Samuel Omlin"

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    return quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ a7c0b7ad-c2ce-447c-ae02-906f49267cd7
using BenchmarkTools

# ╔═╡ 1ff08eb1-b222-4f3a-8926-afec6d0407b5
using Test

# ╔═╡ 208e62cf-2bf1-4a88-99c2-1c38a03e7ad5
begin
using PlutoUI
using PlutoTeachingTools
TableOfContents()
end

# ╔═╡ 71b8e03b-6e48-42c7-b93b-99e5f2215fba
begin
using CairoMakie
using ProgressLogging
end

# ╔═╡ 00566cd7-75d3-4ba1-969a-07db5fa23fb3
md"""
# Parallel computing

The goal of this lecture is to become familiar with:

- Performance limiters and the effective memory throughput metric ``T_\mathrm{eff}``.
- Rewriting array programming code with loops and compute functions.
- Shared memory parallelisation on CPUs using multi-threading.
- Unit testing in Julia.

In the previous lecture, we implemented an accelerated pseudo-transient solver with dynamic relaxation (DR) for the steady diffusion equation. In this lecture, we will assess its performance, make it faster, and run it in parallel on all cores of a CPU.
"""

# ╔═╡ aaa6a605-de7d-4035-b0c7-9c707fb3ded8
md"""
## From Pluto notebooks to Julia scripts

So far, you have solved the exercises in Pluto notebooks. Notebooks are great for interactive exploration, but larger codes are usually developed as plain Julia scripts (`.jl` files) in a code editor, and executed in the Julia REPL or from the terminal. **Starting from this lecture, you will write your code in plain Julia scripts.** The lecture notes remain Pluto notebooks: you can still run them locally to try out the interactive elements.

We recommend [VS Code](https://code.visualstudio.com) with the Julia extension. If you haven't installed them yet, follow the instructions on the [Software installation](https://pde-on-gpu.vaw.ethz.ch/installation/#vs-code) page.

A typical workflow looks like this:

1. Open the folder with your code in VS Code (*File > Open Folder...*), e.g. the folder for this week's exercises in your course GitHub repository.
2. Make the folder a Julia project, as described in [lecture 3](https://pde-on-gpu.vaw.ethz.ch/part1_introduction/lecture03/#Julia-project-environments:-usage-in-this-course), and add the packages you need, e.g. `] add CairoMakie BenchmarkTools`. VS Code shows the active environment in the status bar (*Julia env: ...*); click on it to select a different one.
3. Create a new file with the `.jl` extension, e.g. `elliptic_1d_dr.jl`, and write your code there.
4. Start the Julia REPL with the command *Julia: Start REPL* (`Alt+J Alt+O`), and run the whole script with *Julia: Execute File in REPL* (the ▶ button in the top-right corner of the editor). To run only the current line or the selected code, press `Ctrl+Enter` (or `Shift+Enter` to also move the cursor to the next line). In the REPL, you can also run a script with `include("elliptic_1d_dr.jl")`.
5. Figures that you pass to `display` appear in the VS Code plot pane. To save a figure to a file, e.g. to include it in a `README.md`, use `save("figure.png", fig)`.

!!! note "Running scripts from the terminal"
    You can also run a script from the terminal with `julia --project elliptic_1d_dr.jl`. In this case, CairoMakie opens the figures passed to `display` in your default image viewer.

!!! note "Tip"
    Keep your code inside functions, as we did in the previous lectures. Code at the top level of a script works with global variables, which is slow in Julia (see the [performance tips](https://docs.julialang.org/en/v1/manual/performance-tips/#Avoid-untyped-global-variables)).
"""

# ╔═╡ cb05bc04-4c01-49a6-8e40-6c0ba39646cf
md"""
## Performance limiters

Before we start optimising our code, let's ask ourselves a few questions:

- How can we assess the performance of a numerical application?
- Are you familiar with the concept of wall time?
- What are the key ingredients to understand performance?

### Hardware

- Modern processors (CPUs and GPUs) have multiple cores.
- Modern processors use their parallelism to hide latency, i.e. they overlap the execution time (latency) of individual operations with the execution of other operations.
- Multi-core CPUs and GPUs share similar challenges.

Recall from [lecture 1](https://pde-on-gpu.vaw.ethz.ch/part1_introduction/lecture01/#Why-solve-PDEs-on-GPUs?) that the growth of single-core performance stagnated in the mid-2000s, and processors became multi-core devices: we need **parallel computing** to use their full potential. Moreover, the floating-point performance of processors grows faster than their memory bandwidth, which is known as the **memory wall**:

![Evolution of CPU and GPU performance and memory bandwidth](https://raw.githubusercontent.com/eth-vaw-glaciology/course-101-0250-00/a4f02420601bae984a3e937fb72278b80d857b86/lectures/part1_introduction/assets/l1_cpu_gpu_evo.png)

GPUs are massively parallel devices:
- They are [SIMD](https://en.wikipedia.org/wiki/Single_instruction,_multiple_data) (single instruction, multiple data) machines programmed using threads (SPMD, single program, multiple data) ([more](https://safari.ethz.ch/architecture/fall2020/lib/exe/fetch.php?media=onur-comparch-fall2020-lecture24-simdandgpu-afterlecture.pdf)).
- They further increase the gap between the floating-point performance (FLOP/s) and the memory bandwidth (bytes/s).

Current GPUs (and CPUs) can perform many more floating-point operations in a given amount of time than they can access numbers in main memory. We can quantify this imbalance:

```math
\frac{\mathrm{peak\;floating\;point\;performance\;[TFLOP/s]}}{\mathrm{peak\;memory\;bandwidth\;[TB/s]}} \times \mathrm{size\;of\;a\;number\;[bytes]}~.
```

Let's compute it for a few devices, using the theoretical peak values specified by the vendors and double-precision (FP64) numbers of 8 bytes:

| Device               | FP64 performance (TFLOP/s) | Memory bandwidth (TB/s) | Imbalance (FP64)     |
| :------------------: | :------------------------: | :---------------------: | :------------------: |
| Nvidia GH200 (96 GB) | 34                         | 4                       | 34 / 4 × 8 = 68      |
| Nvidia A100 (40 GB)  | 9.7                        | 1.55                    | 9.7 / 1.55 × 8 ≈ 50  |
| AMD EPYC 7282        | 0.7                        | 0.085                   | 0.7 / 0.085 × 8 ≈ 66 |

_(The FP64 performance of the GPUs is given without tensor cores. The AMD EPYC 7282 is a 16-core CPU.)_

**Meaning:** these devices can perform 50–70 floating-point operations per number accessed in main memory. Floating-point operations are "for free" when we work in the memory-bound regime.

This requires rethinking the numerical implementation and solution strategies.
"""

# ╔═╡ 3ae26849-07cb-4f64-86e3-3eb35ffa15bc
md"""
### Theoretical peak memory bandwidth of your computer

How does your computer compare to these devices? The theoretical peak memory bandwidth ``B_\mathrm{peak}`` is determined by the configuration of the main memory:

```math
B_\mathrm{peak} = n_\mathrm{ch} \times \frac{w}{8} \times f~,
```

where ``n_\mathrm{ch}`` is the number of memory channels, ``w`` is the width of a channel in bits (64 bits for DDR4 and DDR5 memory), and ``f`` is the data rate in megatransfers per second (MT/s). For example, a desktop computer or a laptop with two channels of DDR5-5600 memory has ``B_\mathrm{peak} = 2 \times 8\;\mathrm{B} \times 5600\;\mathrm{MT/s} = 89.6\;\mathrm{GB/s}``.

The vendors list these specifications on their websites: Intel lists the memory types, the maximum number of memory channels and the maximum memory bandwidth of its processors in the [product specifications](https://www.intel.com/content/www/us/en/ark.html), AMD on the [processor specifications](https://www.amd.com/en/products/specifications/processors.html) page, and Apple lists the memory bandwidth in the technical specifications of its computers.
"""

# ╔═╡ 5baa0cfe-343b-4ef5-a635-77094c969733
md"""
When running this notebook in Pluto, enter the specifications of your computer to compute its theoretical peak memory bandwidth:

data rate ``f`` (MT/s): $(@bind __mem_rate NumberField(100:20000; default=5600)) \
number of channels ``n_\mathrm{ch}``: $(@bind __mem_nch NumberField(1:24; default=2)) \
channel width ``w`` (bits): $(@bind __mem_width NumberField(16:16:128; default=64))
"""

# ╔═╡ c769ee88-4d6d-48b3-b556-e3db23e387db
begin
	__B_peak = __mem_nch * __mem_width / 8 * __mem_rate / 1e3 # [GB/s]
	Markdown.parse("""
```math
B_\\mathrm{peak} = $(__mem_nch) \\times $(__mem_width ÷ 8)\\;\\mathrm{B} \\times $(__mem_rate)\\;\\mathrm{MT/s} = $(round(__B_peak; digits=1))\\;\\mathrm{GB/s}
```
""")
end

# ╔═╡ 805d9c4e-1ec7-4098-baae-aeeef5858d7f
md"""
### Arithmetic intensity of PDE solvers

Most numerical algorithms perform only a few floating-point operations (FLOP) per number accessed in main memory. For example, consider the diffusive flux from lecture 2:

```math
q = -\lambda u_x~,
```

which the DR solver from lecture 3 evaluates on a staggered grid as `qx[ix] = -λ[ix] * (u[ix+1] - u[ix]) / dx`. Assuming that `dx` is a scalar, and `u`, `λ` and `qx` are arrays of `Float64` numbers stored in main memory, computing one element of `qx` requires:

- 2 reads (`u[ix+1]` and `λ[ix]`; `u[ix]` was already loaded when computing `qx[ix-1]`) and 1 write (`qx[ix]`) ⟹ 3 × 8 = **24 bytes transferred**;
- 1 subtraction, 1 multiplication and 1 division ⟹ **3 floating-point operations**.

!!! note
	We don't count two memory reads for `u[ix+1]` and `u[ix]`, because a CPU or a GPU never reads a single number from main memory: it fetches a small contiguous block of memory (a cache line, typically 64 bytes) and stores it in a fast cache. Accessing data in the cache is much faster than accessing main memory.

That is about 1 floating-point operation per number transferred, while the devices above could perform 50–70 operations in the same time. Such computations are **memory-bound**: their performance is limited by the memory bandwidth, not by the floating-point performance. Therefore, the number of floating-point operations per second (FLOP/s) is not an adequate metric for the performance of many modern applications on modern hardware.
"""

# ╔═╡ df37ce9a-8c19-46ac-b25e-44bb61cb6c59
md"""
## Effective memory throughput metric ``T_\mathrm{eff}``

We need a performance metric based on the memory throughput to evaluate iterative stencil-based solvers. In this course, we will use the effective memory throughput ``T_\mathrm{eff}`` [GB/s]:

```math
T_\mathrm{eff} = \frac{A_\mathrm{eff}}{t_\mathrm{it}}~.
```

Here, ``t_\mathrm{it}`` [s] is the execution time per iteration, and ``A_\mathrm{eff}`` [GB] is the effective memory access. It is calculated as the sum of:

- twice the memory footprint of the unknown fields, ``D_\mathrm{u}``: fields that depend on their own history and that need to be read and written every iteration;
- the memory footprint of the known fields, ``D_\mathrm{k}``, that do not change every solver iteration.

```math
A_\mathrm{eff} = 2~D_\mathrm{u} + D_\mathrm{k}~.
```

The upper bound of ``T_\mathrm{eff}`` is ``T_\mathrm{peak}``, the peak memory throughput that can be achieved in practice, as measured, e.g., by the [STREAM benchmark](https://www.cs.virginia.edu/stream/) ([McCalpin, 1995](https://www.cs.virginia.edu/~mccalpin/papers/bandwidth/bandwidth.html)) for CPUs, or a GPU analogue.

Defining the ``T_\mathrm{eff}`` metric, we assume that:
1. we evaluate an iterative stencil-based solver,
2. the problem size is much larger than the cache sizes, and
3. the usage of temporal blocking (performing several iterations on a part of the domain while it resides in the cache) is not feasible or advantageous, which is reasonable for real-world applications.

!!! note
    Fields that do not depend on their own history, such as fluxes, are not included in the effective memory access: they can be recomputed on the fly or stored on-chip.

You can read more about the ``T_\mathrm{eff}`` metric in [Räss et al. (2022)](https://gmd.copernicus.org/articles/15/5757/2022/).
"""

# ╔═╡ 11abe2f1-66d8-4d47-a8af-4ff1ae22f592
md"""
### Measuring the peak memory throughput

The simplest way to measure ``T_\mathrm{peak}`` is to copy a large array into another one (a memory copy, or memcopy). A memcopy of ``n`` numbers reads ``n`` numbers and writes ``n`` numbers, so its effective memory access is ``A_\mathrm{eff} = 2 \times n \times 8`` bytes for `Float64` numbers.

We use the `@belapsed` macro from the [BenchmarkTools.jl](https://github.com/JuliaCI/BenchmarkTools.jl) package, which runs a function many times and returns the minimum execution time in seconds. With one thread, we copy the arrays with Julia's `copy!` function. With multiple threads, we use the function `mtcopy!`, which copies the array elements in a loop parallelised with `Threads.@threads`. We will discuss benchmarking and multi-threading in more detail later in this lecture.
"""

# ╔═╡ 368a021e-cefc-4e5d-8483-8bd56804b246
function mtcopy!(B, A)
	Threads.@threads for i in eachindex(B, A)
		@inbounds B[i] = A[i]
	end
	return
end

# ╔═╡ c46c7b29-af24-438b-b0be-ff41dd8c499d
function memcopy_throughput(n; threaded=false)
	A = rand(n)
	B = zeros(n)
	if threaded
		t = @belapsed mtcopy!($B, $A) seconds=0.1
	else
		t = @belapsed copy!($B, $A) seconds=0.1
	end
	return 2 * n * sizeof(Float64) / t / 1e9 # [GB/s]
end

# ╔═╡ 1e8d7d7d-8391-4e03-9551-dc0cb748afc5
md"""
When running this notebook in Pluto, choose the number of threads, and tick the box to run the benchmark for array sizes from ``2^{10}`` to ``2^{26}`` elements. By default, Pluto runs notebooks with approximately as many threads as your computer has physical cores.

threads: $(@bind __memcopy_threaded Select([false => "1", true => "all available"])) \
run the benchmark: $(@bind __memcopy_run CheckBox())
"""

# ╔═╡ 367a4ee5-68db-47fe-a2e1-39fb2537a5b5
begin
__sizes = [1 << i for i in 10:2:26]
__Teffs = Float64[]
if __memcopy_run
	@progress "Benchmarking" for n in __sizes
		Teff = memcopy_throughput(n; threaded=__memcopy_threaded)
		push!(__Teffs, Teff)
	end
end
end

# ╔═╡ ff1df1fd-6f6b-4983-a80b-47edfd15fc98
if __memcopy_run
	fig = Figure(size=(600, 300))
	ax  = Axis(fig[1, 1]; xscale=log2, xlabel="Number of elements", ylabel = L"T_\mathrm{eff}~[\text{GB/s}]", title="Benchmark results")
	xlims!(ax, 1<<9, 1<<27)
	scatterlines!(ax, __sizes, __Teffs; label="measured")
	hlines!(ax, __B_peak; color=:gray, linestyle=:dash, linewidth=2, label=L"B_\mathrm{peak}")
	axislegend(ax)
	fig
end

# ╔═╡ 826cfffe-f260-40c3-a610-a3c49038eb14
md"""
What do you see on the plot? Try to explain the observed trend. Does the measured memory throughput reach the theoretical peak? If not, why?
"""

# ╔═╡ 20fc4edd-ce95-4bf5-9e96-5cf01e72cdad
md"""
!!! note "Interpreting the benchmark"
    - Small arrays fit into the caches, so for small array sizes, we measure the bandwidth of the caches rather than of the main memory. To measure ``T_\mathrm{peak}``, the arrays must be much larger than the caches.
    - The measured throughput is lower than the theoretical peak memory bandwidth ``B_\mathrm{peak}``. On many CPUs, a single core cannot saturate the memory bandwidth: compare the results obtained with 1 thread and with all available threads.
    - For very small arrays, the overhead of starting the threads dominates, and the multi-threaded copy is slower than the single-threaded one.
"""

# ╔═╡ f0d6a820-daa6-48f6-a487-9e4e7f638ab6
md"""
## Effective memory throughput of the DR solver

As a first task, let's compute ``T_\mathrm{eff}`` for the steady diffusion solver with dynamic relaxation (DR) from [lecture 3](https://pde-on-gpu.vaw.ethz.ch/part1_introduction/lecture03/#Dynamic-relaxation).

👉 Create a new script `elliptic_1d_dr.jl`, and copy the package imports, the function `elliptic_1d_dr` that you implemented in lecture 3, and the function call into it. Run the script and check that you obtain the same results as in lecture 3.

!!! note
    In the starting script below, the coefficient in the `β` update is called ``\gamma``, as in the formula in lecture 3 (the code in lecture 3 calls it `A`). This avoids confusion with the effective memory access ``A_\mathrm{eff}``.
"""

# ╔═╡ a03dc7e7-8abe-4273-b9be-4607b86a16e6
Foldable(md"Starting script `elliptic_1d_dr.jl`",
md"""
```julia
using CairoMakie
using LinearAlgebra

@views function elliptic_1d_dr()
    # physics
    lx   = 20.0
    λbg  = 1.0
    λamp = 10.0
    # numerics
    nx    = 200
    εtol  = 1e-6
    niter = 15nx
    nchck = ceil(Int, 0.1nx)
    ndrel = 10
    # preprocessing
    dx   = lx / nx
    xc   = LinRange(dx/2,lx-dx/2,nx)
    xv   = LinRange(dx,lx-dx,nx-1)
    β    = 1 - 2π / nx
    # array initialisation
    u    = zeros(nx)
    λ    = @. λbg + λamp * exp(-(xv-lx/2)^2)
    qx   = zeros(nx-1)
    d    = zeros(nx-2)
    r    = zeros(nx-2)
    z    = zeros(nx-2)
    z0   = zeros(nx-2)
    # preconditioner
    Q    = @. dx^2 / (λ[1:end-1] + λ[2:end])
    # convergence history
    itr_h = Float64[]
    res_h = Float64[]
    # time loop
    for iter = 1:niter
        # update solution
        α = 0.99 * (1 + β)
        @. u[2:end-1] += α * d
        # boundary conditions
        u[1]   = 0
        u[end] = 1
        # compute residual
        @. qx = -λ * (u[2:end] - u[1:end-1]) / dx
        @. r  = -(qx[2:end] - qx[1:end-1]) / dx
        # check convergence
        if iter % nchck == 0
            err = maximum(abs, r)
            push!(itr_h, iter / nx)
            push!(res_h, err)
            if err < εtol
                println(" solver converged in $(iter/nx) × N iterations! 🚀")
                break
            end
        end
        # save old z
        if iter % ndrel == 0
            @. z0 = z
        end
        # compute preconditioned residual
        @. z = Q * r
        # update β
        if iter % ndrel == 0
            γ = abs(dot(d, z .- z0)) / dot(d, d)
            β = (1 - sqrt(γ))^2
        end
        # update search direction
        @. d = d * β + z
    end
    # create plot
    fig = Figure(size=(600, 450))
    ax  = (Axis(fig[1,1]; xlabel="x", ylabel="u", title="solution"),
           Axis(fig[2,1]; xlabel="iter/nx", ylabel="|r|",
                          yscale=log10,
                          title="convergence history",
                          limits=(0, niter/nx, 0.1εtol, 1e2)))
    plt = (lines!(ax[1], xc, u; color=:red),
           lines!(ax[2], itr_h, res_h; color=:black))
    return fig
end

display(elliptic_1d_dr())
```
""")

# ╔═╡ ebc72723-9bc9-436c-841d-ce3152536e67
md"""
👉 Duplicate the script and rename the copy to `elliptic_1d_dr_Teff.jl`. In the new script, we will:

- Add a timer.
- Compute the performance metric ``T_\mathrm{eff}``.
- Deactivate the convergence check and the visualisation.

### Timer and performance

Use `Base.time()` to get the current time stamp in seconds. Start the timer `t_tic` after 10 iterations, to exclude the "warm-up" from the measurement:

```julia
# time loop
t_tic = Base.time(); niter_timed = 0
for iter = 1:niter
    # start the timer after 10 warm-up iterations
    if iter == 11 t_tic = Base.time(); niter_timed = 0 end
    niter_timed += 1
    ...
end
```

The counter `niter_timed` stores the exact number of timed iterations: with the convergence check, the solver can stop before reaching `niter` iterations. Compute the elapsed time `t_toc` after the iteration loop, and the performance metrics:

```julia
t_toc = ...
A_eff = ...          # effective main memory access per iteration [GB]
t_it  = ...          # execution time per iteration [s]
T_eff = A_eff / t_it # effective memory throughput [GB/s]
```

Report `t_toc`, `T_eff` and the number of timed iterations at the end of the function, formatting the output with the `@printf` macro from the `Printf` standard library (add `using Printf` at the top of the script):

```julia
@printf("Time = %1.3f s, T_eff = %1.2f GB/s (niter = %d)\n", ...)
```

!!! hint
    - In the DR solver, the unknown fields that depend on their own history are the solution `u` and the search direction `d`. The known fields are the diffusion coefficient `λ` and the preconditioner `Q`. The flux `qx` and the residuals `r` and `z` don't depend on their own history, and `z0` is only used every `ndrel` iterations, so we don't count them.
    - For simplicity, assume that all arrays have `nx` elements.
    - Initialise `t_tic` and the counter of timed iterations before the iteration loop: a variable that is first assigned inside a loop is local to the loop body.
"""

# ╔═╡ ff2ec07e-4c44-41c4-bacc-acfdda0a621e
md"""
### Deactivating the convergence check and the visualisation

To measure the performance, we need to:

- increase the number of grid cells `nx`, so that the arrays are much larger than the caches;
- limit the number of iterations `niter`: we're only interested in the time per iteration, not in a converged solution;
- deactivate the convergence check, which involves a global reduction (`maximum`) that is not included in ``A_\mathrm{eff}``, and the visualisation, since plotting millions of points is slow.

👉 Use keyword arguments ("kwargs") to change the default behaviour of the solver: pass `nx` and `niter` as keyword arguments (and remove them from the `# numerics` section), and add the flags `do_check` and `do_visu`:

```julia
@views function elliptic_1d_dr(; nx=200, niter=15nx, do_check=true, do_visu=true)
    ...
        # check convergence
        if do_check && iter % nchck == 0
            ...
        end
    ...
    # create plot
    if do_visu
        ...
        return fig
    end
    return
end
```

Then, check the solution with the default parameters, and measure the performance with a large number of grid cells and a limited number of iterations:

```julia
display(elliptic_1d_dr())                                           # check the solution
elliptic_1d_dr(; nx=2^23, niter=110, do_check=false, do_visu=false) # measure the performance
```

With `nx = 2^23` (about 8.4 million grid cells), each array occupies 67 MB of memory, and the solver needs about 540 MB in total. The second call should take a few seconds.

!!! warning
    Don't forget to set `niter` for large values of `nx`: with the default value `niter = 15nx`, the solver would perform more than 10⁸ iterations.
"""

# ╔═╡ c93cf401-2bf1-4d02-8a24-dd41d627ae22
answer_box(
md"""
```julia
using CairoMakie
using LinearAlgebra
using Printf

@views function elliptic_1d_dr(; nx=200, niter=15nx, do_check=true, do_visu=true)
    # physics
    lx   = 20.0
    λbg  = 1.0
    λamp = 10.0
    # numerics
    εtol  = 1e-6
    nchck = ceil(Int, 0.1nx)
    ndrel = 10
    # preprocessing
    dx   = lx / nx
    xc   = LinRange(dx/2,lx-dx/2,nx)
    xv   = LinRange(dx,lx-dx,nx-1)
    β    = 1 - 2π / nx
    # array initialisation
    u    = zeros(nx)
    λ    = @. λbg + λamp * exp(-(xv-lx/2)^2)
    qx   = zeros(nx-1)
    d    = zeros(nx-2)
    r    = zeros(nx-2)
    z    = zeros(nx-2)
    z0   = zeros(nx-2)
    # preconditioner
    Q    = @. dx^2 / (λ[1:end-1] + λ[2:end])
    # convergence history
    itr_h = Float64[]
    res_h = Float64[]
    # time loop
    t_tic = Base.time(); niter_timed = 0
    for iter = 1:niter
        # start the timer after 10 warm-up iterations
        if iter == 11 t_tic = Base.time(); niter_timed = 0 end
        niter_timed += 1
        # update solution
        α = 0.99 * (1 + β)
        @. u[2:end-1] += α * d
        # boundary conditions
        u[1]   = 0
        u[end] = 1
        # compute residual
        @. qx = -λ * (u[2:end] - u[1:end-1]) / dx
        @. r  = -(qx[2:end] - qx[1:end-1]) / dx
        # check convergence
        if do_check && iter % nchck == 0
            err = maximum(abs, r)
            push!(itr_h, iter / nx)
            push!(res_h, err)
            if err < εtol
                println(" solver converged in $(iter/nx) × N iterations! 🚀")
                break
            end
        end
        # save old z
        if iter % ndrel == 0
            @. z0 = z
        end
        # compute preconditioned residual
        @. z = Q * r
        # update β
        if iter % ndrel == 0
            γ = abs(dot(d, z .- z0)) / dot(d, d)
            β = (1 - sqrt(γ))^2
        end
        # update search direction
        @. d = d * β + z
    end
    # performance
    t_toc = Base.time() - t_tic
    A_eff = (2*2 + 2) * nx * sizeof(Float64) / 1e9  # effective main memory access per iteration [GB]
    t_it  = t_toc / niter_timed                     # execution time per iteration [s]
    T_eff = A_eff / t_it                            # effective memory throughput [GB/s]
    @printf("Time = %1.3f s, T_eff = %1.2f GB/s (niter = %d)\n", t_toc, T_eff, niter_timed)
    # create plot
    if do_visu
        fig = Figure(size=(600, 450))
        ax  = (Axis(fig[1,1]; xlabel="x", ylabel="u", title="solution"),
               Axis(fig[2,1]; xlabel="iter/nx", ylabel="|r|",
                              yscale=log10,
                              title="convergence history",
                              limits=(0, niter/nx, 0.1εtol, 1e2)))
        plt = (lines!(ax[1], xc, u; color=:red),
               lines!(ax[2], itr_h, res_h; color=:black))
        return fig
    end
    return
end

display(elliptic_1d_dr())
elliptic_1d_dr(; nx=2^23, niter=110, do_check=false, do_visu=false)
```
""")

# ╔═╡ 44e7be6f-a432-4eae-964d-aa737b1ba01c
md"""
How does the ``T_\mathrm{eff}`` of the solver compare to the memory throughput ``T_\mathrm{peak}`` that you measured with the memcopy benchmark? On an Apple M2 Max laptop, we obtained ``T_\mathrm{eff} \approx 14`` GB/s, while the memcopy on a single core achieved ``T_\mathrm{peak} \approx 110`` GB/s. There is room for improvement!
"""

# ╔═╡ de2207dd-765d-478e-9c88-3e895970987d
Foldable(md"Why can't ``T_\mathrm{eff}`` reach ``T_\mathrm{peak}``?",
md"""
``T_\mathrm{eff}`` can only reach ``T_\mathrm{peak}`` if the code accesses only the fields counted in ``A_\mathrm{eff}``. However, in every iteration, our DR solver also writes and reads the intermediate fields `qx`, `r` and `z`. Counting the reads and writes of all arrays (e.g. the update of `u` reads `u` and `d` and writes `u`), every iteration transfers about 14 arrays instead of the 6 counted in ``A_\mathrm{eff}``. Therefore, an implementation that stores these fields in main memory can achieve at most about 6/14 ≈ 40% of ``T_\mathrm{peak}``. To get closer to ``T_\mathrm{peak}``, one would need to merge several operations into a single loop (kernel fusion) and recompute the intermediate fields on the fly.
""")

# ╔═╡ bc8859ab-4a59-4566-8a11-99533b31cfb8
md"""
## Parallel computing on CPUs

_Towards shared memory parallelisation using the multi-threading capabilities of modern multi-core CPUs._

We'll work it out in 3 steps:
1. Precomputing scalars, removing divisions and allocations.
2. Back to loops I: rewriting array operations as loops.
3. Back to loops II: moving the loops into compute functions ("kernels").

### 1. Precomputing scalars, removing divisions and allocations

👉 Duplicate `elliptic_1d_dr_Teff.jl` and rename it to `elliptic_1d_dr_perf.jl`.

Divisions are more expensive than multiplications. Precompute the inverse of the grid spacing in the `# preprocessing` section:

```julia
_dx  = 1.0 / dx
```

and replace the divisions `/ dx` in the residual computation with multiplications `* _dx`.

The expression `z .- z0` in the `β` update allocates a new temporary array every `ndrel` iterations. Since the old preconditioned residual `z0` is not needed after computing the difference, we can store the difference in `z0` instead:

```julia
@. z0 = z - z0 # reuse z0 to store the difference
γ = abs(dot(d, z0)) / dot(d, d)
```

On our test machine, these changes only slightly improved the performance: ``T_\mathrm{eff}`` increased from about 14 to 15 GB/s, mostly thanks to removing the allocations. Replacing divisions with multiplications matters more in compute-bound codes, where the arithmetic operations are not hidden behind the memory accesses.
"""

# ╔═╡ 58892afc-2f6e-4035-bbf9-2698861bd88d
md"""
### 2. Back to loops I

👉 Duplicate `elliptic_1d_dr_perf.jl` and rename it to `elliptic_1d_dr_perf_loop.jl`.

The goal is now to write out all array operations in the iteration loop as `for` loops over the grid cells. Let's start with the residual.

👉 Rewrite the computation of the flux `qx` and the residual `r` with loops, taking care of the array bounds and the staggered grid:

```julia
# compute residual
for ix = ??
    qx[ix] = ??
end
for ix = ??
    r[ix]  = ??
end
```

!!! hint
    The flux `qx` has `nx-1` elements, located between the cell centres where `u` is defined. The residual `r` has `nx-2` elements, located at the inner cell centres: `r[ix]` corresponds to `u[ix+1]`.
"""

# ╔═╡ b8d5f6bd-b4ba-4982-8960-13bf6f01e708
answer_box(
md"""
```julia
# compute residual
for ix = 1:nx-1
    qx[ix] = -λ[ix] * (u[ix+1] - u[ix]) * _dx
end
for ix = 1:nx-2
    r[ix] = -(qx[ix+1] - qx[ix]) * _dx
end
```
""")

# ╔═╡ fac744fc-e7ca-4f6c-8225-db9b982bc870
md"""
👉 Now, rewrite the update of the solution `u`, the computation of the preconditioned residual `z`, and the update of the search direction `d` with loops.

Keep the operations performed only every `ndrel` iterations as they are: saving `z` to `z0`, and the `β` update. The two dot products in the `β` update are **reductions**: every grid cell contributes to a single number. Reductions require special care when we parallelise the code, and we will come back to them in the section on multi-threading.

!!! hint
    Keep the order of the operations from lecture 3: save `z` to `z0`, compute the new `z`, compute the new `β` using the old `d`, and only then update `d`.

Run the script and check that the solver still converges in the same number of iterations as before.
"""

# ╔═╡ 333a1a68-f525-4dcc-9e21-6b9c954926ca
answer_box(
md"""
```julia
for iter = 1:niter
    # start the timer after 10 warm-up iterations
    if iter == 11 t_tic = Base.time(); niter_timed = 0 end
    niter_timed += 1
    # update solution
    α = 0.99 * (1 + β)
    for ix = 1:nx-2
        u[ix+1] += α * d[ix]
    end
    # boundary conditions
    u[1]   = 0
    u[end] = 1
    # compute residual
    for ix = 1:nx-1
        qx[ix] = -λ[ix] * (u[ix+1] - u[ix]) * _dx
    end
    for ix = 1:nx-2
        r[ix] = -(qx[ix+1] - qx[ix]) * _dx
    end
    # check convergence
    if do_check && iter % nchck == 0
        err = maximum(abs, r)
        push!(itr_h, iter / nx)
        push!(res_h, err)
        if err < εtol
            println(" solver converged in $(iter/nx) × N iterations! 🚀")
            break
        end
    end
    # save old z
    if iter % ndrel == 0
        @. z0 = z
    end
    # compute preconditioned residual
    for ix = 1:nx-2
        z[ix] = Q[ix] * r[ix]
    end
    # update β
    if iter % ndrel == 0
        @. z0 = z - z0 # reuse z0 to store the difference
        γ = abs(dot(d, z0)) / dot(d, d)
        β = (1 - sqrt(γ))^2
    end
    # update search direction
    for ix = 1:nx-2
        d[ix] = d[ix] * β + z[ix]
    end
end
```
""")

# ╔═╡ c384c0e5-30d0-4cc1-97ca-08b5bf9e5b1f
md"""
We can use macros to make the code more readable. Macros are expanded when the code is parsed, before it is compiled. A macro receives its arguments as expressions, and returns a new expression, into which the arguments can be inserted (interpolated) using `$` (see [metaprogramming](https://docs.julialang.org/en/v1/manual/metaprogramming/) in the Julia manual).

Let's define a macro for the difference of neighbouring array elements:

```julia
macro d_xa(A) esc(:( $A[ix+1] - $A[ix] )) end
```

For example, `@d_xa(u)` is replaced with `u[ix+1] - u[ix]`. The function `esc` ("escape") makes the variables in the returned expression, here `ix`, refer to the variables at the place where the macro is used (see [hygiene](https://docs.julialang.org/en/v1/manual/metaprogramming/#Hygiene)).

👉 Define the macro at the top of the script, before the function `elliptic_1d_dr` (a macro must be defined before it is used), and use it in the residual computation.
"""

# ╔═╡ 74e07e8d-c9e2-4b42-9309-064acda33b0c
answer_box(
md"""
```julia
macro d_xa(A) esc(:( $A[ix+1] - $A[ix] )) end

...

# compute residual
for ix = 1:nx-1
    qx[ix] = -λ[ix] * @d_xa(u) * _dx
end
for ix = 1:nx-2
    r[ix] = -@d_xa(qx) * _dx
end
```
""")

# ╔═╡ 05f468da-39f1-4d3b-b6e3-897bf32a9819
md"""
The performance is already much better with the loop version 🚀: on our test machine, ``T_\mathrm{eff}`` increased from about 15 to 34 GB/s.

Note that the array operations in the previous version don't allocate memory: since lecture 3, we use views and in-place broadcasting. In fact, each broadcast operation alone is as fast as the corresponding loop. However, in our tests, the compiler generated less efficient code for a large function containing many broadcast operations. Such effects are hard to predict, which is why we always need to measure the performance.
"""

# ╔═╡ f60fa805-d42f-4411-b76f-ea96bbf441d5
md"""
### 3. Back to loops II

👉 Duplicate `elliptic_1d_dr_perf_loop.jl` and rename it to `elliptic_1d_dr_perf_loop_fun.jl`.

In this last step, the goal is to move the loops into compute functions ("kernels"), and to call those within the iteration loop. Compute functions:
- make the code more modular, and easier to read and to test;
- are needed for efficient multi-threading: `Threads.@threads` turns the loop body into a separate function (a closure), and closures that capture variables reassigned in the enclosing function, such as `α` and `β`, make the code type-unstable and slow (see [performance of captured variables](https://docs.julialang.org/en/v1/manual/performance-tips/#man-performance-captured));
- map directly to GPU kernels, which we will write in the next lecture.

👉 Create the functions `update_u!` (including the boundary conditions), `compute_r!`, `precondition!` and `update_d!`, which take the input and output arrays and the needed scalars as arguments and return `nothing`:

```julia
function update_u!(u, d, α)
    nx = length(u)
    ...
    return
end

function compute_r!(r, qx, u, λ, _dx)
    ...
end

function precondition!(z, r, Q)
    ...
end

function update_d!(d, z, β)
    ...
end
```

Then, call these functions within the iteration loop. For now, keep the `β` update with the dot products in the iteration loop.

!!! note
    Functions that modify their arguments have a `!` at the end of their name; this is a Julia convention.
"""

# ╔═╡ 069d4dd1-041b-4c05-a08d-181db9deb0d6
answer_box(
md"""
```julia
function update_u!(u, d, α)
    nx = length(u)
    for ix = 1:nx-2
        u[ix+1] += α * d[ix]
    end
    u[1]   = 0
    u[end] = 1
    return
end

function compute_r!(r, qx, u, λ, _dx)
    nx = length(u)
    for ix = 1:nx-1
        qx[ix] = -λ[ix] * @d_xa(u) * _dx
    end
    for ix = 1:nx-2
        r[ix] = -@d_xa(qx) * _dx
    end
    return
end

function precondition!(z, r, Q)
    for ix in eachindex(z)
        z[ix] = Q[ix] * r[ix]
    end
    return
end

function update_d!(d, z, β)
    for ix in eachindex(d)
        d[ix] = d[ix] * β + z[ix]
    end
    return
end

...

for iter = 1:niter
    # start the timer after 10 warm-up iterations
    if iter == 11 t_tic = Base.time(); niter_timed = 0 end
    niter_timed += 1
    # update solution
    α = 0.99 * (1 + β)
    update_u!(u, d, α)
    # compute residual
    compute_r!(r, qx, u, λ, _dx)
    # check convergence
    if do_check && iter % nchck == 0
        err = maximum(abs, r)
        push!(itr_h, iter / nx)
        push!(res_h, err)
        if err < εtol
            println(" solver converged in $(iter/nx) × N iterations! 🚀")
            break
        end
    end
    # save old z
    if iter % ndrel == 0
        @. z0 = z
    end
    # compute preconditioned residual
    precondition!(z, r, Q)
    # update β
    if iter % ndrel == 0
        @. z0 = z - z0 # reuse z0 to store the difference
        γ = abs(dot(d, z0)) / dot(d, d)
        β = (1 - sqrt(γ))^2
    end
    # update search direction
    update_d!(d, z, β)
end
```
""")

# ╔═╡ b4b974a6-a6d0-4022-a979-4efb6066773b
md"""
On our test machine, this version runs as fast as the previous one.

!!! note "Bounds checking"
    By default, Julia checks that every array index is within the array bounds. Bounds checks can prevent some compiler optimisations, such as SIMD vectorisation. Once you're sure that your code is correct, you can deactivate bounds checks for a statement with the `@inbounds` macro, e.g. `@inbounds qx[ix] = ...`. Use it carefully: out-of-bounds accesses can silently produce wrong results or crash Julia. Starting Julia with the `--check-bounds=no` option deactivates bounds checks globally, but it is [not recommended](https://github.com/JuliaLang/julia/issues/48245): all packages then have to be precompiled again, and the code can even become slower.
"""

# ╔═╡ 77fab6b5-7ecb-434e-8f38-1247afa80c0c
md"""
### Benchmarking with BenchmarkTools

Julia provides various tools for timing and benchmarking to [track performance issues](https://docs.julialang.org/en/v1/manual/performance-tips/). Julia's `Base` exposes the `@time` macro, which reports the execution time and the memory allocations. The [BenchmarkTools.jl](https://github.com/JuliaCI/BenchmarkTools.jl) package provides more accurate benchmarking tools, namely the `@btime`, `@belapsed` and `@benchmark` macros, among others.

Let's evaluate the performance of our code using `BenchmarkTools`. To time a single iteration with `@belapsed`, we wrap the compute functions into a `compute!` function. Query `? @belapsed` in Julia's REPL to learn more.

👉 Implement the `compute!` function:

```julia
function compute!(u, d, z, r, qx, λ, Q, α, β, _dx)
    update_u!(...)
    ...
    return
end
```

`@belapsed` returns the minimum execution time of a single call in seconds, letting `BenchmarkTools` take care of the sampling.

👉 Add `using BenchmarkTools` at the top of the script, add the keyword argument `do_bench=false` to the solver, move the computation of `A_eff` before the iteration loop, and benchmark `compute!` after the array initialisation:

```julia
# benchmark one iteration with BenchmarkTools
if do_bench
    α     = 0.99 * (1 + β)
    t_it  = @belapsed compute!($u, $d, $z, $r, $qx, $λ, $Q, $α, $β, $_dx)
    T_eff = A_eff / t_it
    @printf("BenchmarkTools: t_it = %1.3e s, T_eff = %1.2f GB/s\n", t_it, T_eff)
    return
end
```

!!! note
    The variables need to be interpolated into the benchmarked expression, i.e. prefixed with `$`. Otherwise, `BenchmarkTools` looks them up as global variables.

The `compute!` function doesn't include the `β` update and the convergence check, which are only performed every `ndrel` and `nchck` iterations. Therefore, ``T_\mathrm{eff}`` measured with `@belapsed` is higher than with the manual timer.
"""

# ╔═╡ ff3212ce-9b9d-454c-afca-e5a755945f4b
answer_box(
md"""
```julia
function compute!(u, d, z, r, qx, λ, Q, α, β, _dx)
    update_u!(u, d, α)
    compute_r!(r, qx, u, λ, _dx)
    precondition!(z, r, Q)
    update_d!(d, z, β)
    return
end

...

# effective main memory access per iteration [GB]
A_eff = (2*2 + 2) * nx * sizeof(Float64) / 1e9
# benchmark one iteration with BenchmarkTools
if do_bench
    α     = 0.99 * (1 + β)
    t_it  = @belapsed compute!($u, $d, $z, $r, $qx, $λ, $Q, $α, $β, $_dx)
    T_eff = A_eff / t_it
    @printf("BenchmarkTools: t_it = %1.3e s, T_eff = %1.2f GB/s\n", t_it, T_eff)
    return
end

...
```
""")

# ╔═╡ b27f815d-27a4-4860-852a-6f52a6590d6f
md"""
## Shared memory parallelisation

Julia's `Base` provides [multi-threading](https://docs.julialang.org/en/v1/manual/multi-threading/). Only two modifications are needed to parallelise the loops in our compute functions:

1. Place `Threads.@threads` in front of the loops in the compute functions, e.g.:

```julia
Threads.@threads for ix = 1:nx-1
    @inbounds qx[ix] = -λ[ix] * @d_xa(u) * _dx
end
```

2. Start Julia with multiple threads:
    - from the terminal, using the `-t` (or `--threads`) option: `julia -t 4` starts Julia with 4 threads, and `julia -t auto` lets Julia choose the number of threads based on the number of available CPU cores;
    - alternatively, by setting the environment variable `JULIA_NUM_THREADS` before starting Julia, e.g. `export JULIA_NUM_THREADS=4` (in PowerShell on Windows: `$env:JULIA_NUM_THREADS=4`);
    - in VS Code: set the number of threads in the settings of the Julia extension (open the settings with `Ctrl+,`, or `Cmd+,` on macOS, and search for `julia.NumThreads`), and restart the REPL with *Julia: Restart REPL* (`Alt+J Alt+R`).

The number of threads can be queried within a Julia session with `Threads.nthreads()`. See also the [Software installation](https://pde-on-gpu.vaw.ethz.ch/installation/#multi-threading-on-cpus) page.

`Threads.@threads` splits the iterations of the loop into chunks and executes them on the available threads. The execution waits until all iterations are completed, so the next loop can safely use the results of the previous one.

!!! note "Number of threads"
    For optimal performance, the number of threads should usually not exceed the number of physical cores of the CPU. Many CPUs run two hardware threads per physical core (simultaneous multithreading, also known as hyper-threading), which usually doesn't improve the performance of memory-bound codes.

!!! warning "@inbounds and Threads.@threads"
    `Threads.@threads` turns the loop body into a separate function (a closure). Therefore, writing `@inbounds Threads.@threads for ...` doesn't deactivate the bounds checks inside the loop: place `@inbounds` inside the loop body, as in the example above.
"""

# ╔═╡ b8949c19-1ab3-4d12-b579-9ca00f7e390a
md"""
### Parallel reductions

Not every loop can be parallelised by placing `Threads.@threads` in front of it. `Threads.@threads` assumes that the iterations of the loop are independent: each iteration may only write to memory locations that no other iteration reads or writes. This is the case for the loops in our compute functions, but not for **reductions**, such as the dot products in the `β` update, where every grid cell contributes to a single number. If several threads update the same variable at the same time, some of the updates get lost. This is called a [race condition](https://en.wikipedia.org/wiki/Race_condition), and it leads to wrong and non-deterministic results. Parallel reductions require a different strategy: each thread reduces its own part of the array, and the partial results are combined at the end.

Instead of implementing parallel reductions ourselves, we use the [AcceleratedKernels.jl](https://github.com/JuliaGPU/AcceleratedKernels.jl) package. It provides parallel implementations of standard algorithms, such as sorting and reductions, for multi-threaded CPUs and for GPUs. Its function `mapreduce(f, op, src, srcs...)` applies the function `f` to the elements of one or several arrays, and combines the results with the operator `op`. For example, the dot product of the arrays `a` and `b` can be computed as:

```julia
AcceleratedKernels.mapreduce(*, +, a, b)
```

With several arrays, `f` takes one argument per array. This allows us to compute ``\boldsymbol{d}^n \cdot (\boldsymbol{z}^{n+1} - \boldsymbol{z}^n)`` on the fly, without storing the difference `z - z0` in `z0`.

👉 Add the AcceleratedKernels package to your project, and `using AcceleratedKernels` at the top of the script. Move the `β` update into a function `compute_β(d, z, z0)`, which computes both dot products with `AcceleratedKernels.mapreduce` and returns the new value of `β`:

```julia
function compute_β(d, z, z0)
    num = AcceleratedKernels.mapreduce(...)
    den = AcceleratedKernels.mapreduce(...)
    γ = abs(num) / den
    return (1 - sqrt(γ))^2
end
```

and call it within the iteration loop:

```julia
# update β
if iter % ndrel == 0
    β = compute_β(d, z, z0)
end
```

The maximum in the convergence check is also a reduction, but we keep it as it is: it is only performed every `nchck` iterations, and it is deactivated when we measure the performance. Note that the serial parts of a code limit the achievable speed-up ([Amdahl's law](https://en.wikipedia.org/wiki/Amdahl%27s_law)).

👉 Add `Threads.@threads` in front of the loops in the compute functions `update_u!`, `compute_r!`, `precondition!` and `update_d!`. Run the script with 1, 2, 4, ... threads and compare the performance.
"""

# ╔═╡ 3719f399-238d-40bc-8101-4301670e1f8d
answer_box(
md"""
```julia
using CairoMakie
using Printf
using BenchmarkTools
using AcceleratedKernels

macro d_xa(A) esc(:( $A[ix+1] - $A[ix] )) end

function update_u!(u, d, α)
    nx = length(u)
    Threads.@threads for ix = 1:nx-2
        @inbounds u[ix+1] += α * d[ix]
    end
    u[1]   = 0
    u[end] = 1
    return
end

function compute_r!(r, qx, u, λ, _dx)
    nx = length(u)
    Threads.@threads for ix = 1:nx-1
        @inbounds qx[ix] = -λ[ix] * @d_xa(u) * _dx
    end
    Threads.@threads for ix = 1:nx-2
        @inbounds r[ix] = -@d_xa(qx) * _dx
    end
    return
end

function precondition!(z, r, Q)
    Threads.@threads for ix in eachindex(z)
        @inbounds z[ix] = Q[ix] * r[ix]
    end
    return
end

function compute_β(d, z, z0)
    num = AcceleratedKernels.mapreduce((_d, _z, _z0) -> _d * (_z - _z0), +, d, z, z0)
    den = AcceleratedKernels.mapreduce(*, +, d, d)
    γ = abs(num) / den
    return (1 - sqrt(γ))^2
end

function update_d!(d, z, β)
    Threads.@threads for ix in eachindex(d)
        @inbounds d[ix] = d[ix] * β + z[ix]
    end
    return
end

function compute!(u, d, z, r, qx, λ, Q, α, β, _dx)
    update_u!(u, d, α)
    compute_r!(r, qx, u, λ, _dx)
    precondition!(z, r, Q)
    update_d!(d, z, β)
    return
end

@views function elliptic_1d_dr(; nx=200, niter=15nx, do_check=true, do_visu=true, do_bench=false)
    # physics
    lx   = 20.0
    λbg  = 1.0
    λamp = 10.0
    # numerics
    εtol  = 1e-6
    nchck = ceil(Int, 0.1nx)
    ndrel = 10
    # preprocessing
    dx   = lx / nx
    xc   = LinRange(dx/2,lx-dx/2,nx)
    xv   = LinRange(dx,lx-dx,nx-1)
    β    = 1 - 2π / nx
    _dx  = 1.0 / dx
    # array initialisation
    u    = zeros(nx)
    λ    = @. λbg + λamp * exp(-(xv-lx/2)^2)
    qx   = zeros(nx-1)
    d    = zeros(nx-2)
    r    = zeros(nx-2)
    z    = zeros(nx-2)
    z0   = zeros(nx-2)
    # preconditioner
    Q    = @. dx^2 / (λ[1:end-1] + λ[2:end])
    # convergence history
    itr_h = Float64[]
    res_h = Float64[]
    # effective main memory access per iteration [GB]
    A_eff = (2*2 + 2) * nx * sizeof(Float64) / 1e9
    # benchmark one iteration with BenchmarkTools
    if do_bench
        α     = 0.99 * (1 + β)
        t_it  = @belapsed compute!($u, $d, $z, $r, $qx, $λ, $Q, $α, $β, $_dx)
        T_eff = A_eff / t_it
        @printf("BenchmarkTools: t_it = %1.3e s, T_eff = %1.2f GB/s\n", t_it, T_eff)
        return
    end
    # time loop
    t_tic = Base.time(); niter_timed = 0
    for iter = 1:niter
        # start the timer after 10 warm-up iterations
        if iter == 11 t_tic = Base.time(); niter_timed = 0 end
        niter_timed += 1
        # update solution
        α = 0.99 * (1 + β)
        update_u!(u, d, α)
        # compute residual
        compute_r!(r, qx, u, λ, _dx)
        # check convergence
        if do_check && iter % nchck == 0
            err = maximum(abs, r)
            push!(itr_h, iter / nx)
            push!(res_h, err)
            if err < εtol
                println(" solver converged in $(iter/nx) × N iterations! 🚀")
                break
            end
        end
        # save old z
        if iter % ndrel == 0
            @. z0 = z
        end
        # compute preconditioned residual
        precondition!(z, r, Q)
        # update β
        if iter % ndrel == 0
            β = compute_β(d, z, z0)
        end
        # update search direction
        update_d!(d, z, β)
    end
    # performance
    t_toc = Base.time() - t_tic
    t_it  = t_toc / niter_timed                     # execution time per iteration [s]
    T_eff = A_eff / t_it                            # effective memory throughput [GB/s]
    @printf("Time = %1.3f s, T_eff = %1.2f GB/s (niter = %d)\n", t_toc, T_eff, niter_timed)
    # create plot
    if do_visu
        fig = Figure(size=(600, 450))
        ax  = (Axis(fig[1,1]; xlabel="x", ylabel="u", title="solution"),
               Axis(fig[2,1]; xlabel="iter/nx", ylabel="|r|",
                              yscale=log10,
                              title="convergence history",
                              limits=(0, niter/nx, 0.1εtol, 1e2)))
        plt = (lines!(ax[1], xc, u; color=:red),
               lines!(ax[2], itr_h, res_h; color=:black))
        return fig
    end
    return
end

display(elliptic_1d_dr())
elliptic_1d_dr(; nx=2^23, niter=110, do_check=false, do_visu=false)
elliptic_1d_dr(; nx=2^23, do_check=false, do_visu=false, do_bench=true)
```
""")

# ╔═╡ ff605448-cf99-4996-bbb3-c0990b9fc770
md"""
👉 Measure ``T_\mathrm{eff}`` of all versions of the solver with `nx = 2^23`, and compare it to ``T_\mathrm{peak}`` measured with the memcopy benchmark at the beginning of this notebook (with 1 thread and with all threads). For reference, these are the values that we measured on an Apple M2 Max laptop with Julia 1.12 (in GB/s):

| Version                                                      | 1 thread | 8 threads |
| :----------------------------------------------------------- | :------: | :-------: |
| `elliptic_1d_dr_Teff.jl`                                     | 14       | –         |
| `elliptic_1d_dr_perf.jl`                                     | 15       | –         |
| `elliptic_1d_dr_perf_loop.jl`                                | 34       | –         |
| `elliptic_1d_dr_perf_loop_fun.jl` (without threads)          | 34       | –         |
| `elliptic_1d_dr_perf_loop_fun.jl` (with `Threads.@threads`)  | 30       | 64        |
| same, `@belapsed compute!(...)`                              | 38       | 75        |
| memcopy (``T_\mathrm{peak}``)                                | 110      | 210       |

Multi-threading speeds up the solver until the memory bandwidth is saturated.
"""

# ╔═╡ c1303472-dffc-4a38-84c9-34fe86f41f3b
md"""
### Multi-threading and SIMD

Modern CPU cores can apply the same operation to several numbers at once using [SIMD](https://en.wikipedia.org/wiki/Single_instruction,_multiple_data) instructions, e.g. [AVX](https://en.wikipedia.org/wiki/Advanced_Vector_Extensions) on x86 processors, or NEON on ARM processors such as the Apple M-series chips. The Julia compiler uses SIMD instructions automatically when it can prove that it is safe to do so.

Julia's `Base` also exposes the [`@simd` macro](https://docs.julialang.org/en/v1/base/base/#Base.SimdLoop.@simd), which gives the compiler extra liberties to reorder the iterations of a loop, e.g. to vectorise a sum `s += a[i]` computed in a loop. To try it, decorate the loop with `@simd for`.

!!! warning
    The `@simd` macro is still experimental and could change or disappear in future versions of Julia. Incorrect use of `@simd` may cause unexpected results.

Using the [LoopVectorization.jl](https://github.com/JuliaSIMD/LoopVectorization.jl) package, it is possible to combine multi-threading with SIMD optimisations. LoopVectorization can also parallelise reductions written as loops. To try it:
1. Add LoopVectorization to your project, and add `using LoopVectorization` at the top of the script.
2. Replace `Threads.@threads` with `@tturbo`.

!!! warning
    `@tturbo` doesn't check array bounds, and assumes that the iterations of the loop can be executed in any order. Misusing it can lead to wrong results or crashes.
"""

# ╔═╡ 2bfd3a58-35fa-45da-adf5-a7cd0f70dd7f
md"""
## Wrapping up

- The performance of PDE solvers is usually limited by the memory bandwidth, not by the floating-point performance.
- The effective memory throughput ``T_\mathrm{eff}`` measures how efficiently a solver uses the memory bandwidth; its upper bound ``T_\mathrm{peak}`` can be measured with a memcopy benchmark.
- We rewrote the DR solver using loops and compute functions, and parallelised it with `Threads.@threads`.
- Reductions require special care in parallel code. AcceleratedKernels.jl provides parallel reductions for CPUs and GPUs.
"""

# ╔═╡ 198cbdf1-7def-47d2-ad81-7fa423331bc9
md"""
# Unit testing in Julia

## The Julia `Test` module

The `Test` standard library provides [basic unit testing](https://docs.julialang.org/en/v1/stdlib/Test/#Basic-Unit-Tests) functionality:
- Unit tests assess whether code is correct by checking that the results are as expected.
- They help to ensure that the code still works after changes, e.g. after rewriting array operations as loops.
- They should be used in packages for continuous integration (CI), when tests are run automatically on GitHub on every push.

## Basic unit tests

Simple unit testing can be performed with the `@test` and `@test_throws` macros:
"""

# ╔═╡ eb38e286-24fb-46f8-9807-1894323ddb2e
@test 1 == 1

# ╔═╡ c16e7214-6d05-40f5-b3c2-f50b3ddb766c
@test_throws MethodError 1 + "a" # the expected error must be provided too

# ╔═╡ 1168fe04-d06f-47bb-b6b2-b145e362e3b6
md"""
Another example:
"""

# ╔═╡ 2f0a6f84-fe5d-46d2-b94d-d3153564f636
@test [1, 2] + [2, 1] == [3, 3]

# ╔═╡ 3b0f0b56-ce06-4488-b53e-c54522ca280e
md"""
For approximate comparisons with `≈` (typed as `\approx` + Tab), `@test` accepts keyword arguments, such as the absolute tolerance `atol`:
"""

# ╔═╡ c0fd1463-f8e0-48f7-b261-fce6d71fb014
@test π ≈ 3.14 atol=0.01

# ╔═╡ 5b9f5205-d74b-454b-8d9d-4433f333873c
md"""
For example, suppose we want to check that our new function `square(x)` works as expected:
"""

# ╔═╡ c3c2c5d4-af9e-41b0-b4f8-f0bf3f709e4e
square(x) = x^2

# ╔═╡ 5ad54350-a4cb-4c6c-ab8b-05bc0cee7545
md"""
If the condition is true, a `Pass` is returned:
"""

# ╔═╡ 2f7114a8-29aa-43fc-9523-ddd347dd58b3
@test square(5) == 25

# ╔═╡ 93c8755a-e2fc-4436-8134-21a647078963
md"""
If the condition is false, the test fails. Outside of a test set, an error is thrown:

```julia-repl
julia> @test square(5) == 20
Test Failed at REPL[3]:1
  Expression: square(5) == 20
   Evaluated: 25 == 20

ERROR: There was an error during testing
```

## Working with test sets

The `@testset` macro can be used to group [tests into sets](https://docs.julialang.org/en/v1/stdlib/Test/#Working-with-Test-Sets). All the tests in a test set will be run, and at the end of the test set a summary will be printed. If any of the tests failed, or could not be evaluated due to an error, the test set will then throw a `TestSetException`.
"""

# ╔═╡ 5b989454-f8ec-4d6d-ae7f-4c2ce7f4b12a
@testset "trigonometric identities" begin
	θ = 2/3*π
	@test sin(-θ) ≈ -sin(θ)
	@test cos(-θ) ≈ cos(θ)
	@test sin(2θ) ≈ 2*sin(θ)*cos(θ)
	@test cos(2θ) ≈ cos(θ)^2 - sin(θ)^2
end;

# ╔═╡ f146fd93-92a8-4b13-8bcf-2a2364c8c3c6
md"""
Let's try it with our `square()` function:
"""

# ╔═╡ d6d6d862-ecc5-47b9-8b7c-2da2c0655f37
@testset "Square Tests" begin
	@test square(5) == 25
	@test square("a") == "aa"
	@test square("bb") == "bbbb"
end;

# ╔═╡ d4354677-e85b-4f60-822c-26bf54f50ac4
md"""
If one of the tests fails, e.g. because of a wrong expected value:

```julia-repl
julia> @testset "Square Tests" begin
           @test square(5) == 25
           @test square("a") == "aa"
           @test square("bb") == "bbbb"
           @test square(5) == 20
       end;
Square Tests: Test Failed at REPL[4]:5
  Expression: square(5) == 20
   Evaluated: 25 == 20

Stacktrace:
 [...]
Test Summary: | Pass  Fail  Total  Time
Square Tests  |    3     1      4  0.6s
RNG of the outermost testset: Random.Xoshiro(...)
ERROR: Some tests did not pass: 3 passed, 1 failed, 0 errored, 0 broken.
```

then the summary tells us that a test failed.

## Where to put tests and how to run them

The simplest option is to put the tests in your script, next to the tested functions. Then the tests run every time the script is executed.

However, for larger pieces of software, such as packages, this becomes unwieldy and also undesired, as we don't want the tests to run every time the code is used. In packages, tests are put into the file `test/runtests.jl`. Tests placed there are run with `test` in Pkg mode (or with `Pkg.test`), and by automated tests (CI).

For example, the tests of the [Example.jl](https://github.com/JuliaLang/Example.jl) package are:

```julia
using Test, Example

@test hello("Julia") == "Hello, Julia"
@test domath(2.0) ≈ 7.0
```

and running them gives:

```julia-repl
julia> using Pkg

julia> Pkg.test("Example")
     Testing Example
      Status `/private/var/folders/.../jl_2NfqB2/Project.toml`
  [7876af07] Example v0.5.5
  [8dfed614] Test v1.11.0
  [...]
     Testing Running tests...
     Testing Example tests passed
```

## Wrapping up

- The `Test` module provides simple _unit testing_ functionality.
- Tests can be grouped into sets using `@testset`.
- We'll later see how tests can be used in CI.
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
CairoMakie = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
PlutoTeachingTools = "661c6b06-c737-4d37-b85c-46df65de6f69"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
ProgressLogging = "33c8b6b6-d38a-422a-b730-caa89a2f386c"
Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[compat]
BenchmarkTools = "~1.8.0"
CairoMakie = "~0.15.15"
PlutoTeachingTools = "~0.4.7"
PlutoUI = "~0.7.83"
ProgressLogging = "~0.1.6"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.12.7"
manifest_format = "2.0"
project_hash = "c3e420a3e3d53a11f460636348be6729359f592e"

[[deps.AbstractFFTs]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "d92ad398961a3ed262d8bf04a1a2b8340f915fef"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.5.0"
weakdeps = ["ChainRulesCore", "Test"]

    [deps.AbstractFFTs.extensions]
    AbstractFFTsChainRulesCoreExt = "ChainRulesCore"
    AbstractFFTsTestExt = "Test"

[[deps.AbstractPlutoDingetjes]]
git-tree-sha1 = "e71ee7b4aa06b045259a7d6101e1cb45ad140bce"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.4.1"

[[deps.AbstractTrees]]
git-tree-sha1 = "2d9c9a55f9c93e8887ad391fbae72f8ef55e1177"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.4.5"

[[deps.Accessors]]
deps = ["CompositionsBase", "ConstructionBase", "Dates", "InverseFunctions", "MacroTools"]
git-tree-sha1 = "7063ad1083578215c7c4bf410368150abe8d5524"
uuid = "7d9f7c33-5ae7-4f3b-8dc6-eff91059b697"
version = "0.1.45"

    [deps.Accessors.extensions]
    AxisKeysExt = "AxisKeys"
    IntervalSetsExt = "IntervalSets"
    LinearAlgebraExt = "LinearAlgebra"
    StaticArraysExt = "StaticArrays"
    StructArraysExt = "StructArrays"
    TestExt = "Test"
    UnitfulExt = "Unitful"

    [deps.Accessors.weakdeps]
    AxisKeys = "94b1ba4f-4ee9-5380-92f1-94cde586c3c5"
    IntervalSets = "8197267c-284f-5f27-9208-e0e47529a953"
    LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"
    StructArrays = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
    Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[[deps.Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "7c2c19b5a26e601634bf718490b89d59685f122e"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "4.7.1"
weakdeps = ["SparseArrays", "StaticArrays"]

    [deps.Adapt.extensions]
    AdaptSparseArraysExt = "SparseArrays"
    AdaptStaticArraysExt = "StaticArrays"

[[deps.AdaptivePredicates]]
git-tree-sha1 = "7e651ea8d262d2d74ce75fdf47c4d63c07dba7a6"
uuid = "35492f91-a3bd-45ad-95db-fcad7dcfedb7"
version = "1.2.0"

[[deps.AliasTables]]
deps = ["PtrArrays", "Random"]
git-tree-sha1 = "9876e1e164b144ca45e9e3198d0b689cadfed9ff"
uuid = "66dad0bd-aa9a-41b7-9441-69ab47430ed8"
version = "1.1.3"

[[deps.Animations]]
deps = ["Colors"]
git-tree-sha1 = "e092fa223bf66a3c41f9c022bd074d916dc303e7"
uuid = "27a7e980-b3e6-11e9-2bcd-0b925532e340"
version = "0.4.2"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Automa]]
deps = ["PrecompileTools", "TranscodingStreams"]
git-tree-sha1 = "94eab0b3ccdcac361188cc661daf69d4433c1818"
uuid = "67c07d97-cdcb-5c2c-af73-a7f9c32a568b"
version = "1.2.0"

[[deps.AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "01b8ccb13d68535d73d2b0c23e39bd23155fb712"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.1.0"

[[deps.AxisArrays]]
deps = ["Dates", "IntervalSets", "IterTools", "RangeArrays"]
git-tree-sha1 = "4126b08903b777c88edf1754288144a0492c05ad"
uuid = "39de3d68-74b9-583c-8d2d-e117c070f3a9"
version = "0.4.8"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.BaseDirs]]
git-tree-sha1 = "8c290a1b223deaeea9aea44b235d24546da8eb98"
uuid = "18cc8868-cbac-4acf-b575-c8ff214dc66f"
version = "1.4.0"

[[deps.BenchmarkTools]]
deps = ["Compat", "JSON", "Logging", "PrecompileTools", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "9670d3febc2b6da60a0ae57846ba74670290653f"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.8.0"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1b96ea4a01afe0ea4090c5c8039690672dd13f2e"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.9+0"

[[deps.CEnum]]
git-tree-sha1 = "389ad5c84de1ae7cf0e28e381131c98ea87d54fc"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.5.0"

[[deps.CRC32c]]
uuid = "8bf52ea8-c179-5cab-976a-9e18b702a9bc"
version = "1.11.0"

[[deps.CRlibm]]
deps = ["CRlibm_jll"]
git-tree-sha1 = "66188d9d103b92b6cd705214242e27f5737a1e5e"
uuid = "96374032-68de-5a5b-8d9e-752f78720389"
version = "1.0.2"

[[deps.CRlibm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e329286945d0cfc04456972ea732551869af1cfc"
uuid = "4e9b3aee-d8a1-5a3d-ad8b-7d824db253f0"
version = "1.0.1+0"

[[deps.Cairo]]
deps = ["Cairo_jll", "Colors", "Glib_jll", "Graphics", "Libdl", "Pango_jll"]
git-tree-sha1 = "71aa551c5c33f1a4415867fe06b7844faadb0ae9"
uuid = "159f3aea-2a34-519c-b102-8c37f9878175"
version = "1.1.1"

[[deps.CairoMakie]]
deps = ["CRC32c", "Cairo", "Cairo_jll", "Colors", "FileIO", "FreeType", "GeometryBasics", "LinearAlgebra", "Makie", "PrecompileTools"]
git-tree-sha1 = "1cda0b7d5abfc95357dae18aca934d401f7869ad"
uuid = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
version = "0.15.15"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "Libdl", "Pixman_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "1fa950ebc3e37eccd51c6a8fe1f92f7d86263522"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.18.7+0"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra"]
git-tree-sha1 = "12177ad6b3cad7fd50c8b3825ce24a99ad61c18f"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.26.1"
weakdeps = ["SparseArrays"]

    [deps.ChainRulesCore.extensions]
    ChainRulesCoreSparseArraysExt = "SparseArrays"

[[deps.CodecZstd]]
deps = ["TranscodingStreams", "Zstd_jll"]
git-tree-sha1 = "da54a6cd93c54950c15adf1d336cfd7d71f51a56"
uuid = "6b39b394-51ab-5f42-8807-6242bab2b4c2"
version = "0.8.7"

[[deps.ColorBrewer]]
deps = ["Colors", "JSON"]
git-tree-sha1 = "07da79661b919001e6863b81fc572497daa58349"
uuid = "a2cac450-b92f-5266-8821-25eda20663c8"
version = "0.4.2"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "b0fd3f56fa442f81e0a47815c92245acfaaa4e34"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.31.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "61761f58648aa7217445f24f841839b78c712232"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.12.3"
weakdeps = ["StyledStrings"]

    [deps.ColorTypes.extensions]
    StyledStringsExt = "StyledStrings"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "Requires", "Statistics", "TensorCore"]
git-tree-sha1 = "8b3b6f87ce8f65a2b4f857528fd8d70086cd72b1"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.11.0"
weakdeps = ["SpecialFunctions"]

    [deps.ColorVectorSpace.extensions]
    SpecialFunctionsExt = "SpecialFunctions"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "Reexport"]
git-tree-sha1 = "291665b547f137df070e4dd83e432b5fee8cc4a0"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.13.2"

[[deps.CommonSolve]]
deps = ["PrecompileTools"]
git-tree-sha1 = "6c389fa857f6ca5a95474b52a52023fd77f24cb7"
uuid = "38540f10-b2f7-11e9-35d8-d573e4eb0ff2"
version = "0.2.14"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "9d8a54ce4b17aa5bdce0ea5c34bc5e7c340d16ad"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.18.1"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.3.1+2"

[[deps.CompositionsBase]]
git-tree-sha1 = "802bb88cd69dfd1509f6670416bd4434015693ad"
uuid = "a33af91c-f02d-484b-be07-31d278c5ca2b"
version = "0.1.2"
weakdeps = ["InverseFunctions"]

    [deps.CompositionsBase.extensions]
    CompositionsBaseInverseFunctionsExt = "InverseFunctions"

[[deps.ComputePipeline]]
deps = ["Observables", "Preferences"]
git-tree-sha1 = "7bc84b769c1d384315e7b5c4ac03a6c303e6cf35"
uuid = "95dc2771-c249-4cd0-9c9f-1f3b4330693c"
version = "0.1.8"

[[deps.ConstructionBase]]
git-tree-sha1 = "b4b092499347b18a015186eae3042f72267106cb"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.6.0"
weakdeps = ["IntervalSets", "LinearAlgebra", "StaticArrays"]

    [deps.ConstructionBase.extensions]
    ConstructionBaseIntervalSetsExt = "IntervalSets"
    ConstructionBaseLinearAlgebraExt = "LinearAlgebra"
    ConstructionBaseStaticArraysExt = "StaticArrays"

[[deps.Contour]]
git-tree-sha1 = "439e35b0b36e2e5881738abc8857bd92ad6ff9a8"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.3"

[[deps.CoreMath]]
deps = ["CoreMath_jll"]
git-tree-sha1 = "8c0480f92b1b1796239156a1b9b1bfb1b39499b4"
uuid = "b7a15901-be09-4a0e-87d2-2e66b0e09b5a"
version = "0.1.0"

[[deps.CoreMath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a692a4c1dc59a4b8bc0b6403876eb3250fde2bc3"
uuid = "a38c48d9-6df1-5ac9-9223-b6ada3b5572b"
version = "0.1.0+0"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataStructures]]
deps = ["OrderedCollections"]
git-tree-sha1 = "b0bc6d2cad1fed8b7fd59a1551a991cb3d2809e6"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.19.6"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.DelaunayTriangulation]]
deps = ["AdaptivePredicates", "EnumX", "ExactPredicates", "Random"]
git-tree-sha1 = "4ac548adcad90c1d5d677af13568a748af4c952b"
uuid = "927a84f5-c5f4-47a5-9785-b46e178433df"
version = "1.6.7"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"
version = "1.11.0"

[[deps.Distributions]]
deps = ["AliasTables", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "Roots", "SpecialFunctions", "Statistics", "StatsAPI", "StatsBase", "StatsFuns"]
git-tree-sha1 = "a958ab3a40c755563f5e1405c0846cb0446bf19d"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.131"

    [deps.Distributions.extensions]
    DistributionsChainRulesCoreExt = "ChainRulesCore"
    DistributionsDensityInterfaceExt = "DensityInterface"
    DistributionsSparseConnectivityTracerExt = "SparseConnectivityTracer"
    DistributionsTestExt = "Test"

    [deps.Distributions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    DensityInterface = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
    SparseConnectivityTracer = "9f842d2f-2579-4b1d-911e-f412cf18a3f5"
    Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.DocStringExtensions]]
git-tree-sha1 = "7442a5dfe1ebb773c29cc2962a8980f47221d76c"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.5"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.7.0"

[[deps.EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e3290f2d49e661fbd94046d7e3726ffcb2d41053"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.4+0"

[[deps.EnumX]]
git-tree-sha1 = "c49898e8438c828577f04b92fc9368c388ac783c"
uuid = "4e289a0a-7415-4d19-859d-a7e5c4648b56"
version = "1.0.7"

[[deps.ExactPredicates]]
deps = ["IntervalArithmetic", "Random", "StaticArrays"]
git-tree-sha1 = "83231673ea4d3d6008ac74dc5079e77ab2209d8f"
uuid = "429591f6-91af-11e9-00e2-59fbe8cec110"
version = "2.2.9"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "2bfb1e047e2ad0a5ca94365340bde8005d637568"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.8.4+0"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libva_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "d9d3cd382f2c999f684e6bfa4039fcc16c153b6f"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "9.0.2+0"

[[deps.FFTA]]
deps = ["AbstractFFTs", "DocStringExtensions", "LinearAlgebra", "MuladdMacro", "Primes", "Random", "Reexport"]
git-tree-sha1 = "65e55303b72f4a567a51b174dd2c47496efeb95a"
uuid = "b86e33f2-c0db-4aa1-a6e0-ab43e668529e"
version = "0.3.1"

[[deps.FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "6621fef488e496356c9c9625d0562c12a6070819"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.20.0"

    [deps.FileIO.extensions]
    HTTPExt = "HTTP"

    [deps.FileIO.weakdeps]
    HTTP = "cd3eb016-35fb-5094-929b-558a96fad6f3"

[[deps.FilePaths]]
deps = ["FilePathsBase", "MacroTools", "Reexport"]
git-tree-sha1 = "a1b2fbfe98503f15b665ed45b3d149e5d8895e4c"
uuid = "8fc22ac5-c921-52a6-82fd-178b2807b824"
version = "0.9.0"

    [deps.FilePaths.extensions]
    FilePathsGlobExt = "Glob"
    FilePathsURIParserExt = "URIParser"
    FilePathsURIsExt = "URIs"

    [deps.FilePaths.weakdeps]
    Glob = "c27321d9-0574-5035-807b-f59d2c89b15c"
    URIParser = "30578b45-9adc-5946-b283-645ec420af67"
    URIs = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"

[[deps.FilePathsBase]]
deps = ["Compat", "Dates"]
git-tree-sha1 = "3bab2c5aa25e7840a4b065805c0cdfc01f3068d2"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.24"
weakdeps = ["Mmap", "Test"]

    [deps.FilePathsBase.extensions]
    FilePathsBaseMmapExt = "Mmap"
    FilePathsBaseTestExt = "Test"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FillArrays]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "086b5fbd032baf544678cc15b52b015e4c4aceb8"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "1.17.1"
weakdeps = ["PDMats", "SparseArrays", "StaticArrays", "Statistics"]

    [deps.FillArrays.extensions]
    FillArraysPDMatsExt = "PDMats"
    FillArraysSparseArraysExt = "SparseArrays"
    FillArraysStaticArraysExt = "StaticArrays"
    FillArraysStatisticsExt = "Statistics"

[[deps.FixedPointNumbers]]
deps = ["Random", "Statistics"]
git-tree-sha1 = "59af96b98217c6ef4ae0dfe065ac7c20831d1a84"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.6"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Zlib_jll"]
git-tree-sha1 = "f85dac9a96a01087df6e3a749840015a0ca3817d"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.17.1+0"

[[deps.Format]]
git-tree-sha1 = "9c68794ef81b08086aeb32eeaf33531668d5f5fc"
uuid = "1fa38f19-a742-5d3f-a2b9-30dd87b9d5f8"
version = "1.3.7"

[[deps.FreeType]]
deps = ["CEnum", "FreeType2_jll"]
git-tree-sha1 = "907369da0f8e80728ab49c1c7e09327bf0d6d999"
uuid = "b38be410-82b0-50bf-ab77-7b57e271db43"
version = "4.1.1"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "70329abc09b886fd2c5d94ad2d9527639c421e3e"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.14.3+1"

[[deps.FreeTypeAbstraction]]
deps = ["BaseDirs", "ColorVectorSpace", "Colors", "FreeType", "GeometryBasics", "Mmap"]
git-tree-sha1 = "4ebb930ef4a43817991ba35db6317a05e59abd11"
uuid = "663a7486-cb36-511b-a19d-713bb74d65c9"
version = "0.10.8"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "7a214fdac5ed5f59a22c2d9a885a16da1c74bbc7"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.17+0"

[[deps.Gamma]]
deps = ["LogExpFunctions"]
git-tree-sha1 = "becc397f7cfb06e343496ae6ffb04818a851da51"
uuid = "a0844989-3bd2-4988-8bea-c9407ab0941b"
version = "1.2.0"

[[deps.GeometryBasics]]
deps = ["EarCut_jll", "LinearAlgebra", "PrecompileTools", "Random", "StaticArrays"]
git-tree-sha1 = "ec46c5825710fa1a15d468acb2d93cc939a7a5fe"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.5.13"

    [deps.GeometryBasics.extensions]
    ExtentsExt = "Extents"
    GeometryBasicsGeoInterfaceExt = "GeoInterface"
    IntervalSetsExt = "IntervalSets"

    [deps.GeometryBasics.weakdeps]
    Extents = "411431e0-e8b7-467b-b5e0-f676ba4f2910"
    GeoInterface = "cf35fbd7-0cd7-5166-be24-54bfbe79505f"
    IntervalSets = "8197267c-284f-5f27-9208-e0e47529a953"

[[deps.GettextRuntime_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll"]
git-tree-sha1 = "45288942190db7c5f760f59c04495064eedf9340"
uuid = "b0724c58-0f36-5564-988d-3bb0596ebc4a"
version = "0.22.4+0"

[[deps.Ghostscript_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Zlib_jll"]
git-tree-sha1 = "38044a04637976140074d0b0621c1edf0eb531fd"
uuid = "61579ee1-b43e-5ca0-a5da-69d92c66a64b"
version = "9.55.1+0"

[[deps.Giflib_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a3efbbc027441271444dcd0c0a46f2d119dc4329"
uuid = "59f7168a-df46-5410-90c8-f2779963d0ec"
version = "6.1.3+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "GettextRuntime_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Zlib_jll"]
git-tree-sha1 = "090526e65de8f69648ac156daae153de8b56df62"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.88.3+0"

[[deps.Graphics]]
deps = ["Colors", "LinearAlgebra", "NaNMath"]
git-tree-sha1 = "a641238db938fff9b2f60d08ed9030387daf428c"
uuid = "a2bd30eb-e257-5431-a919-1863eab51364"
version = "1.1.3"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "69ffb934a5c5b7e086a0b4fee3427db2556fba6e"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.16+0"

[[deps.GridLayoutBase]]
deps = ["GeometryBasics", "InteractiveUtils", "Observables"]
git-tree-sha1 = "ef70da5e123a06a29e2d6ddff0f09985bc226491"
uuid = "3955a311-db13-416c-9275-1d80ed98e5e9"
version = "0.11.3"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll"]
git-tree-sha1 = "9d9531a9cb63a9edc33836414e82a07e81710de2"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "100.14004.0+0"

[[deps.HypergeometricFunctions]]
deps = ["Gamma", "LinearAlgebra"]
git-tree-sha1 = "31bb6c92405c084617facc1d7ed9eb6c402d061e"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.30"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "d1a86724f81bcd184a38fd284ce183ec067d71a0"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "1.0.0"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "0ee181ec08df7d7c911901ea38baf16f755114dc"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "1.0.0"

[[deps.ImageAxes]]
deps = ["AxisArrays", "ImageBase", "ImageCore", "Reexport", "SimpleTraits"]
git-tree-sha1 = "e12629406c6c4442539436581041d372d69c55ba"
uuid = "2803e5a7-5153-5ecf-9a86-9b4c37f5f5ac"
version = "0.6.12"

[[deps.ImageBase]]
deps = ["ImageCore", "Reexport"]
git-tree-sha1 = "eb49b82c172811fd2c86759fa0553a2221feb909"
uuid = "c817782e-172a-44cc-b673-b171935fbb9e"
version = "0.1.7"

[[deps.ImageCore]]
deps = ["ColorVectorSpace", "Colors", "FixedPointNumbers", "MappedArrays", "MosaicViews", "OffsetArrays", "PaddedViews", "PrecompileTools", "Reexport"]
git-tree-sha1 = "8c193230235bbcee22c8066b0374f63b5683c2d3"
uuid = "a09fc81d-aa75-5fe9-8630-4744c3626534"
version = "0.10.5"

[[deps.ImageIO]]
deps = ["FileIO", "IndirectArrays", "JpegTurbo", "LazyModules", "Netpbm", "OpenEXR", "PNGFiles", "QOI", "Sixel", "TiffImages", "UUIDs", "WebP"]
git-tree-sha1 = "f0f005f997dfb8c5fe23920d99458a9619873893"
uuid = "82e4d734-157c-48bb-816b-45c225c6df19"
version = "0.6.10"

[[deps.ImageMetadata]]
deps = ["AxisArrays", "ImageAxes", "ImageBase", "ImageCore"]
git-tree-sha1 = "2a81c3897be6fbcde0802a0ebe6796d0562f63ec"
uuid = "bc367c6b-8a6b-528e-b4bd-a4b897500b49"
version = "0.9.10"

[[deps.Imath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "dcc8d0cd653e55213df9b75ebc6fe4a8d3254c65"
uuid = "905a6f67-0a94-5f89-b386-d35d92009cd1"
version = "3.2.2+0"

[[deps.IndirectArrays]]
git-tree-sha1 = "012e604e1c7458645cb8b436f8fba789a51b257f"
uuid = "9b13fd28-a010-5f03-acff-a1bbcff69959"
version = "1.0.0"

[[deps.Inflate]]
git-tree-sha1 = "d1b1b796e47d94588b3757fe84fbf65a5ec4a80d"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.5"

[[deps.IntegerMathUtils]]
git-tree-sha1 = "c72458f1962faeb003bf23cbdb75164fe6280906"
uuid = "18e54dd8-cb9d-406c-a71d-865a43cbb235"
version = "0.1.4"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.Interpolations]]
deps = ["Adapt", "AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "48922d06068130f87e43edef52382e6a94305ae6"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.16.3"

    [deps.Interpolations.extensions]
    InterpolationsForwardDiffExt = "ForwardDiff"
    InterpolationsUnitfulExt = "Unitful"

    [deps.Interpolations.weakdeps]
    ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[[deps.IntervalArithmetic]]
deps = ["CRlibm", "CoreMath", "MacroTools", "OpenBLASConsistentFPCSR_jll", "Printf", "Random", "RoundingEmulator"]
git-tree-sha1 = "1c531bf0f8a5c60a340926e058fd3f209b5eef5d"
uuid = "d1acc4aa-44c8-5952-acd4-ba5d80a2a253"
version = "1.0.12"

    [deps.IntervalArithmetic.extensions]
    IntervalArithmeticArblibExt = "Arblib"
    IntervalArithmeticDiffRulesExt = "DiffRules"
    IntervalArithmeticForwardDiffExt = "ForwardDiff"
    IntervalArithmeticIntervalSetsExt = "IntervalSets"
    IntervalArithmeticIrrationalConstantsExt = "IrrationalConstants"
    IntervalArithmeticLinearAlgebraExt = "LinearAlgebra"
    IntervalArithmeticMakieExt = "Makie"
    IntervalArithmeticRecipesBaseExt = "RecipesBase"
    IntervalArithmeticSparseArraysExt = "SparseArrays"

    [deps.IntervalArithmetic.weakdeps]
    Arblib = "fb37089c-8514-4489-9461-98f9c8763369"
    DiffRules = "b552c78f-8df3-52c6-915a-8e097449b14b"
    ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
    IntervalSets = "8197267c-284f-5f27-9208-e0e47529a953"
    IrrationalConstants = "92d709cd-6900-40b7-9082-c6be49f344b6"
    LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
    Makie = "ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a"
    RecipesBase = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.IntervalSets]]
git-tree-sha1 = "79d6bd28c8d9bccc2229784f1bd637689b256377"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.7.14"

    [deps.IntervalSets.extensions]
    IntervalSetsRandomExt = "Random"
    IntervalSetsRecipesBaseExt = "RecipesBase"
    IntervalSetsStatisticsExt = "Statistics"

    [deps.IntervalSets.weakdeps]
    Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
    RecipesBase = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
    Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.InverseFunctions]]
git-tree-sha1 = "a779299d77cd080bf77b97535acecd73e1c5e5cb"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.17"
weakdeps = ["Dates", "Test"]

    [deps.InverseFunctions.extensions]
    InverseFunctionsDatesExt = "Dates"
    InverseFunctionsTestExt = "Test"

[[deps.IrrationalConstants]]
git-tree-sha1 = "b2d91fe939cae05960e760110b328288867b5758"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.6"

[[deps.Isoband]]
deps = ["isoband_jll"]
git-tree-sha1 = "f9b6d97355599074dc867318950adaa6f9946137"
uuid = "f1662d9f-8043-43de-a69a-05efc1cc6ff4"
version = "0.1.1"

[[deps.IterTools]]
git-tree-sha1 = "42d5f897009e7ff2cf88db414a389e5ed1bdd023"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.10.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "7204148362dafe5fe6a273f855b8ccbe4df8173e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.8.0"

[[deps.JSON]]
deps = ["Dates", "Logging", "Parsers", "PrecompileTools", "StructUtils", "UUIDs", "Unicode"]
git-tree-sha1 = "4657a834b01ce00f2b94546095c4350617b9af2c"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "1.10.0"

    [deps.JSON.extensions]
    JSONArrowExt = ["ArrowTypes"]

    [deps.JSON.weakdeps]
    ArrowTypes = "31f734f8-188a-4ce0-8406-c8a06bd891cd"

[[deps.JpegTurbo]]
deps = ["CEnum", "FileIO", "ImageCore", "JpegTurbo_jll", "TOML"]
git-tree-sha1 = "9496de8fb52c224a2e3f9ff403947674517317d9"
uuid = "b835a17e-a41a-41e7-81f0-2f016b05efe0"
version = "0.1.6"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "037babc10853eeb8e585418922246cb97b8e5b74"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "3.2.0+1"

[[deps.JuliaSyntaxHighlighting]]
deps = ["StyledStrings"]
uuid = "ac6e5ff7-fb65-4e79-a425-ec3bc9c03011"
version = "1.12.0"

[[deps.KernelDensity]]
deps = ["Distributions", "DocStringExtensions", "FFTA", "Interpolations", "StatsBase"]
git-tree-sha1 = "9eda8292dd3268b3b7ec9df21bbfac24e177ec52"
uuid = "5ab0869b-81aa-558d-bb23-cbf5423bbe9b"
version = "0.6.12"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "059aabebaa7c82ccb853dd4a0ee9d17796f7e1bc"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.3+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "39bca05343661c347aae0bca57a5994a0bf4f08d"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "4.2.0+0"

[[deps.LLVMOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e5b100780d4d30d63b4618d7930d48af409c1772"
uuid = "1d63c593-3942-5779-bab2-d838dc0a180e"
version = "23.1.1+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f88f3ccef05a6a72a0cf0ed417c8fd68530f4ab2"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.4.1"

[[deps.Latexify]]
deps = ["Format", "Ghostscript_jll", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Requires"]
git-tree-sha1 = "df7566479bd64f20bd16b09960145e70160ffb3b"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.16.12"

    [deps.Latexify.extensions]
    DataFramesExt = "DataFrames"
    SparseArraysExt = "SparseArrays"
    SymEngineExt = "SymEngine"
    TectonicExt = "tectonic_jll"

    [deps.Latexify.weakdeps]
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    SymEngine = "123dc426-2d89-5057-bbad-38513e3affd8"
    tectonic_jll = "d7dd28d6-a5e6-559c-9131-7eb760cdacc5"

[[deps.LazyModules]]
git-tree-sha1 = "a560dd966b386ac9ae60bdd3a3d3a326062d3c3e"
uuid = "8cdb02fc-e678-4876-92c5-9defec4f444e"
version = "0.3.1"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "OpenSSL_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.15.0+0"

[[deps.LibGit2]]
deps = ["LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"
version = "1.11.0"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "OpenSSL_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.9.0+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "OpenSSL_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.3+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "c8da7e6a91781c41a863611c7e966098d783c57a"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.4.7+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "d36c21b9e7c172a44a10484125024495e2625ac0"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.7.1+1"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "be484f5c92fad0bd8acfef35fe017900b0b73809"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.18.0+0"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "cc3ad4faf30015a3e8094c9b5b7f19e85bdf2386"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.42.0+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "XZ_jll", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "aebd334d06cee9f24cea70bd19a39749daf73881"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.7.3+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "d620582b1f0cbe2c72dd1d5bd195a9ce73370ab1"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.42.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.12.0"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "b85e2797b2409570e84c4de46238c0ed5f6476ae"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "1.0.2"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"
version = "1.11.0"

[[deps.MIMEs]]
git-tree-sha1 = "c64d943587f7187e751162b3b84445bbbd79f691"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "1.1.0"

[[deps.MacroTools]]
git-tree-sha1 = "1e0228a030642014fe5cfe68c2c0a818f9e3f522"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.16"

[[deps.Makie]]
deps = ["Animations", "Base64", "CRC32c", "ColorBrewer", "ColorSchemes", "ColorTypes", "Colors", "ComputePipeline", "Contour", "Dates", "DelaunayTriangulation", "Distributions", "DocStringExtensions", "Downloads", "FFMPEG_jll", "FileIO", "FilePaths", "FixedPointNumbers", "Format", "FreeType", "FreeTypeAbstraction", "GeometryBasics", "GridLayoutBase", "ImageBase", "ImageIO", "InteractiveUtils", "Interpolations", "IntervalSets", "InverseFunctions", "Isoband", "KernelDensity", "LaTeXStrings", "LinearAlgebra", "MacroTools", "Markdown", "MathTeXEngine", "Observables", "OffsetArrays", "PNGFiles", "Packing", "Pkg", "PlotUtils", "PolygonOps", "PrecompileTools", "Printf", "REPL", "Random", "RelocatableFolders", "Scratch", "ShaderAbstractions", "SignedDistanceFields", "SparseArrays", "Statistics", "StatsBase", "StatsFuns", "StructArrays", "TriplotBase", "UnicodeFun", "Unitful"]
git-tree-sha1 = "5f6f5d1b1fb7ff98c9a083bbfd4c661a9808e758"
uuid = "ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a"
version = "0.24.15"

    [deps.Makie.extensions]
    MakieDynamicQuantitiesExt = "DynamicQuantities"

    [deps.Makie.weakdeps]
    DynamicQuantities = "06fc5a27-2a28-4c7c-a15d-362465fb6821"

[[deps.MappedArrays]]
git-tree-sha1 = "0ee4497a4e80dbd29c058fcee6493f5219556f40"
uuid = "dbb5928d-eab1-5f90-85c2-b9b0edb7c900"
version = "0.4.3"

[[deps.Markdown]]
deps = ["Base64", "JuliaSyntaxHighlighting", "StyledStrings"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.MathTeXEngine]]
deps = ["AbstractTrees", "Automa", "DataStructures", "FreeTypeAbstraction", "GeometryBasics", "LaTeXStrings", "REPL", "RelocatableFolders", "UnicodeFun"]
git-tree-sha1 = "aa1078778be5a8e5259ff04fbc3d258b3e78d464"
uuid = "0a4f8689-d25c-4efe-a92b-7142dfc1aa53"
version = "0.6.9"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "ec4f7fbeab05d7747bdf98eb74d130a2a2ed298d"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.2.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"
version = "1.11.0"

[[deps.MosaicViews]]
deps = ["MappedArrays", "OffsetArrays", "PaddedViews", "StackViews"]
git-tree-sha1 = "7b86a5d4d70a9f5cdf2dacb3cbe6d251d1a61dbe"
uuid = "e94cdb99-869f-56ef-bcf0-1ae2bcbe0389"
version = "0.3.4"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2025.11.4"

[[deps.MuladdMacro]]
deps = ["PrecompileTools"]
git-tree-sha1 = "283bf85d4a767481dd924dff0eee1735e95f449e"
uuid = "46d2c3a1-f734-5fdb-9937-b9b9aeba4221"
version = "0.2.7"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "dbd2e8cd2c1c27f0b584f6661b4309609c5a685e"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.1.4"

[[deps.Netpbm]]
deps = ["FileIO", "ImageCore", "ImageMetadata"]
git-tree-sha1 = "d92b107dbb887293622df7697a2223f9f8176fcd"
uuid = "f09324ee-3d7c-5217-9330-fc30815ba969"
version = "1.1.1"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.3.0"

[[deps.Observables]]
git-tree-sha1 = "7438a59546cf62428fc9d1bc94729146d37a7225"
uuid = "510215fc-4207-5dde-b226-833fc4488ee2"
version = "0.5.5"

[[deps.OffsetArrays]]
git-tree-sha1 = "117432e406b5c023f665fa73dc26e79ec3630151"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.17.0"
weakdeps = ["Adapt"]

    [deps.OffsetArrays.extensions]
    OffsetArraysAdaptExt = "Adapt"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "b6aa4566bb7ae78498a5e68943863fa8b5231b59"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.6+0"

[[deps.OpenBLASConsistentFPCSR_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "38a93f17e431141c6470bb67a88952a7c4f0e928"
uuid = "6cdc7f73-28fd-5e50-80fb-958a8875b1af"
version = "0.3.34+0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.29+0"

[[deps.OpenEXR]]
deps = ["Colors", "FileIO", "OpenEXR_jll"]
git-tree-sha1 = "97db9e07fe2091882c765380ef58ec553074e9c7"
uuid = "52e1d378-f018-4a11-a4be-720524705ac7"
version = "0.3.3"

[[deps.OpenEXR_jll]]
deps = ["Artifacts", "Imath_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "1bcebd887dd33f1108210b3954049b1bb8af0e7a"
uuid = "18a262bb-aa17-5467-a713-aee519bc75cb"
version = "3.4.15+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.7+0"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.5.6+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1346c9208249809840c91b26703912dff463d335"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.6+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e2bb57a313a74b8104064b7efd01406c0a50d2ff"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.6.1+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "05f45c2e0de6259db764adbfd2f1dc6d3f8de13c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "2.0.1"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.44.0+1"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "123266c25174ef6c8d4718920abc206452cf8de6"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.41"
weakdeps = ["StatsBase"]

    [deps.PDMats.extensions]
    StatsBaseExt = "StatsBase"

[[deps.PNGFiles]]
deps = ["Base64", "CEnum", "ImageCore", "IndirectArrays", "OffsetArrays", "libpng_jll"]
git-tree-sha1 = "32b657a0d57c310a1a172bfc8c8cf68c5e674323"
uuid = "f57f5aa1-a3ce-4bc8-8ab9-96f992907883"
version = "0.4.5"

[[deps.Packing]]
deps = ["GeometryBasics"]
git-tree-sha1 = "bc5bf2ea3d5351edf285a06b0016788a121ce92c"
uuid = "19eb6ba3-879d-56ad-ad62-d5c202156566"
version = "0.5.1"

[[deps.PaddedViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "0fac6313486baae819364c52b4f483450a9d793f"
uuid = "5432bcbf-9aad-5242-b902-cca2824c8663"
version = "0.5.12"

[[deps.Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1912a9f1b9ca55005b03ba075f8e19993583e237"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.58.2+0"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools"]
git-tree-sha1 = "663e8b48b789916221e0765393b289ca6c88f24e"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "3.0.0"

[[deps.Pixman_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LLVMOpenMP_jll", "Libdl"]
git-tree-sha1 = "e4a6721aa89e62e5d4217c0b21bd714263779dda"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.46.4+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.12.1"
weakdeps = ["REPL"]

    [deps.Pkg.extensions]
    REPLExt = "REPL"

[[deps.PkgVersion]]
deps = ["Pkg"]
git-tree-sha1 = "f9501cc0430a26bc3d156ae1b5b0c1b47af4d6da"
uuid = "eebad327-c553-4316-9ea0-9fa01ccd7688"
version = "0.3.3"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "PrecompileTools", "Printf", "Reexport", "Statistics"]
git-tree-sha1 = "f20e945b895d2009c6c28d8bbf40a5cd846f7c2f"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.5.0"

[[deps.PlutoTeachingTools]]
deps = ["Downloads", "HypertextLiteral", "Latexify", "Markdown", "PlutoUI"]
git-tree-sha1 = "90b41ced6bacd8c01bd05da8aed35c5458891749"
uuid = "661c6b06-c737-4d37-b85c-46df65de6f69"
version = "0.4.7"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Downloads", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "e189d0623e7ce9c37389bac17e80aac3b0302e75"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.83"

[[deps.PolygonOps]]
git-tree-sha1 = "77b3d3605fc1cd0b42d95eba87dfcd2bf67d5ff6"
uuid = "647866c9-e3ac-4575-94e7-e3d426903924"
version = "0.1.2"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "edbeefc7a4889f528644251bdb5fc9ab5348bc2c"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.3.4"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "5005266de4bfe50e53ff44a5cb5c540b6e47a254"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.6.0"

[[deps.Primes]]
deps = ["IntegerMathUtils"]
git-tree-sha1 = "25cdd1d20cd005b52fc12cb6be3f75faaf59bb9b"
uuid = "27ebfcd6-29c5-5fa9-bf4b-fb8fc14df3ae"
version = "0.5.7"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.Profile]]
deps = ["StyledStrings"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"
version = "1.11.0"

[[deps.ProgressLogging]]
deps = ["Logging", "SHA", "UUIDs"]
git-tree-sha1 = "f0803bc1171e455a04124affa9c21bba5ac4db32"
uuid = "33c8b6b6-d38a-422a-b730-caa89a2f386c"
version = "0.1.6"

[[deps.ProgressMeter]]
deps = ["Distributed", "Printf"]
git-tree-sha1 = "fbb92c6c56b34e1a2c4c36058f68f332bec840e7"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.11.0"

[[deps.PtrArrays]]
git-tree-sha1 = "4fbbafbc6251b883f4d2705356f3641f3652a7fe"
uuid = "43287f4e-b6f4-7ad1-bb20-aadabca52c3d"
version = "1.4.0"

[[deps.QOI]]
deps = ["ColorTypes", "FileIO", "FixedPointNumbers"]
git-tree-sha1 = "472daaa816895cb7aee81658d4e7aec901fa1106"
uuid = "4b34888f-f399-49d4-9bb3-47ed5cae4e65"
version = "1.0.2"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "5e8e8b0ab68215d7a2b14b9921a946fee794749e"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.11.3"

    [deps.QuadGK.extensions]
    QuadGKEnzymeExt = "Enzyme"

    [deps.QuadGK.weakdeps]
    Enzyme = "7da242da-08ed-463a-9acd-ee780be4f1d9"

[[deps.REPL]]
deps = ["InteractiveUtils", "JuliaSyntaxHighlighting", "Markdown", "Sockets", "StyledStrings", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.RangeArrays]]
git-tree-sha1 = "b9039e93773ddcfc828f12aadf7115b4b4d225f5"
uuid = "b3c3ace0-ae52-54e7-9d0b-2c1406fd6b9d"
version = "0.3.2"

[[deps.Ratios]]
deps = ["Requires"]
git-tree-sha1 = "1342a47bf3260ee108163042310d26f2be5ec90b"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.5"
weakdeps = ["FixedPointNumbers"]

    [deps.Ratios.extensions]
    RatiosFixedPointNumbersExt = "FixedPointNumbers"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "ffdaf70d81cf6ff22c2b6e733c900c3321cab864"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.1"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "62389eeff14780bfe55195b7204c0d8738436d64"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.1"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "5b3d50eb374cea306873b371d3f8d3915a018f0b"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.9.0"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6d40b2fe70437b01397d2a4d5b020008da4e7019"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.5.2+0"

[[deps.Roots]]
deps = ["Accessors", "CommonSolve", "Printf"]
git-tree-sha1 = "a700562d106889a6e103b0d4db2a14f94c43db0c"
uuid = "f2b01f46-fcfa-551c-844a-d8ac1e96c665"
version = "3.0.9"

    [deps.Roots.extensions]
    RootsChainRulesCoreExt = "ChainRulesCore"
    RootsForwardDiffExt = "ForwardDiff"
    RootsIntervalRootFindingExt = "IntervalRootFinding"
    RootsSymPyExt = "SymPy"
    RootsSymPyPythonCallExt = "SymPyPythonCall"
    RootsUnitfulExt = "Unitful"

    [deps.Roots.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
    IntervalRootFinding = "d2bf35a9-74e0-55ec-b149-d360ff49b807"
    SymPy = "24249f21-da20-56a4-8eb1-6a02cf4ae2e6"
    SymPyPythonCall = "bc8888f7-b21e-4b7c-a06a-5d9c9496438c"
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[[deps.RoundingEmulator]]
git-tree-sha1 = "40b9edad2e5287e05bd413a38f61a8ff55b9557b"
uuid = "5eaf0fd0-dfba-4ccb-bf02-d820a40db705"
version = "0.2.1"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SIMD]]
deps = ["PrecompileTools"]
git-tree-sha1 = "e24dc23107d426a096d3eae6c165b921e74c18e4"
uuid = "fdea26ae-647d-5447-a871-4b548cad5224"
version = "3.7.2"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "9b81b8393e50b7d4e6d0a9f14e192294d3b7c109"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.3.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.ShaderAbstractions]]
deps = ["ColorTypes", "FixedPointNumbers", "GeometryBasics", "LinearAlgebra", "Observables", "StaticArrays"]
git-tree-sha1 = "57aa595158717ef165e6f5ab639fe2e3178c0a2b"
uuid = "65257c39-d410-5151-9873-9b3e5be5013e"
version = "0.5.1"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"
version = "1.11.0"

[[deps.SignedDistanceFields]]
deps = ["Statistics"]
git-tree-sha1 = "3949ad92e1c9d2ff0cd4a1317d5ecbba682f4b92"
uuid = "73760f76-fbc4-59ce-8f25-708e95d2df96"
version = "0.4.1"

[[deps.SimpleTraits]]
deps = ["InteractiveUtils", "MacroTools"]
git-tree-sha1 = "7ddb0b49c109481b046972c0e4ab02b2127d6a75"
uuid = "699a6c99-e7fa-54fc-8d76-47d257e15c1d"
version = "0.9.6"

[[deps.Sixel]]
deps = ["Dates", "FileIO", "ImageCore", "IndirectArrays", "OffsetArrays", "REPL", "libsixel_jll"]
git-tree-sha1 = "0494aed9501e7fb65daba895fb7fd57cc38bc743"
uuid = "45858cf5-a6b0-47a3-bbea-62219f50df47"
version = "0.1.5"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"
version = "1.11.0"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "13cd91cc9be159e3f4d95b857fa2aa383b53772a"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.3"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.12.0"

[[deps.SpecialFunctions]]
deps = ["IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "429071b23f4c9a13fb6582f807cc2ef454082408"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.9.0"
weakdeps = ["ChainRulesCore"]

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

[[deps.StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "be1cf4eb0ac528d96f5115b4ed80c26a8d8ae621"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.2"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "PrecompileTools", "Random", "StaticArraysCore"]
git-tree-sha1 = "39e70e0ab5d7f89833a62ab7c79df15d4fc417c1"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.9.22"
weakdeps = ["ChainRulesCore", "Statistics"]

    [deps.StaticArrays.extensions]
    StaticArraysChainRulesCoreExt = "ChainRulesCore"
    StaticArraysStatisticsExt = "Statistics"

[[deps.StaticArraysCore]]
git-tree-sha1 = "6ab403037779dae8c514bad259f32a447262455a"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.4"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "e2b53ce13a53367e96601081e33d34746b571bad"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.5"
weakdeps = ["SparseArrays"]

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "178ed29fd5b2a2cfc3bd31c13375ae925623ff36"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.8.0"

[[deps.StatsBase]]
deps = ["AliasTables", "DataAPI", "DataStructures", "IrrationalConstants", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "adb9da019510162e67a4493fc235c23203d8b09e"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.13"

[[deps.StatsFuns]]
deps = ["HypergeometricFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "91a5737baed20ee31f3faea0e51f57461f6a689e"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "2.2.1"
weakdeps = ["ChainRulesCore", "InverseFunctions"]

    [deps.StatsFuns.extensions]
    StatsFunsChainRulesCoreExt = "ChainRulesCore"
    StatsFunsInverseFunctionsExt = "InverseFunctions"

[[deps.StructArrays]]
deps = ["ConstructionBase", "DataAPI", "Tables"]
git-tree-sha1 = "ad8002667372439f2e3611cfd14097e03fa4bccd"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.7.3"

    [deps.StructArrays.extensions]
    StructArraysAdaptExt = "Adapt"
    StructArraysGPUArraysCoreExt = ["GPUArraysCore", "KernelAbstractions"]
    StructArraysLinearAlgebraExt = "LinearAlgebra"
    StructArraysSparseArraysExt = "SparseArrays"
    StructArraysStaticArraysExt = "StaticArrays"

    [deps.StructArrays.weakdeps]
    Adapt = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
    GPUArraysCore = "46192b85-c4d5-4398-a991-12ede77f4527"
    KernelAbstractions = "63c18a36-062a-441e-b654-da1e3ab1ce7c"
    LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.StructUtils]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "b814d5005d6a529d740ffe06f8a86396f6501138"
uuid = "ec057cc2-7a8d-4b58-b3b3-92acb9f63b42"
version = "2.9.2"

    [deps.StructUtils.extensions]
    StructUtilsLazilyInitializedFieldsExt = ["LazilyInitializedFields"]
    StructUtilsMeasurementsExt = ["Measurements"]
    StructUtilsStaticArraysCoreExt = ["StaticArraysCore"]
    StructUtilsTablesExt = ["Tables"]

    [deps.StructUtils.weakdeps]
    LazilyInitializedFields = "0e77f7df-68c5-4e49-93ce-4cd80f5598bf"
    Measurements = "eff96d63-e80a-5855-80a2-b1b0885c5ab7"
    StaticArraysCore = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
    Tables = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"

[[deps.StyledStrings]]
uuid = "f489334b-da3d-4c2e-b8f0-e476e12c162b"
version = "1.11.0"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.8.3+2"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "a94d9bdda1b7bed0046cea645639ab3f62196fac"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.14.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

[[deps.TiffImages]]
deps = ["CodecZstd", "ColorTypes", "DataStructures", "DocStringExtensions", "FileIO", "FixedPointNumbers", "IndirectArrays", "Inflate", "Mmap", "OffsetArrays", "PkgVersion", "PrecompileTools", "ProgressMeter", "SIMD", "UUIDs"]
git-tree-sha1 = "9ca5f1f2d42f80df4b8c9f6ab5a64f438bbd9976"
uuid = "731e570b-9d59-4bfa-96dc-6df516fadf69"
version = "0.11.9"

[[deps.TranscodingStreams]]
git-tree-sha1 = "0c45878dcfdcfa8480052b6ab162cdd138781742"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.11.3"

[[deps.Tricks]]
git-tree-sha1 = "311349fd1c93a31f783f977a71e8b062a57d4101"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.13"

[[deps.TriplotBase]]
git-tree-sha1 = "4d4ed7f294cda19382ff7de4c137d24d16adc89b"
uuid = "981d1d27-644d-49a2-9326-4793e63143c3"
version = "0.1.0"

[[deps.URIs]]
git-tree-sha1 = "908fec9df6c5de98548ead82a468c95ccf6cd263"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.7.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
version = "1.11.0"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unitful]]
deps = ["Dates", "LinearAlgebra", "Random"]
git-tree-sha1 = "1f0f9f401753701a7e4113b5056ca38d33875b55"
uuid = "1986cc42-f94f-5a68-af5c-568840ba703d"
version = "1.29.0"

    [deps.Unitful.extensions]
    ConstructionBaseUnitfulExt = "ConstructionBase"
    ForwardDiffExt = "ForwardDiff"
    InverseFunctionsUnitfulExt = "InverseFunctions"
    LatexifyExt = ["Latexify", "LaTeXStrings"]
    NaNMathExt = "NaNMath"
    PrintfExt = "Printf"

    [deps.Unitful.weakdeps]
    ConstructionBase = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
    ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"
    LaTeXStrings = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
    Latexify = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
    NaNMath = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
    Printf = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.WebP]]
deps = ["CEnum", "ColorTypes", "FileIO", "FixedPointNumbers", "ImageCore", "libwebp_jll"]
git-tree-sha1 = "aa1ca3c47f119fbdae8770c29820e5e6119b83f2"
uuid = "e3aaa7dc-3e4b-44e0-be63-ffb868ccd7c1"
version = "0.1.3"

[[deps.WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "248a7031b3da79a127f14e5dc5f417e26f9f6db7"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "1.1.0"

[[deps.XZ_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e52eca002a11c30a858185efdfb15311e1c7a6bf"
uuid = "ffd25f8a-64ca-5728-b0f7-c24cf3aae800"
version = "5.8.4+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "808090ede1d41644447dd5cbafced4731c56bd2f"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.8.13+0"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "aa1261ebbac3ccc8d16558ae6799524c450ed16b"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.13+0"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "52858d64353db33a56e13c341d7bf44cd0d7b309"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.6+0"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "1a4a26870bf1e5d26cd585e38038d399d7e65706"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.8+0"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "75e00946e43621e09d431d9b95818ee751e6b2ef"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "6.0.2+0"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "7ed9347888fac59a618302ee38216dd0379c480d"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.12+0"

[[deps.Xorg_libpciaccess_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "58972370b81423fc546c56a60ed1a009450177c3"
uuid = "a65dc6b1-eb27-53a1-bb3e-dea574b5389e"
version = "0.19.0+0"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXau_jll", "Xorg_libXdmcp_jll"]
git-tree-sha1 = "bfcaf7ec088eaba362093393fe11aa141fa15422"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.17.1+0"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a63799ff68005991f9d9491b6e95bd3478d783cb"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.6.0+0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.3.1+2"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "446b23e73536f84e8037f5dce465e92275f6a308"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.7+1"

[[deps.isoband_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51b5eeb3f98367157a7a12a1fb0aa5328946c03c"
uuid = "9a68df92-36a6-505f-a73e-abb412b6bfb4"
version = "0.2.3+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1210ba774d3427387d307bf1f416d699b7c39417"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.15.1+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "cb007192783c56d8249db4cf0e3495001edfe414"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.17.5+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.15.0+0"

[[deps.libdrm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libpciaccess_jll"]
git-tree-sha1 = "28e57478e8a160d346a19c28b3fffb9273bcc9c2"
uuid = "8e53e030-5e6c-5a89-a30b-be5b7263a166"
version = "2.4.134+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "646634dd19587a56ee2f1199563ec056c5f228df"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.4+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "e51150d5ab85cee6fc36726850f0e627ad2e4aba"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.58+0"

[[deps.libsixel_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "libpng_jll"]
git-tree-sha1 = "c1733e347283df07689d71d61e14be986e49e47a"
uuid = "075b6546-f08a-558a-be8f-8157d0f608a5"
version = "1.10.5+0"

[[deps.libva_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll", "Xorg_libXext_jll", "Xorg_libXfixes_jll", "libdrm_jll"]
git-tree-sha1 = "7dbf96baae3310fe2fa0df0ccbb3c6288d5816c9"
uuid = "9a156e7d-b971-5f62-b2c9-67348b8fb97c"
version = "2.23.0+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll"]
git-tree-sha1 = "11e1772e7f3cc987e9d3de991dd4f6b2602663a5"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.8+0"

[[deps.libwebp_jll]]
deps = ["Artifacts", "Giflib_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libglvnd_jll", "Libtiff_jll", "libpng_jll"]
git-tree-sha1 = "52d3b9475133c3bc8c0a7f90f18bfc8cdb5a443a"
uuid = "c5f90fcd-3b7e-5836-afba-fc50a0988cb2"
version = "1.6.1+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.64.0+1"

[[deps.p7zip_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.7.0+0"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "14cc7083fc6dff3cc44f2bc435ee96d06ed79aa7"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "10164.0.1+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e7b67590c14d487e734dcb925924c5dc43ec85f3"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "4.1.0+0"
"""

# ╔═╡ Cell order:
# ╟─00566cd7-75d3-4ba1-969a-07db5fa23fb3
# ╟─aaa6a605-de7d-4035-b0c7-9c707fb3ded8
# ╟─cb05bc04-4c01-49a6-8e40-6c0ba39646cf
# ╟─3ae26849-07cb-4f64-86e3-3eb35ffa15bc
# ╟─5baa0cfe-343b-4ef5-a635-77094c969733
# ╟─c769ee88-4d6d-48b3-b556-e3db23e387db
# ╟─805d9c4e-1ec7-4098-baae-aeeef5858d7f
# ╟─df37ce9a-8c19-46ac-b25e-44bb61cb6c59
# ╟─11abe2f1-66d8-4d47-a8af-4ff1ae22f592
# ╠═a7c0b7ad-c2ce-447c-ae02-906f49267cd7
# ╠═368a021e-cefc-4e5d-8483-8bd56804b246
# ╠═c46c7b29-af24-438b-b0be-ff41dd8c499d
# ╟─1e8d7d7d-8391-4e03-9551-dc0cb748afc5
# ╟─367a4ee5-68db-47fe-a2e1-39fb2537a5b5
# ╟─ff1df1fd-6f6b-4983-a80b-47edfd15fc98
# ╟─826cfffe-f260-40c3-a610-a3c49038eb14
# ╟─20fc4edd-ce95-4bf5-9e96-5cf01e72cdad
# ╟─f0d6a820-daa6-48f6-a487-9e4e7f638ab6
# ╟─a03dc7e7-8abe-4273-b9be-4607b86a16e6
# ╟─ebc72723-9bc9-436c-841d-ce3152536e67
# ╟─ff2ec07e-4c44-41c4-bacc-acfdda0a621e
# ╟─c93cf401-2bf1-4d02-8a24-dd41d627ae22
# ╟─44e7be6f-a432-4eae-964d-aa737b1ba01c
# ╟─de2207dd-765d-478e-9c88-3e895970987d
# ╟─bc8859ab-4a59-4566-8a11-99533b31cfb8
# ╟─58892afc-2f6e-4035-bbf9-2698861bd88d
# ╟─b8d5f6bd-b4ba-4982-8960-13bf6f01e708
# ╟─fac744fc-e7ca-4f6c-8225-db9b982bc870
# ╟─333a1a68-f525-4dcc-9e21-6b9c954926ca
# ╟─c384c0e5-30d0-4cc1-97ca-08b5bf9e5b1f
# ╟─74e07e8d-c9e2-4b42-9309-064acda33b0c
# ╟─05f468da-39f1-4d3b-b6e3-897bf32a9819
# ╟─f60fa805-d42f-4411-b76f-ea96bbf441d5
# ╟─069d4dd1-041b-4c05-a08d-181db9deb0d6
# ╟─b4b974a6-a6d0-4022-a979-4efb6066773b
# ╟─77fab6b5-7ecb-434e-8f38-1247afa80c0c
# ╟─ff3212ce-9b9d-454c-afca-e5a755945f4b
# ╟─b27f815d-27a4-4860-852a-6f52a6590d6f
# ╟─b8949c19-1ab3-4d12-b579-9ca00f7e390a
# ╟─3719f399-238d-40bc-8101-4301670e1f8d
# ╟─ff605448-cf99-4996-bbb3-c0990b9fc770
# ╟─c1303472-dffc-4a38-84c9-34fe86f41f3b
# ╟─2bfd3a58-35fa-45da-adf5-a7cd0f70dd7f
# ╟─198cbdf1-7def-47d2-ad81-7fa423331bc9
# ╠═1ff08eb1-b222-4f3a-8926-afec6d0407b5
# ╠═eb38e286-24fb-46f8-9807-1894323ddb2e
# ╠═c16e7214-6d05-40f5-b3c2-f50b3ddb766c
# ╟─1168fe04-d06f-47bb-b6b2-b145e362e3b6
# ╠═2f0a6f84-fe5d-46d2-b94d-d3153564f636
# ╟─3b0f0b56-ce06-4488-b53e-c54522ca280e
# ╠═c0fd1463-f8e0-48f7-b261-fce6d71fb014
# ╟─5b9f5205-d74b-454b-8d9d-4433f333873c
# ╠═c3c2c5d4-af9e-41b0-b4f8-f0bf3f709e4e
# ╟─5ad54350-a4cb-4c6c-ab8b-05bc0cee7545
# ╠═2f7114a8-29aa-43fc-9523-ddd347dd58b3
# ╟─93c8755a-e2fc-4436-8134-21a647078963
# ╠═5b989454-f8ec-4d6d-ae7f-4c2ce7f4b12a
# ╟─f146fd93-92a8-4b13-8bcf-2a2364c8c3c6
# ╠═d6d6d862-ecc5-47b9-8b7c-2da2c0655f37
# ╟─d4354677-e85b-4f60-822c-26bf54f50ac4
# ╟─208e62cf-2bf1-4a88-99c2-1c38a03e7ad5
# ╟─71b8e03b-6e48-42c7-b93b-99e5f2215fba
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
