md"""
## Exercise 3 - **Nonlinear steady-state diffusion 1D**
"""

#md # 👉 See [Logistics](/logistics/#submission) for submission details.

md"""
The goal of this exercise is to:
- Investigate second-order acceleration
- Implement a fast implicit nonlinear diffusion solver
"""

md"""
In this exercise you will transform the explicit nonlinear 1D diffusion solver to achieve a steady state solution, and, in a second step, achieve a fast solution relying on the second-order implementation. The model could be applied, e.g., to predict spatial distribution of pollutant in the subsurface.

To get started, save a copy of the `diffusion_nl_1D.jl` script we did in class (also available [here](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/) after the lecture), name it `diffusion_nl_1D_steady_1.jl`, and implement the changes tasked below.
"""

md"""
### Task 1
As first task, adapt the parameters and the implementation. In the `# Physics` section, set the total simulation time `ttot=200.0` and move the `D0` initialisation to the `# Array initialisation` section.

In the `# Numerics` section, add the nonlinear tolerance the solver should converge to, `epsi = 1e-10`.

Since we are interested in a concentration, rename the quantity to be diffused from `H` to `C`, and initialise it as a Gaussian profile centred in $x = 0$ with standard deviation $σ=1$ and amplitude of 0.5.

Initialise the diffusivity `D0=5` in every grid point of the domain. In the region $[0.6~L_x - 0.8~L_x]$, the subsurface is less permeable thus the values of `D0=1.5`. Also, initialise all arrays that would require it.

Finally, as boundary conditions, fix the concentration in the left ($dx/2$) and right ($L_x-dx/2$) cell centre to 0.5 and 0.1, respectively.

Define the time or iteration loop to, e.g., run from `t=0` until `t=ttot`, and to abort if the error drops below `epsi`. Note that another implementation of your choice of the loop is fine too. Define the error as the `maximum(abs.(∆C))`, where `∆C` is the difference between the values of concentration before and after the update at every iteration or time step (you can use unicode characters in Julia).

Report graphically the distribution of the concentration `C` as function of `x`, adding axes labels and a title reporting time, iteration count and current error.
"""

md"""
### Task 2
As you realised, it takes a large amount of iterations to converge the transient problem to a steady state. In this second task, you will accelerate the nonlinear diffusion solver using the second order method.

Duplicate the `diffusion_nl_1D_steady_1.jl` and rename the copy to `diffusion_nl_1D_steady_2.jl`.

Then, add to the `# Numerics` section a relaxation factor `rel = 0.1` that we will use to implement a continuation on the nonlinear diffusion coefficient.

In the `# Derived numerics` section, add the damping factor `dmp  = 1.0 - 2π/nx`, which is the value that will most optimally damp the damped-wave equation we will solve using the second order method.

Initialise the effective diffusion coefficient array `D` to 1, setting the initial guess for the relaxation.

In the time or iteration loop, implement the relaxation (or continuation) on the effective diffusion coefficient array `D`, such that at each iteration, `(1-rel)` from the previous values of `D` is being added to `rel` times the new value, computed as `(D0.*C).^n` (the physical expression of `D`).

Because we are only interested in the final distribution of `C`, at steady-state, the time step `dt` turns in a numerical parameter that no longer needs to be a scalar; it should be defined locally to each grid point; we do no longer need the global reduction `maximum.(D)`. Adapt the `dt` formula to use the _**local maximum**_ amongst direct neighbouring grid points for `D` (in every point of the domain).
"""

#nb # > 💡 hint: In 1D, a `maxloc()` function could be defined as such `@views maxloc(A) = max.(A[1:end-2],A[2:end-1],A[3:end]).`
#md # \note{In 1D, a `maxloc()` function could be defined as such `@views maxloc(A) = max.(A[1:end-2],A[2:end-1],A[3:end])`.}

md"""
Finally, and most important, modify the `dCdt` update operation to incorporate the damping term applied to the values of `dCdt` from the previous iteration. To implement the second order scheme, turn the `dCdt` assignment to an update, where you add to current definition of `dCdt` previous values of `dCdt*dmp`:

```julia
dCdt .= dCdt.*dmp .+ ...
```
"""

md"""
### Task 3

Report graphically the distribution of the concentration `C` as function of `x`, adding axes labels and title reporting iteration count and current error.

Reflect on the speed-up obtained by the second-order method and feel free to add a comment about it.
"""

#nb # > 💡 hint: The iteration count for the accelerated 1D code should be in the order of 3400.
#md # \note{The iteration count for the accelerated 1D code should be in the order of 3400.}

md"""
🎉 Well-done! This was a long one. Here is a sample output the code should produce:

![steady_1D_ex4](./figures/steady_1D_ex4.png)
"""
