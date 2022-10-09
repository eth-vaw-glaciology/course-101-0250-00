<!--This file was generated, do not modify it.-->
## Exercise 3 - **Advection-diffusion in 2D**

👉 See [Logistics](/logistics/#submission) for submission details.

The goal of this exercise is to
- Extend the advection-diffusion solver with implicit diffusion step from 1D to 2D
- Implement the upwind advection scheme in 2D
- Modify the problem configuration

Create a code `implicit_advection_diffusion_2D.jl` for this exercise and add it to the `lecture3` folder in your private GitHub repo. Report the results of this exercise within a new section in the `README`.

### Getting started

1. Duplicate the the `implicit_diffusion_1D.jl` code you created in Exercise 2 and name it `implicit_advection_diffusion_2D.jl`.
2. Extend the 1D calculations to 2D
3. Add advection as in Exercise 2

Modify the initial conditions to include following parameters in the `# physics` section:
```julia
# physics
lx,ly   = 10.0,10.0
dc      = 1.0
vx      = 10.0
vy      = -10.0
```
and implement following initial condition
```julia
# array initialisation
C       = @. exp(-(xc-lx/4)^2 -(yc'-3ly/4)^2)
C_old   = copy(C)
```

Choose the time step according to the following (stability) criterion:

```julia
dt = min(dx/abs(vx),dy/abs(vy))/2
```

Also make sure to use the following numerical parameters (in number of grid points `nx,ny`)
```julia
# numerics
nx,ny   = 200,201
ϵtol    = 1e-8
maxiter = 10nx
ncheck  = ceil(Int,0.02nx)
nt      = 50

```

Note that the iterative pseudo-timestep limitation should be updated to
```julia
dτ = min(dx,dy)/sqrt(1/ρ)/sqrt(2)
```
for 2D configurations.

\note{Make sure to update the flux array initialisation and include the flux in the y-direction `qy` and use now 2D arrays: `qx,qy = zeros(nx-1,??), zeros(??,ny-1)`.}

### Task 1
Repeat the steps from the Exercise 1 to create the implicit time-dependent diffusion solver but in 2D. **Do not include advection yet.** Pay attention to add information relative to the second dimension whenever it's needed.


Make a short animation showing the time evolution of the concentration field `C` during `nt = 50` physical time steps. The figure should contain 2 subplots, the first displaying the `heatmap` of the `C` field and the second the evolution of the by `nx` normalised iteration count:

```julia
# visualisation
p1 = heatmap(xc,yc,C';xlims=(0,lx),ylims=(0,ly),clims=(0,1),aspect_ratio=1,
                 xlabel="lx",ylabel="ly",title="iter/nx=$(round(iter/nx,sigdigits=3))")
p2 = plot(iter_evo,err_evo;xlabel="iter/nx",ylabel="err",
        yscale=:log10,grid=true,markershape=:circle,markersize=10)
display(plot(p1,p2;layout=(2,1)))
```

### Task 2
Include now the advection step in a similar way as in the 1D case from the previous exercise, i.e., adding them after the iteration loop within the time loop. Use advection velocities and parameters listed above, taking care in implementing the "upwind" strategy discussed in Lecture 2.

Make a short animation showing the time evolution of the concentration field `C` during `nt = 50` physical time steps using the same figure layout as for Task 1.

