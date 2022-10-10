<!--This file was generated, do not modify it.-->
## Exercise 1 - **Thermal porous convection in 2D**

👉 See [Logistics](/logistics/#submission) for submission details.

The goal of this exercise is to:
- Implement coupled diffusion equations in 2D
- Consolidate the implicit updates and dual timestepping

In this first exercise, you will finalise the thermal porous convection discussed and implemented in class.

### Task 1
Create a new folder in your GitHub repository for this week's (lecture 4) exercises. In there, create a new Julia script `porous_convection_2D.jl` for this homework. Take 1D steady diffusion script `l3_steady_diffusion_1D.jl` as a basis. Rename variables so that we solve it for the pressure.

### Task 2
Convert this script to 2D. The script should produce a `heatmap()` plot after the iterations converge.

Use `nx = 128` and `ny = 129` grid points.

### Task 3

Wrap the iteration loop into a time loop. Make `nt=10` time steps.

### Task 4

Add new fields for the temperature evolution (advection and diffusion). Add the temperature update after the iteration loop. Don't forget updwind! Implement initial and boundary conditions.

### Task 5

Add two-way coupling using the Boussinesq approximation, i.e., the dependence of density on temperature in the Darcy flux. Produce the animation displaying the temperature evolution and arrows for velocities.

```julia
Vscale = 1/maximum(sqrt.(Vxp.^2 + Vyp.^2)) * dx*(st-1)
quiver!(Xp[:], Yp[:], quiver=(Vxp[:]*Vscale, Vyp[:]*Vscale), lw=0.1, c=:blue); frame(anim)
```

