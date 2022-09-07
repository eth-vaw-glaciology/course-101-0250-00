#src # This is needed to make this run as normal Julia file
using Markdown #src

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
#nb # _Lecture 2_
md"""
# PDEs and physical processes - diffusion, wave propagation, advection
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
A **partial differential equation (PDE)** is an equation which imposes relations between the various partial derivatives of a multivariable function. [_Wikipedia_](https://en.wikipedia.org/wiki/Partial_differential_equation)
"""

#md # \note{
#md # _**Classification of second-order PDEs:**_
#md # - **Parabolic:**\
#md #   $∂u/∂t - α ∇^2 u - b = 0$ (e.g. transient heat diffusion)
#md # - **Hyperbolic:**\
#md #   $∂^2u/∂t^2 - c^2 ∇^2 u = 0$ (e.g. acoustic wave equation)
#md # - **Elliptic:**\
#md #   $∇^2 u - b = 0$ (e.g. steady state diffusion, Laplacian)
#md # }

#nb # > _**Classification of second-order PDEs:**_
#nb # >  - **Parabolic:**\
#nb # >    $∂u/∂t - α ∇^2 u - b = 0$ (e.g. transient heat diffusion)
#nb # >  - **Hyperbolic:**\
#nb # >    $∂^2u/∂t^2 - c^2 ∇^2 u = 0$ (e.g. acoustic wave equation)
#nb # >  - **Elliptic:**\
#nb # >    $∇^2 u - b = 0$ (e.g. steady state diffusion, Laplacian)

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## Parabolic PDEs - diffusion
"""

#md # ~~~
# <center>
#   <video width="80%" autoplay loop controls src="../assets/literate_figures/porous_convection_2D.mp4"/>
# </center>
#md # ~~~

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
The [diffusion equation](https://en.wikipedia.org/wiki/Diffusion_equation) was introduced by Fourier in 1822 to understand heat distribution ([heat equation](https://en.wikipedia.org/wiki/Heat_equation)) in various materials.

Diffusive processes were also employed by Fick in 1855 with application to chemical and particle diffusion ([Fick's law](https://en.wikipedia.org/wiki/Fick%27s_laws_of_diffusion)).
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
The diffusion equation is often reported as a second order parabolic PDE, here for a multivariable function $C(x,t)$ showing derivatives in both temporal $∂t$ and spatial $∂x$ derivatives (here for the 1D case)

$$
\frac{∂C}{∂t} = D\frac{∂^2 C}{∂ x^2}~,
$$

where $D$ is the diffusion coefficient.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
A more general description combines a diffusive flux:

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
We introduce the physical parameters that are relevant for the considered problem, i.e., the domain length `lx` and the diffusion coefficient `dc`:

```julia
# Physics
lx   = 10.0
dc   = 1.0
```
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Then we declare numerical parameters: the number of grid cells used to discretize the computational domain `nx`, and the frequency of updating the visualisation:

```julia
# numerics
nx   = 200
nvis = 5
```
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
In the `# array initialisation` section, we need to initialise one array to store the concentration field `C`, and the diffusive flux in the x direction `qx`:

```julia
# array initialisation
C    = @. sin(10π*xc/lx); C_i = copy(C)
qx   = zeros(Float64, nx) # won't work
```
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Wait... why it wouldn't work?
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

## physics
lx   = 20.0
dc   = 1.0
## numerics
nx   = 200
nvis = 5
## derived numerics
dx   = lx/nx
dt   = dx^2/dc/2
nt   = nx^2 ÷ 100
xc   = LinRange(dx/2,lx-dx/2,nx)
## array initialisation
C    = @. sin(10π*xc/lx); C_i = copy(C)
qx   = zeros(Float64, nx) # won't work

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Followed by the 3 physics computations (lines) in the time loop
"""

## Time loop
for it = 1:nt
    #q x         .= # add solution
    #C[2:end-1] .-= # add solution
    ## Visualisation
end


#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
One can examine the size of the various vectors ...
"""

## check sizes and staggering
@show size(qx)
@show size(C)
@show size(C[2:end-1])

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
... and visualise it
"""

using Plots
plot(xc               , C   , label="Concentration", linewidth=:1.0, markershape=:circle, markersize=5, framestyle=:box)
plot!(xc[1:end-1].+dx/2, qx  , label="flux of concentration", linewidth=:1.0, markershape=:circle, markersize=5, framestyle=:box)

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
#nb # Let's implement the diffusion solver
#nb using Plots
#nb 
#nb @views function diffusion_1D()
#nb     ## Physics
#nb     Lx   = 10.0
#nb     D    = 1.0
#nb     ttot = 2.0
#nb     ## Numerics
#nb     nx   = 128
#nb     nout = 10
#nb     ## Derived numerics
#nb     dx   = Lx/nx
#nb     dt   = dx^2/D/2.1
#nb     nt   = cld(ttot, dt)
#nb     xc   = LinRange(dx/2, Lx-dx/2, nx)
#nb     ## Array initialisation
#nb     C    =  rand(Float64, nx)
#nb     Ci   =  copy(C)
#nb     dCdt = zeros(Float64, nx-2)
#nb     qx   = zeros(Float64, nx-1)
#nb     ## Time loop
#nb     for it = 1:nt
#nb         #qx         .= # add solution
#nb         #dCdt       .= # add solution
#nb         C[2:end-1] .= C[2:end-1] .+ dt.*dCdt
#nb         if it % nout == 0
#nb             IJulia.clear_output(true); plot(xc, Ci, lw=2, label="C initial")
#nb             display(plot!(xc, C, lw=2, xlims=(xc[1], xc[end]), ylims=(0.0, 1.0), xlabel="Lx", ylabel="Concentration", title="time = $(round(it*dt, sigdigits=3))", framestyle=:box, label="concentration"))
#nb             sleep(0.1)
#nb         end
#nb     end
#nb     return
#nb end

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
#nb # And execute it
#nb diffusion_1D()

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
## Hyperbolic PDEs - acoustic wave propagation
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## First-order PDEs - advection
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
> Advection is a partial differential equation that governs the motion of a conserved scalar field as it is advected by a known velocity vector field. [_Wikipedia_](https://en.wikipedia.org/wiki/Advection)
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
We will here briefly discuss advection of a quantity $C$ by a constant velocity $v_x$ in the one-dimensional x-direction.

$$ \frac{∂C}{∂t} = -\frac{∂(v_x~C)}{∂x} ~.$$
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
In case the flow is incompressible ($∇⋅v = 0$ - here $\frac{∂v_x}{∂x}=0$), the advection equation can be rewritten as

$$ \frac{∂C}{∂t} = -v_x \frac{∂C}{∂x} ~.$$
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Let's once more start from the simple 1D reaction code, modifying it to implement the advection equation.
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Starting from the reaction code, turn `ξ` into `vx=1.0`, the advection velocity, remove `C_eq`, set total simulation time `ttot = 5.0`

```julia
# Physics
Lx   = 10.0
vx   = 1.0
ttot = 5.0
```
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
The only change in the `# Derived numerics` section is the stable advection time step definition, to comply with the [CFL stability condition](https://en.wikipedia.org/wiki/Courant–Friedrichs–Lewy_condition) for explicit time integration.

```julia
# Derived numerics
dt   = dx/vx
```
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
In the `# Array initialisation` section, initialise the quantity `C` as a Gaussian profile of amplitude 1, standard deviation 1, with centre located at $c = 0.3 Lx$.

```julia
C = exp.( ... )
```
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
#nb # > 💡 hint: Gaussian distribution as function of coordinate $x_c$, $ C = \exp(x_c - c)^2 $
#md # \note{Gaussian distribution as function of coordinate $x_c$, $ C = \exp(x_c - c)^2 $}


#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
One should also pay attention regarding the correct initialisation of `dCdt` in terms of vector dimension, since the rate of change of `C`, `dCdt`, is the derivative of `C`.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Defining `dCdt` as following

```julia
dCdt     .= .-vx.*diff(C)./dx
```

implements the right and side of the 1D advection equation.
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Now, the question is how to add `dCdt` to `C` within the update rule ?
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
3 (main) possibilities exist.

👉 Your turn. Try it out yourself and motivate your best choice.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
#nb # Initialise the simulation
#nb using Plots, IJulia
#nb ## Physics
#nb Lx   = 10.0
#nb vx   = 1.0
#nb ttot = 5.0
#nb ## Numerics
#nb nx   = 128
#nb nout = 10
#nb ## Derived numerics
#nb dx   = Lx/nx
#nb dt   = dx/vx
#nb nt   = cld(ttot, dt)
#nb xc   = LinRange(dx/2, Lx-dx/2, nx)
#nb ## Array initialisation
#nb #C    =  exp.(  )
#nb Ci   =  copy(C)
#nb #dCdt = zeros ...

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
#nb # Execute the time loop
#nb ## Time loop
#nb for it = 1:nt
#nb     #dCdt .= ...
#nb     #C    .= ...
#nb     ## add solution
#nb     if it % nout == 0
#nb         IJulia.clear_output(true); plot(xc, Ci, lw=2, label="C initial")
#nb         display(plot!(xc, C, lw=2, xlims=(xc[1], xc[end]), ylims=(0.0, 1.0), xlabel="Lx", ylabel="Concentration", title="time = $(round(it*dt, sigdigits=3))", framestyle=:box, label="C"))
#nb         sleep(0.1)
#nb     end
#nb end

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Here we go, an upwind approach is needed to implement a stable advection algorithm

```julia
C[2:end]   .= C[2:end]   .+ dt.*dCdt # if vx>0
C[1:end-1] .= C[1:end-1] .+ dt.*dCdt # if vx<0
```
"""



#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## Wrapping-up

- We implemented and solved PDEs for reaction, diffusion and advection processes in 1D
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
- We used conservative staggered grid finite-differences, explicit forward Euler time stepping and upwind scheme (advection).
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Note that this is far from being the only way to tackle numerical solutions to these PDEs. In this course, we will stick to those concepts as they will allow for efficient GPU (parallel) implementations.
"""


