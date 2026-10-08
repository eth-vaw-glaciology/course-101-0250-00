### A Pluto.jl notebook ###
# v1.0.4

#> [frontmatter]
#> chapter = "2"
#> section = "2"
#> order = "2"
#> title = "GPU computing"
#> date = "2026-10-13"
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

# ╔═╡ 18644e96-732f-58fb-af00-94304aed4912
begin
	using PlutoUI
	using PlutoTeachingTools
	TableOfContents()
end

# ╔═╡ 05ba1f91-0562-5c92-ab65-08e153b71e09
using Random

# ╔═╡ f438d61f-de97-522b-a0a1-5f190cc26c78
md"""
# GPU computing

The goal of this lecture is to become familiar with:

- The architecture of GPUs and the CUDA programming model.
- Working on a supercomputer: running Julia on the GPUs of Alps at CSCS.
- GPU array programming and kernel programming with CUDA.jl.
- Kernel fusion and data races.

In the previous lecture, we measured the performance of the steady diffusion solver with dynamic relaxation (DR), and parallelised it on all cores of a CPU. In this lecture, we will run it on a GPU.
"""

# ╔═╡ 9b52148b-be63-5e12-9d68-37c1a5490373
md"""
## GPU architecture

CPUs and GPUs are designed for different workloads:

- A CPU has a few powerful cores with large caches. It is designed to minimise the time it takes to complete a single task (the latency).
- A GPU has thousands of simpler cores. It is designed to maximise the amount of work completed per unit of time (the throughput). GPUs hide the latency of memory accesses by running many more threads than they have cores: while some threads wait for data from memory, others compute.

In this course, we use the Nvidia GH200 Grace Hopper superchip, which combines a 72-core Arm CPU (Grace) and an H100 GPU (Hopper):

- The main memory of the GPU, called global memory, holds 96 GB, with a theoretical peak memory bandwidth of 4 TB/s.
- The GPU consists of 132 streaming multiprocessors (SMs). Each SM contains the compute units, registers, and an L1 cache, part of which can be used as shared memory. All SMs share a 50 MB L2 cache.
- In GPU programming, the CPU is called the **host**, and the GPU the **device**. Host and device have separate memories. On the GH200, they are connected with a link of up to 900 GB/s (in both directions combined), several times slower than the global memory of the GPU.

!!! note
    Keep the data on the GPU. Transfers between the host memory and the device memory are much slower than accesses to the device memory.

Recall from [lecture 4](https://pde-on-gpu.vaw.ethz.ch/part2_solving_pdes_on_gpus/lecture04/#Performance-limiters) that the GH200 can perform about 68 floating-point operations per number accessed in main memory. Stencil-based PDE solvers are memory-bound on GPUs, as on CPUs, and we will evaluate their performance with the effective memory throughput ``T_\mathrm{eff}``.
"""

# ╔═╡ 7001b2a2-fca0-5fdb-a6bc-7577bd534da9
md"""
## The CUDA programming model

Nvidia GPUs are programmed with [CUDA](https://docs.nvidia.com/cuda/cuda-c-programming-guide/). In Julia, the [CUDA.jl](https://cuda.juliagpu.org/stable/) package compiles Julia functions to GPU code, and exposes the CUDA programming model.

A **kernel** is a function executed on the GPU by many threads in parallel. The threads are organised in a hierarchy:

- **Threads** are grouped into **blocks**. All threads of a block run on the same SM, and can cooperate through its shared memory.
- The blocks form the **grid**. The blocks are independent of each other: they are executed in any order, on any SM.

Blocks and grid can be 1D, 2D or 3D, which maps naturally to 1D, 2D and 3D arrays. Within a kernel, every thread computes the indices of the array elements that it processes from the following functions:

- `threadIdx()`: the index of the thread within its block;
- `blockIdx()`: the index of the block within the grid;
- `blockDim()`: the number of threads per block, i.e. the block size;
- `gridDim()`: the number of blocks in the grid.

Each of them returns a named tuple with the fields `x`, `y` and `z`, one for each dimension. As indices start at 1 in Julia, the global indices of a thread are:

```julia
ix = (blockIdx().x - 1) * blockDim().x + threadIdx().x # 1D, 2D and 3D
iy = (blockIdx().y - 1) * blockDim().y + threadIdx().y # 2D and 3D
iz = (blockIdx().z - 1) * blockDim().z + threadIdx().z # 3D
```

The figure below shows a 2D example with blocks of 4 × 3 threads and a grid of 2 × 2 blocks. In our codes, we map one thread to every cell of the grid. For example, the thread `(4, 3)` of the block `(2, 2)` computes the cell `ix = (2 - 1) * 4 + 4 = 8`, `iy = (2 - 1) * 3 + 3 = 6`.

![Relation between the CUDA grid and the finite-difference grid](https://raw.githubusercontent.com/eth-vaw-glaciology/course-101-0250-00/7856f387a3ef0656bc872878e24b12cb907f438a/lectures/part2_solving_pdes_on_gpus/assets/l5_cuda_grid.png)
"""

# ╔═╡ 01399db9-7b24-5da5-adba-a1950e670413
md"""
### Launching a kernel

The number of threads per block and the number of blocks are the **launch parameters** of a kernel. In CUDA.jl, a kernel is launched with the `@cuda` macro:

```julia
@cuda threads=nthreads blocks=nblocks kernel!(args...)
```

where `nthreads` and `nblocks` are integers in 1D, and tuples of 2 or 3 integers in 2D and 3D. Every array element needs a thread, so we compute the number of blocks with the ceiling division `cld`:

| Array size     | Threads per block       | Number of blocks                        | Indices      |
| :------------- | :---------------------- | :-------------------------------------- | :----------- |
| `nx`           | `nthreads = 256`        | `nblocks = cld(nx, nthreads)`           | `ix`         |
| `nx × ny`      | `nthreads = (32, 8)`    | `nblocks = cld.((nx, ny), nthreads)`    | `ix, iy`     |
| `nx × ny × nz` | `nthreads = (32, 4, 4)` | `nblocks = cld.((nx, ny, nz), nthreads)` | `ix, iy, iz` |

If the array size is not a multiple of the block size, the last block contains threads whose indices are out of the array bounds. The kernel must skip them with an `if` statement, e.g. in a kernel that multiplies the elements of an array by a scalar:

```julia
function scale!(A, s)
    ix = (blockIdx().x - 1) * blockDim().x + threadIdx().x
    if ix <= length(A)
        @inbounds A[ix] = s * A[ix]
    end
    return
end
```

When running this notebook in Pluto, change the array size and the number of threads per block to see which thread computes which array element:

array size `n`: $(@bind __n NumberField(1:64; default=10)) \
threads per block `nthreads`: $(@bind __nthreads NumberField(1:32; default=4))
"""

# ╔═╡ 49bdef45-79ed-51f0-be55-928e79347153
let n = __n, nthreads = __nthreads
	nblocks = cld(n, nthreads)
	rows = ["| `blockIdx().x` | `threadIdx().x` | `ix` | |",
	        "| :-: | :-: | :-: | :-- |"]
	for bx in 1:nblocks, tx in 1:nthreads
		ix = (bx - 1) * nthreads + tx
		push!(rows, "| $bx | $tx | $ix | $(ix <= n ? "computes `A[$ix]`" : "idle, `ix > n`") |")
	end
	Markdown.parse("`nblocks = cld($n, $nthreads) = $nblocks`\n\n" * join(rows, "\n"))
end

# ╔═╡ 62755132-0c7d-54fd-9762-ff670fe5247f
md"""
### Choosing the launch parameters

- A block contains at most 1024 threads, i.e. the product of the block sizes in all dimensions is at most 1024.
- The threads of a block are executed in groups of 32 threads, called **warps**. All threads of a warp execute the same instruction at the same time. Use block sizes that are multiples of 32.
- If consecutive threads of a warp access consecutive memory locations, their memory accesses are combined into a few memory transactions (**coalesced** memory access). Julia stores arrays in column-major order: map `threadIdx().x` to the first array index, as in the formulas above.
- Each SM runs several blocks at the same time. To keep all SMs busy and to hide the memory latency, a kernel needs many more threads than the GPU has compute units: for the problem sizes in this course, millions of threads.

Since the blocks are executed in any order, the threads of different blocks can't synchronise within a kernel. However, kernels launched one after another are executed in order: a kernel starts only when the previous one has completed.
"""

# ╔═╡ 6fc03af9-cdb6-52df-a008-bda1ecf75dff
md"""
## Working on a supercomputer

In this course, we run our codes on the supercomputer [Alps](https://www.cscs.ch/computers/alps) at the Swiss National Supercomputing Centre (CSCS), on the cluster **daint**. Every compute node of daint hosts 4 GH200 superchips.

A supercomputer consists of **login nodes** and **compute nodes**:

- We connect to a login node with `ssh`. The login nodes are shared by all users: use them to edit files, to work with Git, and to submit jobs, but never to run computations.
- Computations run on compute nodes, which we request from the job scheduler [SLURM](https://slurm.schedmd.com/documentation.html).

👉 Follow the steps in the section [GPU computing on Alps](https://pde-on-gpu.vaw.ethz.ch/installation/#gpu-computing-on-alps) of the Software installation page to set up your account, SSH, and Julia on daint. Do it before the class: installing and precompiling the packages takes a while.

### Software environment

On daint, Julia is provided as a user environment ([uenv](https://docs.cscs.ch/software/uenv/)). Start it after logging in:

```sh
uenv start --view=juliaup,modules julia/26.3:v1
```

### Interactive jobs

To work interactively, request a compute node with `salloc`, open a shell on it with `srun`, and start Julia:

```sh
salloc -C'gpu' -Aclass04 -N1 --time=01:00:00 # one node for one hour
srun -n1 --pty /bin/bash -l                  # shell on the compute node
julia --project                              # Julia on the compute node
```

!!! warning
    On daint, compute nodes are allocated exclusively: the node with its 4 GPUs is reserved for you until the allocation ends. Release it as soon as you are done: exit the shell on the compute node and the allocation with `exit`, or cancel the job with `scancel <jobid>`. List your jobs with `squeue --me`.

### Batch jobs

Longer runs, e.g. benchmarks, are better submitted as batch jobs with `sbatch`, which run without your terminal being connected. See [Running a remote job on Alps](https://pde-on-gpu.vaw.ethz.ch/installation/#running-a-remote-job-on-alps) for an example job script.

### Editing code and running scripts

We recommend one of two workflows:

1. **VS Code on a compute node**: run VS Code's server on the compute node through a [tunnel](https://pde-on-gpu.vaw.ethz.ch/installation/#using-vs-code-on-alps), and connect to it from VS Code on your computer. You can then edit files and use the Julia REPL on the compute node as on your computer.
2. **Terminal**: edit your scripts on the login node (e.g. with VS Code's [Remote - SSH](https://pde-on-gpu.vaw.ethz.ch/installation/#vs-code-remote---ssh-setup) extension), and run them on the compute node in the terminal, e.g. with `julia --project my_script.jl`.

There is no display on the compute nodes: save figures to files with `save("figure.png", fig)`, and open them in VS Code. Use the command `nvidia-smi` to see the GPUs of the node and their usage.

!!! tip
    Use Git to move your code between your computer, daint, and GitHub: clone your private course repository on daint, and push your changes from there.
"""

# ╔═╡ 8ba19705-2829-50a6-9e62-eef706c09c1c
md"""
## GPU programming with CUDA.jl

👉 On a compute node of daint, create a folder for this lecture, make it a Julia project, add the packages `CUDA`, `BenchmarkTools` and `CairoMakie`, and check that CUDA.jl finds the GPUs:

```julia-repl
julia> using CUDA

julia> CUDA.versioninfo()
```

### GPU arrays

The `CuArray` type represents an array in the GPU memory:

```julia
A = CUDA.zeros(Float64, nx) # array of zeros on the GPU
B = CUDA.rand(Float64, nx)  # array of random numbers on the GPU
C = CuArray(rand(nx))       # copy an array from the CPU to the GPU
c = Array(C)                # copy an array from the GPU to the CPU
```

!!! warning
    Without an explicit type, `CUDA.zeros(nx)` and `CUDA.rand(nx)` create arrays of `Float32` numbers. In this course, always specify the type: `CUDA.zeros(Float64, nx)`.

### Array programming

Broadcasting works with `CuArray`s: CUDA.jl compiles every broadcast expression to a GPU kernel. Reductions, such as `sum`, `maximum`, `mapreduce` and `dot`, also run on the GPU, and return their result to the CPU:

```julia
A .= B .+ 2 .* C     # one kernel
err = maximum(abs, A) # reduction on the GPU
```

The array programming codes of the previous lectures therefore run on GPUs after replacing `zeros` with `CUDA.zeros`. However:

- Every broadcast statement is a separate kernel, which reads its inputs from main memory and writes its outputs to main memory.
- Accessing single elements of a `CuArray` from the CPU, e.g. `A[1] = 0`, is called **scalar indexing**. It is extremely slow, as every access transfers a single number between the CPU and the GPU. CUDA.jl therefore throws an error for scalar indexing. Use broadcasting instead, e.g. `A[1:1] .= 0`. For debugging, scalar indexing can be allowed with `CUDA.@allowscalar A[1] = 0`.

### Kernel programming

Kernels give us full control over the computations performed by every thread. A kernel is a regular Julia function, which:

- computes the indices of its thread, and checks the array bounds;
- operates on single array elements: it can't allocate arrays or use broadcasting;
- returns `nothing`.

For example, a kernel that copies the array `A` to the array `B`:

```julia
function memcopy_kp!(B, A)
    ix = (blockIdx().x - 1) * blockDim().x + threadIdx().x
    if ix <= length(B)
        @inbounds B[ix] = A[ix]
    end
    return
end

nthreads = 256
nblocks  = cld(length(B), nthreads)
@cuda threads=nthreads blocks=nblocks memcopy_kp!(B, A)
```

### Synchronisation and benchmarking

Kernel launches are asynchronous: `@cuda` and broadcast statements return immediately, while the GPU is still computing. The GPU executes the kernels in the order in which they were launched, so we don't need to wait between two kernels. However, to measure the execution time, we have to wait until the GPU has completed its work, either with `CUDA.synchronize()` or by prefixing an expression with `CUDA.@sync`:

```julia
t_it = @belapsed CUDA.@sync @cuda threads=$nthreads blocks=$nblocks memcopy_kp!($B, $A)
```

Copying an array to the CPU with `Array`, and reductions, which return their result to the CPU, synchronise implicitly.

!!! warning
    To pass options to `@belapsed`, e.g. `seconds=1`, put the expression after `CUDA.@sync` in parentheses: `@belapsed CUDA.@sync(f(...)) seconds=1`. Without the parentheses, `CUDA.@sync` takes the option as its own argument, and fails.
"""

# ╔═╡ 6c6dd980-65dd-5a51-a177-3c4b764cb860
md"""
## Peak memory throughput of the GPU

As in lecture 4, we measure the peak memory throughput ``T_\mathrm{peak}`` with a memory copy. On the GPU, we compare three implementations: `copyto!`, broadcasting (`B .= A`), and the kernel `memcopy_kp!` with different numbers of threads per block. We also benchmark a **triad**, `A = B + s * C`, which reads two arrays and writes one, as many compute kernels do. The functions `memcopy_1d` and `triad_1d` return ``T_\mathrm{peak}`` in GB/s.

👉 Create the script `memcopy_1d_gpu.jl` below, and run it on a compute node of daint.
"""

# ╔═╡ 99412da1-ee08-5aad-9be6-55f44b158c07
Foldable(md"Script `memcopy_1d_gpu.jl`",
md"""
```julia
using CUDA
using BenchmarkTools
using Printf

function memcopy_kp!(B, A)
    ix = (blockIdx().x - 1) * blockDim().x + threadIdx().x
    if ix <= length(B)
        @inbounds B[ix] = A[ix]
    end
    return
end

function triad_kp!(A, B, C, s)
    ix = (blockIdx().x - 1) * blockDim().x + threadIdx().x
    if ix <= length(A)
        @inbounds A[ix] = B[ix] + s * C[ix]
    end
    return
end

function memcopy_1d(; n, nthreads=256, version=:kernel)
    A = CUDA.rand(Float64, n)
    B = CUDA.zeros(Float64, n)
    if version == :copyto
        t_it = @belapsed CUDA.@sync(copyto!($B, $A)) seconds=1
    elseif version == :broadcast
        t_it = @belapsed CUDA.@sync($B .= $A) seconds=1
    else
        nblocks = cld(n, nthreads)
        t_it = @belapsed CUDA.@sync(@cuda threads=$nthreads blocks=$nblocks memcopy_kp!($B, $A)) seconds=1
    end
    T_peak = 2 * n * sizeof(Float64) / t_it / 1e9
    @printf("%-9s n = %9d, nthreads = %4s: T_peak = %7.1f GB/s\n", version, n, version == :kernel ? nthreads : "-", T_peak)
    return T_peak
end

function triad_1d(; n, nthreads=256)
    A = CUDA.zeros(Float64, n)
    B = CUDA.rand(Float64, n)
    C = CUDA.rand(Float64, n)
    s = rand()
    nblocks = cld(n, nthreads)
    t_it = @belapsed CUDA.@sync(@cuda threads=$nthreads blocks=$nblocks triad_kp!($A, $B, $C, $s)) seconds=1
    T_peak = 3 * n * sizeof(Float64) / t_it / 1e9
    @printf("triad     n = %9d, nthreads = %4d: T_peak = %7.1f GB/s\n", n, nthreads, T_peak)
    return T_peak
end

# array size
for p in 16:4:28
    memcopy_1d(; n=2^p, version=:copyto)
end
# implementations and block size
n = 2^28
memcopy_1d(; n, version=:broadcast)
for nthreads in (1, 32, 64, 128, 256, 1024)
    memcopy_1d(; n, nthreads)
end
triad_1d(; n)
```
""")

# ╔═╡ e861a1d0-25ca-5c52-841d-5516a1177cf6
md"""
On a GH200 of daint, we measured (in GB/s):

| Array size `n` | `copyto!` |
| :------------- | :-------: |
| `2^16`         | TBD       |
| `2^20`         | TBD       |
| `2^24`         | TBD       |
| `2^28`         | TBD       |

| Implementation, `n = 2^28`             | ``T_\mathrm{peak}`` |
| :------------------------------------- | :-----------------: |
| `B .= A`                               | TBD                 |
| `memcopy_kp!`, 1 thread per block      | TBD                 |
| `memcopy_kp!`, 32 threads per block    | TBD                 |
| `memcopy_kp!`, 64 threads per block    | TBD                 |
| `memcopy_kp!`, 128 threads per block   | TBD                 |
| `memcopy_kp!`, 256 threads per block   | TBD                 |
| `memcopy_kp!`, 1024 threads per block  | TBD                 |
| `triad_kp!`, 256 threads per block     | TBD                 |

What do you observe? How do the results depend on the array size and on the number of threads per block?
"""

# ╔═╡ 033f12da-8325-5ad8-8e03-26d32497ee0f
Foldable(md"Discussion",
md"""
- For small arrays, the execution time is dominated by the overhead of launching the kernel, a few microseconds, and the measured throughput is low. The GPU reaches ``T_\mathrm{peak}`` only for arrays of hundreds of megabytes, much larger than the L2 cache.
- With 1 thread per block, every warp has a single active thread out of 32, and the memory accesses are not coalesced: the throughput is far below ``T_\mathrm{peak}``. From about 64–128 threads per block, the kernel is as fast as `copyto!`.
- The measured ``T_\mathrm{peak}`` is about TBD % of the theoretical peak memory bandwidth of 4000 GB/s.
""")

# ╔═╡ b84b1cdf-e77d-5e07-8084-19bfb67ea468
md"""
## Porting the DR solver to the GPU

We now port the multi-threaded DR solver from lecture 4 to the GPU, using kernel programming. Each compute function becomes a kernel, in which the loop over the grid cells is replaced by the index of the thread.

👉 Duplicate the script `elliptic_1d_dr_perf_loop_fun.jl` from lecture 4, and rename the copy to `elliptic_1d_dr_gpu.jl`. Replace `using AcceleratedKernels` with `using CUDA`, and follow the steps below.

### 1. Arrays on the GPU

Allocate the arrays on the GPU with `CUDA.zeros(Float64, ...)`, and copy the diffusion coefficient to the GPU:

```julia
λ = CuArray(@. λbg + λamp * exp(-(xv-lx/2)^2))
```

The preconditioner `Q` is computed by broadcasting from `λ`, so it ends up on the GPU without changes.

### 2. Compute functions become kernels

For example, the function `update_d!` becomes:

```julia
function update_d!(d, z, β)
    ix = (blockIdx().x - 1) * blockDim().x + threadIdx().x
    if ix <= length(d)
        @inbounds d[ix] = d[ix] * β + z[ix]
    end
    return
end
```

👉 Rewrite the functions `update_u!`, without the boundary conditions, and `precondition!` in the same way.

The function `compute_r!` contains two loops: the second one computes `r[ix]` from `qx[ix]` and `qx[ix+1]`. In a kernel, `qx[ix+1]` is computed by another thread, possibly in another block, and we can't make sure that it is already computed. We therefore split `compute_r!` into two kernels: `compute_q!` computes the flux, and `compute_r!` the residual. The second kernel starts only when the first one has completed.

👉 Implement the kernels `compute_q!(qx, u, λ, _dx)` and `compute_r!(r, qx, _dx)`.
"""

# ╔═╡ a8afb68c-d38d-50ee-932d-3e9685633195
answer_box(
md"""
```julia
function update_u!(u, d, α)
    ix = (blockIdx().x - 1) * blockDim().x + threadIdx().x
    if ix <= length(d)
        @inbounds u[ix+1] += α * d[ix]
    end
    return
end

function compute_q!(qx, u, λ, _dx)
    ix = (blockIdx().x - 1) * blockDim().x + threadIdx().x
    if ix <= length(qx)
        @inbounds qx[ix] = -λ[ix] * @d_xa(u) * _dx
    end
    return
end

function compute_r!(r, qx, _dx)
    ix = (blockIdx().x - 1) * blockDim().x + threadIdx().x
    if ix <= length(r)
        @inbounds r[ix] = -@d_xa(qx) * _dx
    end
    return
end

function precondition!(z, r, Q)
    ix = (blockIdx().x - 1) * blockDim().x + threadIdx().x
    if ix <= length(z)
        @inbounds z[ix] = Q[ix] * r[ix]
    end
    return
end
```
""")

# ╔═╡ 22ab774d-4b11-5f71-8d8e-4029094ab0fc
md"""
### 3. Boundary conditions

The kernel `update_u!` only updates the inner grid points, so the boundary values never change. We can therefore set them once, before the iteration loop. Setting `u[1] = 0` would be scalar indexing; use broadcasting instead:

```julia
# boundary conditions
u[1:1]     .= 0
u[end:end] .= 1
```

### 4. The ``\beta`` update

CUDA.jl implements `mapreduce` on the GPU. 👉 In the function `compute_β`, replace `AcceleratedKernels.mapreduce` with `mapreduce`. Saving `z` to `z0` (`@. z0 = z`) and the convergence check (`maximum(abs, r)`) work on GPU arrays without changes.

### 5. Launching the kernels

👉 Define the launch parameters in the `# numerics` section:

```julia
nthreads = 256
nblocks  = cld(nx, nthreads)
```

and launch the kernels in the iteration loop and in the function `compute!` with `@cuda threads=nthreads blocks=nblocks`, e.g.:

```julia
@cuda threads=nthreads blocks=nblocks update_u!(u, d, α)
```

All arrays have at most `nx` elements, so we can use the same launch parameters for all kernels: the bounds checks skip the extra threads. Add `nthreads` and `nblocks` to the arguments of `compute!`.

### 6. Timing and visualisation

- Synchronise before reading the timer: replace `t_tic = Base.time()` at iteration 11 with `CUDA.synchronize(); t_tic = Base.time()`, and add `CUDA.synchronize()` after the iteration loop.
- Benchmark one iteration with `@belapsed CUDA.@sync compute!(...)`.
- Copy the solution to the CPU for plotting: `lines!(ax[1], xc, Array(u); color=:red)`.

Run the script on a compute node of daint. The solver converges in the same number of iterations as on the CPU.
"""

# ╔═╡ fa24286f-9f01-5ec6-92f4-f434e6b0084e
answer_box(
md"""
```julia
using CairoMakie
using Printf
using BenchmarkTools
using CUDA

macro d_xa(A) esc(:( $A[ix+1] - $A[ix] )) end

function update_u!(u, d, α)
    ix = (blockIdx().x - 1) * blockDim().x + threadIdx().x
    if ix <= length(d)
        @inbounds u[ix+1] += α * d[ix]
    end
    return
end

function compute_q!(qx, u, λ, _dx)
    ix = (blockIdx().x - 1) * blockDim().x + threadIdx().x
    if ix <= length(qx)
        @inbounds qx[ix] = -λ[ix] * @d_xa(u) * _dx
    end
    return
end

function compute_r!(r, qx, _dx)
    ix = (blockIdx().x - 1) * blockDim().x + threadIdx().x
    if ix <= length(r)
        @inbounds r[ix] = -@d_xa(qx) * _dx
    end
    return
end

function precondition!(z, r, Q)
    ix = (blockIdx().x - 1) * blockDim().x + threadIdx().x
    if ix <= length(z)
        @inbounds z[ix] = Q[ix] * r[ix]
    end
    return
end

function compute_β(d, z, z0)
    num = mapreduce((_d, _z, _z0) -> _d * (_z - _z0), +, d, z, z0)
    den = mapreduce(*, +, d, d)
    γ = abs(num) / den
    return (1 - sqrt(γ))^2
end

function update_d!(d, z, β)
    ix = (blockIdx().x - 1) * blockDim().x + threadIdx().x
    if ix <= length(d)
        @inbounds d[ix] = d[ix] * β + z[ix]
    end
    return
end

function compute!(u, d, z, r, qx, λ, Q, α, β, _dx, nthreads, nblocks)
    @cuda threads=nthreads blocks=nblocks update_u!(u, d, α)
    @cuda threads=nthreads blocks=nblocks compute_q!(qx, u, λ, _dx)
    @cuda threads=nthreads blocks=nblocks compute_r!(r, qx, _dx)
    @cuda threads=nthreads blocks=nblocks precondition!(z, r, Q)
    @cuda threads=nthreads blocks=nblocks update_d!(d, z, β)
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
    nthreads = 256
    nblocks  = cld(nx, nthreads)
    # preprocessing
    dx   = lx / nx
    xc   = LinRange(dx/2,lx-dx/2,nx)
    xv   = LinRange(dx,lx-dx,nx-1)
    β    = 1 - 2π / nx
    _dx  = 1.0 / dx
    # array initialisation
    u    = CUDA.zeros(Float64, nx)
    λ    = CuArray(@. λbg + λamp * exp(-(xv-lx/2)^2))
    qx   = CUDA.zeros(Float64, nx-1)
    d    = CUDA.zeros(Float64, nx-2)
    r    = CUDA.zeros(Float64, nx-2)
    z    = CUDA.zeros(Float64, nx-2)
    z0   = CUDA.zeros(Float64, nx-2)
    # preconditioner
    Q    = @. dx^2 / (λ[1:end-1] + λ[2:end])
    # boundary conditions
    u[1:1]     .= 0
    u[end:end] .= 1
    # convergence history
    itr_h = Float64[]
    res_h = Float64[]
    # effective main memory access per iteration [GB]
    A_eff = (2*2 + 2) * nx * sizeof(Float64) / 1e9
    # benchmark one iteration with BenchmarkTools
    if do_bench
        α     = 0.99 * (1 + β)
        t_it  = @belapsed CUDA.@sync compute!($u, $d, $z, $r, $qx, $λ, $Q, $α, $β, $_dx, $nthreads, $nblocks)
        T_eff = A_eff / t_it
        @printf("BenchmarkTools: t_it = %1.3e s, T_eff = %1.2f GB/s\n", t_it, T_eff)
        return
    end
    # iteration loop
    t_tic = Base.time(); niter_timed = 0
    for iter = 1:niter
        # start the timer after 10 warm-up iterations
        if iter == 11 CUDA.synchronize(); t_tic = Base.time(); niter_timed = 0 end
        niter_timed += 1
        # update solution
        α = 0.99 * (1 + β)
        @cuda threads=nthreads blocks=nblocks update_u!(u, d, α)
        # compute residual
        @cuda threads=nthreads blocks=nblocks compute_q!(qx, u, λ, _dx)
        @cuda threads=nthreads blocks=nblocks compute_r!(r, qx, _dx)
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
        @cuda threads=nthreads blocks=nblocks precondition!(z, r, Q)
        # update β
        if iter % ndrel == 0
            β = compute_β(d, z, z0)
        end
        # update search direction
        @cuda threads=nthreads blocks=nblocks update_d!(d, z, β)
    end
    # performance
    CUDA.synchronize()
    t_toc = Base.time() - t_tic
    t_it  = t_toc / niter_timed # execution time per iteration [s]
    T_eff = A_eff / t_it        # effective memory throughput [GB/s]
    @printf("Time = %1.3f s, T_eff = %1.2f GB/s (niter = %d)\n", t_toc, T_eff, niter_timed)
    # create plot
    if do_visu
        fig = Figure(size=(600, 450))
        ax  = (Axis(fig[1,1]; xlabel="x", ylabel="u", title="solution"),
               Axis(fig[2,1]; xlabel="iter/nx", ylabel="|r|",
                              yscale=log10,
                              title="convergence history",
                              limits=(0, niter/nx, 0.1εtol, 1e2)))
        plt = (lines!(ax[1], xc, Array(u); color=:red),
               lines!(ax[2], itr_h, res_h; color=:black))
        return fig
    end
    return
end

fig = elliptic_1d_dr()
save("elliptic_1d_dr_gpu.png", fig)
elliptic_1d_dr(; nx=2^26, niter=110, do_check=false, do_visu=false)
elliptic_1d_dr(; nx=2^26, do_check=false, do_visu=false, do_bench=true)
```
""")

# ╔═╡ 9911120a-5067-5337-acd6-abe95bb06d9e
md"""
!!! note
    The GPU and the CPU solvers compute the same solution, but not exactly: the reductions in `compute_β` and in the convergence check sum the numbers in a different order on the GPU, which changes the rounding errors. As in the reference tests of lecture 4, compare the results approximately, with `≈`.

On a GH200, we measured for `nx = 2^26` (in GB/s):

| Version                               | ``T_\mathrm{eff}`` |
| :------------------------------------ | :----------------: |
| `elliptic_1d_dr_gpu.jl`, manual timer | TBD                |
| `elliptic_1d_dr_gpu.jl`, `@belapsed compute!(...)` | TBD   |
| memcopy (``T_\mathrm{peak}``)         | TBD                |

That's about TBD times faster than the multi-threaded solver on the M2 Max laptop from lecture 4 (64 GB/s). Yet, ``T_\mathrm{eff}`` is still far below ``T_\mathrm{peak}``.
"""

# ╔═╡ db660ad6-ddb8-581b-832e-c8f812d591c2
md"""
## Kernel fusion

Let's count the arrays that the kernels read and write in main memory in every iteration. As in lecture 4, we count every array once per kernel: neighbouring elements, such as `u[ix]` and `u[ix+1]`, are loaded together from main memory.

| Kernel          | Reads        | Writes | Arrays |
| :-------------- | :----------- | :----- | :----: |
| `update_u!`     | `u`, `d`     | `u`    | 3      |
| `compute_q!`    | `u`, `λ`     | `qx`   | 3      |
| `compute_r!`    | `qx`         | `r`    | 2      |
| `precondition!` | `Q`, `r`     | `z`    | 3      |
| `update_d!`     | `d`, `z`     | `d`    | 3      |
| total           |              |        | 14     |

The effective memory access ``A_\mathrm{eff}`` only counts 6 arrays: the unknown fields `u` and `d` are read and written, and the known fields `λ` and `Q` are read. Therefore, ``T_\mathrm{eff}`` can reach at most 6/14 ≈ 43% of ``T_\mathrm{peak}``.

**Kernel fusion** merges several kernels into one, to avoid storing intermediate results in main memory. The flux `qx` doesn't depend on its own history: instead of storing it, we can recompute it on the fly in the kernel that computes the residual. The thread `ix` needs the fluxes on both sides of the grid point `ix + 1`:

```julia
function compute_r!(r, u, λ, _dx)
    ix = (blockIdx().x - 1) * blockDim().x + threadIdx().x
    if ix <= length(r)
        @inbounds begin
            qxW = -λ[ix  ] * (u[ix+1] - u[ix  ]) * _dx
            qxE = -λ[ix+1] * (u[ix+2] - u[ix+1]) * _dx
            r[ix] = -(qxE - qxW) * _dx
        end
    end
    return
end
```

Every flux is now computed twice, by two neighbouring threads, but floating-point operations are "for free" in memory-bound codes. The fused kernel reads `u` and `λ`, and writes `r`: 3 arrays instead of 5, i.e. 12 arrays per iteration, and an upper bound of 6/12 = 50% of ``T_\mathrm{peak}``.

👉 Duplicate `elliptic_1d_dr_gpu.jl`, rename the copy to `elliptic_1d_dr_gpu_fused.jl`, replace `compute_q!` and `compute_r!` with the fused kernel, and remove the array `qx`. Check that the solver still converges, and measure ``T_\mathrm{eff}`` for `nx = 2^26`. On a GH200, we measured ``T_\mathrm{eff}`` = TBD GB/s with the manual timer, and TBD GB/s with `@belapsed`.

Why not fuse all kernels into one? The residual at the grid point `ix + 1` depends on the updated values of `u` at the neighbouring points, which are computed by other threads, possibly in other blocks. Kernels that need results of other threads can't be fused: they need the synchronisation between two kernel launches. On the other hand, `precondition!` only uses the residual at the same grid point, and could be fused with `compute_r!`.
"""

# ╔═╡ dd789305-614c-5d15-a510-7ff31949c906
md"""
## Data races

The threads of a kernel run concurrently, in an unspecified order. A **data race** occurs if a thread reads a memory location that another thread of the same kernel writes, or if two threads write to the same location: the result then depends on the execution order of the threads. Consider three kernels with the index `ix` of an inner grid point:

```julia
A[ix] = 2 * A[ix]                            # ✅ every thread reads and writes only its own element
B[ix] = A[ix-1] - 2 * A[ix] + A[ix+1]        # ✅ A is only read, B is only written
A[ix] = A[ix-1] - 2 * A[ix] + A[ix+1]        # ❌ data race: A[ix-1] and A[ix+1] may be already updated
```

To update a stencil, write the new values to a second array, and swap the two arrays after the kernel:

```julia
@cuda threads=nthreads blocks=nblocks update!(A2, A)
A, A2 = A2, A # swaps the names of the arrays, without copying them
```

In our DR solver, `update_u!` writes `u`, but every thread reads only its own element `u[ix+1]`, and `compute_q!` reads the neighbouring values of `u`, but writes `qx`: there is no data race.

!!! note
    With array programming, the in-place update `@. A[2:end-1] = A[1:end-2] - 2 * A[2:end-1] + A[3:end]` is correct: Julia detects that the arrays on both sides of the assignment overlap, and makes a temporary copy of the right-hand side. In kernels, avoiding data races is our responsibility.

To see what can happen, let's emulate a kernel on the CPU, executing the "threads" one after another, in different orders. The function `smooth!` writes the result to a second array, the function `smooth_inplace!` updates the array in place:
"""

# ╔═╡ f1b09f77-a344-5352-9907-a400a7b11580
function smooth!(B, A, order)
	for ix in order
		B[ix] = (A[ix-1] + A[ix] + A[ix+1]) / 3
	end
	return B
end

# ╔═╡ 254fe2be-58a8-5d65-af10-0de681d65280
function smooth_inplace!(A, order)
	for ix in order
		A[ix] = (A[ix-1] + A[ix] + A[ix+1]) / 3
	end
	return A
end

# ╔═╡ 611426dd-325d-5205-8865-51bbe9fb560b
let
	A0     = [0.0, 0.0, 0.0, 3.0, 0.0, 0.0, 0.0]
	inner  = 2:length(A0)-1
	orders = [collect(inner), collect(reverse(inner)), shuffle(Xoshiro(1), inner)]
	rows   = ["| order of the threads | `smooth!` | `smooth_inplace!` |", "| :-- | :-- | :-- |"]
	for order in orders
		B = smooth!(copy(A0), A0, order)
		A = smooth_inplace!(copy(A0), order)
		push!(rows, "| `$order` | `$(round.(B; digits=2))` | `$(round.(A; digits=2))` |")
	end
	Markdown.parse(join(rows, "\n"))
end

# ╔═╡ 27cc085d-8380-5db3-854e-e50e984b4f31
md"""
With a second array, the result doesn't depend on the order of the threads. In place, every order gives a different result. On a GPU, the order changes from run to run, and the results of a kernel with a data race are not reproducible.
"""

# ╔═╡ 2a63c2d8-834b-5358-b342-e055c5281f71
md"""
## Wrapping up

- GPUs hide the memory latency by running many threads. In the CUDA programming model, the threads are grouped into blocks, which form the grid. Blocks and grid can be 1D, 2D or 3D, and every thread computes its global indices from `threadIdx()`, `blockIdx()` and `blockDim()`.
- On a supercomputer, we compute on compute nodes requested from SLURM, not on the login nodes.
- With CUDA.jl, array programming codes run on GPUs with few changes. Kernel programming gives full control over the computations of every thread. Kernel launches are asynchronous: synchronise before measuring the time.
- We ported the DR solver to the GPU. Kernel fusion reduces the number of arrays accessed in main memory, and increases ``T_\mathrm{eff}``.
- A data race occurs when a thread reads or writes memory that another thread of the same kernel writes. Write the results of stencil updates to a second array.
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
PlutoTeachingTools = "661c6b06-c737-4d37-b85c-46df65de6f69"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[compat]
PlutoTeachingTools = "~0.4.7"
PlutoUI = "~0.7.83"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.12.7"
manifest_format = "2.0"
project_hash = "45f96084c9da07a80b927f282076a566c79bb29c"

[[deps.AbstractPlutoDingetjes]]
git-tree-sha1 = "e71ee7b4aa06b045259a7d6101e1cb45ad140bce"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.4.1"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "61761f58648aa7217445f24f841839b78c712232"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.12.3"
weakdeps = ["StyledStrings"]

    [deps.ColorTypes.extensions]
    StyledStringsExt = "StyledStrings"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.3.1+2"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.7.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FixedPointNumbers]]
deps = ["Random", "Statistics"]
git-tree-sha1 = "59af96b98217c6ef4ae0dfe065ac7c20831d1a84"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.6"

[[deps.Format]]
git-tree-sha1 = "9c68794ef81b08086aeb32eeaf33531668d5f5fc"
uuid = "1fa38f19-a742-5d3f-a2b9-30dd87b9d5f8"
version = "1.3.7"

[[deps.Ghostscript_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Zlib_jll"]
git-tree-sha1 = "38044a04637976140074d0b0621c1edf0eb531fd"
uuid = "61579ee1-b43e-5ca0-a5da-69d92c66a64b"
version = "9.55.1+0"

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

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "7204148362dafe5fe6a273f855b8ccbe4df8173e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.8.0"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "037babc10853eeb8e585418922246cb97b8e5b74"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "3.2.0+1"

[[deps.JuliaSyntaxHighlighting]]
deps = ["StyledStrings"]
uuid = "ac6e5ff7-fb65-4e79-a425-ec3bc9c03011"
version = "1.12.0"

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

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "OpenSSL_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.15.0+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "OpenSSL_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.3+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.12.0"

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

[[deps.Markdown]]
deps = ["Base64", "JuliaSyntaxHighlighting", "StyledStrings"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2025.11.4"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.3.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.29+0"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.5.6+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "f9b03759e9ef463718934fbed30820b39997511e"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "2.0.2"

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

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "5005266de4bfe50e53ff44a5cb5c540b6e47a254"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.6.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "62389eeff14780bfe55195b7204c0d8738436d64"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.1"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "e2b53ce13a53367e96601081e33d34746b571bad"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.5"

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

    [deps.Statistics.weakdeps]
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.StyledStrings]]
uuid = "f489334b-da3d-4c2e-b8f0-e476e12c162b"
version = "1.11.0"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

[[deps.Tricks]]
git-tree-sha1 = "311349fd1c93a31f783f977a71e8b062a57d4101"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.13"

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

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.3.1+2"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.15.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.64.0+1"
"""

# ╔═╡ Cell order:
# ╟─f438d61f-de97-522b-a0a1-5f190cc26c78
# ╟─9b52148b-be63-5e12-9d68-37c1a5490373
# ╟─7001b2a2-fca0-5fdb-a6bc-7577bd534da9
# ╟─01399db9-7b24-5da5-adba-a1950e670413
# ╟─49bdef45-79ed-51f0-be55-928e79347153
# ╟─62755132-0c7d-54fd-9762-ff670fe5247f
# ╟─6fc03af9-cdb6-52df-a008-bda1ecf75dff
# ╟─8ba19705-2829-50a6-9e62-eef706c09c1c
# ╟─6c6dd980-65dd-5a51-a177-3c4b764cb860
# ╟─99412da1-ee08-5aad-9be6-55f44b158c07
# ╟─e861a1d0-25ca-5c52-841d-5516a1177cf6
# ╟─033f12da-8325-5ad8-8e03-26d32497ee0f
# ╟─b84b1cdf-e77d-5e07-8084-19bfb67ea468
# ╟─a8afb68c-d38d-50ee-932d-3e9685633195
# ╟─22ab774d-4b11-5f71-8d8e-4029094ab0fc
# ╟─fa24286f-9f01-5ec6-92f4-f434e6b0084e
# ╟─9911120a-5067-5337-acd6-abe95bb06d9e
# ╟─db660ad6-ddb8-581b-832e-c8f812d591c2
# ╟─dd789305-614c-5d15-a510-7ff31949c906
# ╠═f1b09f77-a344-5352-9907-a400a7b11580
# ╠═254fe2be-58a8-5d65-af10-0de681d65280
# ╠═611426dd-325d-5205-8865-51bbe9fb560b
# ╟─27cc085d-8380-5db3-854e-e50e984b4f31
# ╟─2a63c2d8-834b-5358-b342-e055c5281f71
# ╟─18644e96-732f-58fb-af00-94304aed4912
# ╟─05ba1f91-0562-5c92-ab65-08e153b71e09
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
