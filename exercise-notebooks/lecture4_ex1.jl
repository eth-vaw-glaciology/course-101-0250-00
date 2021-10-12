md"""
## Exercise 1 - **Nonlinear diffusion in 2D**
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

Create a new folder in your GitHub repository for this week's (lecture 4) exercises. In there, create a new Julia script `diffusion_nl_2D.jl` for this homework. The script should produce a `heatmap()` plot that update upon time steps, with labelled axes and physical time displayed as title.

Use `nx = 128` and `ny = 129` grid points.
"""

md"""
### Task 2

Track the maximal ice thickness over time and report it in a plot as function of time.
"""
