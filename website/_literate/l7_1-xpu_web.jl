#src # This is needed to make this run as normal Julia file
using Markdown #src

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
#nb # _Lecture 7_
md"""
# Julia XPU: the two-language solution
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### The goal of this lecture 7:

- Address the **_two-language problem_**
- Backend portable XPU implementation
- Towards Stokes I: acoustic to elastic
- Reference testing, GitHub CI and workflows
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## The two-language problem
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Combining CPU and GPU implementation within a single code.
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
You may certainly be familiar with this situation in scientific computing:

![two-lang problem](../assets/literate_figures/l7-2lang_1.png)
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Which may turn out into a costly cycle:

![two-lang problem](../assets/literate_figures/l7-2lang_2.png)

"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
This situation is referred to as the **_two-language problem_**.
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Multi-language/software environment leads to:
- Translation errors
- Large development time (overhead)
- Non-portable solutions
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Good news! Julia is a perfect candidate to solve the **_two-language problem_** as Julia code is:
- **_simple_**, high-level, interactive (low development costs)
- **_fast_**, compiled just ahead of time (before one uses it for the first time)
"""

#md # @@img-med
# ![two-lang problem](../assets/literate_figures/l7-2lang_3.png)
#md # @@

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Julia provides a **_portable_** solution in many aspects (beyond performance portability).
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
As you may have started to experience, GPUs deliver great performance but may not be present in every laptop or workstation. Also, powerful GPUs require to be hosted in servers, especially when multiple GPUs are needed to perform high-resolution calculations.
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Wouldn't it be great to have **single code that both executes on CPU and GPU?**
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
> Using the CPU "backend" for prototyping and debugging, and switching to the GPU "backend" for production purpose.
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Wouldn't it be great? ... **YES**, and there is a Julia solution!
"""

#md # @@img-med
# ![ParallelStencil](../assets/literate_figures/ps_logo.png)
#md # @@


#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## Backend portable XPU implementation
"""

#nb # ![ParallelStencil](../assets/literate_figures/ps_logo.png)


#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Let's get started with [ParallelStencil.jl](https://github.com/omlins/ParallelStencil.jl)
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### Getting started with ParallelStencil

ParallelStencil enables to:
- Write architecture-agnostic high-level code
- Parallel high-performance stencil computations on GPUs and CPUs

"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
ParallelStencil relies on the native kernel programming capabilities of:
- [CUDA.jl](https://cuda.juliagpu.org/stable/) for high-performance computations on GPUs
- [Base.Threads](https://docs.julialang.org/en/v1/base/multi-threading/#Base.Threads) for high-performance computations on CPUs
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### Short tour of ParallelStencil's README

Before we start our push-up exercises, let's have a rapid tour of [ParallelStencil](https://github.com/omlins/ParallelStencil.jl)'s repo and [`README`](https://github.com/omlins/ParallelStencil.jl).

"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
_So, how does it work?_

As first hands-on for this lecture, let's _**merge**_ the diffusion 2D solvers [`diffusion_2D_perf_loop_fun.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/) and the [`diffusion_2D_perf_gpu.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/) into a single _**XPU**_ code using ParallelStencil.
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
#nb # > 💡 note: Two approaches are possible (we'll implement both). Parallelisation using stencil computations with 1) math-close notation; 2) more explicit kernel programming approach.
#md # \note{Two approaches are possible (we'll implement both). Parallelisation using stencil computations with 1) math-close notation; 2) more explicit kernel programming approach.}



#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### Stencil computations with math-close notation

Let's get started with using the ParallelStencil.jl module and the `ParallelStencil.FiniteDifferences2D` submodule to enable math-close notation.

💻 We'll start from the [`diffusion_2D_perf_gpu.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/) (available in the [scripts/](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/) folder in case you don't have it at hand from lecture 6) to create the `diffusion_2D_xpu.jl` script.
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
The first step is to handle the packages:
"""
const USE_GPU = false
using ParallelStencil
using ParallelStencil.FiniteDifferences2D
@static if USE_GPU
    @init_parallel_stencil(CUDA, Float64, 2)
else
    @init_parallel_stencil(Threads, Float64, 2)
end
using Plots, Printf

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Then, we need to create two compute functions , `compute_q!` to compute the fluxes, and `compute_C!` for computing the update of `C`, the quantity we diffusion (e.g. concentration).
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Let's start with `compute_q!`. There we want to program the following fluxes

$$ q_x = -D\frac{∂C}{∂x} ~,~~ q_y = -D\frac{∂C}{∂y} ~.$$

"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
ParallelStencil's `FiniteDifferences2D` submodule provides macros we need: `@all()`, `@d_xi()`, `@d_yi()`.

The macros used in this example are described in the Module documentation callable from the Julia REPL / IJulia:
```julia
julia> using ParallelStencil.FiniteDifferences2D

julia>?

help?> @all
```
This would, e.g., give you more infos about the `@all` macro. 
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
So, back to our compute function (kernel). The `compute_q!` function gets the `@parallel` macro in its definition and returns nothing.

Inside, we define the flux definition as following:
"""
@parallel function compute_q!(qx, qy, C, D, dx, dy)
    @all(qx) = -D*@d_xi(C)/dx
    @all(qy) = -D*@d_yi(C)/dy
    return
end

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Now that we're done with `compute_q!`, your turn!

By analogy, update `compute_C!`.
"""
@parallel function compute_C!(C, qx, qy, dt, dx, dy)
   @inn(C) = @inn(C) - dt*( @d_xa(qx)/dx + @d_ya(qy)/dy )
    return
end

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
So far so good. We are done with the kernels. Let's see what changes are needed in the main part of the script.

In the `# Physics` section, change total time to `ttot = 1e2`. The `# Numerics` only needs `nx`, `ny` and `nout`; the kernel launch parameters being now automatically adapted:
"""
@views function diffusion_2D(; do_visu=false)
    ## Physics
    Lx, Ly  = 10.0, 10.0
    D       = 1.0
    ttot    = 1e2
    ## Numerics
    nx, ny  = 32*4, 32*4 # number of grid points
    nout    = 50
    ## [...]
    return
end

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
In the `# Derived numerics`, we can skip the scalar pre-processing, keeping only
"""
## [...]
## Derived numerics
dx, dy  = Lx/nx, Ly/ny
dt      = min(dx,dy)^2/D/4.1
nt      = cld(ttot, dt)
xc, yc  = LinRange(dx/2, Lx-dx/2, nx), LinRange(dy/2, Ly-dy/2, ny)
## [...]

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
In the `# Array initialisation` section, we need to wrap the Gaussian by `Data.Array` (instead of `CuArray`) and initialise the flux arrays:
"""
## [...]
## Array initialisation
C       = Data.Array(exp.(.-(xc .- Lx/2).^2 .-(yc' .- Ly/2).^2))
qx      = @zeros(nx-1,ny-2)
qy      = @zeros(nx-2,ny-1)
## [...]

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
In the `# Time loop`, only the kernel call needs to be worked out. We can here re-use the single `@parallel` macro which now serves to launch the computations on the chosen backend:
"""
## [...]
t_tic = 0.0; niter = 0
## Time loop
for it = 1:nt
    if (it==11) t_tic = Base.time(); niter = 0 end
    @parallel compute_q!(qx, qy, C, D, dx, dy)
    @parallel compute_C!(C, qx, qy, dt, dx, dy)
    niter += 1
    if do_visu && (it % nout == 0)
        ## visualisation unchanged
    end
end
## [...]

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
The performance evaluation section remaining unchanged, we are all set!

**Wrap-up tasks**
- Let's execute the code having the `USE_GPU = false` flag set. We are running on multi-threading CPU backend with multi-threading enabled.
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
- Changing the `USE_GPU` flag to `true` (having first relaunched a Julia session) will make the application running on a GPU. On the GPU, you can reduce `ttot` and increase `nx, ny` in order achieve higher $T_\mathrm{eff}$.
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
#nb # > 💡 note: Curious to see how it works under the hood? Feel free to [explore the source code](https://github.com/omlins/ParallelStencil.jl/blob/cd59a5b0d1fd32ceaecbf7fc922ab87a24257781/src/ParallelKernel/parallel.jl#L263). Another nice bit of open source software (and the fact that Julia's meta programming rocks 🚀).
#md # \note{Curious to see how it works under the hood? Feel free to [explore the source code](https://github.com/omlins/ParallelStencil.jl/blob/cd59a5b0d1fd32ceaecbf7fc922ab87a24257781/src/ParallelKernel/parallel.jl#L263). Another nice bit of open source software (and the fact that Julia's meta programming rocks 🚀).}


#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### Stencil computations with more explicit kernel programming approach

ParallelStencil also allows for more explicit kernel programming, enabled by `@parallel_indices` kernel definitions. In style, the codes are closer to the initial plain GPU version we started from, [`diffusion_2D_perf_gpu.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/).
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
As the macro name suggests, kernels defined using `@parallel_indices` allow for explicit indices handling within the kernel operations. This approach is _**currently**_ more performant than using `@parallel` kernel definitions.
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
As second push-up, let's transform the `diffusion_2D_xpu.jl` into `diffusion_2D_perf_xpu.jl`.

💻 We'll need bits from both [`diffusion_2D_perf_gpu.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/) and `diffusion_2D_xpu.jl`.
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
We can keep the package handling and initialisation identical to what we implemented in the `diffusion_2D_xpu.jl` script.
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Then, we can start from the flux macro an compute function definition from the `diffusion_2D_perf_gpu.jl` script, removing the `ix`, `iy` indices as those are now handled by ParallelStencil. The function definition takes however the `@parallel_indices` macro and the `(ix,iy)` tuple:
"""
## macros to avoid array allocation
macro qx(ix,iy)  esc(:( -D_dx*(C[$ix+1,$iy+1] - C[$ix,$iy+1]) )) end
macro qy(ix,iy)  esc(:( -D_dy*(C[$ix+1,$iy+1] - C[$ix+1,$iy]) )) end

@parallel_indices (ix,iy) function compute!(C2, C, D_dx, D_dy, dt, _dx, _dy, size_C1_2, size_C2_2)
    if (ix<=size_C1_2 && iy<=size_C2_2)
        C2[ix+1,iy+1] = C[ix+1,iy+1] - dt*( (@qx(ix+1,iy) - @qx(ix,iy))*_dx + (@qy(ix,iy+1) - @qy(ix,iy))*_dy )
    end
    return
end

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
The `# Physics` section remains unchanged, and the `# Numerics section` is identical to the previous `xpu` script, i.e., no need for explicit block and thread definition.
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
#nb # > 💡 note: ParallelStencil computes the GPU kernel launch parameters based on optimal heuristics. Recalling lecture 6, multiple of 32 are most optimal; number of grid points should thus be chosen accordingly, i.e. as multiple of 32.
#md # \warn{ParallelStencil computes the GPU kernel launch parameters based on optimal heuristics. Recalling lecture 6, multiple of 32 are most optimal; number of grid points should thus be chosen accordingly, i.e. as multiple of 32.}

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
We can then keep the scalar preprocessing (`D_dx`, `D_dy`, `_dx`, `_dy`) in the `# Derived numerics` section.

In the `# Array initialisation`, make sure wrapping the Gaussian by `Data.Array`. The `cuthreads` and `cublocks` tuples are no longer needed.
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
The `# Time loop` gets very concise; XPU kernels are launched here also with `@parallel` macro (that implicitly includes `synchronize()` statement):
"""
## Time loop
for it = 1:nt
    if (it==11) t_tic = Base.time(); niter = 0 end
    @parallel compute!(C2, C, D_dx, D_dy, dt, _dx, _dy, size_C1_2, size_C2_2)
    C, C2 = C2, C # pointer swap
    niter += 1
    if do_visu && (it % nout == 0)
        ## visu unchanged
    end
end

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Here we go 🚀 The `diffusion_2D_perf_xpu.jl` code is ready and should squeeze the performance out of your CPU or GPU, running as fast as the exclusive Julia multi-threaded or Julia GPU implementations, respectively.
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### Multi-XPU support

_What about multi-XPU support and distributed memory parallelisation?_

ParallelStencil is seamlessly interoperable with [`ImplicitGlobalGrid.jl`](), which enables distributed parallelisation of stencil-based XPU applications on a regular staggered grid and enables close to ideal weak scaling of real-world applications on thousands of GPUs.

Moreover, ParallelStencil enables hiding communication behind computation with a simple macro call and without any particular restrictions on the package used for communication.
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
_This will be material for next lectures._
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
#nb # > 💡 note: Head to ParallelStencil's [miniapp section](https://github.com/omlins/ParallelStencil.jl#concise-singlemulti-xpu-miniapps) if you are curious about various domain science applications featrued there.
#md # \note{Head to ParallelStencil's [miniapp section](https://github.com/omlins/ParallelStencil.jl#concise-singlemulti-xpu-miniapps) if you are curious about various domain science applications featrued there.}


#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## Towards Stokes flow I: acoustic to elastic
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Pursuing the exploration of various physical processes, we are missing two important categories: solid mechanics (e.g., Navier-Cauchy equations) and fluid mechanics (e.g., Navier-Stokes equations).

The goal of this part of the lecture is to explore the elastic wave propagation processes, building upon acoustic waves from lecture 3.

We'll use a practical approach to familiarise with stress, strain, strain-rates and elastic rheology, i.e., the elastic shear and bulk modulus. (We'll concentrate on the fluid mechanics in a following lecture.)
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
The [Navier-Cauchy equation](https://en.wikipedia.org/wiki/Linear_elasticity#Elastodynamics_in_terms_of_displacements) we are interested in reads as following, when expressed (linearised) in terms of velocities ($v=∂^2u/∂t^2$):

$$ \frac{∂P}{∂t} = -K ∇_k v_k ~,$$

$$ \frac{∂τ}{∂t} = μ\left(∇_i v_j + ∇_j v_i -\frac{1}{3} δ_{ij} ∇_k v_k \right) ~,$$

$$ ρ \frac{∂v_i}{∂t} = ∇_j \left( τ_{ij} - P δ_{ij} \right) ~,$$

where $P$ is the pressure, $v$ the velocity, $K$ the bulk modulus, $μ$ the elastic shear modulus, $τ$ the deviatoric stress tensor, $ρ$ the density, and $\delta_{ij}$ the Kronecker delta. 
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
One can recognise the terms from the acoustic wave equation, namely:

$$ \frac{∂P}{∂t} = -K ∇_k v_k ~,$$

$$ ρ \frac{∂v_i}{∂t} = ∇_j \left( - P δ_{ij} \right)~,$$

which suggests only volumetric or bulk effects to be considered in the latter.
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Note that the original constitutive relation in linear elasticity (elastic rheology) is

$$ σ = -P + μ \left(∇_i u_j + ∇_j u_i \right) ~.$$

However, we here consider deviatoric stresses $(τ)$ (removing the trace of the stress tensor - the pressure $P$) and derive the expression w.r.t. time to express it as function of strain-rates $(v)$.
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### Task 1 - starting from acoustic
The task is now to implement the Navier-Cauchy equations in 2D starting from the acoustic 2D script realised in lecture 3.

We can start from the [`acoustic_2D_elast0.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/) script located in the (available in the [scripts/](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/) folder).
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
After running the script to confirm all works as expected, start by:
- making a new version of the script: `acoustic_2D_elast1.jl`
- modifying the array dimensions in order to have velocity arrays with appropriate sizes allowing to update all pressure values `(nx, ny)`,
- renaming `qx` and `qy` to `dVxdt` and `dVydt`, respectively.
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### Task 2 - adding normal stresses
The next task is to add the normal stress, the $xx$ and $yy$ components of the stress tensor.

One can make the analogy of stresses being "fluxes of momentum", the velocity equations (4) being the momentum balance. Since we here consider elastic processes (Cauchy-Navier elasticity), these fluxes will be time dependent (see eq. 3).
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Start by making a new version of the script named `acoustic_2D_elast2.jl`. Then, add for the $xx$ normal stress component following (the array needs to be initialised):
```julia
τxx  .= τxx .+ dt*(2.0.*μ.* (diff(Vx,dims=1)/dx .- 1/3 .*∇V))
```
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Note that one has to remove the divergence (volumetric part) of the stress tensor if considering its deviatoric form (removing the trace of the tensor, i.e. the pressure we explicitly define and compute).

Also, adding elastic shear rheology, we need to define the elastic shear modulus $μ = 1$ in the `# Physics` section.
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Repeat this for the $yy$ normal stress component:
```julia
τyy  .= τyy .+ dt*(2.0.*μ.* (diff(Vy,dims=2)/dy) .- 1.0/3.0 .*∇V)
```

We now have to fix the divergence which is not yet defined, replacing the appropriate calculation by (that needs to be initialised):
```julia
∇V    .= diff(Vx,dims=1)./dx .+ diff(Vy,dims=2)./dy
```
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Having added elasticity to the acoustic process (elastic stresses instead of only pressure), we need to adapt the time step stability condition:
```julia
dt     = min(dx,dy)/sqrt((K + 4/3*μ)/ρ)/2.1
```
to take shear modulus $μ$ into account.

This new addition should now permit to propagate a first elastic wave. However, taking a closer look at the animation, you may certainly see that the wave propagates as a square. Reason for this is that we are missing the shear stress, the $xy$ components of the tensor (see figure below).
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}

#md # @@img-med
# ![elastic missing shear](../assets/literate_figures/l7-elast.gif)
#md # @@

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
We're soon done.

However, his last part is a [homework task](#exercise_3_-_cauchy-navier_elastic_waves).
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Now it's **time to wrap up** this part before moving to more Git workflows. So far, we learned about:
- How Julia solves the two-language problem 
- XPU programming with ParallelStencil 
- Cauchy-Navier elastic wave propagation (solid mechanics)
"""


