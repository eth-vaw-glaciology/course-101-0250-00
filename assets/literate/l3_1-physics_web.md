<!--This file was generated, do not modify it.-->
# Solving elliptic PDEs

### The goal of this lecture 3 is to familiarise (or refresh) with:
- The damped wave equation
- Spectral analysis of linear PDEs
- Pseudo-transient method for solving elliptic PDEs
- Spatial discretisation: 1D and 2D

In the previous lecture, we established that the solution to the elliptic PDE could be obtained through integrating in time a corresponding parabolic PDE:

$$
\frac{\partial C}{\partial t} - \frac{\partial^2 C}{\partial x^2} = 0
$$

and discussed the limitation of this approach, for numerical modelling, i.e., the quadratic dependence of the number of time steps on the number of grid points in spatial discretisation.

~~~
<center>
  <video width="80%" autoplay loop controls src="../assets/literate_figures/diffusion_1D_steady_state.mp4"/>
</center>
~~~

## Accelerating elliptic solver convergence: intuition

In this lecture, we'll improve the convergence rate of the elliptic solver, and consider the generalisation to higher dimensions

Let's recall the stability conditions for diffusion and acoustic wave propagation:

```julia
dt = dx^2/dc/2      # diffusion
dt = dx/sqrt(1/β/ρ) # acoustic wave propagation
```

We can see that the acceptable time step for an acoustic problem is proportional to the grid spacing `dx`, and not `dx^2` as for the diffusion.

The number of time steps required for the wave to propagate through the domain is only proportional to the number of grid points `nx`.

Can we use that information to reduce the time required for the elliptic solver to converge?
In the solution to the wave equation, the waves do not attenuate with time: _there is no steady state!_

~~~
<center>
  <video width="80%" autoplay loop controls src="../assets/literate_figures/acoustic_1D.mp4"/>
</center>
~~~

## Damped wave equation

Let's add diffusive properties to the wave equation by simply combining the physics:

$$
\rho\frac{\partial V_x}{\partial t} = -\frac{\partial Pr}{\partial x}
$$

$$
\beta\frac{\partial Pr}{\partial t} + \frac{Pr}{\eta} = -\frac{\partial Vx}{\partial x}
$$

Note the addition of the new term $\frac{Pr}{\eta}$ to the left-hand side of the mass balance equation, which could be interpreted physically as adding the bulk viscosity to the gas.

Equvalently, we could add the time derivatives to the diffusion equation

$$
\rho\frac{\partial q}{\partial t} + \frac{q}{D} = -\frac{\partial C}{\partial x}
$$

$$
\frac{\partial C}{\partial t} = -\frac{\partial q}{\partial x}
$$

In that case, the new term would be `\rho\frac{\partial q}{\partial t}`, which could be interpreted physically as adding inertia to the momentum equation for diffusive flux.

## From 1D to 2D

Let's discuss how to implement the acoustic wave equation (and the diffusion equation from last week's material) in 2D.

We want the $x$ and $y$ axis to represent spatial extend, and solve in each grid point for the pressure or the concentration, for the acoustic and diffusion process, respectively.

But let's first look at the equation, augmenting the Table we just started to fill

|  Physics       |  1D formulation  |  2D formulation  |
| :------------: | :--------------: | :--------------: |
| Diffusion      | $q_x = -D\frac{∂C}{∂x}$            | $q_x = -D\frac{∂C}{∂x}$ |
|                |                                    | $q_y = -D\frac{∂C}{∂y}$ |
|                | $\frac{∂C}{∂t} = -\frac{∂q_x}{∂x}$ | $\frac{∂C}{∂t} = -\left(\frac{∂q_x}{∂x} + \frac{∂q_y}{∂y} \right)$ |
| Acoustic waves | $\frac{∂V_x}{∂t} = -\frac{1}{ρ}~\frac{∂P}{∂x}$ | $\frac{∂V_x}{∂t} = -\frac{1}{ρ}~\frac{∂P}{∂x}$ |
|                |                                                | $\frac{∂V_y}{∂t} = -\frac{1}{ρ}~\frac{∂P}{∂y}$ |
|                | $\frac{∂P}{∂t} = -K~\frac{∂V_x}{∂x}$           | $\frac{∂P}{∂t} = -K~\left(\frac{∂V_x}{∂x} + \frac{∂V_y}{∂y} \right)$ |

For both physics
- The fluxes which are directional or vector quantities have a new $y$-direction component
- The balance equation or divergence, now balances the sum of the fluxes from all dimensions

Let's get started first with the diffusion equation, then the wave equation (as homework).

### To dos:
- Add $y$-direction physics and numerics
- Update time step definition
- Update initial Gaussian condition
- Initialise all new arrays
- Update physics calculations in the time loop
- Update plotting

#### $y$-direction physics and numerics

You can make multi-statement lines for scalars:

```julia
Lx, Ly = 10.0, 10.0
```

#### Time step definition

Take now the most restrictive condition, e.g.:

```julia
dt = min(dx, dy)/...
```

#### Initialise arrays

Recall that we are using conservative finite-differences and thus a _staggered grid_.

For 2D grids, we will have to handle scalar quantity and two fluxes as depicted below, taking care about correct staggering:

![staggered-grid](../assets/literate_figures/stagg_2D.png)

#### 2D plotting

You can use `heatmap()` function from `Plots.jl`, to plot e.g. `C` as function of the spatial coordinates `xc` and `yc`:

```julia
heatmap(xc, yc, C')
```
_note the transpose `'`_

Use `display()` to force the display of the plot, e.g., in the time loop every `nout`.

More advanced implementation, one can define the plotting options and apply them in the `heatmap()` call:

```julia
opts = (aspect_ratio=1, xlims=(xc[1], xc[end]), ylims=(yc[1], yc[end]), clims=(0.0, 1.0), c=:davos, xlabel="Lx", ylabel="Ly", title="time = $(round(it*dt, sigdigits=3))")
display(heatmap(xc, yc, C'; opts...))
```

That's how the 2D diffusion looks like:

![diffusion](../assets/literate_figures/diffusion_2D_1.gif)

Let's get started with 2D.

**It's time to launch Julia on your computer** 🚀

👉 [Download the `diffusion_1D.jl` script](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/) to get you started

````julia:ex1
#sol #md # 👉 [Download the `diffusion_2D.jl` script](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/).
````

