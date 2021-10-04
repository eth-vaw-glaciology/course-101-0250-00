<!--This file was generated, do not modify it.-->
## Exercise 1 - **Acoustic waves in 2D**

👉 See [Logistics](/logistics/#submission) for submission details.

The goal of this exercise is to:
- Implement 2D wave equation
- Consolidate the finite-difference discretisation
- Familiarise with visualisation

In this first exercise, the goal is to repeat the steps we did in class with the diffusion codes going from the 1D to the 2D implementation.

Starting from the 1D acoustic wave equation we discussed in lecture 3, extend the 1D code to a 2D configuration. Use the same parameters for the $y$-direction quantities.

\note{Don't forget to initialise (pre-allocate) all arrays (vectors) needed in the calculations}

### Task 1

Create a new Julia script `acoustic_2D_v1.jl` for this homework. The script should produce a `heatmap()` plot that update upon time steps, with labelled axes and physical time displayed as title.

Use `nx = 128` and `ny = 129` grid points.

\note{During development, having `nx ≠ ny` may prevent errors with staggering to occur}

### Task 2

Record the pressure at position $(x,y) = (5,7)$ during the entire simulation and report it as a subplot (pressure as function of time).

\note{Check out e.g. [here](https://docs.juliaplots.org/latest/tutorial/#Combining-Multiple-Plots-as-Subplots) for inspiration about subplots}

