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
## What is convection and why we want to model it

Convection is a fluid flow driven by any instability arising from the interaction between the fluid properties such as density, and external forces such as gravity. If a layer of denser fluid lays on top of a layer of fluid with lower density, they will eventually mix and swap. An example of such fluids would be oil and water. In thermal convection, the density difference is caused by the thermal expansion of the fluid, i.e., the dependence of density on temperature. Usually, higher temperatures correspond to the lower densities.

~~~
<center>
  <video width="80%" autoplay loop controls src="https://upload.wikimedia.org/wikipedia/commons/0/0e/Lava_lamp_%28oT%29_07_ies.ogv"/>
</center>
~~~
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Fluid flows in porous materials such as rocks and soil could also be a result of convection. In this course, we only consider porous convection since it build on the already acquired knowledge of steady-state and transient diffusion processes. Porous convection often arises in nature and geoengineering. For example, water circulation in hydrothermal systems is caused by thermal convection, and mixing of CO$_2$ with saline water during geological storage results from chemical convection.
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
In the following, we will introduce the equation governing the thermal porous convection, demonstrate that in the simple cases these equations reduce to the already familiar steady-state and transient diffusion equations.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## Thermal porous convection: a physical model

Consider a layer of porous material of size $l_x \times l_y$. We assume that this layer is saturated with fluid, i.e., the pore space is completely filled by fluid. We introduce the _porosity_ $\varphi$ -- the volume fraction of material taken by pore space. The conservation of mass for the fluid requires:

$$
\frac{\partial\varphi\rho}{\partial t} + \nabla\cdot(\rho\varphi\boldsymbol{v}) = 0
$$

Here $\rho$ is the density of the fluid, and $\boldsymbol{v}$ is the fluid velocity. If the porous material is undeformable, i.e. $\varphi = \mathrm{const}$ and the fluid is incompressible, i.e., $\mathrm{d}\rho/\mathrm{d}t = \partial\rho/\partial t + \boldsymbol{v}\cdot\nabla\rho = 0$, the conservation of mass reduces to the following:

$$
\nabla\cdot(\varphi\boldsymbol{v}) = 0
$$
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### Darcy's law

We define the quantity $\boldsymbol{q_D} = \varphi\boldsymbol{v}$, which is called the _Darcy flux_ or _Darcy velocity_ and is the volumetric flow rate per unit area of the porous media.
Standard approximation is the linear dependence between $\boldsymbol{q_D}$ and the pressure gradient, known as the [_Darcy's law_](https://en.wikipedia.org/wiki/Darcy's_law):

$$
\boldsymbol{q_D} = -\frac{k}{\eta}(\nabla p - \rho \boldsymbol{g})
$$

where $k$ is the proportionality coefficient called _permeability_, $\eta$ is the fluid viscosity, $p$ is pressure, $\boldsymbol{g}$ is the gravity vector.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### Diffusion equation for pressure
Substituting the Darcy's law into the mass conservation law for incompressible fluid, we obtain the steady-state diffusion equation for the pressure $p$:
$$
-\nabla\cdot\left[\frac{k}{\eta}(\nabla p - \rho\boldsymbol{g})\right] = 0
$$
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### Heat convection in porous media

In the following, we assume for simplicity that the porosity is constant: $\varphi=\mathrm{const}$.

Conservation of energy in the fluid results in the following equation for the temperature $T$:
$$
\rho c_p \frac{\partial T}{\partial t} + \rho c_p\boldsymbol{v}\cdot\nabla T + \nabla\cdot\boldsymbol{q_T} = 0
$$
Here, $c_p$ is the specific heat capacity of the fluid, and $\boldsymbol{q_T}$ is the conductive heat flux. Note that the time $t$ here is the physical time.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
In a very similar manner to the Darcy's law, we relate the heat flux to the gradient of temperature (Fourier's law):

$$
\boldsymbol{q_T} = -\lambda\nabla T
$$

where $\lambda$ is the _thermal conductivity_. Assuming $\lambda=\mathrm{const}$, substituting the Fourier's law into the energy equation, and using the definition of the Darcy flux we obtain:
$$
\frac{\partial T}{\partial t} + \frac{1}{\varphi}\boldsymbol{q_D}\cdot\nabla T - \frac{\lambda}{\rho c_p} \nabla\cdot\nabla T = 0
$$

This is the transient advection-diffusion equation. The temperature is advected with the fluid velocity $\boldsymbol{q_D}/\varphi$ and diffused with the diffusion coefficient $\lambda/(\rho c_p)$
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### Modeling buoyancy: Boussinesq approximaiton

Now the transient pressure diffusion and steady pressure diffusion are coupled in a one-way fashion through the Darcy flux in the temperature equation. To model convection, we need to incorporate the dependency of the density on temperature in the equations. The simplest way is to introduce the linear dependency:

$$
\rho = \rho_0\left\[1-\alpha (T-T_0)\right\]
$$
where $\alpha$ is the thermal expansion coefficient.

However, the equations were formulated for the incompressible case!
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
In convection problems, the gravity term $\rho\boldsymbol{g}$ makes the dominant contribution to the force balance. Therefore, variations in density due to thermal expansion are often accounted for only in the $\rho\boldsymbol{g}$ term and are neglected in other places. This is called the [_Boussinesq approximation_](https://en.wikipedia.org/wiki/Boussinesq_approximation_(buoyancy)).
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Using the Boussinesq approximation, the incompressible equations remain valid, and the only place where the modified densities is the definition of the Darcy flux:

$$
\boldsymbol{q_D} = -\frac{k}{\eta}(\nabla P - \rho_0\left[1-\alpha (T-T_0)\right]\boldsymbol{g})
$$
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## Solving thermal porous convection using the pseudo-transient method

We already discussed how the steady-state and transient equations could be solved efficiently by adding the pseudo-transient terms to the governing equations. Let's do this for the porous convection!
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
This can be achieved by typing entering the Pkg mode from the Julia REPL in the target folder

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
"""

#nb # > 💡 note: The `Manifest.toml` file should be kept local. An automated way of doing so is to add it as entry to a `.gitignore` file in the root of your repo. Mac users may also add `.DS_Store` to their `.gitignore`.`
#md # \note{The `Manifest.toml` file should be kept local. An automated way of doing so is to add it as entry to a `.gitignore` file in the root of your repo. Mac users may also add `.DS_Store` to their `.gitignore`}
