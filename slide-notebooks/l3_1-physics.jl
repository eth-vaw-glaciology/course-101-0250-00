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

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
![acoustic wave](./figures/acoustic2D_2.gif)
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

![hook](./figures/hooke.png)

$$ F_\mathrm{Newton}~~=~~F_\mathrm{Hook}~,$$

$$ m⋅a(t)~~=~~k x_+ - k x_-~,$$

where $m$ is the mass, $k$ de spring stiffness, and $x_+$, $x_-$ the oscillations of the masses (small distances). The acceleration $a(t)$ can be substituted by the second derivative of displacement $u$ as function of time $t$, $∂^2u/∂t^2$, while balancing $x_+ - x_-$ and taking the limit leads to $∂^2u/∂x^2$.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
> _**Note on classification of PDEs:**_
> - **Elliptic:**\
>   $∇^2 u - b = 0$ (e.g. steady state diffusion, Laplacian)
> - **Parabolic:**\
>   $∂u/∂t - α ∇^2 u - b = 0$ (e.g. transient heat diffusion)
> - **Hyperbolic:**\
>   $∂^2u/∂t^2 - c^2 ∇^2 u = 0$ (e.g. wave equation)
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

![diffusion](./figures/diffusion_0.gif)
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
... in order to obtain and implement the acoustic wave equation

![acoustic](./figures/acoustic_1.gif)
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### From diffusion to acoustic wave

We won't implement first the hyperbolic equation as introduced, but rather start from a flux/update formulation, as we used to implement for the diffusion equation.
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
To this end, we can rewrite the second order wave equation

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
Let's get started with this. We will do this exercise in a Julia standalone script and run it in from the REPL using the local Julia install.

**It's time to launch Julia on your computer** 🚀

👉 [Download the `diffusion_1D.jl` script](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/) to get you started
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
#hint P     =  exp.(...)
#sol P     =  exp.(.-(xc .- Lx/2).^2)
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
#hint qx         .= .-1.0/ρ.*diff(...)./dx
#hint Vx         .= ...
#hint dPdt       .= ...
#hint P[2:end-1] .= P[2:end-1] ...
#sol qx         .= .-1.0/ρ.*diff(P )./dx
#sol Vx         .= Vx         .+ dt.*qx
#sol dPdt       .= .-    K.*diff(Vx)./dx
#sol P[2:end-1] .= P[2:end-1] .+ dt.*dPdt
```
"""

#sol #md # 👉 [Download the `acoustic_1D.jl` script](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/) for comparison.

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Comparing diffusive and wave physics, we can summarise following:
"""

#!nb # |  Physics        |  1D formulation |
#!nb # | :------------:  | :-------------: |
#!nb # | Diffusion      | $q_x = -D\frac{∂C}{∂x}$ |
#!nb # |                | $\frac{∂C}{∂t} = -\frac{∂q_x}{∂x}$ |
#!nb # | Acoustic waves | $\frac{∂V_x}{∂t} = -\frac{1}{ρ}~\frac{∂P}{∂x}$ |
#!nb # |                | $\frac{∂P}{∂t} = -K~\frac{∂V_x}{∂x}$ |

#nb # |  Physics        |  1D formulation |
#nb # |  ------------:  | :-------------  |
#nb # | Diffusion      | $$q_x = -D\frac{∂C}{∂x}$$  $$\frac{∂C}{∂t} = -\frac{∂q_x}{∂x}$$ |
#nb # | Acoustic waves | $$\frac{∂V_x}{∂t} = -\frac{1}{ρ}~\frac{∂P}{∂x}$$  $$\frac{∂P}{∂t} = -K~\frac{∂V_x}{∂x}$$ |

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
"""

#!nb # |  Physics       |  1D formulation  |  2D formulation  |
#!nb # | :------------: | :--------------: | :--------------: |
#!nb # | Diffusion      | $q_x = -D\frac{∂C}{∂x}$            | $q_x = -D\frac{∂C}{∂x}$ |
#!nb # |                |                                    | $q_y = -D\frac{∂C}{∂y}$ |
#!nb # |                | $\frac{∂C}{∂t} = -\frac{∂q_x}{∂x}$ | $\frac{∂C}{∂t} = -\left(\frac{∂q_x}{∂x} + \frac{∂q_y}{∂y} \right)$ |
#!nb # | Acoustic waves | $\frac{∂V_x}{∂t} = -\frac{1}{ρ}~\frac{∂P}{∂x}$ | $\frac{∂V_x}{∂t} = -\frac{1}{ρ}~\frac{∂P}{∂x}$ |
#!nb # |                |                                                | $\frac{∂V_y}{∂t} = -\frac{1}{ρ}~\frac{∂P}{∂y}$ |
#!nb # |                | $\frac{∂P}{∂t} = -K~\frac{∂V_x}{∂x}$           | $\frac{∂P}{∂t} = -K~\left(\frac{∂V_x}{∂x} + \frac{∂V_y}{∂y} \right)$ |


#nb # |  Physics       |  1D formulation |  2D formulation |
#nb # | ------------:  | :-------------- | :-------------- |
#nb # | Diffusion      | $$q_x = -D\frac{∂C}{∂x}$$  $$\frac{∂C}{∂t} = -\frac{∂q_x}{∂x}$$ | $$q_x = -D\frac{∂C}{∂x}$$  $$q_y = -D\frac{∂C}{∂y}$$  $$\frac{∂C}{∂t} = -\left(\frac{∂q_x}{∂x} + \frac{∂q_y}{∂y} \right)$$ |
#nb # | Acoustic waves | $$\frac{∂V_x}{∂t} = -\frac{1}{ρ}~\frac{∂P}{∂x}$$  $$\frac{∂P}{∂t} = -K~\frac{∂V_x}{∂x}$$ |$$\frac{∂V_x}{∂t} = -\frac{1}{ρ}~\frac{∂P}{∂x}$$  $$\frac{∂V_y}{∂t} = -\frac{1}{ρ}~\frac{∂P}{∂y}$$  $$\frac{∂P}{∂t} = -K~\left(\frac{∂V_x}{∂x} + \frac{∂V_y}{∂y} \right)$$ |


#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
For both physics
- The fluxes which are directional or vector quantities have a new $y$-direction component
- The balance equation or divergence, now balances the sum of the fluxes from all dimensions

"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Let's get started first with the diffusion equation, then the wave equation (as homework).
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### To dos:
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
#### $y$-direction physics and numerics

You can make multi-statement lines for scalars:

```julia
Lx, Ly = 10.0, 10.0
```
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
#### Time step definition

Take now the most restrictive condition, e.g.:

```julia
dt = min(dx, dy)/...
```
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
#### Initialise arrays

Recall that we are using conservative finite-differences and thus a _staggered grid_.

For 2D grids, we will have to handle scalar quantity and two fluxes as depicted below, taking care about correct staggering:

![staggered-grid](./figures/stagg_2D.png)
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
#### 2D plotting

You can use `heatmap()` function from `Plots.jl`, to plot e.g. `C` as function of the spatial coordinates `xc` and `yc`:

```julia
heatmap(xc, yc, C')
```
_note the transpose `'`_

Use `display()` to force the display of the plot, e.g., in the time loop every `nout`.
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
More advanced implementation, one can define the plotting options and apply them in the `heatmap()` call:

```julia
opts = (aspect_ratio=1, xlims=(xc[1], xc[end]), ylims=(yc[1], yc[end]), clims=(0.0, 1.0), c=:davos, xlabel="Lx", ylabel="Ly", title="time = $(round(it*dt, sigdigits=3))")
display(heatmap(xc, yc, C'; opts...))
```
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
That's how the 2D diffusion looks like:

![diffusion](./figures/diffusion_2D_1.gif)
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Let's get started with 2D.

**It's time to launch Julia on your computer** 🚀

👉 [Download the `diffusion_1D.jl` script](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/) to get you started
"""

#sol #md # 👉 [Download the `diffusion_2D.jl` script](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/).
