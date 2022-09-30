#src # This is needed to make this run as normal Julia file
using Markdown #src

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
#nb # _Lecture 4_
md"""
# Modelling multi-physics
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### The goal of lecture 4 is to combine the acquired knowledge of numerical modelling and develop the first practical application: thermal porous convection in 2D.
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
### Building upon:
- The diffusion equation
- Spatial discretisation: 1D and 2D
- Finite-differences and staggered grids
- Accelerated pseudo-transient method
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

![staggered-grid](./figures/l4_stagg_2D.png)
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

![diffusion](./figures/l4_diffusion_2D_1.gif)
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Let's get started with 2D.

**It's time to launch Julia on your computer** 🚀

👉 [Download the `diffusion_1D.jl` script](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/) to get you started
"""

#sol=#md # 👉 [Download the `diffusion_2D.jl` script](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/).


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

(@v1.8) pkg> activate .

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
