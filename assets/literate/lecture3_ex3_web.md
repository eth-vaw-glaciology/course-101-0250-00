<!--This file was generated, do not modify it.-->
## Exercise 3 - **Acoustic waves in 2D - v3**

👉 See [Logistics](/logistics/#submission) for submission details.

The goal of this exercise is to:
- Implement 2D wave equation
- Consolidate the finite-difference discretisation
- Familiarise with visualisation

In this third exercise, implement the wave equation as reported in the [beginning of lecture 3](#the_wave_equation),

$$ \frac{∂^2P}{∂t^2} = c^2 ∇^2 P~, $$

where
- $P$ is pressure,
- $c$ a non-negative real constant, here the speed of sound.

Cross-check that $c=\sqrt(K/ρ)$ and add `c` as new parameter to a `# Derived physics` section in the code.

The challenge here is to implement the second order time derivtive of the pressure $P$.

\note{You may need to use 2 arrays for the pressure update, `Pold` and `P`; in `Pold` you can store the values at time `(it-1)`, while you can use the array `P` for holding current `(it)` pressure values and finally use both to predict `Pnew` `(it+1)`}

### Task 1

Create a new Julia script `acoustic_2D_v3.jl` for this homework. The script should produce a `heatmap()` plot that update upon time steps, with labelled axes and physical time displayed as title.

Use `nx = 128` and `ny = 129` grid points and the same parameters as for exercise 1 and 2.

