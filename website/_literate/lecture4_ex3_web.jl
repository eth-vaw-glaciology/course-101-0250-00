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
In this exercise you will transform the explicit nonlinear 1D diffusion solver to achieve a steady state solution, and, in a second step, achieve a fast solution relying on the second-order implementation. The model could be applied, e.g., at the spatial distribution of pollutant in the subsurface.

To get started, save a copy of the `diffusion_1D.jl` script we did in class (also available [here](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/) after the lecture), name it `diffusion_nl_1D_steady_1.jl`, and implement following changes.
"""

md"""
### Task 1
As first task, you will adapt the parameters and the implementation. For the `# Physics`, set the total simulation time `ttot=200.0` and move the `D0` initialisation to the `# Array initialisation` section.

In the `# Numerics` section, add the nonlinear tolerance the solver should converge to, `epsi = 1e-10`.

Since we are interested in a concentration, rename the quantity to be diffused from `H` to `C`, and initialise it as a Gaussian centred in $L_x/2$ with standard deviation $σ=1$ and amplitude of 0.5. Initialise the diffusivity `D0=5` in every grid point of the domain. In the region $[0.6~L_x - 0.8~L_x]$, the subsurface is less permeable thus the value of `D0=1.5` there. Also, initialise all array that would require it.

Finally, fix the concentration in the left ($dx/2$) and right ($L_x-dx/2$) cell centre to 0.5 and 0.1, respectively.

Define the time or iteration loop to run from `t=0` until `t=ttot`, and to abort if the error drops below `epsi`. Define the error the `maximum(abs.(∆C))`, where `∆C` is the difference between the values of concentration before and after the update at every iteration or time step.

Report graphically the distribution of concentration `C` as function of `x`, adding axes labels and title reporting time, iteration count and current error.
"""

md"""
### Task 2
As you realised, it takes a large amount of iterations to converge the transient problem to a steady state. In this second task, you will accelerate the nonlinear diffusion solver using the second order method.

Duplicate the `diffusion_nl_1D_steady_1.jl` and rename the copy to `diffusion_nl_1D_steady_2.jl`.

Then, add to the `# Numerics` section a relaxation factor `rel = 0.1` that we will use to implement a continuation on the nonlinear diffusion coefficient.

In the `# Derived numerics` section, add the damping factor `dmp  = 1.0 - 2π/nx`, which is the value that will most optimally damp the damped-wave equation we will solve in the second order method.

Initialise the effective diffusion coefficient array `D` to 1, the initial guess for the relaxation.

In the time or iteration loop, implement the relaxation (or continuation) on the effective diffusion coefficient array `D`, such that at each iteration, we `(1-rel)` from the previous value of `D` is added to `rel` times the new value computed as `(D0.*C).^n` (the physical expression).

Because we are only interested in the final distribution of `C`, at steady-state, the time step `dt` turns in a numerical parameter that no longer needs to be a scalar. Adapt `dt` to use the local maximum amongst direct neighbouring grid points, in every point of the domain
"""

#nb # > 💡 hint: In 1D, a `maxloc` function could be defined as such `@views maxloc(A) = max.(A[1:end-2],A[2:end-1],A[3:end])`
#md # \note{In 1D, a `maxloc` function could be defined as such `@views maxloc(A) = max.(A[1:end-2],A[2:end-1],A[3:end])`}

md"""
Finally, modify the `dCdt` update to incorporate the damping term applied to the values of `dCdt` from the previous iteration.
"""

#nb # > 💡 hint: Look up the `Laplacian_damped.jl` implementation from lecture 4 if you need inspiration.
#md # \note{Look up the `Laplacian_damped.jl` implementation from lecture 4 if you need inspiration.}

md"""
Report graphically the distribution of concentration `C` as function of `x`, adding axes labels and title reporting time, iteration count and current error.

Reflect on the speed-up obtained by the second-order method and feel free to add a comment about it.

🎉 Well-done! This was a long one.
"""




