#src # This is needed to make this run as normal Julia file
using Markdown #src

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
#nb # _Lecture 3_
md"""
# From diffusion to acoustic waves
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### The goal of this lecture 3 is to familiarise (or refresh) with
- The wave equation
- The diffusion equation
- Spatial discretisation: 1D and 2D
- Finite-differences and staggered grids
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## The wave equation

The wave equation is a second-order partial differential equation.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
![acoustic wave](../assets/literate_figures/acoustic2D_2.gif)
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
> The [wave equation](https://en.wikipedia.org/wiki/Wave_equation) is a second-order linear partial differential equation for the description of waves—as they occur in classical physics—such as mechanical waves (e.g. water waves, sound waves and seismic waves) or light waves. [_Wikipedia_](https://en.wikipedia.org/wiki/Wave_equation)
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
The hyperbolic equation reads

$$ \frac{∂^2u}{∂t^2} = c^2 ∇^2 u~, $$

where
- $u$ is pressure, displacement (or another scalar quantity)
- $c$ a non-negative real constant (speed of sound, stiffness, ...)
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
The wave equation can be elegantly derived, e.g., from [Hooke's law](https://en.wikipedia.org/wiki/Wave_equation#From_Hooke's_law) and second law of Newton considering masses interconnected with springs.

![hook](../assets/literate_figures/hook.png)

$$ F_\mathrm{Newton}~~=~~F_\mathrm{Hook}~,$$

$$ m⋅a(t)~~=~~k x_+ - k x_-~,$$

where $m$ is the mass, $k$ de spring stiffness, and $x_+$, $x_-$ the oscillations of the masses (small distances).
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
_Note on classification of PDEs:_
- **Elliptic:**\
  $∇^2 u - b = 0$ (e.g. steady state diffusion, Laplacian)
- **Parabolic:**\
  $∂u/∂t - α ∇^2 u - b = 0$ (e.g. transient heat diffusion)
- **Hyperbolic:**\
  $∂^2u/∂t^2 - c^2 ∇^2 u = 0$ (e.g. wave equation)
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### Back to the wave equation

The the first objective of this lecture is to implement the wave equation in 1D (spatial discretisation) using an explicit time integration (forward Euler) as seen in lecture 2 for the advection-diffusion-reaction physics.
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Also, we will consider acoustic or pressure waves. We can thus rewrite the wave equation as

$$ \frac{∂^2 P}{∂t^2} = c^2 ∇^2 P~,$$

where
- $P$ is pressure
- $c$ is the speed of sound
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Our first task will be to modify the diffusion equation from lecture 2 ...

![diffusion](../assets/literate_figures/diffusion1D.gif)
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
... in order to obtain and implement the acoustic wave equation

![diffusion](../assets/literate_figures/acoustic1D.gif)
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### From diffusion to acoustic wave

We won't implement first the hyperbolic equation as introduced, but rather start from a flux / update formulation, as we used to implement for the diffusion equation.
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
To this end, we can thus rewrite the second order wave equation

$$ \frac{∂^2 P}{∂t^2} = c^2 ∇^2 P~,$$

as two first order equations

$$ \frac{∂V_x}{∂t} = -\frac{1}{ρ}~\frac{∂P}{∂x}~,$$

$$ \frac{∂P}{∂t}  = -K~\frac{∂V_x}{∂x}~.$$
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
One can even push the analogy one step further, defining a flux of "momentum" as 

$$ q_x = -\frac{1}{ρ}~\frac{∂P}{∂x}~,$$

using it to update velocity

$$ \frac{∂V_x}{∂t} = q_x,$$

before computing the mass balance (conservation law or divergence of fluxes)

$$ \frac{∂P}{∂t}  = -K~\frac{∂V_x}{∂x}~.$$
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
This formulation is very similar to the diffusion equation, as the only addition is the time-dependence (or history) in the fluxes:

$$ \frac{∂V_x}{∂t} = q_x,$$
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Let's get started with this. We will do this exercise in a Julia standalone script and run it in from REPL using your local Julia install.

It's time to launch Julia on your computer 🚀
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
We can start modifying the diffusion code's, changing `ttot=20` in `# Physics`, and taking a Gaussian (centred in `Lx/2`, `σ=1`) as initial condition for the pressure `P`

```julia
# Physics
Lx    = 10.0
ρ     = 1.0
K     = 1.0
ttot  = 20.0

# Derived numerics
P     =  exp.(...)
```

Note that the time step needs a new definition: `dt = dx/sqrt(K/ρ)/2.1`
"""


#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Then, the diffusion physics:

```julia
qx         .= .-D.*diff(C )./dx
dCdt       .= .-   diff(qx)./dx
C[2:end-1] .= C[2:end-1] .+ dt.*dCdt
```

Should be modified to account for pressure `P` instead of concentration `C`, the flux update (`Vx`) added, and the coefficients modified:

```julia
qx         .= .-1.0/ρ.*diff(...)./dx
Vx         .= ...
dPdt       .= ...
P[2:end-1] .= P[2:end-1] ...
```
"""


#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Comparing diffusive and wave physics, we can summarise following:

|  Physics        |  1D formulation |
| :------------:  | :-------------: |
| Diffusion      | $$qx = -D\frac{∂C}{∂x}$$  $$\frac{∂C}{∂t} = -\frac{∂q}{∂x}$$ |
| Acoustic waves | $$\frac{∂V_x}{∂t} = -\frac{1}{ρ}~\frac{∂P}{∂x}$$  $$\frac{∂P}{∂t} = -K~\frac{∂V_x}{∂x}$$ |
"""




