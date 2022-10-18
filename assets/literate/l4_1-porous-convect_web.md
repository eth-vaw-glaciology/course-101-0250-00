<!--This file was generated, do not modify it.-->
# Modelling multi-physics

### The goal of lecture 4 is to combine the acquired knowledge of numerical modelling and develop the first practical application: thermal porous convection in 2D.

### Building upon:
- The diffusion equation
- Spatial discretisation: 1D and 2D
- Finite-differences and staggered grids
- Accelerated pseudo-transient method

## What is convection and why we want to model it

Convection is a fluid flow driven by any instability arising from the interaction between the fluid properties such as density, and external forces such as gravity. If a layer of denser fluid lays on top of a layer of fluid with lower density, they will eventually mix and swap.

An example of such fluids would be oil and water. In thermal convection, the density difference is caused by the thermal expansion of the fluid, i.e., the dependence of density on temperature. Usually, higher temperatures correspond to lower densities.

~~~
<iframe width="560" height="315" src="https://www.youtube.com/embed/zbo6jUGrwdk" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
~~~

Fluid flows in porous materials such as rocks and soil could also be a result of convection.

In this course, we only consider porous convection since it build on the already acquired knowledge of steady-state and transient diffusion processes.

Porous convection often arises in nature and geoengineering. For example, water circulation in hydrothermal systems is caused by thermal convection, and mixing of CO$_2$ with saline water during geological storage results from chemical convection.

In the following, we will introduce the equation governing the thermal porous convection, demonstrate that in the simple cases these equations reduce to the already familiar steady-state and transient diffusion equations.

## Thermal porous convection: a physical model

Consider a layer of porous material of size $l_x \times l_y$. We assume that this layer is saturated with fluid, i.e., the pore space is completely filled by fluid. We introduce the _porosity_ $\varphi$, the volume fraction of material taken by pore space. The conservation of mass for the fluid requires:

$$
\frac{\partial\rho\varphi}{\partial t} + \nabla\cdot(\rho\varphi\boldsymbol{v}) = 0
$$

Here $\rho$ is the density of the fluid, and $\boldsymbol{v}$ is the fluid velocity. If the porous material is undeformable, i.e., $\varphi = \mathrm{const}$ and the fluid is incompressible, i.e., $\mathrm{d}\rho/\mathrm{d}t = \partial\rho/\partial t + \boldsymbol{v}\cdot\nabla\rho = 0$, the conservation of mass reduces to the following:

$$
\nabla\cdot(\varphi\boldsymbol{v}) = 0
$$

### Darcy's law

We define the quantity $\boldsymbol{q_D} = \varphi\boldsymbol{v}$, which is called the _Darcy flux_ or _Darcy velocity_ and is the volumetric flow rate per unit area of the porous media.
Standard approximation is the linear dependence between $\boldsymbol{q_D}$ and the pressure gradient, known as the [_Darcy's law_](https://en.wikipedia.org/wiki/Darcy's_law):

$$
\boldsymbol{q_D} = -\frac{k}{\eta}(\nabla p - \rho \boldsymbol{g})
$$

where $k$ is the proportionality coefficient called _permeability_, $\eta$ is the fluid viscosity, $p$ is pressure, $\boldsymbol{g}$ is the gravity vector.

### Diffusion equation for pressure
Substituting the Darcy's law into the mass conservation law for incompressible fluid, we obtain the steady-state diffusion equation for the pressure $p$:
$$
\nabla\cdot\left[\frac{k}{\eta}(\nabla p - \rho\boldsymbol{g})\right] = 0
$$

### Heat convection in porous media

In the following, we assume for simplicity that the porosity is constant: $\varphi=\mathrm{const}$.

Conservation of energy in the fluid results in the following equation for the temperature $T$:
$$
\rho c_p \frac{\partial T}{\partial t} + \rho c_p\boldsymbol{v}\cdot\nabla T + \nabla\cdot\boldsymbol{q_F} = 0
$$
Here, $c_p$ is the specific heat capacity of the fluid, and $\boldsymbol{q_F}$ is the conductive heat flux. Note that the time $t$ here is the physical time.

In a very similar manner to the Darcy's law, we relate the heat flux to the gradient of temperature (Fourier's law):

$$
\boldsymbol{q_F} = -\lambda\nabla T
$$

where $\lambda$ is the _thermal conductivity_. Assuming $\lambda=\mathrm{const}$, substituting the Fourier's law into the energy equation, and using the definition of the Darcy flux we obtain:
$$
\frac{\partial T}{\partial t} + \frac{1}{\varphi}\boldsymbol{q_D}\cdot\nabla T - \frac{\lambda}{\rho c_p} \nabla\cdot\nabla T = 0
$$

This is the transient advection-diffusion equation. The temperature is advected with the fluid velocity $\boldsymbol{q_D}/\varphi$ and diffused with the diffusion coefficient $\lambda/(\rho c_p)$

### Modelling buoyancy: Boussinesq approximation

Now the transient pressure diffusion and steady pressure diffusion are coupled in a one-way fashion through the Darcy flux in the temperature equation. To model convection, we need to incorporate the dependency of the density on temperature in the equations. The simplest way is to introduce the linear dependency:

$$
\rho = \rho_0\left[1-\alpha (T-T_0)\right]
$$

where $\alpha$ is the thermal expansion coefficient.

However, the equations were formulated for the incompressible case!

In convection problems, the gravity term $\rho\boldsymbol{g}$ makes the dominant contribution to the force balance. Therefore, variations in density due to thermal expansion are often accounted for only in the $\rho\boldsymbol{g}$ term and are neglected in other places. This is called the [_Boussinesq approximation_](https://en.wikipedia.org/wiki/Boussinesq_approximation_(buoyancy)).

Using the Boussinesq approximation, the incompressible equations remain valid, and the modified densities only appear in the definition of the Darcy flux:

$$
\boldsymbol{q_D} = -\frac{k}{\eta}(\nabla P - \rho_0\left[1-\alpha (T-T_0)\right]\boldsymbol{g})
$$

## Solving thermal porous convection using the pseudo-transient method

We already discussed how the steady-state and transient equations could be solved efficiently by adding the pseudo-transient terms to the governing equations.

Let's apply this strategy to solve the thermal porous convection!

The thermal porous convection is a coupled system of equations describing the evolution of pressure and temperature. To simplify the equations, we solve not for the absolute values for pressure and temperature, but for the deviation of pressure from hydrostatic gradient $\int_{z}\rho g\,dz$, and deviation of temperature from the reference value $T_0$.

In addition, to reduce the number of independent variables in the code, instead of using the Fourier heat flux $\boldsymbol{q_F}$ we use the temperature diffusion flux $\boldsymbol{q_T}=\boldsymbol{q_F}/(\rho_0 c_p)$.

With these reformulations in mind, the full system of equations to solve is:

$$
\boldsymbol{q_D} = -\frac{k}{\eta}(\nabla p - \rho_0\alpha\boldsymbol{g}T)
$$

$$
\nabla\cdot\boldsymbol{q_D} = 0
$$

$$
\boldsymbol{q_T} = -\frac{\lambda}{\rho_0 c_p}\nabla T
$$

$$
\frac{\partial T}{\partial t} + \frac{1}{\varphi}\boldsymbol{q_D}\cdot\nabla T + \nabla\cdot\boldsymbol{q_T} = 0
$$

We formulate the pseudo-transient system of equations by augmenting the system with pseudo-physical terms. We add inertial terms to the Darcy and temperature diffusion fluxes:

$$
\theta_D\frac{\partial \boldsymbol{q_D}}{\partial\tau} + \boldsymbol{q_D} = -\frac{k}{\eta}(\nabla p - \rho_0\alpha\boldsymbol{g}T)
$$
$$
\theta_T\frac{\partial \boldsymbol{q_T}}{\partial\tau} + \boldsymbol{q_T} = -\frac{\lambda}{\rho_0 c_p}\nabla T
$$
Here, $\theta_D$ and $\theta_T$ are the characteristic relaxation times for pressure and heat diffusion, respectively, and $\tau$ is the pseudo-time.

Then, we add the pseudo-compressibility to the mass balance equation. For each physical time step we discretise the physical time derivative and add the pseudo-time derivative (dual-time method):
$$
\beta\frac{\partial p}{\partial\tau} + \nabla\cdot\boldsymbol{q_D} = 0
$$

$$
\frac{\partial T}{\partial \tau} + \frac{T-T_\mathrm{old}}{\mathrm{d}t} + \frac{1}{\varphi}\boldsymbol{q_D}\cdot\nabla T + \nabla\cdot\boldsymbol{q_T} = 0
$$

Here, $\beta$ is the pseudo-compressibility, $\mathrm{d}t$ is the physical time step, and $T_\mathrm{old}$ is the distribution of temperature at the previous physical time step.

This new system of equations is amendable to the efficient solution by the pseudo-transient method. We'll implement the thermal porous convection solver in 2 stages:
- in the first stage, we'll program the efficient elliptic solver for the pressure, leaving the temperature update explicit, and;
- in the second stage, we'll make the temperature (advection-diffusion) solver also implicit.

### Useful information

#### Initialise arrays

Recall that we are using conservative finite-differences and thus a _staggered grid_.

For 2D grids, we will have to handle scalar quantity and two fluxes as depicted below, taking care about correct staggering:

![staggered-grid](../assets/literate_figures/l4_stagg_2D.png)

#### 2D plotting

You can use `heatmap()` function from `Plots.jl`, to plot e.g. `C` as function of the spatial coordinates `xc` and `yc`:

```julia
heatmap(xc, yc, C')
```
_note the transpose `'`_

Use `display()` to force the display of the plot, e.g., in the time loop every `nout`.

More advanced implementation, one can define the plotting options and apply them in the `heatmap()` call:

```julia
opts = (aspect_ratio=1, xlims=(xc[1], xc[end]), ylims=(yc[1], yc[end]), clims=(0.0, 1.0), c=:turbo, xlabel="Lx", ylabel="Ly", title="time = $(round(it*dt, sigdigits=3))")
display(heatmap(xc, yc, C'; opts...))
```

# Julia's Project environment

On GitHub, make sure to create a new folder for each week's exercises.

Each week's folder should be a Julia project, i.e. contain a `Project.toml` file.

This can be achieved by typing entering the Pkg mode from the Julia REPL in the target folder

```julia-repl
julia> ]

(@v1.8) pkg> activate .

(lectureXX) pkg> add Plots
```

and adding at least one package.

In addition, it is recommended to have the following structure and content:
- lectureXX
  - `README.md`
  - `Project.toml`
  - `Manifest.toml`
  - docs/
  - scripts/

Codes could be placed in the `scripts/` folder. Output material to be displayed in the `README.md` could be placed in the `docs/` folder.

\note{The `Manifest.toml` file should be kept local. An automated way of doing so is to add it as entry to a `.gitignore` file in the root of your repo. Mac users may also add `.DS_Store` to their `.gitignore`}

