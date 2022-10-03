<!--This file was generated, do not modify it.-->
## Exercise 3 - **Advection-diffusion in 2D**

👉 See [Logistics](/logistics/#submission) for submission details.

The goal of this exercise is to
- Extend the advection-diffusion solver with implicit diffusion step from 1D to 2D
- Implement the upwind advection scheme in 2D

👉 Download the `steady_diffusion_reaction_2D.jl` script [here](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/) if needed (available after the course).

### Task 1
Repeat the steps from the Exercise 1 to make the implicit time-dependent 2D solver. Make a short animation showing the time evolution of the concentration field `C` during `nt=5` physical time steps.

### Task 2
Add the advection step in a similar way to the 1D case from the previous exercise. Choose the time step according to the stability criterion:

```julia
dt = min(dx/abs(vx),dy/abs(vy))/2
```

Make a short animation showing the time evolution of the concentration field `C` during `nt=10` physical time steps.

