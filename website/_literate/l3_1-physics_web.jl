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

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Let's get started with this. We will do this exercise in a Julia standalone script and run it in from REPL using your local Julia install.

It's time to launch Julia on your computer 🚀
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
We can start modifying the diffusion code's, adding `ρ` and `K` and changing `ttot=20` in `# Physics`, and taking a Gaussian (centred in `Lx/2`, `σ=1`) as initial condition for the pressure `P`

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
|  ------------:  | :-------------  |
| Diffusion      | $$qx = -D\frac{∂C}{∂x}$$  $$\frac{∂C}{∂t} = -\frac{∂qx}{∂x}$$ |
| Acoustic waves | $$\frac{∂V_x}{∂t} = -\frac{1}{ρ}~\frac{∂P}{∂x}$$  $$\frac{∂P}{∂t} = -K~\frac{∂V_x}{∂x}$$ |
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## From 1D to 2D

Let's discuss how to implement the acoustic wave equation (and the diffusion equation from last week's material) in 2D.
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
We want the $x$ and $y$ axis to represent spatial extend, and solve in each grid point for the pressure or the concentration, for the acoustic and diffusion process, respectively.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
But let's first look at the equation, augmenting the Table we just started to fill

|  Physics       |  1D formulation |  2D formulation |
| ------------:  | :-------------- | :-------------- |
| Diffusion      | $$qx = -D\frac{∂C}{∂x}$$  $$\frac{∂C}{∂t} = -\frac{∂qx}{∂x}$$ | $$qx = -D\frac{∂C}{∂x}$$  $$qy = -D\frac{∂C}{∂y}$$  $$\frac{∂C}{∂t} = -\left(\frac{∂qx}{∂x} + \frac{∂qy}{∂y} \right)$$ |
| Acoustic waves | $$\frac{∂V_x}{∂t} = -\frac{1}{ρ}~\frac{∂P}{∂x}$$  $$\frac{∂P}{∂t} = -K~\frac{∂V_x}{∂x}$$ |$$\frac{∂V_x}{∂t} = -\frac{1}{ρ}~\frac{∂P}{∂x}$$  $$\frac{∂V_y}{∂t} = -\frac{1}{ρ}~\frac{∂P}{∂y}$$  $$\frac{∂P}{∂t} = -K~\left(\frac{∂V_x}{∂x} + \frac{∂V_y}{∂y} \right)$$ |
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
For both physics
- The fluxes which are directional or vector quantities have a new $y$-direction component
- The balance equation or divergence, now include the sum of the flux balance from all dimensions

"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Let's get started first with the diffusion equation, then the wave equation (as homework).
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
To dos:
- Add $y$-direction physics and numerics
- Update time step definition
- Update initial Gaussian condition
- Initialise all new arrays
- Update physics calculations in the time loop
- Update plotting
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### $y$-direction physics and numerics

You can make multi-statement lines for scalars:

```julia
Lx, Ly = 10.0, 10.0
```
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
### Time step definition

Take now the most restrictive condition, e.g.:

```julia
dt = min(dx, dy)/...
```
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### 2D plotting

You can use `heatmap()` function from `PLots.jl`, to plot e.g. `C` as function of the spatial coordinates `xc` and `yc`:

```julia
heatmap(xc, yc, C')
```
_note the transpose `'`_
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
More advanced implementation, one can define the plotting options and apply them in the `heatmap` call:

```julia
opts = (aspect_ratio=1, xlims=(xc[1], xc[end]), ylims=(yc[1], yc[end]), clims=(0.0, 1.0), c=:davos, xlabel="Lx", ylabel="Ly", title="time = $(round(it*dt, sigdigits=3))")
display(heatmap(xc, yc, C'; opts...))
```
"""




