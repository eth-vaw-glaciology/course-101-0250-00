md"""
## Exercise 1 — **Advection-Diffusion**
"""

#md # 👉 [Download the notebook to get started with this exercise!](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/notebooks/lecture2_ex1.ipynb)

#md # \warn{Write a monolithic Julia script to solve this exercise in a Jupyter notebook and hand it in on Moodle ([more](/homework)).}

md"""
The goal of this exercise is to couple physical processes implementing:
- 1D advection-diffusion
- Non-dimensional numbers
"""

md"""
The goal of this exercise is to combine advection and diffusion processes acting on the concentration of a quantity $C$.

From what you learned in class, write an advection-diffusion code having following physical input parameters:

```julia
# Physics
lx   = 20.0  # domain length
dc   = 0.1   # diffusion coefficient
vx   = 1.0   # advection velocity
ttot = 20.0  # total simulation time
```

Discretise your domain in 200 finite-difference cells such that the first cell centre is located at `dx/2` and the last cell centre at `lx-dx/2`. Use following explicit time step limiters:

```julia
dta  = dx/abs(vx)
dtd  = dx^2/dc/2
dt   = min(dtd, dta)
```

As initial condition, define a Gaussian profile of concentration `C` of amplitude and standard deviation equal to 1, located at `lx/4`.

In the time-loop, add a condition that would change de direction of the velocity `vx` at time `ttot/2`.

Set Dirichlet boundary conditions on the concentration for the diffusion process such that `C=0` at the boundaries. This can be implicitly achieved by updating only the inner points of `C` with the divergence of the diffusive flux (i.e. `C[2:end-1]`). For the advection part, implement upwind scheme making sure to treat cases for both positive and negative velocities `vx`.
"""

#nb # > 💡 hint: Don't forget to initialise (pre-allocate) all arrays (vectors) needed in the calculations.
#md # \note{Don't forget to initialise (pre-allocate) all arrays (vectors) needed in the calculations.}

md"""
### Question 1

Report the initial and final distribution of concentration on a figure with axis-label, title, and plotted line labels. Also, report on the figure (as text in one label of your choice) the maximal final concentration value and its x location.

### Question 2

Repeat the exercise but introduce the non-dimensional [Péclet number](https://en.wikipedia.org/wiki/Péclet_number) $Pe = lx~vx/dc$ as physical quantity defining the diffusion coefficient `dc` as a `# Derived physics` quantity. Confirm the if $Pe >> 100$ the diffusion happens in a much longer time compared to the advection, and the opposite for $Pe << 100$.
"""

#nb # > 💡 hint: You may want to adapt (potentially reduce) `ttot` in one of the cases as to avoid the simulation to run forever.
#md # \note{You may want to adapt (potentially reduce) `ttot` in one of the cases as to avoid the simulation to run forever.}


