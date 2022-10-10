md"""
## Exercise 1 - **Thermal porous convection in 2D**
"""

#md # 👉 See [Logistics](/logistics/#submission) for submission details.

md"""
The goal of this exercise is to:
- Implement a 2D nonlinear diffusion equation
- Consolidate the finite-difference discretisation
"""

md"""
In this first exercise, you will port the shallow ice-like 1D nonlinear diffusion code we did in class to a 2D implementation.

Starting from the 1D nonlinear diffusion equation we discussed in lecture 4, extend the 1D code to a 2D configuration. Use the same parameters for the $y$-dimension quantities as the one you already have for the $x$-dimension.
"""

#nb # > 💡 hint: Don't forget to initialise (pre-allocate) all arrays (vectors) needed in the calculations. You will also need to handle the effective diffusivities in both $x$ and $y$ directions to account for correct staggering.
#md # \note{Don't forget to initialise (pre-allocate) all arrays (vectors) needed in the calculations. You will also need to handle the effective diffusivities in both $x$ and $y$ directions to account for correct staggering.}

md"""
### Task 1
Create a new folder in your GitHub repository for this week's (lecture 4) exercises. In there, create a new Julia script `porous_convection_2D.jl` for this homework. Take 1D steady diffusion script `l3_steady_diffusion_1D.jl` as a basis. Rename variables so that we solve it for the pressure.
"""

md"""
### Task 2
Convert this script to 2D. The script should produce a `heatmap()` plot after the iterations converge.

Use `nx = 128` and `ny = 129` grid points.
"""

md"""
### Task 3

Wrap the iteration loop into a time loop. Make `nt=10` time steps.
"""

md"""
### Task 4

Add new fields for the temperature evolution (advection and diffusion). Add the temperature update after the iteration loop. Don't forget updwind! Implement initial and boundary conditions.
"""

md"""
### Task 5

Add two-way coupling using the Boussinesq approximation, i.e., the dependence of density on temperature in the Darcy flux. Produce the animation displaying the temperature evolution and arrows for velocities.

```julia
Vscale = 1/maximum(sqrt.(Vxp.^2 + Vyp.^2)) * dx*(st-1)
quiver!(Xp[:], Yp[:], quiver=(Vxp[:]*Vscale, Vyp[:]*Vscale), lw=0.1, c=:blue); frame(anim)
```
"""
