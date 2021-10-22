<!--This file was generated, do not modify it.-->
## Exercise 4 - **Nonlinear steady-state diffusion 2D**

👉 See [Logistics](/logistics/#submission) for submission details.

The goal of this exercise is to:
- Investigate second-order acceleration
- Implement a fast implicit nonlinear diffusion solver in 2D

In this exercise you will transform the fast implicit nonlinear diffusion 1D solver from Exercise 3 to 2D.

To get started, save a copy of the `diffusion_nl_1D_steady_2.jl` script from [Exercise 3 - Task 2](#task_2__3), and name it `diffusion_nl_2D_steady_2.jl`.

### Task 1
You will port the 1D code to 2D, duplicating, if needed, all parameters from the $x$-dimension to the $y$-dimension. *(You can keep the definition of the damping term only function of `nx` since your domain is square.)*

In the `# Array initialisation`, use following functions to initialise 3 ellipses where the background subsurface permeability is reduced from `D0 = 5.0` to `D0 = 1.5`:

```julia
rad2_1 = (xc .- 2*Lx/3).^2 .* 3 .+ (yc' .-   Ly/3).^2 ./ 4
rad2_2 = (xc .- 2*Lx/3).^2 ./ 4 .+ (yc' .- 2*Ly/3).^2 .* 3
rad2_3 = (xc .-   Lx/3).^2 .* 1 .+ (yc' .-   Ly/2).^2 ./ 1
```

Use these "radius" functions to set the values of `D0 = 1.5` when the radius is smaller then 1.0 (for all 3 cases).

As boundary conditions, set `C = 0.5` at $x=dx/2$ and `C = 0.1` at $x=Lx-dx/2$. Implement a "no-flux" boundary condition ($∆C$ vanishes in the direction orthogonal to the boundary) at $y=dy/2$ and $y=Ly-dy/2$.

\note{Take care to adapt the iterative time step condition for 2D diffusion and think about how to modify the `maxloc()` function for 2D purposes, taking the local maximum amongst all 8 neighbours for each grid point.}

Report graphically the distribution of concentration `C` as function of `x` and `y` using a heatmap plot, adding axes labels and title reporting time, iteration count and current error.

\note{The iteration count for the accelerated 2D code should be in the order of 4500.}

Here is a sample output the code should produce:

![steady_2D_ex4](../assets/literate_figures/steady_2D_ex4.png)

