md"""
## Exercise 3 - **Navier-Stokes flow**
"""

#md # 👉 See [Logistics](/logistics/#submission) for submission details.

md"""
The goal of this exercise is to:
- Implement a viscous Stokes flow
- Step from the Navier-Cauchy elastic wave solver to en explicit Navier-Stokes solver
- Get a glimpse into fluid dynamics

"""

md"""
### Getting started

In this exercise your task will be to modify the elastic wave code `elastic_2D.jl` from [Exercise 3, Lecture 7](/lecture7/#task_4_-_rearranging_the_code), turning it into a weakly compressible viscous Navier-Stokes flow solver with inertia terms.

The main task will be to modify the shear rheology, now viscous. Viscosity [Pa.s] defines as the ratio between  stress $τ$ and strain-rate $ε̇$.

In this lecture's Git repository, duplicate the `elastic_2D.jl` renaming it `viscous_NS_2D.jl`.

### Task 1

Modify the physics in order to implement the weakly compressible Navier-Stokes equations:

$$ \frac{∂P}{∂t} = -K ∇_k v_k ~,$$

$$ τ = μ\left(∇_i v_j + ∇_j v_i -\frac{1}{3} δ_{ij} ∇_k v_k \right) ~,$$

$$ ρ \frac{∂v_i}{∂t} = ∇_j \left( τ_{ij} - P δ_{ij} \right) ~,$$

where $P$ is the pressure, $v$ the velocity, $K$ the bulk modulus, $μ$ the viscosity, $τ$ the viscous deviatoric stress tensor, $ρ$ the density, and $\delta_{ij}$ the Kronecker delta.

### Task 2 

In a new section of the `README.md` add a figure from code featuring 4 subplots depicting pressure $P$, velocity x-component $v_x$, normal and shear stress components, $\tau_{xx}$ and $\tau_{xy}$, respectively, and a short description.
"""


