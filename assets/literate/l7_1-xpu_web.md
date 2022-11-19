<!--This file was generated, do not modify it.-->
# Julia xPU: the two-language solution

### The goal of this lecture 7:

- Address the **_two-language problem_**
- Backend portable xPU implementation
- Towards 3D porous convection
- Reference testing, GitHub CI and workflows

## The two-language problem

Combining CPU and GPU implementation within a single code.

You may certainly be familiar with this situation in scientific computing:

![two-lang problem](../assets/literate_figures/l7_2lang_1.png)

Which may turn out into a costly cycle:

![two-lang problem](../assets/literate_figures/l7_2lang_2.png)

This situation is referred to as the **_two-language problem_**.

Multi-language/software environment leads to:
- Translation errors
- Large development time (overhead)
- Non-portable solutions

Good news! Julia is a perfect candidate to solve the **_two-language problem_** as Julia code is:
- **_simple_**, high-level, interactive (low development costs)
- **_fast_**, compiled just ahead of time (before one uses it for the first time)

@@img-med
![two-lang problem](../assets/literate_figures/l7_2lang_3.png)
@@

Julia provides a **_portable_** solution in many aspects (beyond performance portability).

As you may have started to experience, GPUs deliver great performance but may not be present in every laptop or workstation. Also, powerful GPUs require to be hosted in servers, especially when multiple GPUs are needed to perform high-resolution calculations.

Wouldn't it be great to have **single code that both executes on CPU and GPU?**

> Using the CPU "backend" for prototyping and debugging, and switching to the GPU "backend" for production purpose.

Wouldn't it be great? ... **YES**, and there is a Julia solution!

@@img-med
![ParallelStencil](../assets/literate_figures/l7_ps_logo.png)
@@

## Backend portable xPU implementation

Let's get started with [ParallelStencil.jl](https://github.com/omlins/ParallelStencil.jl)

### Getting started with ParallelStencil

ParallelStencil enables to:
- Write architecture-agnostic high-level code
- Parallel high-performance stencil computations on GPUs and CPUs

ParallelStencil relies on the native kernel programming capabilities of:
- [CUDA.jl](https://cuda.juliagpu.org/stable/) for high-performance computations on Nvidia GPUs
- [Base.Threads](https://docs.julialang.org/en/v1/base/multi-threading/#Base.Threads) for high-performance computations on CPUs
- And _to be released soon_ [AMDGPU.jl](https://amdgpu.juliagpu.org/stable/) for high-performance computations on AMD GPUs

### Short tour of ParallelStencil's `README`

Before we start our exercises, let's have a rapid tour of [ParallelStencil](https://github.com/omlins/ParallelStencil.jl)'s repo and [`README`](https://github.com/omlins/ParallelStencil.jl).

_So, how does it work?_

As first hands-on for this lecture, let's _**merge**_ the 2D fluid pressure diffusion solvers [`diffusion_2D_perf_loop_fun.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/) and the [`diffusion_2D_perf_gpu.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/) into a single _**xPU**_ code using ParallelStencil.

\note{Two approaches are possible (we'll implement both). Parallelisation using stencil computations with 1) math-close notation; 2) more explicit kernel programming approach.}

### Stencil computations with math-close notation

Let's get started with using the ParallelStencil.jl module and the `ParallelStencil.FiniteDifferences2D` submodule to enable math-close notation.

💻 We'll start from the `Pf_diffusion_2D_perf_gpu.jl` (available later in the [scripts/](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/) folder in case you don't have it from lecture 6) to create the `Pf_diffusion_2D_xpu.jl` script.

The first step is to handle the packages:

````julia:ex1
const USE_GPU = false
using ParallelStencil
using ParallelStencil.FiniteDifferences2D
@static if USE_GPU
    @init_parallel_stencil(CUDA, Float64, 2)
else
    @init_parallel_stencil(Threads, Float64, 2)
end
using Plots,Plots.Measures,Printf
````

Then, we need to update the two compute functions , `compute_flux!` and `update_Pf!`.

Let's start with `compute_flux!`.

ParallelStencil's `FiniteDifferences2D` submodule provides macros we need: `@inn_x()`, `@inn_y()`, `@d_xa()`, `@d_ya()`.

The macros used in this example are described in the Module documentation callable from the Julia REPL / IJulia:
```julia-repl
julia> using ParallelStencil.FiniteDifferences2D

julia>?

help?> @inn_x
  @inn_x(A): Select the inner elements of A in dimension x. Corresponds to A[2:end-1,:].
```
This would, e.g., give you more infos about the `@inn_x` macro.

So, back to our compute function (kernel). The `compute_flux!` function gets the `@parallel` macro in its definition and returns nothing.

Inside, we define the flux definition as following:

````julia:ex2
@parallel function compute_flux!(qDx,qDy,Pf,k_ηf_dx,k_ηf_dy,_1_θ_dτ)
    @inn_x(qDx) = @inn_x(qDx) - (@inn_x(qDx) + k_ηf_dx*@d_xa(Pf))*_1_θ_dτ
    @inn_y(qDy) = @inn_y(qDy) - (@inn_y(qDy) + k_ηf_dy*@d_ya(Pf))*_1_θ_dτ
    return nothing
end
````

Note that currently the shorthand `-=` notation is not supported and we need to explicitly write out the equality. Now that we're done with `compute_flux!`, your turn!

By analogy, update `update_Pf!`.

````julia:ex3
@parallel function update_Pf!(Pf,qDx,qDy,_dx,_dy,_β_dτ)
    @all(Pf) = @all(Pf) - (@d_xa(qDx)*_dx + @d_ya(qDy)*_dy)*_β_dτ
    return nothing
end
````

So far so good. We are done with the kernels. Let's see what changes are needed in the main part of the script.

In the `# numerics` section, `threads` and `blocks` are no longer needed; the kernel launch parameters being now automatically adapted:

````julia:ex4
function Pf_diffusion_2D(;do_check=false)
    # physics
    # [...]
    # numerics
    nx, ny  = 16*32, 16*32 # number of grid points
    maxiter = 500
    # [...]
    return
end
````

In the `# array initialisation` section, we need to wrap the Gaussian by `Data.Array` (instead of `CuArray`) and use the `@zeros` to initialise the other arrays:

````julia:ex5
# [...]
# array initialisation
Pf      = Data.Array( @. exp(-(xc-lx/2)^2 -(yc'-ly/2)^2) )
qDx     = @zeros(nx+1,ny  )
qDy     = @zeros(nx  ,ny+1)
r_Pf    = @zeros(nx  ,ny  )
# [...]
````

In the `# iteration loop`, only the kernel call needs to be worked out. We can here re-use the single `@parallel` macro which now serves to launch the computations on the chosen backend:

````julia:ex6
# [...]
# iteration loop
iter = 1; err_Pf = 2ϵtol
t_tic = 0.0; niter = 0
while err_Pf >= ϵtol && iter <= maxiter
    if (iter==11) t_tic = Base.time(); niter = 0 end
    @parallel compute_flux!(qDx,qDy,Pf,k_ηf_dx,k_ηf_dy,_1_θ_dτ)
    @parallel update_Pf!(Pf,qDx,qDy,_dx,_dy,_β_dτ)
    if do_check && (iter%ncheck == 0)
        #  [...]
    end
    iter += 1; niter += 1
end
# [...]
````

The performance evaluation section remaining unchanged, we are all set!

**Wrap-up tasks**
- Let's execute the code having the `USE_GPU = false` flag set. We are running on multi-threading CPU backend with multi-threading enabled.

- Changing the `USE_GPU` flag to `true` (having first relaunched a Julia session) will make the application running on a GPU. On the GPU, you can reduce `ttot` and increase `nx, ny` in order achieve higher $T_\mathrm{eff}$.

\note{Curious to see how it works under the hood? Feel free to [explore the source code](https://github.com/omlins/ParallelStencil.jl/blob/cd59a5b0d1fd32ceaecbf7fc922ab87a24257781/src/ParallelKernel/parallel.jl#L263). Another nice bit of open source software (and the fact that Julia's meta programming rocks 🚀).}

### Stencil computations with more explicit kernel programming approach

ParallelStencil also allows for more explicit kernel programming, enabled by `@parallel_indices` kernel definitions. In style, the codes are closer to the initial plain GPU version we started from, [`diffusion_2D_perf_gpu.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/).

As the macro name suggests, kernels defined using `@parallel_indices` allow for explicit indices handling within the kernel operations. This approach is _**currently**_ slightly more performant than using `@parallel` kernel definitions.

As second step, let's transform the `Pf_diffusion_2D_xpu.jl` into `Pf_diffusion_2D_perf_xpu.jl`.

💻 We'll need bits from both `Pf_diffusion_2D_perf_gpu.jl` and `Pf_diffusion_2D_xpu.jl`.

We can keep the package handling and initialisation identical to what we implemented in the `Pf_diffusion_2D_xpu.jl` script, but start again from the `Pf_diffusion_2D_perf_gpu.jl` script.

Then, we can modify the `compute_flux!` function definition from the `diffusion_2D_perf_gpu.jl` script, removing the `ix`, `iy` indices as those are now handled by ParallelStencil. The function definition takes however the `@parallel_indices` macro and the `(ix,iy)` tuple:

````julia:ex7
macro d_xa(A)  esc(:( $A[ix+1,iy]-$A[ix,iy] )) end
macro d_ya(A)  esc(:( $A[ix,iy+1]-$A[ix,iy] )) end

@parallel_indices (ix,iy) function compute_flux!(qDx,qDy,Pf,k_ηf_dx,k_ηf_dy,_1_θ_dτ)
    nx,ny=size(Pf)
    if (ix<=nx-1 && iy<=ny  )  qDx[ix+1,iy] -= (qDx[ix+1,iy] + k_ηf_dx*@d_xa(Pf))*_1_θ_dτ  end
    if (ix<=nx   && iy<=ny-1)  qDy[ix,iy+1] -= (qDy[ix,iy+1] + k_ηf_dy*@d_ya(Pf))*_1_θ_dτ  end
    return nothing
end
````

The `# physics` section remains unchanged, and the `# numerics section` is identical to the previous `xpu` script, i.e., no need for explicit block and thread definition.

\warn{ParallelStencil computes the GPU kernel launch parameters based on optimal heuristics. Recalling lecture 6, multiple of 32 are most optimal; number of grid points should thus be chosen accordingly, i.e. as multiple of 32.}

We can then keep the scalar preprocessing in the `# derived numerics` section.

In the `# array initialisation`, make sure to wrap the Gaussian by `Data.Array`, initialise zeros with the `@zeros` macro and remove information about precision (`Float64`)from there.

The `# iteration loop` remains concise; xPU kernels are launched here also with `@parallel` macro (that implicitly includes `synchronize()` statement):

````julia:ex8
# [...]
# iteration loop
iter = 1; err_Pf = 2ϵtol
t_tic = 0.0; niter = 0
while err_Pf >= ϵtol && iter <= maxiter
    if (iter==11) t_tic = Base.time(); niter = 0 end
    @parallel compute_flux!(qDx,qDy,Pf,k_ηf_dx,k_ηf_dy,_1_θ_dτ)
    @parallel update_Pf!(Pf,qDx,qDy,_dx,_dy,_β_dτ)
    if do_check && (iter%ncheck == 0)
        # [...]
    end
    iter += 1; niter += 1
end
# [...]
````

Here we go 🚀 The `Pf_diffusion_2D_perf_xpu.jl` code is ready and should squeeze the performance out of your CPU or GPU, running as fast as the exclusive Julia multi-threaded or Julia GPU implementations, respectively.

### Multi-xPU support

_What about multi-xPU support and distributed memory parallelisation?_

ParallelStencil is seamlessly interoperable with [`ImplicitGlobalGrid.jl`](https://github.com/eth-cscs/ImplicitGlobalGrid.jl), which enables distributed parallelisation of stencil-based xPU applications on a regular staggered grid and enables close to ideal weak scaling of real-world applications on thousands of GPUs.

Moreover, ParallelStencil enables hiding communication behind computation with a simple macro call and without any particular restrictions on the package used for communication.

_This will be material for next lectures._

\note{Head to ParallelStencil's [miniapp section](https://github.com/omlins/ParallelStencil.jl#concise-singlemulti-xpu-miniapps) if you are curious about various domain science applications featured there.}

## Towards 3D thermal porous convection

The goal of the first project of the course is to have a thermal porous convection solver in 3D. Before using multiple GPUs in order to afford high numerical resolution in 3D, we will first have to create a 3D single xPU thermal porous convection solver.

The first step is to port the `Pf_diffusion_2D_xpu.jl` script to 3D.

These are the steps to follow in order to make the transition happen.
1. Copy and rename the `Pf_diffusion_2D_xpu.jl` script to `Pf_diffusion_3D_xpu.jl`
2. Adapt the last argument of `@init_parallel_stencil` to `3`
3. Compute `qDz`, the flux in `z`-direction
4. Add that flux to the divergence in the `Pf` update
5. Modify the `CFL` to `cfl = 1.0/sqrt(3.1)` as for 3D
6. Consistently add the `z`-direction in the code

The initialisation can be done as following:

````julia:ex9
Pf = Data.Array([exp(-(xc[ix]-lx/2)^2 -(yc[iy]-ly/2)^2 -(zc[iz]-lz/2)^2) for ix=1:nx,iy=1:ny,iz=1:nz])
````

And don't forget to update `A_eff` in the performance formula!

_Note that 3D simulations are expensive so make sure to adapt the number of grid points accordingly. As example, on a P100 GPU, we won't be able to squeeze much more than `511^3` resolution for a diffusion solver, and the entire porous convection code will certainly not execute at more then `255^3` or `383^3`._

