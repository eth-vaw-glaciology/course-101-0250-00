md"""
## Exercise 3 - **Advection-diffusion in 2D**
"""

#md # 👉 See [Logistics](/logistics/#submission) for submission details.

md"""
The goal of this exercise is to
- Extend the advection-diffusion solver with implicit diffusion step from 1D to 2D
- Implement the upwind advection scheme in 2D

Create a code `implicit_advection_diffusion_2D.jl` for this exercise and add it to the `lecture3` folder in your private GitHub repo. Report the results of this exercise within a new section in the `README`.
"""

md"""
### Task 1
Repeat the steps from the Exercise 1 to create the implicit time-dependent 2D solver. Make a short animation showing the time evolution of the concentration field `C` during `nt=5` physical time steps.
"""

md"""
### Task 2
Add the advection step in a similar way to the 1D case from the previous exercise. Use following advection velocities

```julia
vx = 1.0
vy = -1.0
```
taking care in implementing the "upwind" strategy discussed in Lecture 2.

Choose the time step according to the stability criterion:

```julia
dt = min(dx/abs(vx),dy/abs(vy))/2
```

Make a short animation showing the time evolution of the concentration field `C` during `nt=10` physical time steps.
"""


