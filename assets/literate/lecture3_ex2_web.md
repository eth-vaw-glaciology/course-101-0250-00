<!--This file was generated, do not modify it.-->
## Exercise 2 - **Operator-splitting for advection-diffusion**

👉 See [Logistics](/logistics/#submission) for submission details.

The goal of this exercise is to implement the advection-diffusion with implicit timestepping for diffusion. Start from the time-dependent code you developed in Exercise 1. Then add advection step after the iteration loop so that the concentration is advected only once per physical time step.

### Getting started
1. Duplicate the file `implicit_diffusion_1D.jl` in the folder `lecture3` and name it `implicit_advection_diffusion_1D.jl`.
4. Modify that script so that it includes the advection step as follows.

### Task 1
Add advection to the implicit diffusion code, using an advection velocity of

```julia
vx = 1.0
```
and use the stability criteria for advection to specify the physical timestep:

```julia
dt = dx/abs(vx)
```

Note that now one doesn't need to take the minimum between the time steps for diffusion and advection, since the diffusion that is more restrictive is resolved implicitly. Also, we do not consider any change in velocity direction at mid-simulation.

Now the physical timestep `dt` is defined by advection velocity, so the `da` number that is needed for calculating the optimal PT parameters, has to be computed from `dt`:

```julia
# derived numerics
dt      = dx/abs(vx)
da      = lx^2/dc/dt
re      = ...
ρ       = ...
dτ      = ...
```

Report with the figure, plotting a spatial distribution of concentration `C` after `nt=10` time steps, on top of the plot of the initial concentration distribution. Add the figure to the `README.md` file.

