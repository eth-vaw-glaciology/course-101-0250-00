#src # This is needed to make this run as normal Julia file
using Markdown #src

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
#nb # _Lecture 2_
md"""
# ODEs & PDEs: advection - diffusion - reaction
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Reaction - Diffusion - Advection gifs
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### The goal of this lecture 2 is to familiarise (or refresh) with
- Ordinary differential equations - ODEs (e.g. reaction equation)
- Partial differential equations - PDEs (e.g. diffusion and advection equations)
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
- Finite-difference discretisation
- Explicit solutions
- Multi-process (physics) coupling
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
> A **partial differential equation (PDE)** is an equation which imposes relations between the various partial derivatives of a multivariable function.\
> **Ordinary differential equations (ODE)** form a subclass of partial differential equations, corresponding to functions of a single variable. [_Wikipedia_](https://en.wikipedia.org/wiki/Partial_differential_equation)
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## ODEs
Simple reaction equation, finite-difference method and explicit solution
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Let's take-off 🚀
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Our first task is to design a numerical solution approach for the following reaction process (e.g. [reaction kinetics](https://en.wikipedia.org/wiki/Chemical_kinetics))

$$
\frac{∂C}{∂t} = -\frac{C-C_{eq}}{ξ}~,
$$

"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
where $C$ is the concentration of ,e.g. a specific chemical quantity, $t$ is time, $C_{eq}$ is the equilibrium concentration of $C$ and $ξ$ is the reaction rate.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Suppose the reaction kinetics process occurs in a spatial domain (x-direction) of $Lx=10.0$, consider a reaction rate $ξ=10.0$ and an equilibrium concentration $C_{eq}=0.5$.

The goal is now to predict the evolution of a system with initial random distribution of concentration $C$ in the range $[0, 1]$ for non-dimensional total time of $20.0$.
"""

## Physics
Lx   = 10.0
ξ    = 10.0
Ceq  = 0.5
ttot = 20.0

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
As next step, one needs to discretise the continuum problem in both space and time. We will use a [finite-difference](https://en.wikipedia.org/wiki/Finite_difference) spatial discretisation and an explicit ([forward Euler](https://en.wikipedia.org/wiki/Euler_method)) time integration scheme.
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
In a new `# Numerics` section we define the number of grid points we will use to discretise our physical domain $Lx$.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Then, in a `# Derived numerics` section, we compute the grid size `dx`, the time-step `dt`, the number of time-steps `nt` and the vector containing the coordinate of all cell centres `xc`.
"""

## Numerics
nx   = 128
## Derived numerics
dx   = Lx/nx
dt   = ξ/2.0
nt   = cld(ttot, dt)
xc   = LinRange(dx/2, Lx-dx/2, nx)

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
#nb # > 💡 hint:
#nb # > Type `?` in the Julia REPL followed by the function you want to know more about to display infos
#md # \note{Type `?` in the Julia REPL followed by the function you want to know more about to display infos}

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
We now need to initialise 3 1D arrays to hold information about concentration `C`, initial concentration distribution `Ci`, and rate of change of concentration `dCdt`.
"""

## Array initialisation
C    =  rand(Float64, nx)
Ci   =  copy(C)
dCdt = zeros(Float64, nx)

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
#nb # > 💡 hint: Note we here work with double precision arithmetic `Float64`
#md # \note{We here work with double precision arithmetic `Float64`}

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Remains the most important part, the `# Time loop` where _predictive_ action should take place. We will loop from `it=1` to `nt` computing the rate of change of `C`, `dCdt`, and then updating `C`. We also want to visualise the evolution of the concentration distribution.

```julia
using Plots

# Time loop
for it = 1:nt
  dCdt = ...
  C    = ...
  display(plot(xc, C, lw=2, xlims=(xc[1], xc[end]), ylims=(0.0, 1.0),
               xlabel="Lx", ylabel="Concentration", title="time = $(it*dt)",
               framestyle=:box, label="Concentration"))
end
```
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
- Make sure to update the arrays `dCdt` and `C` using the [dot syntax](https://docs.julialang.org/en/v1/manual/functions/#man-vectorized) for vectorised functions.
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
- The `display()` function will force to update the figure within the loop. Note that in Jupyter notebooks, you can use following syntax to avoid the creation of a new figure at each step.

```julia
using IJulia
IJulia.clear_output(true)
display(plot(...))
```
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
👉 Your turn. Let's implement the reaction physics.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
After the time loop, we can also display the initial concentration we stored `Ci` and the equilibrium concentration `Ceq`:

```julia
plot!(xc, Ci, lw=2, label="C initial")
display(plot!(xc, Ceq*ones(nx), lw=2, label="Ceq"))
```

Note that calling further instances of `plot!()` will act as "hold-on" and allow to display multiple objects on top of each other.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
We may want to write a single "monolithic" `reaction_1D.jl` code to perform these steps that looks as following
"""

#!nb using Plots
#!nb 
#!nb @views function reaction_1D()
#!nb     ## Physics
#!nb     Lx   = 10.0
#!nb     ξ    = 10.0
#!nb     Ceq  = 0.5
#!nb     ttot = 20.0
#!nb     ## Numerics
#!nb     nx   = 128
#!nb     ## Derived numerics
#!nb     dx   = Lx/nx
#!nb     dt   = ξ/2.0
#!nb     nt   = cld(ttot, dt)
#!nb     xc   = LinRange(dx/2, Lx-dx/2, nx)
#!nb     ## Array initialisation
#!nb     C    =  rand(Float64, nx)
#!nb     Ci   =  copy(C)
#!nb     dCdt = zeros(Float64, nx)
#!nb     ## Time loop
#!nb     for it = 1:nt
#!nb         #dCdt = ...
#!nb         #C    = ...
#!nb         #display(plot(xc, C, lw=2, xlims=(xc[1], xc[end]), ylims=(0.0, 1.0),
#!nb                      #xlabel="Lx", ylabel="Concentration", title="time = $(it*dt)",
#!nb                      #framestyle=:box, label="Concentration"))
#!nb     end
#!nb     #plot!(xc, Ci, lw=2, label="C initial")
#!nb     #display(plot!(xc, Ceq*ones(nx), lw=2, label="Ceq"))
#!nb     return
#!nb end
#!nb 
#!nb reaction_1D()

#nb using Plots
#nb 
#nb @views function reaction_1D()
#nb     ## Physics
#nb     #[...]
#nb     ## Numerics
#nb     #[...]
#nb     ## Derived numerics
#nb     #[...]
#nb     ## Array initialisation
#nb     #[...]
#nb     ## Time loop
#nb     for it = 1:nt
#nb         #dCdt
#nb         #C
#nb         #[...]   
#nb     end
#nb     return
#nb end
#nb 
#nb reaction_1D()

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
So, excellent, we have our first 1D ODE solver up and running in Julia :-)
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## PDEs - diffusion

From reactions to diffusion and advection - involving gradients (neighbouring cells).
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Starting from the reaction script that we just finalised, we will now do as few as possible changes to solve the diffusion equation.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
The [diffusion equation](https://en.wikipedia.org/wiki/Diffusion_equation) was introduced by Fourier in 1822 to understand heat distribution ([heat equation](https://en.wikipedia.org/wiki/Heat_equation)) in various materials.

Diffusive processes were also employed by Fick in 1855 with application to chemical and particle diffusion ([Fick's law](https://en.wikipedia.org/wiki/Fick%27s_laws_of_diffusion)).
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
The diffusion equation is often reported as a second order parabolic PDE, here for a multivariable function $C(x,t)$ showing derivatives in both temporal $∂t$ and spatial $∂x$ derivatives (or changes)

$$
\frac{∂C}{∂t} = D\frac{∂^2 C}{∂ x^2}~,
$$

where $D$ is the diffusion coefficient.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
The second order formulation is only possible if the diffusion coefficient D is a single value valid in all the considered domain.

A more general description allowing for non-uniform, non-linear diffusion coefficient combines a diffusive flux:

$$ q = -D\frac{∂C}{∂x}~,$$
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
and a conservation or flux balance equations:

$$ \frac{∂C}{∂t} = -\frac{∂q}{∂x}~. $$
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
To discretise the diffusion equation, we will keep the explicit forward Euler method as temporal discretisation and use [finite-differences](https://en.wikipedia.org/wiki/Finite_difference) for the spatial discretisation.

Finite-differences discretisation on regular staggered grid allows for concise and performance oriented algorithms, because only neighbouring cell access is needed to evaluate gradient and data alignment is natively pretty optimal.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
A long story short, we will approximate the gradient of concentration $C$ over a distance $∂x$, a first derivative $\frac{∂C}{∂x}$, we will perform following discrete operation

$$ \frac{C_{x+dx} - C_{x}}{dx}~, $$

where $dx$ is the discrete size of the cell.

The same reasoning also applies to the flux balance equation.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
We can use Julia's `diff()` operator to apply the $ C_{x+dx} - C_{x} $,
```julia
C[ix+1] - C[ix]
```
in a vectorised fashion to our entire `C` vector as
```julia
diff(C)
```
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
So, we are ready to solve the 1D diffusion equation.
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Starting from the reaction code, turn `ξ` into `D=1.0`, the diffusion coefficient, remove `C_eq`, set total simulation time `ttot = 2.0`
"""

## Physics
Lx   = 10.0
D    = 1.0
ttot = 2.0

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
The only change in the `# Derived numerics` section is the diffusive stable time step definition, to comply with the [CFL stability condition](https://en.wikipedia.org/wiki/Courant–Friedrichs–Lewy_condition) for explicit time integration
"""

## Derived numerics
dt   = dx^2/D/2.1

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
In the `# Array initialisation` section, we need a new object to hold the diffusive flux in x direction `qx`
"""

dCdt = zeros(Float64, nx) # wring size - will fail because of staggering
qx   = zeros(Float64, nx) # wring size - will fail because of staggering

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Wait... what about the staggering ?

No surprise `C .= diff(C)` won't work ...
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
👉 Your turn. Let's implement our first diffusion solver trying to think about how to solve the staggering issue.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
The initialisation steps of the diffusion code should contain
"""

## Physics
Lx   = 10.0
D    = 1.0
ttot = 2.0
## Numerics
nx   = 12
nout = 10
## Derived numerics
dx   = Lx/nx
dt   = dx^2/D/2.1
nt   = cld(ttot, dt)
xc   = LinRange(dx/2, Lx-dx/2, nx)
## Array initialisation
C    =  rand(Float64, nx)
Ci   =  copy(C)
dCdt = zeros(Float64, nx-2)
qx   = zeros(Float64, nx-1);

# _(execute it)_

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Followed by the 3 physics computations (lines) in the time loop
"""

## Time loop
for it = 1:nt
    qx         .= .-D.*diff(C )./dx
    dCdt       .= .-   diff(qx)./dx
    C[2:end-1] .= C[2:end-1] .+ dt.*dCdt
    ## Visualisation
end

# _(execute it)_

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
One can examine the size of the various vectors ...
"""

## check sizes and staggering
@show size(qx)
@show size(dCdt)
@show size(C)
@show size(C[2:end-1]);

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
... and visualise it
"""

using Plots
 plot(xc               , C   , legend=false, linewidth=:1.0, markershape=:circle, markersize=5, framestyle=:box)
plot!(xc[1:end-1].+dx/2, qx  , legend=false, linewidth=:1.0, markershape=:circle, markersize=5, framestyle=:box)
plot!(xc[2:end-1]      , dCdt, legend=false, linewidth=:1.0, markershape=:circle, markersize=5, framestyle=:box)


#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Note: plotting and visualisation is slow. A convenient workaround is to only visualise or render the figure every `nout` iteration within the time loop 

```julia
if it % nout == 0
    plot()
end
```
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## PDEs - Advection

From reactions to diffusion and advection - involving gradients (neighbouring cells).
"""
