<!--This file was generated, do not modify it.-->
## Exercise 1 - **Thermal porous convection in 2D**

👉 See [Logistics](/logistics/#submission) for submission details.

The goal of this exercise is to:
- Implement coupled diffusion equations in 2D
- Consolidate the implicit updates and dual timestepping

In this first exercise, you will finalise the thermal porous convection discussed and implemented in class. The following tasks combine the major steps needed to program 2D thermal porous convection starting from 1D steady state diffusion.

### Getting started
Create a new folder named `lecture4` in your GitHub repository for this week's (lecture 4) exercises. In there, create a new Julia script named `porous_convection_2D.jl` for this homework. Take the 1D steady diffusion script `l3_steady_diffusion_1D.jl` as a basis.

### Task 1
Rename variables so that we solve it for the pressure:
 - `C` should now be replaced by `Pf`
 - `qx` becomes `qDx` and should be initialised with size `nx+1`. Modify the rest of the code accordingly such that entire `Pf` array can be updated having the boundary condition set on the flux.
 - `dc` becomes `k_ηf` which is now the permeability over fluid viscosity
 - `dτ./(ρ*dc .+ dτ)` from flux update becomes `1.0./(1.0 + θ_dτ)`
 - `dτ` from pressure update becomes `β_dτ`. Note that instead of multiplying by `dτ` one should divide by `β_dτ`

Use following definition for `θ_dτ` and `β_dτ`:
```julia
θ_dτ    = lx/re/cfl/dx
β_dτ    = (re*k_ηf)/(cfl*dx*lx)
```
and introduce `cfl = 1.0/sqrt(2.1)` in the numerics section. Also, `ρ` is no longer needed and we can move `re` to numerics section as well.

Finally, update residual and error checking calculation as following (initialising `r_Pf` accordingly)
```julia
r_Pf  .= diff(qDx)./dx
err_Pf = maximum(abs.(r_Pf))
```
renaming `err` to `err_Pf`.

### Task 2
Convert this script to 2D. The script should produce a `heatmap()` plot after the iterations converge. Start by renaming the main function `porous_convection_2D`.

Use `lx=40.0` and `ly=20.0` and make sure the `dx` and `dy` cell size to be equal by selecting the appropriate number of grid points `ny` in $y$ direction.

In the numerical parameters, take `min(dx,dy)`, `max(lx,ly)` and `max(nx,ny)` whenever possible.

Make the initial condition a Gaussian distribution in 2D; you can use following
```julia
@. exp(-(xc-lx/4)^2 -(yc'-ly/4)^2)
```
taking care not to omit the transpose `'`.

Also, initialise the flux in the $y$ direction `qDy`. Update the residual calculation to account for the 2D setup.

Add a line to print out the convergence results within the `ncheck` block. You can take inspiration from:
```julia
@printf("  iter/nx=%.1f, err_Pf=%1.3e\n",iter/nx,err_Pf)
```

Finally, remove the error saving procedure used to plot convergence.

### Task 3

Wrap the iteration loop into a time loop. Make `nt=10` time steps. Move visualisation part out of the iteration loop and ass also an error monitoring step after the iteration loop as
```julia
@printf("it = %d, iter/nx=%.1f, err_Pf=%1.3e\n",it,iter/nx,err_Pf)
```
to verify convergence.

### Task 4

Add new fields for the temperature evolution (advection and diffusion) using a fully explicit update approach outside of the iteration loop, right before visualisation. Don't forget to use an upwind scheme!

Use following time step definition (and compute it right before the temperature update)
```julia
dt_adv = ϕ*min(dx/maximum(abs.(qDx)), dy/maximum(abs.(qDy)))/2.1
dt     = min(dt_diff,dt_adv)
```

The temperature update part could contain one update for the diffusion-related process and one for advection:
```julia
T[2:end-1,2:end-1] .+= dt.*λ_ρCp.*(...)
T[2:end-1,2:end-1] .-= dt./ϕ.*(...)
```

Make sure to add following to the initialisation
```julia
# physics
αρgx,αρgy = 0.0,1.0
αρg       = sqrt(αρgx^2+αρgy^2)
ΔT        = 200.0
ϕ         = 0.1
Ra        = 100
λ_ρCp     = 1/Ra*(αρg*k_ηf*ΔT*ly/ϕ) # Ra = αρg*k_ηf*ΔT*ly/λ_ρCp/ϕ
# numerics
dt_diff   = min(dx,dy)^2/λ_ρCp/4.1
```

Implement initial and boundary conditions; Remove the fluid pressure perturbation and initialise temperature array `T` as following taking care of setting upper and lower boundary initial conditions as well; heating from below and cooling from above.
```julia
T         = @. ΔT*exp(-xc^2 - (yc'+ly/2)^2)
T[:,1] .= ΔT/2; T[:,end] .= -ΔT/2
```

Left and right boundaries of the temperature field should have an adiabatic condition, i.e.,
```julia
T[[1,end],:] .= T[[2,end-1],:]
```

In addition, also centre the `xc` and `yc` coordinates such that they span for $x$ direction, from `-lx/2+dx/2` to `lx/2-dx/2`. For `ly`, define coordinates such the they span from `-ly+dy/2` to `-dy/2` (having the 0 at the upper surface).

### Task 5

Add two-way coupling using the Boussinesq approximation, i.e., add the dependence of density on temperature in the Darcy flux. Produce the animation displaying the temperature evolution including arrows (quiver plot) for velocities.

Change parameters as following: `nt=500`, `nx=127` and `Ra=1000.0`.

For visualisation, embed the plotting into a `nvis` statement setting `nvis=5`. Below you'll find a sample code for visualisation:
```julia
# visualisation
if it % nvis == 0
    qDxc  .= # average qDx in x
    qDyc  .= # average qDx in y
    qDmag .= sqrt.(qDxc.^2 .+ qDyc.^2)
    qDxc  ./= qDmag
    qDyc  ./= qDmag
    qDx_p = qDxc[1:st:end,1:st:end]
    qDy_p = qDyc[1:st:end,1:st:end]
    heatmap(xc,yc,T';xlims=(xc[1],xc[end]),ylims=(yc[1],yc[end]),aspect_ratio=1,c=:turbo)
    display(quiver!(Xp[:], Yp[:], quiver=(qDx_p[:], qDy_p[:]), lw=0.5, c=:black))
end
```

where `Xp` and `Yp` could be initialised as following before the time loop:
```julia
# visualisation init
st        = ceil(Int,nx/25)
Xc, Yc    = [x for x=xc, y=yc], [y for x=xc,y=yc]
Xp, Yp    = Xc[1:st:end,1:st:end], Yc[1:st:end,1:st:end]
```

Well done 🚀 - you made it. Add the produced gif or animation to the `README.md` within your `lecture4` folder.

The final convection animation you produced should be similar to the one displayed hereafter (using the parameters listed above):
~~~
<center>
  <video width="90%" autoplay loop controls src="../assets/literate_figures/l4_porous_convection_2D_ex1.mp4"/>
</center>
~~~

