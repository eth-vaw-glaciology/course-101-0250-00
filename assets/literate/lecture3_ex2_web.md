<!--This file was generated, do not modify it.-->
## Exercise 2 - **Operator-splitting for advection-diffusion**

👉 See [Logistics](/logistics/#submission) for submission details.

The goal of this exercise is to implement the advection-diffusion with implicit timestepping for diffusion. Start from the time-dependent code you developed in Exercise 1. Then add advection step after the iteration loop so that the concentration is advected only once per physical time step.

### Task 1
Add advection to the implicit diffusion code. Use the stability criteria for advection to specify the physical timestep:

```julia
dt = dx/abs(vx)
```

Note that now one doesn't need to take the minimum between the time steps for diffusion and advection, since the diffusion that is more restrictive is resolved implicitly.

Report with the figure, plotting a spatial distribution of concentration `C` after `nt=10` time steps, on top of the plot of the initial concentration distribution.

