---
title: "xPU computing"
tags: ["module2"]
date: "2026-10-20"
order: 3
chapter: 2
section: 3
layout: "md.jlmd"
toc: true
---

<!--
Note for editors: PlutoPages interpolates this page as a HypertextLiteral (@htl) string, and then parses it as Markdown with CommonMark.jl. Therefore:
- write \\ for a backslash, e.g. \\mathrm in LaTeX or \\n in strings;
- write \$ for a dollar sign;
- a less-than sign that is not followed by a letter, e.g. in comparisons in code, breaks HypertextLiteral: write it as \$(HTML("<")) without the backslash.
-->

# xPU computing

The goal of this lecture is to become familiar with:

- Backend-portable (xPU) programming with ParallelStencil.jl: a single code that runs on both CPUs and GPUs.
- Stencil computations with math-close notation (`@parallel`) and with explicit kernel programming (`@parallel_indices`).
- Solving the elliptic problem in 2D and 3D with dynamic relaxation (DR).
- Unit and reference tests of a Julia package, and continuous integration (CI) with GitHub Actions.

In lecture 4, we parallelised the DR solver for the steady diffusion equation on the CPU with multi-threading, and in lecture 5, we ported it to the GPU with CUDA.jl. We now have two versions of the same solver, which we have to maintain separately. As we saw in [lecture 1](https://pde-on-gpu.vaw.ethz.ch/part1_introduction/lecture01/#Why-Julia?), Julia solves the two-language problem: the same high-level language serves for prototyping and for high-performance production codes. With the ParallelStencil.jl package, we can go one step further and write a single code that runs on both CPUs and GPUs, which we call an **xPU** code. We can then prototype and debug on the CPU of a laptop, and switch to GPUs for production runs.

In this lecture, we will merge our CPU and GPU solvers into a single xPU code, and extend it to 2D and 3D. Finally, we will learn how to test a solver automatically on GitHub.

## Backend-portable xPU programming

![ParallelStencil.jl](../assets/l6_ps_logo.png)

[ParallelStencil.jl](https://github.com/omlins/ParallelStencil.jl) enables writing architecture-agnostic, high-level code for high-performance stencil computations on CPUs and GPUs. It relies on the native kernel programming capabilities of:

- [CUDA.jl](https://cuda.juliagpu.org/stable/) for Nvidia GPUs;
- [AMDGPU.jl](https://amdgpu.juliagpu.org/stable/) for AMD GPUs;
- [Metal.jl](https://metal.juliagpu.org/stable/) for Apple GPUs;
- [Base.Threads](https://docs.julialang.org/en/v1/base/multi-threading/) and [Polyester.jl](https://github.com/JuliaSIMD/Polyester.jl) for multi-threaded CPUs.

👉 Take a quick tour of ParallelStencil's [`README`](https://github.com/omlins/ParallelStencil.jl). Then, on your computer and on daint, create a folder for this lecture, make it a Julia project, and add the packages `ParallelStencil`, `AcceleratedKernels`, `BenchmarkTools` and `CairoMakie`, as well as `CUDA` on daint.

### Initialisation

ParallelStencil is initialised with the macro `@init_parallel_stencil`, which takes the package used for parallelisation (the backend), the number type, and the number of dimensions. A boolean constant `USE_GPU` lets us select the backend:

```julia
const USE_GPU = false
@static if USE_GPU
    using CUDA
end
using ParallelStencil
using ParallelStencil.FiniteDifferences2D
@static if USE_GPU
    @init_parallel_stencil(CUDA, Float64, 2, inbounds=false)
else
    @init_parallel_stencil(Threads, Float64, 2, inbounds=false)
end
```

- The backend package, here CUDA, must be loaded before ParallelStencil. `@static if` evaluates the condition when the code is parsed: with `USE_GPU = false`, CUDA is never loaded, and the code also runs on computers without an Nvidia GPU.
- With the `Threads` backend, the kernels run on the CPU with multi-threading: start Julia with several threads, e.g. `julia --project -t auto`, as in lecture 4.
- With `inbounds=false`, Julia checks the array bounds in all kernels. Once your code produces the expected results, you can set `inbounds=true` to deactivate the bounds checks, which may improve the performance.

!!! warning "Restart Julia after changing the backend"
    ParallelStencil can only be initialised once per Julia session. Restart Julia after changing `USE_GPU`.

`@init_parallel_stencil` creates the module `Data`. `Data.Array` is the array type of the selected backend and number type: `Array{Float64}` with the `Threads` backend, and `CuArray{Float64}` with the CUDA backend. ParallelStencil also provides macros that allocate arrays of this type:

```julia
A = @zeros(nx, ny)           # array of zeros, on the CPU or on the GPU
B = @ones(nx, ny)            # array of ones
C = @rand(nx, ny)            # array of random numbers
D = Data.Array(rand(nx, ny)) # copy an array from the CPU to the backend
d = Array(D)                 # copy an array from the backend to the CPU, e.g. for plotting
```

!!! note "Other backends"
    - On Apple computers, the Metal backend runs the kernels on the integrated GPU. However, Apple GPUs don't support `Float64` numbers, so we don't use the Metal backend in this course.
    - ParallelStencil also provides a KernelAbstractions backend, which switches between CPUs and GPUs at runtime, without restarting Julia (see [Interactive prototyping with runtime hardware selection](https://github.com/omlins/ParallelStencil.jl#interactive-prototyping-with-runtime-hardware-selection) in the `README`).

### Two ways to write kernels

ParallelStencil supports two ways of writing kernels:

1. **Stencil computations with math-close notation:** kernels declared with `@parallel` are written with macros, e.g. from the submodule `ParallelStencil.FiniteDifferences2D`, which compute finite differences of whole arrays, without explicit indices. The notation is close to the array programming notation of lectures 2 and 3.
2. **Explicit kernel programming:** kernels declared with `@parallel_indices` work with explicit indices, like the CUDA kernels of lecture 5.

Both kinds of kernels are launched with `@parallel`:

```julia
@parallel kernel!(args...)
```

ParallelStencil computes the launch parameters, i.e. the number of threads per block and the number of blocks, automatically. In contrast to `@cuda`, `@parallel` waits until the kernel has completed. Therefore, we don't need to synchronise before reading the timer.

### Math-close notation

The submodule `FiniteDifferences2D` provides macros to select array elements, and to compute differences and averages of neighbouring array elements. The suffix `a` stands for "all": the macro operates on all elements in the other dimension. The suffix `i` stands for "inner": the macro selects the inner elements in the other dimension. For an array `A` of size `nx × ny`:

| Macro      | Array programming equivalent                    | Size              |
| :--------- | :---------------------------------------------- | :---------------- |
| `@all(A)`  | `A`                                             | `nx × ny`         |
| `@inn(A)`  | `A[2:end-1, 2:end-1]`                           | `(nx-2) × (ny-2)` |
| `@d_xa(A)` | `A[2:end, :] - A[1:end-1, :]`                   | `(nx-1) × ny`     |
| `@d_ya(A)` | `A[:, 2:end] - A[:, 1:end-1]`                   | `nx × (ny-1)`     |
| `@d_xi(A)` | `A[2:end, 2:end-1] - A[1:end-1, 2:end-1]`       | `(nx-1) × (ny-2)` |
| `@d_yi(A)` | `A[2:end-1, 2:end] - A[2:end-1, 1:end-1]`       | `(nx-2) × (ny-1)` |
| `@av_xi(A)` | `(A[1:end-1, 2:end-1] + A[2:end, 2:end-1]) / 2` | `(nx-1) × (ny-2)` |
| `@av_yi(A)` | `(A[2:end-1, 1:end-1] + A[2:end-1, 2:end]) / 2` | `(nx-2) × (ny-1)` |

Type `?FiniteDifferences2D` in the REPL to list all macros, e.g. for harmonic averages (`@harm_xi`) and second-order differences (`@d2_xi`), and `?@d_xi` to read the documentation of a macro:

```julia-repl
julia> using ParallelStencil.FiniteDifferences2D

help?> @d_xi
  @d_xi(A): Compute differences between adjacent elements of A along the dimension x and select the inner elements of A in the remaining dimension. Corresponds to @inn_y(@d_xa(A)).
```

A `@parallel` kernel consists of assignments to arrays written with these macros, and returns `nothing`. For example, the update of the solution `@. u[2:end-1, 2:end-1] += α * d` becomes:

```julia
@parallel function update_u!(u, d, α)
    @inn(u) = @inn(u) + α * @all(d)
    return
end
```

All the terms of a statement must have the same size, here `(nx-2) × (ny-2)`. However, a kernel can contain several statements that operate on arrays of different sizes: each statement is only computed for the indices within the bounds of the array on its left-hand side.

!!! warning
    Update operators, such as `+=` and `-=`, are not supported in `@parallel` kernels: write out the assignment, as in the example above.

!!! note "How does it work?"
    `@parallel` turns the kernel into a kernel with explicit indices, similar to the kernels that you wrote in lecture 5, together with the code that launches it on the selected backend. This is possible thanks to Julia's [metaprogramming](https://docs.julialang.org/en/v1/manual/metaprogramming/) capabilities. Feel free to [explore the source code](https://github.com/omlins/ParallelStencil.jl/tree/main/src)!

## The elliptic problem in 2D

We solve the steady diffusion equation from lectures 3–5 in the 2D domain ``[0, l_x] \\times [0, l_y]``:

```math
\\boldsymbol{\\nabla}\\cdot(\\lambda \\boldsymbol{\\nabla} u) = \\frac{\\partial}{\\partial x}\\left(\\lambda \\frac{\\partial u}{\\partial x}\\right) + \\frac{\\partial}{\\partial y}\\left(\\lambda \\frac{\\partial u}{\\partial y}\\right) = 0~.
```

As in 1D, we compute the residual from the diffusive flux ``\\boldsymbol{q} = -\\lambda \\boldsymbol{\\nabla} u``, which now has two components:

```math
q_x = -\\lambda \\frac{\\partial u}{\\partial x}~, \\qquad q_y = -\\lambda \\frac{\\partial u}{\\partial y}~, \\qquad r = -\\left(\\frac{\\partial q_x}{\\partial x} + \\frac{\\partial q_y}{\\partial y}\\right)~.
```

The DR iterations, i.e. the updates of the solution ``u``, of the preconditioned residual ``z``, of the search direction ``d`` and of the damping parameter ``\\beta``, remain unchanged.

### Discretisation

We extend the staggered grid from lecture 3 to 2D:

- The solution `u` is defined at the cell centres `(xc, yc)`, and has `nx × ny` elements. The values in the first and last rows and columns are prescribed by the boundary conditions, and the `(nx-2) × (ny-2)` inner values are the unknowns.
- The flux `qx` is located on the cell faces between the cell centres in the x direction, and has `(nx-1) × (ny-2)` elements. The flux `qy` is located on the cell faces in the y direction, and has `(nx-2) × (ny-1)` elements. We only need the fluxes across the faces of the inner cells.
- The residual `r`, the preconditioned residuals `z` and `z0`, the search direction `d` and the preconditioner `Q` are defined at the inner cell centres, and have `(nx-2) × (ny-2)` elements.

In 1D, the diffusion coefficient `λ` is defined at the same locations as the flux `qx`. In 2D, we need `λ` at the locations of both flux components. Instead of storing `λ` twice, in arrays of the sizes of `qx` and `qy`, we define it once at the cell centres, like `u`, with `nx × ny` elements. We then compute the values of `λ` at the cell faces as the averages of the values in the two neighbouring cells. Compared to two (or, in 3D, three) arrays, this reduces the memory footprint of the solver. We sample `λ` from a Gaussian anomaly in the centre of the domain:

```math
\\lambda(x, y) = \\lambda_\\mathrm{bg} + \\lambda_\\mathrm{amp} \\exp\\left(-(x - l_x/2)^2 - (y - l_y/2)^2\\right)~.
```

As in 1D, we impose ``u = 0`` at ``x = 0`` and ``u = 1`` at ``x = l_x``. At the boundaries ``y = 0`` and ``y = l_y``, we prescribe the linear profile between these two values, which is the solution for a constant ``\\lambda``. Far from the anomaly, the solution is close to this profile.

### Preconditioner

👉 Write down the discretised residual at an inner grid cell, and derive the Jacobi preconditioner `Q` as in lecture 3: collect the coefficient of the value of `u` at that cell, negate it, and take its inverse.

<details>
<summary>Want to see the answer?</summary>

!!! answer "Answer"
    The element `r[ix, iy]` is located at the cell centre of `u[ix+1, iy+1]`. With the fluxes across the four faces of this cell, the discretised residual reads:

    ```julia
    r[ix, iy] = -((qx[ix+1, iy] - qx[ix, iy]) / dx + (qy[ix, iy+1] - qy[ix, iy]) / dy)
    qx[ix, iy] = -0.5 * (λ[ix, iy+1] + λ[ix+1, iy+1]) * (u[ix+1, iy+1] - u[ix, iy+1]) / dx
    qy[ix, iy] = -0.5 * (λ[ix+1, iy] + λ[ix+1, iy+1]) * (u[ix+1, iy+1] - u[ix+1, iy]) / dy
    ```

    The coefficient of `u[ix+1, iy+1]` in `r[ix, iy]` is:

    ```julia
    -0.5 * (λ[ix, iy+1] + 2λ[ix+1, iy+1] + λ[ix+2, iy+1]) / dx^2 - 0.5 * (λ[ix+1, iy] + 2λ[ix+1, iy+1] + λ[ix+1, iy+2]) / dy^2
    ```

    Therefore, the preconditioner is:

    ```julia
    λc   = λ[2:end-1, 2:end-1]
    Q    = @. 2.0 / ((λ[1:end-2, 2:end-1] + 2.0 * λc + λ[3:end, 2:end-1]) * _dx^2 +
                     (λ[2:end-1, 1:end-2] + 2.0 * λc + λ[2:end-1, 3:end]) * _dy^2)
    ```

    The terms in parentheses, divided by 2, are the sums of the values of `λ` on the two faces of the cell in each direction, as in the 1D formula `Q = dx^2 / (λ[1:end-1] + λ[2:end])` from lecture 3. The array `λc` is a view of the inner values of `λ`, since the solver function is annotated with `@views`.

</details>

### Iteration parameters and performance metric

- We keep the initial value of the damping parameter from 1D, using the largest number of grid cells: `β = 1 - 2π / max(nx, ny)`. The DR solver then adapts `β` during the iterations.
- We use the same number of grid cells in both directions, `ny = nx`. As in 1D, the number of iterations needed to converge scales with `nx`, so we keep normalising the iteration count by `nx`.
- The unknown fields are `u` and `d`, and the known fields are `λ` and `Q`. Assuming that all arrays have `nx × ny` elements, the effective memory access per iteration is:

```julia
A_eff = (2*2 + 2) * nx * ny * sizeof(Float64) / 1e9 # [GB]
```

## A 2D xPU solver with math-close notation

👉 Duplicate the script `elliptic_1d_dr_gpu.jl` from lecture 5, rename the copy to `elliptic_2d_dr_xpu.jl`, and follow the steps below.

### 1. Packages

Replace `using CUDA` with the initialisation of ParallelStencil shown above, and add `using AcceleratedKernels`. Remove the macro `@d_xa` that we defined in lecture 4: `FiniteDifferences2D` provides its own version of it.

### 2. Preprocessing and array initialisation

Rename the function to `elliptic_2d_dr`, set the default resolution to `nx=128`, and add the keyword argument `ny=nx`. Extend the `# physics` and `# preprocessing` sections to 2D, and initialise the arrays on the backend with `Data.Array` and `@zeros`:

```julia
# physics
lx, ly = 20.0, 20.0
λbg    = 1.0
λamp   = 10.0
...
# preprocessing
dx, dy = lx / nx, ly / ny
xc, yc = LinRange(dx/2, lx-dx/2, nx), LinRange(dy/2, ly-dy/2, ny)
β      = 1 - 2π / max(nx, ny)
_dx, _dy = 1.0 / dx, 1.0 / dy
# array initialisation
u    = Data.Array([(x - xc[1]) / (xc[end] - xc[1]) for x in xc, y in yc])
u[2:end-1, 2:end-1] .= 0.0
λ    = Data.Array([λbg + λamp * exp(-(x - lx/2)^2 - (y - ly/2)^2) for x in xc, y in yc])
qx   = @zeros(nx-1, ny-2)
qy   = @zeros(nx-2, ny-1)
d    = @zeros(nx-2, ny-2)
...
```

The array comprehensions `[... for x in xc, y in yc]` create 2D arrays on the CPU, which `Data.Array` copies to the backend. We first initialise `u` with the linear profile, which sets the boundary values, and then set its inner values, our initial guess, to zero.

👉 Complete the array initialisation, and compute the preconditioner `Q` derived above. Since `Q` is computed by broadcasting from `λ`, it ends up on the backend without changes. Finally, remove the boundary conditions before the iteration loop: the initialisation of `u` already sets the boundary values, which never change, since `update_u!` only updates the inner values.

### 3. Kernels

Replace the CUDA kernels with `@parallel` kernels. The kernel `update_u!` is given above.

👉 Implement the kernels `compute_q!(qx, qy, u, λ, _dx, _dy)`, `compute_r!(r, qx, qy, _dx, _dy)`, `precondition!(z, r, Q)` and `update_d!(d, z, β)`.

!!! hint
    - Check the sizes: `@av_xi(λ)` and `@d_xi(u)` have the same size as `qx`, and `@d_xa(qx)` has the same size as `r`.
    - As in lecture 5, the fluxes and the residual must be computed in separate kernels: the residual of a cell depends on fluxes computed by other threads.

<details>
<summary>Want to see the answer?</summary>

!!! answer "Answer"
    ```julia
    @parallel function compute_q!(qx, qy, u, λ, _dx, _dy)
        @all(qx) = -@av_xi(λ) * @d_xi(u) * _dx
        @all(qy) = -@av_yi(λ) * @d_yi(u) * _dy
        return
    end

    @parallel function compute_r!(r, qx, qy, _dx, _dy)
        @all(r) = -(@d_xa(qx) * _dx + @d_ya(qy) * _dy)
        return
    end

    @parallel function precondition!(z, r, Q)
        @all(z) = @all(Q) * @all(r)
        return
    end

    @parallel function update_d!(d, z, β)
        @all(d) = @all(d) * β + @all(z)
        return
    end
    ```

</details>

### 4. The ``\\beta`` update

👉 Copy the function `compute_β` from lecture 4, which computes the dot products with `AcceleratedKernels.mapreduce`. AcceleratedKernels.jl is backend-agnostic, like ParallelStencil: the reductions run multi-threaded for CPU arrays, and on the GPU for GPU arrays. The convergence check with `maximum(abs, r)` and saving `z` to `z0` with broadcasting work on both backends without changes.

### 5. Iteration loop and benchmarking

👉 Launch the kernels with `@parallel` in the iteration loop and in the function `compute!`, e.g.:

```julia
@parallel update_u!(u, d, α)
```

Since ParallelStencil computes the launch parameters, and `@parallel` waits until the kernel has completed:

- remove the launch parameters `nthreads` and `nblocks`;
- remove `CUDA.synchronize()` around the timer, and `CUDA.@sync` in the benchmark with `@belapsed`.

Also update the arguments of `compute!`, and the effective memory access `A_eff`.

### 6. Visualisation

👉 Replace the line plot of the solution with a heatmap, and add contour lines that show how the anomaly of `λ` deflects the solution. Since there is no display on the compute nodes of daint, save the figure in the solver function. Finally, return the solution, copied to the CPU, and the convergence history, e.g. for further analysis or for testing:

```julia
# visualisation
if do_visu
    fig = Figure(size=(600, 750))
    ax  = (Axis(fig[1,1][1,1]; aspect=DataAspect(), xlabel="x", ylabel="y", title="solution"),
           Axis(fig[2,1]; xlabel="iter/nx", ylabel="|r|",
                          yscale=log10,
                          title="convergence history",
                          limits=(0, niter/nx, 0.1εtol, 1e2)))
    plt = (heatmap!(ax[1], xc, yc, Array(u); colormap=:turbo),
           lines!(ax[2], itr_h, res_h; color=:black))
    contour!(ax[1], xc, yc, Array(u); levels=0.05:0.1:0.95, color=:white)
    Colorbar(fig[1,1][1,2], plt[1])
    rowsize!(fig.layout, 1, Relative(0.65))
    save("elliptic_2d_dr_xpu.png", fig)
end
return Array(u), itr_h, res_h
```

### Running the solver

👉 Run the script on your computer with `USE_GPU = false` and several threads. With the default parameters, the solver converges in about 6.6 × `nx` iterations, and produces the following figure:

![Solution and convergence history of the 2D solver](../assets/l6_elliptic_2d.png)

👉 Double the resolution. Does the number of iterations, normalised by `nx`, stay the same?

👉 On a compute node of daint, set `USE_GPU = true` and run the same script on the GPU, without changing anything else in the code. For the performance measurements, increase the resolution to `nx = 2^13`.

<details>
<summary>Want to see the answer?</summary>

!!! answer "Answer"
    ```julia
    const USE_GPU = false
    @static if USE_GPU
        using CUDA
    end
    using ParallelStencil
    using ParallelStencil.FiniteDifferences2D
    @static if USE_GPU
        @init_parallel_stencil(CUDA, Float64, 2, inbounds=false)
    else
        @init_parallel_stencil(Threads, Float64, 2, inbounds=false)
    end
    using CairoMakie
    using Printf
    using BenchmarkTools
    using AcceleratedKernels

    @parallel function update_u!(u, d, α)
        @inn(u) = @inn(u) + α * @all(d)
        return
    end

    @parallel function compute_q!(qx, qy, u, λ, _dx, _dy)
        @all(qx) = -@av_xi(λ) * @d_xi(u) * _dx
        @all(qy) = -@av_yi(λ) * @d_yi(u) * _dy
        return
    end

    @parallel function compute_r!(r, qx, qy, _dx, _dy)
        @all(r) = -(@d_xa(qx) * _dx + @d_ya(qy) * _dy)
        return
    end

    @parallel function precondition!(z, r, Q)
        @all(z) = @all(Q) * @all(r)
        return
    end

    function compute_β(d, z, z0)
        num = AcceleratedKernels.mapreduce((_d, _z, _z0) -> _d * (_z - _z0), +, d, z, z0)
        den = AcceleratedKernels.mapreduce(*, +, d, d)
        γ = abs(num) / den
        return (1 - sqrt(γ))^2
    end

    @parallel function update_d!(d, z, β)
        @all(d) = @all(d) * β + @all(z)
        return
    end

    function compute!(u, d, z, r, qx, qy, λ, Q, α, β, _dx, _dy)
        @parallel update_u!(u, d, α)
        @parallel compute_q!(qx, qy, u, λ, _dx, _dy)
        @parallel compute_r!(r, qx, qy, _dx, _dy)
        @parallel precondition!(z, r, Q)
        @parallel update_d!(d, z, β)
        return
    end

    @views function elliptic_2d_dr(; nx=128, ny=nx, niter=15nx, do_check=true, do_visu=true, do_bench=false)
        # physics
        lx, ly = 20.0, 20.0
        λbg    = 1.0
        λamp   = 10.0
        # numerics
        εtol  = 1e-6
        nchck = ceil(Int, 0.1nx)
        ndrel = 10
        # preprocessing
        dx, dy = lx / nx, ly / ny
        xc, yc = LinRange(dx/2, lx-dx/2, nx), LinRange(dy/2, ly-dy/2, ny)
        β      = 1 - 2π / max(nx, ny)
        _dx, _dy = 1.0 / dx, 1.0 / dy
        # array initialisation
        u    = Data.Array([(x - xc[1]) / (xc[end] - xc[1]) for x in xc, y in yc])
        u[2:end-1, 2:end-1] .= 0.0
        λ    = Data.Array([λbg + λamp * exp(-(x - lx/2)^2 - (y - ly/2)^2) for x in xc, y in yc])
        qx   = @zeros(nx-1, ny-2)
        qy   = @zeros(nx-2, ny-1)
        d    = @zeros(nx-2, ny-2)
        r    = @zeros(nx-2, ny-2)
        z    = @zeros(nx-2, ny-2)
        z0   = @zeros(nx-2, ny-2)
        # preconditioner
        λc   = λ[2:end-1, 2:end-1]
        Q    = @. 2.0 / ((λ[1:end-2, 2:end-1] + 2.0 * λc + λ[3:end, 2:end-1]) * _dx^2 +
                         (λ[2:end-1, 1:end-2] + 2.0 * λc + λ[2:end-1, 3:end]) * _dy^2)
        # convergence history
        itr_h = Float64[]
        res_h = Float64[]
        # effective main memory access per iteration [GB]
        A_eff = (2*2 + 2) * nx * ny * sizeof(Float64) / 1e9
        # benchmark one iteration with BenchmarkTools
        if do_bench
            α     = 0.99 * (1 + β)
            t_it  = @belapsed compute!(\$u, \$d, \$z, \$r, \$qx, \$qy, \$λ, \$Q, \$α, \$β, \$_dx, \$_dy)
            T_eff = A_eff / t_it
            @printf("BenchmarkTools: t_it = %1.3e s, T_eff = %1.2f GB/s\\n", t_it, T_eff)
            return
        end
        # iteration loop
        t_tic = Base.time(); niter_timed = 0
        for iter = 1:niter
            # start the timer after 10 warm-up iterations
            if iter == 11 t_tic = Base.time(); niter_timed = 0 end
            niter_timed += 1
            # update solution
            α = 0.99 * (1 + β)
            @parallel update_u!(u, d, α)
            # compute residual
            @parallel compute_q!(qx, qy, u, λ, _dx, _dy)
            @parallel compute_r!(r, qx, qy, _dx, _dy)
            # check convergence
            if do_check && iter % nchck == 0
                err = maximum(abs, r)
                push!(itr_h, iter / nx)
                push!(res_h, err)
                if err $(HTML("<")) εtol
                    println(" solver converged in \$(iter/nx) × N iterations! 🚀")
                    break
                end
            end
            # save old z
            if iter % ndrel == 0
                @. z0 = z
            end
            # compute preconditioned residual
            @parallel precondition!(z, r, Q)
            # update β
            if iter % ndrel == 0
                β = compute_β(d, z, z0)
            end
            # update search direction
            @parallel update_d!(d, z, β)
        end
        # performance
        t_toc = Base.time() - t_tic
        t_it  = t_toc / niter_timed # execution time per iteration [s]
        T_eff = A_eff / t_it        # effective memory throughput [GB/s]
        @printf("Time = %1.3f s, T_eff = %1.2f GB/s (niter = %d)\\n", t_toc, T_eff, niter_timed)
        # visualisation
        if do_visu
            fig = Figure(size=(600, 750))
            ax  = (Axis(fig[1,1][1,1]; aspect=DataAspect(), xlabel="x", ylabel="y", title="solution"),
                   Axis(fig[2,1]; xlabel="iter/nx", ylabel="|r|",
                                  yscale=log10,
                                  title="convergence history",
                                  limits=(0, niter/nx, 0.1εtol, 1e2)))
            plt = (heatmap!(ax[1], xc, yc, Array(u); colormap=:turbo),
                   lines!(ax[2], itr_h, res_h; color=:black))
            contour!(ax[1], xc, yc, Array(u); levels=0.05:0.1:0.95, color=:white)
            Colorbar(fig[1,1][1,2], plt[1])
            rowsize!(fig.layout, 1, Relative(0.65))
            save("elliptic_2d_dr_xpu.png", fig)
        end
        return Array(u), itr_h, res_h
    end

    elliptic_2d_dr()
    # performance: use nx=2^13 on the GPU
    elliptic_2d_dr(; nx=2^12, niter=110, do_check=false, do_visu=false)
    elliptic_2d_dr(; nx=2^12, do_check=false, do_visu=false, do_bench=true)
    ```

</details>

!!! note "Comparing CPU and GPU results"
    As in lecture 5, the CPU and GPU solvers compute the same solution, but not exactly: the reductions sum the numbers in a different order on the GPU, which changes the rounding errors. Compare the results approximately, with `≈`.

## Explicit kernel programming

Math-close notation is concise, but every statement operates on whole arrays: intermediate results, such as the fluxes `qx` and `qy`, have to be stored in main memory. Let's count the arrays that the kernels read and write in main memory in every iteration, assuming, as in lecture 5, that neighbouring elements are loaded together:

| Kernel          | Reads             | Writes     | Arrays |
| :-------------- | :---------------- | :--------- | :----: |
| `update_u!`     | `u`, `d`          | `u`        | 3      |
| `compute_q!`    | `u`, `λ`          | `qx`, `qy` | 4      |
| `compute_r!`    | `qx`, `qy`        | `r`        | 3      |
| `precondition!` | `Q`, `r`          | `z`        | 3      |
| `update_d!`     | `d`, `z`          | `d`        | 3      |
| total           |                   |            | 16     |

The effective memory access counts 6 arrays, so ``T_\\mathrm{eff}`` can reach at most 6/16 ≈ 38% of ``T_\\mathrm{peak}``.

In lecture 5, we fused the computation of the flux and the residual into a single kernel, which recomputes the fluxes on the fly. With ParallelStencil, kernels declared with `@parallel_indices` make this possible: they give us full control over the computations of every thread:

```julia
@parallel_indices (ix, iy) function update_u!(u, d, α)
    u[ix+1, iy+1] += α * d[ix, iy]
    return
end
```

The tuple `(ix, iy)` names the indices that ParallelStencil computes for every thread on the GPU, and loops over on the CPU. In contrast to `@parallel` kernels, `@parallel_indices` kernels support update operators, such as `+=`.

By default, `@parallel` runs a `@parallel_indices` kernel for all indices of the largest array argument, here `u`. However, `update_u!` only updates the inner values of `u`, one for each element of `d`. We therefore pass the ranges of the indices explicitly, as the first argument of `@parallel`:

```julia
@parallel (1:nx-2, 1:ny-2) update_u!(u, d, α)
```

ParallelStencil makes sure that only the threads within these ranges execute the kernel. Therefore, we don't need the bounds checks of lecture 5.

👉 Duplicate `elliptic_2d_dr_xpu.jl`, and rename the copy to `elliptic_2d_dr_perf_xpu.jl`. Rewrite all kernels with `@parallel_indices`, and fuse `compute_q!` and `compute_r!` into a single kernel `compute_r!(r, u, λ, _dx, _dy)`, which computes the fluxes across the four faces of each inner cell on the fly. Remove the arrays `qx` and `qy`, and `using ParallelStencil.FiniteDifferences2D`.

!!! hint
    - The thread `(ix, iy)` computes `r[ix, iy]`, which is located at the cell centre of `u[ix+1, iy+1]`. Name the fluxes after the faces of the cell, e.g. `qxW` and `qxE` for the west and east faces. The value of `λ` on the west face is `0.5 * (λ[ix, iy+1] + λ[ix+1, iy+1])`.
    - The kernels `precondition!` and `update_d!` only access arrays of size `(nx-2) × (ny-2)`, so they can be launched without explicit ranges.

<details>
<summary>Want to see the answer?</summary>

!!! answer "Answer"
    ```julia
    @parallel_indices (ix, iy) function update_u!(u, d, α)
        u[ix+1, iy+1] += α * d[ix, iy]
        return
    end

    @parallel_indices (ix, iy) function compute_r!(r, u, λ, _dx, _dy)
        qxW = -0.5 * (λ[ix  , iy+1] + λ[ix+1, iy+1]) * (u[ix+1, iy+1] - u[ix  , iy+1]) * _dx
        qxE = -0.5 * (λ[ix+1, iy+1] + λ[ix+2, iy+1]) * (u[ix+2, iy+1] - u[ix+1, iy+1]) * _dx
        qyS = -0.5 * (λ[ix+1, iy  ] + λ[ix+1, iy+1]) * (u[ix+1, iy+1] - u[ix+1, iy  ]) * _dy
        qyN = -0.5 * (λ[ix+1, iy+1] + λ[ix+1, iy+2]) * (u[ix+1, iy+2] - u[ix+1, iy+1]) * _dy
        r[ix, iy] = -((qxE - qxW) * _dx + (qyN - qyS) * _dy)
        return
    end

    @parallel_indices (ix, iy) function precondition!(z, r, Q)
        z[ix, iy] = Q[ix, iy] * r[ix, iy]
        return
    end

    @parallel_indices (ix, iy) function update_d!(d, z, β)
        d[ix, iy] = d[ix, iy] * β + z[ix, iy]
        return
    end

    function compute!(u, d, z, r, λ, Q, α, β, _dx, _dy)
        nx, ny = size(u)
        @parallel (1:nx-2, 1:ny-2) update_u!(u, d, α)
        @parallel (1:nx-2, 1:ny-2) compute_r!(r, u, λ, _dx, _dy)
        @parallel precondition!(z, r, Q)
        @parallel update_d!(d, z, β)
        return
    end
    ```

</details>

### Performance

The fused kernel `compute_r!` reads `u` and `λ`, and writes `r`: 3 arrays instead of 7. The solver now accesses 12 arrays per iteration, which raises the upper bound of ``T_\\mathrm{eff}`` to 6/12 = 50% of ``T_\\mathrm{peak}``.

On the Apple M2 Max laptop from lecture 4, with 8 threads and 4096 × 4096 grid cells, we measured (in GB/s):

| Version                                                  | manual timer | `@belapsed compute!(...)` |
| :------------------------------------------------------- | :----------: | :-----------------------: |
| `elliptic_1d_dr_perf_loop_fun.jl` (lecture 4, `nx = 2^23`) | 64          | 75                        |
| `elliptic_2d_dr_xpu.jl`                                  | 29           | 36                        |
| `elliptic_2d_dr_perf_xpu.jl`                             | 42           | 55                        |
| memcopy (``T_\\mathrm{peak}``)                            | 210          | –                         |

Measured with `@belapsed`, the fused version is about 50% faster, which is more than the ratio of 16 to 12 arrays suggests: counting arrays only gives a rough estimate of the performance.

👉 Measure ``T_\\mathrm{eff}`` of both 2D versions on a GH200 of daint, with `nx = 2^13`. Compare the results with the 1D GPU solvers of lecture 5, and with ``T_\\mathrm{peak}`` ≈ 3600 GB/s measured with `copyto!`. Then set `inbounds=true` in `@init_parallel_stencil`, and measure again.

<details>
<summary>Want to see the answer?</summary>

!!! answer "Answer"
    ```julia
    const USE_GPU = false
    @static if USE_GPU
        using CUDA
    end
    using ParallelStencil
    @static if USE_GPU
        @init_parallel_stencil(CUDA, Float64, 2, inbounds=false)
    else
        @init_parallel_stencil(Threads, Float64, 2, inbounds=false)
    end
    using CairoMakie
    using Printf
    using BenchmarkTools
    using AcceleratedKernels

    @parallel_indices (ix, iy) function update_u!(u, d, α)
        u[ix+1, iy+1] += α * d[ix, iy]
        return
    end

    @parallel_indices (ix, iy) function compute_r!(r, u, λ, _dx, _dy)
        qxW = -0.5 * (λ[ix  , iy+1] + λ[ix+1, iy+1]) * (u[ix+1, iy+1] - u[ix  , iy+1]) * _dx
        qxE = -0.5 * (λ[ix+1, iy+1] + λ[ix+2, iy+1]) * (u[ix+2, iy+1] - u[ix+1, iy+1]) * _dx
        qyS = -0.5 * (λ[ix+1, iy  ] + λ[ix+1, iy+1]) * (u[ix+1, iy+1] - u[ix+1, iy  ]) * _dy
        qyN = -0.5 * (λ[ix+1, iy+1] + λ[ix+1, iy+2]) * (u[ix+1, iy+2] - u[ix+1, iy+1]) * _dy
        r[ix, iy] = -((qxE - qxW) * _dx + (qyN - qyS) * _dy)
        return
    end

    @parallel_indices (ix, iy) function precondition!(z, r, Q)
        z[ix, iy] = Q[ix, iy] * r[ix, iy]
        return
    end

    function compute_β(d, z, z0)
        num = AcceleratedKernels.mapreduce((_d, _z, _z0) -> _d * (_z - _z0), +, d, z, z0)
        den = AcceleratedKernels.mapreduce(*, +, d, d)
        γ = abs(num) / den
        return (1 - sqrt(γ))^2
    end

    @parallel_indices (ix, iy) function update_d!(d, z, β)
        d[ix, iy] = d[ix, iy] * β + z[ix, iy]
        return
    end

    function compute!(u, d, z, r, λ, Q, α, β, _dx, _dy)
        nx, ny = size(u)
        @parallel (1:nx-2, 1:ny-2) update_u!(u, d, α)
        @parallel (1:nx-2, 1:ny-2) compute_r!(r, u, λ, _dx, _dy)
        @parallel precondition!(z, r, Q)
        @parallel update_d!(d, z, β)
        return
    end

    @views function elliptic_2d_dr(; nx=128, ny=nx, niter=15nx, do_check=true, do_visu=true, do_bench=false)
        # physics
        lx, ly = 20.0, 20.0
        λbg    = 1.0
        λamp   = 10.0
        # numerics
        εtol  = 1e-6
        nchck = ceil(Int, 0.1nx)
        ndrel = 10
        # preprocessing
        dx, dy = lx / nx, ly / ny
        xc, yc = LinRange(dx/2, lx-dx/2, nx), LinRange(dy/2, ly-dy/2, ny)
        β      = 1 - 2π / max(nx, ny)
        _dx, _dy = 1.0 / dx, 1.0 / dy
        # array initialisation
        u    = Data.Array([(x - xc[1]) / (xc[end] - xc[1]) for x in xc, y in yc])
        u[2:end-1, 2:end-1] .= 0.0
        λ    = Data.Array([λbg + λamp * exp(-(x - lx/2)^2 - (y - ly/2)^2) for x in xc, y in yc])
        d    = @zeros(nx-2, ny-2)
        r    = @zeros(nx-2, ny-2)
        z    = @zeros(nx-2, ny-2)
        z0   = @zeros(nx-2, ny-2)
        # preconditioner
        λc   = λ[2:end-1, 2:end-1]
        Q    = @. 2.0 / ((λ[1:end-2, 2:end-1] + 2.0 * λc + λ[3:end, 2:end-1]) * _dx^2 +
                         (λ[2:end-1, 1:end-2] + 2.0 * λc + λ[2:end-1, 3:end]) * _dy^2)
        # convergence history
        itr_h = Float64[]
        res_h = Float64[]
        # effective main memory access per iteration [GB]
        A_eff = (2*2 + 2) * nx * ny * sizeof(Float64) / 1e9
        # benchmark one iteration with BenchmarkTools
        if do_bench
            α     = 0.99 * (1 + β)
            t_it  = @belapsed compute!(\$u, \$d, \$z, \$r, \$λ, \$Q, \$α, \$β, \$_dx, \$_dy)
            T_eff = A_eff / t_it
            @printf("BenchmarkTools: t_it = %1.3e s, T_eff = %1.2f GB/s\\n", t_it, T_eff)
            return
        end
        # iteration loop
        t_tic = Base.time(); niter_timed = 0
        for iter = 1:niter
            # start the timer after 10 warm-up iterations
            if iter == 11 t_tic = Base.time(); niter_timed = 0 end
            niter_timed += 1
            # update solution
            α = 0.99 * (1 + β)
            @parallel (1:nx-2, 1:ny-2) update_u!(u, d, α)
            # compute residual
            @parallel (1:nx-2, 1:ny-2) compute_r!(r, u, λ, _dx, _dy)
            # check convergence
            if do_check && iter % nchck == 0
                err = maximum(abs, r)
                push!(itr_h, iter / nx)
                push!(res_h, err)
                if err $(HTML("<")) εtol
                    println(" solver converged in \$(iter/nx) × N iterations! 🚀")
                    break
                end
            end
            # save old z
            if iter % ndrel == 0
                @. z0 = z
            end
            # compute preconditioned residual
            @parallel precondition!(z, r, Q)
            # update β
            if iter % ndrel == 0
                β = compute_β(d, z, z0)
            end
            # update search direction
            @parallel update_d!(d, z, β)
        end
        # performance
        t_toc = Base.time() - t_tic
        t_it  = t_toc / niter_timed # execution time per iteration [s]
        T_eff = A_eff / t_it        # effective memory throughput [GB/s]
        @printf("Time = %1.3f s, T_eff = %1.2f GB/s (niter = %d)\\n", t_toc, T_eff, niter_timed)
        # visualisation
        if do_visu
            fig = Figure(size=(600, 750))
            ax  = (Axis(fig[1,1][1,1]; aspect=DataAspect(), xlabel="x", ylabel="y", title="solution"),
                   Axis(fig[2,1]; xlabel="iter/nx", ylabel="|r|",
                                  yscale=log10,
                                  title="convergence history",
                                  limits=(0, niter/nx, 0.1εtol, 1e2)))
            plt = (heatmap!(ax[1], xc, yc, Array(u); colormap=:turbo),
                   lines!(ax[2], itr_h, res_h; color=:black))
            contour!(ax[1], xc, yc, Array(u); levels=0.05:0.1:0.95, color=:white)
            Colorbar(fig[1,1][1,2], plt[1])
            rowsize!(fig.layout, 1, Relative(0.65))
            save("elliptic_2d_dr_perf_xpu.png", fig)
        end
        return Array(u), itr_h, res_h
    end

    elliptic_2d_dr()
    # performance: use nx=2^13 on the GPU
    elliptic_2d_dr(; nx=2^12, niter=110, do_check=false, do_visu=false)
    elliptic_2d_dr(; nx=2^12, do_check=false, do_visu=false, do_bench=true)
    ```

</details>

## Going 3D

Many applications require 3D simulations, which are expensive: this is where GPUs become indispensable. Thanks to the math-close notation, extending the 2D solver to 3D is straightforward.

👉 Duplicate `elliptic_2d_dr_xpu.jl`, rename the copy to `elliptic_3d_dr_xpu.jl`, and extend the solver to 3D:

1. Use `ParallelStencil.FiniteDifferences3D`, and set the number of dimensions in `@init_parallel_stencil` to 3.
2. Add the z direction everywhere: the domain size `lz`, the number of grid cells `nz=nx`, the grid spacing `dz` and its inverse `_dz`, and the coordinates `zc`.
3. Add a third dimension to all arrays: e.g. `λ` has `nx × ny × nz` elements, `qx` has `(nx-1) × (ny-2) × (nz-2)` elements, and `r` has `(nx-2) × (ny-2) × (nz-2)` elements. Add the flux in the z direction `qz`, which has `(nx-2) × (ny-2) × (nz-1)` elements.
4. Compute `qz` with `@av_zi(λ)` and `@d_zi(u)` in `compute_q!`, and add its contribution `@d_za(qz) * _dz` to the residual.
5. Add the z direction to the preconditioner `Q`, and use `max(nx, ny, nz)` in the initial value of `β`.
6. Update the effective memory access `A_eff`: the number of grid cells is now `nx * ny * nz`. Thanks to the cell-centred `λ`, the number of known fields doesn't change.
7. Visualise a horizontal slice of the solution in the middle of the domain, `Array(u)[:, :, nz÷2]`.

The array comprehensions take a third iterator in 3D, e.g.:

```julia
λ = Data.Array([λbg + λamp * exp(-(x - lx/2)^2 - (y - ly/2)^2 - (z - lz/2)^2) for x in xc, y in yc, z in zc])
```

Set the default resolution to `nx=64`. With the default parameters, the solver converges in about 6.2 × `nx` iterations, and produces the following figure:

![Horizontal slice of the solution and convergence history of the 3D solver](../assets/l6_elliptic_3d.png)

<details>
<summary>Want to see the answer?</summary>

!!! answer "Answer"
    ```julia
    const USE_GPU = false
    @static if USE_GPU
        using CUDA
    end
    using ParallelStencil
    using ParallelStencil.FiniteDifferences3D
    @static if USE_GPU
        @init_parallel_stencil(CUDA, Float64, 3, inbounds=false)
    else
        @init_parallel_stencil(Threads, Float64, 3, inbounds=false)
    end
    using CairoMakie
    using Printf
    using BenchmarkTools
    using AcceleratedKernels

    @parallel function update_u!(u, d, α)
        @inn(u) = @inn(u) + α * @all(d)
        return
    end

    @parallel function compute_q!(qx, qy, qz, u, λ, _dx, _dy, _dz)
        @all(qx) = -@av_xi(λ) * @d_xi(u) * _dx
        @all(qy) = -@av_yi(λ) * @d_yi(u) * _dy
        @all(qz) = -@av_zi(λ) * @d_zi(u) * _dz
        return
    end

    @parallel function compute_r!(r, qx, qy, qz, _dx, _dy, _dz)
        @all(r) = -(@d_xa(qx) * _dx + @d_ya(qy) * _dy + @d_za(qz) * _dz)
        return
    end

    @parallel function precondition!(z, r, Q)
        @all(z) = @all(Q) * @all(r)
        return
    end

    function compute_β(d, z, z0)
        num = AcceleratedKernels.mapreduce((_d, _z, _z0) -> _d * (_z - _z0), +, d, z, z0)
        den = AcceleratedKernels.mapreduce(*, +, d, d)
        γ = abs(num) / den
        return (1 - sqrt(γ))^2
    end

    @parallel function update_d!(d, z, β)
        @all(d) = @all(d) * β + @all(z)
        return
    end

    function compute!(u, d, z, r, qx, qy, qz, λ, Q, α, β, _dx, _dy, _dz)
        @parallel update_u!(u, d, α)
        @parallel compute_q!(qx, qy, qz, u, λ, _dx, _dy, _dz)
        @parallel compute_r!(r, qx, qy, qz, _dx, _dy, _dz)
        @parallel precondition!(z, r, Q)
        @parallel update_d!(d, z, β)
        return
    end

    @views function elliptic_3d_dr(; nx=64, ny=nx, nz=nx, niter=15nx, do_check=true, do_visu=true, do_bench=false)
        # physics
        lx, ly, lz = 20.0, 20.0, 20.0
        λbg        = 1.0
        λamp       = 10.0
        # numerics
        εtol  = 1e-6
        nchck = ceil(Int, 0.1nx)
        ndrel = 10
        # preprocessing
        dx, dy, dz = lx / nx, ly / ny, lz / nz
        xc, yc, zc = LinRange(dx/2, lx-dx/2, nx), LinRange(dy/2, ly-dy/2, ny), LinRange(dz/2, lz-dz/2, nz)
        β          = 1 - 2π / max(nx, ny, nz)
        _dx, _dy, _dz = 1.0 / dx, 1.0 / dy, 1.0 / dz
        # array initialisation
        u    = Data.Array([(x - xc[1]) / (xc[end] - xc[1]) for x in xc, y in yc, z in zc])
        u[2:end-1, 2:end-1, 2:end-1] .= 0.0
        λ    = Data.Array([λbg + λamp * exp(-(x - lx/2)^2 - (y - ly/2)^2 - (z - lz/2)^2) for x in xc, y in yc, z in zc])
        qx   = @zeros(nx-1, ny-2, nz-2)
        qy   = @zeros(nx-2, ny-1, nz-2)
        qz   = @zeros(nx-2, ny-2, nz-1)
        d    = @zeros(nx-2, ny-2, nz-2)
        r    = @zeros(nx-2, ny-2, nz-2)
        z    = @zeros(nx-2, ny-2, nz-2)
        z0   = @zeros(nx-2, ny-2, nz-2)
        # preconditioner
        λc   = λ[2:end-1, 2:end-1, 2:end-1]
        Q    = @. 2.0 / ((λ[1:end-2, 2:end-1, 2:end-1] + 2.0 * λc + λ[3:end, 2:end-1, 2:end-1]) * _dx^2 +
                         (λ[2:end-1, 1:end-2, 2:end-1] + 2.0 * λc + λ[2:end-1, 3:end, 2:end-1]) * _dy^2 +
                         (λ[2:end-1, 2:end-1, 1:end-2] + 2.0 * λc + λ[2:end-1, 2:end-1, 3:end]) * _dz^2)
        # convergence history
        itr_h = Float64[]
        res_h = Float64[]
        # effective main memory access per iteration [GB]
        A_eff = (2*2 + 2) * nx * ny * nz * sizeof(Float64) / 1e9
        # benchmark one iteration with BenchmarkTools
        if do_bench
            α     = 0.99 * (1 + β)
            t_it  = @belapsed compute!(\$u, \$d, \$z, \$r, \$qx, \$qy, \$qz, \$λ, \$Q, \$α, \$β, \$_dx, \$_dy, \$_dz)
            T_eff = A_eff / t_it
            @printf("BenchmarkTools: t_it = %1.3e s, T_eff = %1.2f GB/s\\n", t_it, T_eff)
            return
        end
        # iteration loop
        t_tic = Base.time(); niter_timed = 0
        for iter = 1:niter
            # start the timer after 10 warm-up iterations
            if iter == 11 t_tic = Base.time(); niter_timed = 0 end
            niter_timed += 1
            # update solution
            α = 0.99 * (1 + β)
            @parallel update_u!(u, d, α)
            # compute residual
            @parallel compute_q!(qx, qy, qz, u, λ, _dx, _dy, _dz)
            @parallel compute_r!(r, qx, qy, qz, _dx, _dy, _dz)
            # check convergence
            if do_check && iter % nchck == 0
                err = maximum(abs, r)
                push!(itr_h, iter / nx)
                push!(res_h, err)
                if err $(HTML("<")) εtol
                    println(" solver converged in \$(iter/nx) × N iterations! 🚀")
                    break
                end
            end
            # save old z
            if iter % ndrel == 0
                @. z0 = z
            end
            # compute preconditioned residual
            @parallel precondition!(z, r, Q)
            # update β
            if iter % ndrel == 0
                β = compute_β(d, z, z0)
            end
            # update search direction
            @parallel update_d!(d, z, β)
        end
        # performance
        t_toc = Base.time() - t_tic
        t_it  = t_toc / niter_timed # execution time per iteration [s]
        T_eff = A_eff / t_it        # effective memory throughput [GB/s]
        @printf("Time = %1.3f s, T_eff = %1.2f GB/s (niter = %d)\\n", t_toc, T_eff, niter_timed)
        # visualisation
        if do_visu
            u_slice = Array(u)[:, :, nz÷2]
            fig = Figure(size=(600, 750))
            ax  = (Axis(fig[1,1][1,1]; aspect=DataAspect(), xlabel="x", ylabel="y", title="solution at z = lz/2"),
                   Axis(fig[2,1]; xlabel="iter/nx", ylabel="|r|",
                                  yscale=log10,
                                  title="convergence history",
                                  limits=(0, niter/nx, 0.1εtol, 1e2)))
            plt = (heatmap!(ax[1], xc, yc, u_slice; colormap=:turbo),
                   lines!(ax[2], itr_h, res_h; color=:black))
            contour!(ax[1], xc, yc, u_slice; levels=0.05:0.1:0.95, color=:white)
            Colorbar(fig[1,1][1,2], plt[1])
            rowsize!(fig.layout, 1, Relative(0.65))
            save("elliptic_3d_dr_xpu.png", fig)
        end
        return Array(u), itr_h, res_h
    end

    elliptic_3d_dr()
    # performance: use nx=2^9 on the GPU
    elliptic_3d_dr(; nx=2^8, niter=110, do_check=false, do_visu=false)
    elliptic_3d_dr(; nx=2^8, do_check=false, do_visu=false, do_bench=true)
    ```

</details>

👉 Finally, create the script `elliptic_3d_dr_perf_xpu.jl`, a 3D version of `elliptic_2d_dr_perf_xpu.jl` with `@parallel_indices` kernels and the fused residual kernel.

<details>
<summary>Want to see the answer?</summary>

!!! answer "Answer"
    The kernels and the function `compute!` are:

    ```julia
    @parallel_indices (ix, iy, iz) function update_u!(u, d, α)
        u[ix+1, iy+1, iz+1] += α * d[ix, iy, iz]
        return
    end

    @parallel_indices (ix, iy, iz) function compute_r!(r, u, λ, _dx, _dy, _dz)
        qxW = -0.5 * (λ[ix  , iy+1, iz+1] + λ[ix+1, iy+1, iz+1]) * (u[ix+1, iy+1, iz+1] - u[ix  , iy+1, iz+1]) * _dx
        qxE = -0.5 * (λ[ix+1, iy+1, iz+1] + λ[ix+2, iy+1, iz+1]) * (u[ix+2, iy+1, iz+1] - u[ix+1, iy+1, iz+1]) * _dx
        qyS = -0.5 * (λ[ix+1, iy  , iz+1] + λ[ix+1, iy+1, iz+1]) * (u[ix+1, iy+1, iz+1] - u[ix+1, iy  , iz+1]) * _dy
        qyN = -0.5 * (λ[ix+1, iy+1, iz+1] + λ[ix+1, iy+2, iz+1]) * (u[ix+1, iy+2, iz+1] - u[ix+1, iy+1, iz+1]) * _dy
        qzB = -0.5 * (λ[ix+1, iy+1, iz  ] + λ[ix+1, iy+1, iz+1]) * (u[ix+1, iy+1, iz+1] - u[ix+1, iy+1, iz  ]) * _dz
        qzT = -0.5 * (λ[ix+1, iy+1, iz+1] + λ[ix+1, iy+1, iz+2]) * (u[ix+1, iy+1, iz+2] - u[ix+1, iy+1, iz+1]) * _dz
        r[ix, iy, iz] = -((qxE - qxW) * _dx + (qyN - qyS) * _dy + (qzT - qzB) * _dz)
        return
    end

    @parallel_indices (ix, iy, iz) function precondition!(z, r, Q)
        z[ix, iy, iz] = Q[ix, iy, iz] * r[ix, iy, iz]
        return
    end

    @parallel_indices (ix, iy, iz) function update_d!(d, z, β)
        d[ix, iy, iz] = d[ix, iy, iz] * β + z[ix, iy, iz]
        return
    end

    function compute!(u, d, z, r, λ, Q, α, β, _dx, _dy, _dz)
        nx, ny, nz = size(u)
        @parallel (1:nx-2, 1:ny-2, 1:nz-2) update_u!(u, d, α)
        @parallel (1:nx-2, 1:ny-2, 1:nz-2) compute_r!(r, u, λ, _dx, _dy, _dz)
        @parallel precondition!(z, r, Q)
        @parallel update_d!(d, z, β)
        return
    end
    ```

    In the function `elliptic_3d_dr`, remove the arrays `qx`, `qy` and `qz`, and launch `update_u!` and `compute_r!` with the ranges `(1:nx-2, 1:ny-2, 1:nz-2)`.

</details>

On the M2 Max laptop, with 8 threads and 256 × 256 × 256 grid cells, i.e. as many grid cells as in 2D, we measured (in GB/s):

| Version                       | manual timer | `@belapsed compute!(...)` |
| :---------------------------- | :----------: | :-----------------------: |
| `elliptic_3d_dr_xpu.jl`       | 16           | 18                        |
| `elliptic_3d_dr_perf_xpu.jl`  | 27           | 39                        |

In 3D, the solver accesses 18 arrays per iteration with math-close notation, and 12 arrays with the fused residual kernel, while ``A_\\mathrm{eff}`` counts 6 arrays. The upper bounds of ``T_\\mathrm{eff}``, 33% and 50% of ``T_\\mathrm{peak}``, are thus similar to 2D. Why is ``T_\\mathrm{eff}`` lower in 3D?

<details>
<summary>Discussion</summary>

Our count of the memory accesses assumes that neighbouring array elements are loaded together from main memory, and then reused from the cache. In 2D, the neighbours in the y direction are one column, i.e. `nx` elements, apart in memory. In 3D, the neighbours in the z direction are one xy-plane, i.e. `nx × ny` elements, apart. To reuse the values of an array, the cache must hold several planes of it, which is often not the case: some values are loaded from main memory several times, and the actual memory traffic is larger than our estimate. GPUs face the same challenge. Optimising 3D stencil codes for the caches and the on-chip memory is an advanced topic, which we will come back to later in this course.

</details>

👉 Measure ``T_\\mathrm{eff}`` of both 3D versions on a GH200 of daint with `nx = 2^9`, i.e. 512 × 512 × 512 grid cells.

!!! note "Memory usage in 3D"
    With 512 × 512 × 512 grid cells, every array occupies about 1.1 GB of memory. The math-close version allocates 10 arrays, i.e. about 11 GB, which fits into the 96 GB of the GH200. Keep the memory usage in mind when increasing the resolution: doubling the number of grid cells in every direction increases the memory usage by a factor of 8.

## Towards multi-xPU

ParallelStencil is seamlessly interoperable with [ImplicitGlobalGrid.jl](https://github.com/eth-cscs/ImplicitGlobalGrid.jl), which distributes stencil-based xPU applications on a regular staggered grid across many CPUs or GPUs, and achieves close to ideal weak scaling on thousands of GPUs. Moreover, ParallelStencil can hide the communication between GPUs behind the computations with a single macro call. This will be the topic of the next lectures.

!!! note
    Head to ParallelStencil's [miniapp section](https://github.com/omlins/ParallelStencil.jl#concise-singlemulti-xpu-miniapps) if you are curious about applications from various domain sciences implemented with ParallelStencil.

## Wrapping up

- With ParallelStencil.jl, a single code runs on CPUs and GPUs: the backend is selected in `@init_parallel_stencil`, and the arrays are allocated with `@zeros` or copied to the backend with `Data.Array`.
- `@parallel` kernels with math-close notation are concise, and are easy to extend from 2D to 3D. `@parallel_indices` kernels give full control over the computations of every thread, e.g. for kernel fusion.
- We extended the DR solver to 2D and 3D: the number of iterations still scales linearly with the number of grid cells in each direction. Defining `λ` at the cell centres, and averaging it to the cell faces, reduces the memory footprint of the solver.

# Testing and continuous integration

In [lecture 4](https://pde-on-gpu.vaw.ethz.ch/part2_solving_pdes_on_gpus/lecture04/#Unit-testing-in-Julia), we wrote unit tests with the `Test` standard library. In this part, we will put a solver into a small Julia package, test it with `] test`, and run the tests automatically on GitHub after every push.

Nowadays, good numerical software is expected to be well tested. The [final projects](https://pde-on-gpu.vaw.ethz.ch/final_projects/) of this course must therefore contain unit and reference tests, which run automatically on GitHub.

## Kinds of tests

- **Unit tests** check small parts of the code, usually single functions.
- **Integration tests** check larger parts of the code, e.g. a whole solver.
- **Reference tests** compare the results of the code with the results of a previous version, which we consider correct. A reference test doesn't tell whether the results are correct, but it detects any change of the results, e.g. after optimising the code.
- **Continuous integration (CI)** runs the tests automatically whenever the code changes, e.g. on every push to GitHub.

!!! note "Reference tests of simulations"
    The results of floating-point computations depend on the order of the operations, e.g. on the GPU or with a different number of threads. Compare the results approximately, with `≈` and a suitable tolerance. For large simulations, compare only the values at a few tens of grid points.

## A small package

The command `test` of the package mode runs the tests of a package, which are located in the file `test/runtests.jl`. A package is a Julia project with a name, a unique identifier (UUID), and a module of the same name in the file `src/<name>.jl`.

👉 Generate a package `Elliptic1D` on your computer, outside your course repository:

```julia-repl
julia> ]

(@v1.12) pkg> generate Elliptic1D
  Generating  project Elliptic1D:
    Elliptic1D/Project.toml
    Elliptic1D/src/Elliptic1D.jl
```

`generate` creates the folder `Elliptic1D` with the file `Project.toml`, which contains the name and the UUID of the package, and the file `src/Elliptic1D.jl` with the module `Elliptic1D`.

👉 Replace the content of `src/Elliptic1D.jl` with the DR solver from lecture 4, without the plotting and the timing:

- Move the `β` update into a function `compute_β(d, z, z0)`, which we can test separately.
- Return the solution and the convergence history.
- Export the function `elliptic_1d_dr`, so that it is available after `using Elliptic1D`.

Then, start Julia in the package folder with `julia --project`, and add the dependency `LinearAlgebra` with `] add LinearAlgebra`. Even standard libraries have to be declared as dependencies of a package.

<details>
<summary>Want to see the answer?</summary>

!!! answer "Answer"
    ```julia
    module Elliptic1D

    using LinearAlgebra

    export elliptic_1d_dr

    # estimate the damping parameter β from the search direction d
    # and the change of the preconditioned residual z - z0
    function compute_β(d, z, z0)
        γ = abs(dot(d, z .- z0)) / dot(d, d)
        return (1 - sqrt(γ))^2
    end

    @views function elliptic_1d_dr(; nx=200, niter=15nx)
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
        # iteration loop
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
                if err $(HTML("<")) εtol
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
                β = compute_β(d, z, z0)
            end
            # update search direction
            @. d = d * β + z
        end
        return u, itr_h, res_h
    end

    end # module Elliptic1D
    ```

</details>

## Writing the tests

The tests of a package run in a separate environment, which contains the package itself and the dependencies of the tests. We declare these in the file `test/Project.toml`.

👉 Create the test environment, and add the `Test` standard library to it:

```julia-repl
(Elliptic1D) pkg> activate test

(test) pkg> add Test

(test) pkg> activate .
```

👉 Create the file `test/runtests.jl`, which loads the packages `Elliptic1D` and `Test`, and contains:

- unit tests of the function `compute_β`: if `z` doesn't change, then ``\\gamma = 0`` and ``\\beta = 1``; if `z` changes by `d`, then ``\\gamma = 1`` and ``\\beta = 0``;
- a reference test: run the solver with `nx = 64`, check that it converges, and compare the solution at a few grid points with reference values, which you obtain from a run of your current solver.

Functions that are not exported, such as `compute_β`, are accessed with the module name: `Elliptic1D.compute_β`.

<details>
<summary>Want to see the answer?</summary>

!!! answer "Answer"
    ```julia
    using Elliptic1D
    using Test

    @testset "Elliptic1D" begin
        @testset "unit tests: compute_β" begin
            d  = [1.0, 2.0, 3.0]
            z0 = [0.5, 0.5, 0.5]
            # z doesn't change: γ = 0, no damping
            @test Elliptic1D.compute_β(d, z0, z0) == 1.0
            # z changes by d: γ = 1, full damping
            @test Elliptic1D.compute_β(d, z0 .+ d, z0) ≈ 0.0 atol=1e-12
        end

        @testset "reference test" begin
            u, itr_h, res_h = elliptic_1d_dr(; nx=64)
            # the solver converges
            @test res_h[end] $(HTML("<")) 1e-6
            # the solution matches the reference values from a previous run
            inds  = [8, 16, 32, 48, 56]
            u_ref = [0.12964753561537531, 0.2778162895920091, 0.49914932793046585, 0.70365130873788, 0.8518255710551478]
            @test u[inds] ≈ u_ref rtol=1e-6
        end
    end
    ```

</details>

👉 Run the tests with `] test`:

```julia-repl
(Elliptic1D) pkg> test
     Testing Elliptic1D
...
     Testing Running tests...
Test Summary: | Pass  Total  Time
Elliptic1D    |    4      4  1.0s
     Testing Elliptic1D tests passed
```

Check that the tests detect errors: e.g., change the sign of the flux in the solver, and run the tests again.

!!! note "Testing ParallelStencil codes"
    ParallelStencil can only be initialised once per Julia session. To test 2D and 3D codes in the same package, start a separate Julia process for each of them from `test/runtests.jl`. `Base.julia_cmd()` returns the command that starts the current Julia executable, and `Base.active_project()` the project of the test environment.

## Continuous integration with GitHub Actions

With continuous integration, the tests run automatically on every push to GitHub. This makes sure that:

- the tests are always run;
- failing tests are noticed immediately, e.g. in a pull request, and GitHub notifies you by email.

[GitHub Actions](https://docs.github.com/en/actions) runs workflows, which are defined in YAML files in the folder `.github/workflows` of a repository. For example, this course's website is generated from the lecture files, and deployed by the workflow [`ExportNotebooks.yml`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/.github/workflows/ExportNotebooks.yml) on every push to the course repository.

👉 Create the file `.github/workflows/CI.yml` in the package folder:

```yaml
name: CI
on:
  push:
    branches:
      - main
  pull_request:
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
      - uses: julia-actions/setup-julia@v3
        with:
          version: "1.12"
      - uses: julia-actions/cache@v3
      - uses: julia-actions/julia-buildpkg@v1
      - uses: julia-actions/julia-runtest@v1
```

The workflow runs on every pull request, and on every push to the `main` branch. Its steps run on a virtual machine with Ubuntu Linux:

1. `actions/checkout` downloads the repository;
2. `julia-actions/setup-julia` installs Julia 1.12;
3. `julia-actions/cache` caches the installed packages, which speeds up the following runs;
4. `julia-actions/julia-buildpkg` installs the dependencies of the package;
5. `julia-actions/julia-runtest` runs the tests, as `] test` does.

👉 Create a new repository `Elliptic1D.jl` in your personal GitHub account, not in the course organisation. Add a file `.gitignore` containing `Manifest.toml` to the package folder, and push the package to the new repository:

```sh
cd Elliptic1D
git init
git add .
git commit -m "Add Elliptic1D package"
git branch -M main
git remote add origin git@github.com:<username>/Elliptic1D.jl.git
git push -u origin main
```

The tests now run in the tab *Actions* of the repository. The first run takes a few minutes, since Julia has to be installed and the packages precompiled.

The repository [course-101-0250-00-L6Testing.jl](https://github.com/eth-vaw-glaciology/course-101-0250-00-L6Testing.jl) from a previous year of this course shows another small package with tests and CI.

!!! warning "No GPUs on GitHub"
    The virtual machines of GitHub Actions don't have GPUs. To test xPU codes on GitHub, run the tests with a CPU backend.

### Status badge

GitHub creates a badge, i.e. a small image, which shows the status of the latest run of a workflow:

![CI status badge](../assets/l6_ci-badge.png)

It is usually added to the `README.md` file, right below the title, with a link to the runs of the workflow:

```markdown
[![CI](https://github.com/<username>/Elliptic1D.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/<username>/Elliptic1D.jl/actions/workflows/CI.yml)
```

👉 Add a `README.md` file with the title `# Elliptic1D.jl` and the badge to your package, and push it. The badge turns green once the tests pass.

!!! note "CI minutes"
    GitHub Actions is free for public repositories. For private repositories, the run time is limited, e.g. to 2000 minutes per month on GitHub's free plan. In any case, keep your tests short: use small grids, and only a few hundred iterations.

## Wrapping up

- Unit tests check single functions. Reference tests compare the results of the code with the results of a previous version. Compare floating-point results approximately, with a tolerance.
- `] test` runs the file `test/runtests.jl` of a package, in an environment with the package and the dependencies in `test/Project.toml`.
- With continuous integration, GitHub Actions runs the tests on every push, and the status badge shows the result.
