<!--This file was generated, do not modify it.-->
## Exercise 2 - **Acoustic waves in 2D - v2**

👉 See [Logistics](/logistics/#submission) for submission details.

The goal of this exercise is to:
- Implement 2D wave equation
- Consolidate the finite-difference discretisation
- Familiarise with visualisation

In this second exercise, you will implement a more concise version of the 2D wave equation.

Start from the 2D wave equation code from exercise 1, and reformulat the physics calculation without the explicit definition of the $q_x, q_y$ terms; only use velocities $V_x, V_y$ and pressure $P$.

### Task 1

Create a new Julia script `acoustic_2D_v2.jl` for this homework. The script should produce a `heatmap()` plot that update upon time steps, with labelled axes and physical time displayed as title.

Use `nx = 128` and `ny = 129` grid points and the same parameters as for exercise 1.

### Task 2

Create a 3-panels plot that shows the 2D pressure $P$ and the velocity $V_x$ fields, as well as the 1D cross section of the pressure field at $Ly/2$.

