md"""
## Exercise 3 - **Acoustic waves in 2D - v3**
"""

#md # 👉 See [Logistics](/logistics/#submission) for submission details.

md"""
The goal of this exercise is to:
- Implement 2D wave equation
- Consolidate the finite-difference discretisation
- Familiarise with visualisation
"""

md"""
In this third exercise, implement the wave equation as reported in the [beginning of lecture 3](#the_wave_equation),

$$ \frac{∂^2P}{∂t^2} = c^2 ∇^2 P~, $$

where
- $P$ is pressure,
- $c$ a non-negative real constant, here the speed of sound.

Cross-check that $c=\sqrt(K/ρ)$ and add `c` as new parameter to a `# Derived physics` section in the code.

The challenge here is to implement the second order time derivtive of the pressure $P$. The second order time derivative expands as

$$  \frac{∂^2P}{∂t^2} = P^{t+∆t} - 2~P^{t} + P^{t-∆t}~,$$

reason you actually need 3 explicit time integration layer, $P_\mathrm{new},~P_\mathrm{current},~P_\mathrm{old}$, updating $P_\mathrm{new}$ as from the two others and having your spatial derivatives done on $P_\mathrm{current}$.

Also, initialise all 3 pressure arrays with the same Gaussian initial condition.
"""

#nb # > 💡 hint: You may need to use 3 arrays for the pressure update, `Pold`, `P` and `Pnew`; in `Pold` you can store the values at time `(it-1)`, while you can use the array `P` for holding current `(it)` pressure values and finally use `Pnew` for prediction at `(it+1)`. Don't forget to assign the appropriate updates at the end of the time loop.
#md # \note{You may need to use 3 arrays for the pressure update, `Pold`, `P` and `Pnew`; in `Pold` you can store the values at time `(it-1)`, while you can use the array `P` for holding current `(it)` pressure values and finally use `Pnew` for prediction at `(it+1)`. Don't forget to assign the appropriate updates at the end of the time loop.}

md"""
### Task 1

Create a new Julia script `acoustic_2D_v3.jl` for this homework. The script should produce a `heatmap()` plot that update upon time steps, with labelled axes and physical time displayed as title.

Use `nx = 128` and `ny = 129` grid points and the same parameters as for exercise 1 and 2.
"""
