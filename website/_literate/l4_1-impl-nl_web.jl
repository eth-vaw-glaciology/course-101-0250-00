#src # This is needed to make this run as normal Julia file
using Markdown #src

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
#nb # _Lecture 4_
md"""
# Nonlinear and implicit solutions
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### The goal of this lecture 4 is to explore:
- Nonlinear solutions
- Steady-state and implicit iterative solutions
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
### Building upon:
- The diffusion equation
- Spatial discretisation: 1D and 2D
- Finite-differences and staggered grids
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## Nonlinear solutions

Until now we investigated linear and transient processes using a forward Euler explicit time integration.
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
However many interesting application may exhibit nonlinear behaviours, e.g.,

$$\frac{∂H}{∂t}=\frac{∂}{∂x}\left(H^n\frac{∂H}{∂x}\right)~,$$

where $H$ could be the ice thickness and $n$ a power-law exponent ($n=3-5$), as in depth-integrated or shallow ice approximation (SIA) models:
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
![SIA](../assets/literate_figures/diffusion_nl_1D_1.gif)

> So-called depth-integrated or shallow approximation equations are, e.g., the shallow ice equations or the [shallow water equations](https://en.wikipedia.org/wiki/Shallow_water_equations)
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Adding nonlinearities in the explicit time integration approach is fairly straight forward.

Let's turn the [linear 1D diffusion from lecture 2](/lecture2/#pdes_-_diffusion) into a shallow ice-like solver as push-up exercise.

👉 [Download the `diffusion_1D.jl` script](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/) to get you started.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
We want to modify the linear 1D diffusion equation

$$\frac{∂C}{∂t}=-\frac{∂}{∂x}\left(-D\frac{∂H}{∂x}\right)~,$$

into

$$\frac{∂H}{∂t}=-\frac{∂}{∂x}\left(-D_H\frac{∂H}{∂x}\right)~,$$

where $D_H = (D_0~H)^n$ is the effective diffusion coefficient, and $H$ the, e.g., the ice thickness.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Starting from the linear 1D diffusion code, we need to:
- change `C` to `H`
- implement the `H`-dependent diffusion coefficient
- update `dt` definition

Using the following parameters:

```julia
D0   = 5.0
n    = 5
```
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
💻 Let's get started 🚀
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
#nb # > 💡 hint: Think about the staggering of the `H`-dependent effective diffusion coefficient. Since D is no longer constant, special care is needed for the time step definition `dt`.
#md # \note{Think about the staggering of the `H`-dependent effective diffusion coefficient. Since D is no longer constant, special care is needed for the time step definition `dt`.}
#md # The effective diffusion coefficient and time step definition can be implement as
#md # ```julia
#md # D  .= (D0.*H).^n
#md # dt  = dx^2/maximum(D)/2.1
#md # qx .= .-av(D)
#md # ```
#md # where `dt` must be placed inside the time loop and `av` is the averaging function defined as
#md # ```julia
#md # @views av(A) = 0.5.*(A[1:end-1].+A[2:end])
#md # ```

#md # 👉 [Download the `diffusion_nl_1D.jl` script.](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/)

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## Steady-state and implicit iterative solutions

Let's now discuss how to implement steady-state and implicit iterative solvers.
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
_But why?_

- One may only be interested in the final distribution, or "steady-state".
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
- Strong nonlinearities may not be captured with sufficient accuracy in explicit time integration.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## Steady-state

Let's assume we are interested in a steady-state reached by a time-dependent diffusive processes 

$$\frac{∂A}{∂t}=D~∇^2A~,$$

for time $t→∞$ (or $∂t→∞$). This parabolic PDE then turns into an elliptic PDE as $∂A/∂t → 0$,

$$0=D~∇^2A~.$$
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
How to solve $0=D~∇^2 A$ ?
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
#### Solution 1
Use a direct sparse solver approach: build a system of linear equations in the form $K~a=b$, where $a$ is the solution vector ($A$ from the Laplacian notation) and $K$ the finite-difference coefficient matrix ($D~∇^2$), then apply the inverse of $K$, $K^{-1}$, on $b$ to retrieve $a$ (you may be familiar with `a = K \ b`).
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
#### Solution 2
Use an iterative matrix-free approach: introduce (or bring back) the transient term (from explicit time integration) $∂a/∂t$ such that $∂a/∂t=b - K~a$ and use it to iteratively reach the steady state, i.e. when $∂a/∂t→0$.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
#### Pros and cons Solution 1 _(non-exhaustive)_

- +unconditionally stable
- +insensitive to variation in material parameters (e.g. $D$)
- +fast for "few" degrees of freedom (dofs)
- -nonlinear growth of memory usage
- -slow or impossible to apply to large systems (many dofs)
- -complex to implement
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
#### Pros and cons Solution 2 _(non-exhaustive)_

- +unconditionally stable for physical time (in the residual)
- +simple to implement
- +low memory usage linearly growing with problem size
- -somewhat sensitive to variation in material parameters
- -needs tuning of numerical parameters ($∂t$)
- 👉 **needs second order implementation**
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### Investigating _Solution 2_:
- the limitations from the "naive" first order implementation
- the second order implementation and its benefits.
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
We will first implement

$$0=D~∇^2A~,$$

which we will use as "smoother", applying it to diffuse away initial random noise distribution.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
💻 Let's get started implementing the 2D Laplacian

```julia
# Laplacian 2D
using Plots

@views function laplacian2D()

    return
end

@time laplacian2D()
```
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
We can use the following model configuration

```julia
fact    = 1
# Physics
lx, ly  = 10, 10
D       = 1
# Numerics
nx, ny  = fact*50, fact*50
dx, dy  = lx/nx, ly/ny
niter   = 20*nx
dt      = dx^2/D/4.1
```
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
and initial conditions
```julia
# Initial conditions
A       = zeros(Float64, nx,ny)
dAdt    = zeros(Float64, nx,ny)
A[2:end-1,2:end-1] .= rand(nx-2,ny-2)
```
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
To display the initial condition:
```julia
display(heatmap(A', aspect_ratio=1, xlims=(1,nx), ylims=(1,ny)))
```

![init_rnd](../assets/literate_figures/init_rnd.png)
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Second, we can implement the time loop.

_But, is it iteration loop or time loop?_
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
If we were to solve a physical transient problem (parabolic PDE), this would be the physical time loop.

However, we are here interested in minimising the residual function $D~∇^2A$ (such that $∂A/∂t→0$). Thus, we are speaking about **iterations or pseudo-time (i.e. numerics)**.

This means that actually, $t$ has the meaning of $τ$, pseudo-time or numerics.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
```julia
errv = [] # storage for error
# iteration loop
for it = 1:niter
   dAdt[2:end-1,2:end-1] .= D.*( diff(diff(A[:,2:end-1],dims=1),dims=1)/dx^2 .+
                                 diff(diff(A[2:end-1,:],dims=2),dims=2)/dy^2 )
   A                     .= A .+ dt.*dAdt
    if it % nx == 0
        err = maximum(abs.(A)); push!(errv, err)
       p1=plot(nx:nx:it,log10.(errv), linewidth=3, markersize=4,
               markershape=:circle, framestyle=:box, legend=false,
               xlabel="iter", ylabel="log10(max(|A|))", title="iter=$it")
       p2=heatmap(A', aspect_ratio=1, xlims=(1,nx), ylims=(1,ny),
                  title="max(|A|)=$(round(err,sigdigits=3))")
       display(plot(p1,p2, dpi=150))
    end
end
```
"""

#src #########################################################################


#md # 👉 [Download the `Laplacian.jl` script](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/).

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Running the `Laplacian.jl` code with `nx, ny = 50, 50` (thus `niter = 1000`) produces the following output

![Laplacian2D](../assets/literate_figures/Laplacian2D.png)
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
So over 1000 iterations, the magnitude of the error ($\max(|A|)$) only dropped about 1/2 an order of magnitude.

How can we improve this?
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
👉 **One needs a second order implementation**
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
The goal is to reach a steady-state, we thus seek the left-hand-side of the "numerical" parabolic equation

$$\frac{∂A}{∂t}=D~∇^2A~,$$

to vanish upon convergence, i.e., $∂A/∂t→0$. To this end, we are free to add any additional terms as long as they will also tend towards 0 with iterations.
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
We could thus add a second order term:

$$\frac{∂^2A}{∂t^2} + α \frac{∂A}{∂t}=D~∇^2A~,$$

where $α$ is a numerical parameter to optimise.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Adding specifically this second order term makes the parabolic PDE to switch to an hyperbolic system, e.g., the acoustic wave propagation.
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Even better, we actually have now a **damped wave equation**!

_So what's exciting about it?_
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
The first order method, a diffusion-like process (parabolic PDE), converges really slowly because the speed at which information travels during smoothing steps is limited by the diffusive CFL, function of $1/dx^2$. This limitation will also make the method scale **quadratically** with numerical resolution increase.
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
A non-damped wave equation (hyperbolic PDE) features information travelling using the wave CFL, functrion of $1/dx$, and thus the method could scale **linearly** with numerical resolution increase. However, it would never converge.
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
The second order method is actually a damped wave equation; the damping introduces a dissipative term that allows to reach a steady state.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
We can now tune the damping parameter to minimise the iteration count, finding the sweet spot between slowly converging diffusion and non-dissipative waves.

> One classical reference to this method can be found in [Frankel (1950)](https://doi.org/10.2307/2002770), reported as _**the second order Richardson method**_.\
> In the coming weeks, a preprint will be made available that further discusses the second-order method, also named _**pseudo-transient method**_, and the optimal damping parameter selection.
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
💻 Let's try it out. Starting from the `Laplacian.jl` script we just made, we'll turn it into a `Laplacian_damped.jl`.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Changes include now the addition of an `order` flag, damping term `dmp`, a wave-like time step definition,
```julia
order   = 2
dmp     = 2.0/nx
dt      = dx/sqrt(D)/2.1
```

and the second order pseudo-physics
```julia
dAdt[2:end-1,2:end-1] .= dAdt[2:end-1,2:end-1]*(1-dmp)*(order-1) .+ 
                         dt.*D.*( diff(diff(A[:,2:end-1],dims=1),dims=1)/dx^2 .+
                                  diff(diff(A[2:end-1,:],dims=2),dims=2)/dy^2 )
A                     .= A .+ dt.*dAdt
```
"""

#md # 👉 [Download the `Laplacian_damped.jl` script](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/).

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Running the `Laplacian_damped.jl` code with `nx, ny = 50, 50` (thus `niter = 1000`) produces the following output

![Laplacian2D damped](../assets/literate_figures/Laplacian2D_damped.png)
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Yay, over the same 1000 iterations, the magnitude of the error ($\max(|A|)$) now dropped about 8 orders of magnitude.

This is a massive improvement over the first order method for minor changes in code 🙂
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Also the second order method:
- only adds 1 array read (`dAdt`), and 
- is fully local (no global reduction is needed)
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Finally, we can verify that the second order method iteration count scales linearly with increase in numerical grid resolution.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Note that various formulations of the second-order implementation exist and lead to a linear scaling of iteration count with resolution increase.
A useful and more concise one may be the following one:

```julia
dAdt[2:end-1,2:end-1] .= dAdt[2:end-1,2:end-1].*(1-dmp) .+ 
                         D.*( diff(diff(A[:,2:end-1],dims=1),dims=1)/dx^2 .+
                              diff(diff(A[2:end-1,:],dims=2),dims=2)/dy^2 )
A                     .= A .+ dt.*dAdt
```
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## Implicit solutions

The usage of _implicit_ may be confusing as it often lacks of clear definition and context.

In a physics-based PDE world, an _implicit solution_ most often refers to:
- a time-independent solution (steady-state), or
- a time-dependant solution where the spatial derivatives are evaluated for the new time integration layer one is actually solving for.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Achieving an implicit solution of following time-dependent diffusive (parabolic) PDE,

$$\frac{∂C}{∂t}=D~∇^2C~,$$

implies a time discretisation as

$$C^{t+∆t}=C^{t} + ∆t~D~∇^2C^{t+∆t}~.$$
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
In the iterative framework we previously discussed, a solution of this physical time-dependent diffusion equation can be achieved by:
- collecting all physical terms in the right-hand-side (spatial and temporal derivatives),
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
- augmenting the system, on the left-hand-side, by a numerical or pseudo-time integration $∂C/∂τ$:

$$\frac{∂C}{∂τ}=-\frac{∂C}{∂t} + D~∇^2C~.$$
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
This system can now be solved using the second order method we previously introduced, the physical time derivative acting as a reaction term with $∆t$ the physical time-step acting as a "reaction rate" analogous:

$$C^{τ+∆τ}=C^{τ} + ∆τ~\left( -\frac{C^{τ}-C^{t}}{∆t} + ~D~∇^2C^{τ} \right)~,$$

where $C^{τ} = C^{τ+∆τ} = C^{t+∆t}$ upon convergence, i.e., upon $∂C/∂τ → 0$.
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
This approach is also known as the "dual-time stepping".
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
#nb # ### That's it for the "intro" part on iterative approaches to solve PDEs.
#nb #
#nb # 💻 Starting next week, we will port codes for (multi-) GPUs implementations

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
#nb # _Lecture 4_
md"""
# Julia's Project environment
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
On GitHub, make sure to create a new folder for each week's exercises.

Each week's folder should be a Julia project, i.e. contain a `Project.toml` file.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
This can be achieved by typing entering the Pkg mode from the Julia REPL in the tatrget folder

```julia-repl
julia> ]

(@v1.6) pkg> activate .

(lectureXX) pkg> add Plots
```

and adding at least one package.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
In addition, it is recommended to have the following structure and content:
- lectureXX
  - `README.md`
  - `Project.toml`
  - `Manifest.toml`
  - docs/
  - scripts/
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Codes could be placed in the `scripts/` folder. Output material to be displayed in the `README.md` could be placed in the `docs/` folder.

The `Manifest.toml` file should be kept local. An automated way of doing so is to add it as entry to a `.gitignore` file in the root of your repo. Mac users may also add `.DS_Store` to their `.gitignore`.
"""


