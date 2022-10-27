<!--This file was generated, do not modify it.-->
## Exercise 2 - **Thermal porous convection with implicit temperature update**

👉 See [Logistics](/logistics/#submission) for submission details.

The goal of this exercise is to:
- Implement implicit advection-diffusion and dual-timestepping
- Build your intuition about convection and the Rayleigh number

In this exercise you will implement the fully implicit and fully coupled solver for the thermal porous convection problem. Starting from the working solver that uses the explicit update for the temperature, you will introduce the pseudo-transient parameters for the implicit transient diffusion problem, and move the temperature update to the iteration loop. Then you will introduce the [Rayleigh number](https://en.wikipedia.org/wiki/Rayleigh_number) that characterises the intensity of the buoyancy-driven convection, and verify that your numerical code confirms the analytical predictions for the critical Rayleigh number separating the heat diffusion- and advection-dominated flow regimes.

### Task 1
Copy the file `porous_convection_2D.jl` and name it `porous_convection_implicit_2D.jl`. Rename the pseudo-transient variables for fluid pressure diffusion to avoid conflicts with the variables for temperature:

- `re` should be replaced with `re_D`
- `θ_dτ` should be replaced with `θ_dτ_D`
- `β_dτ` should be replaced with `β_dτ_D`

Adjust the value of `re_D` since the physics is now fully coupled:

```julia
re_D        = 4π
```

Move the time step definition into the beginning of the time loop. For the first time step, use different definition to avoid division by 0. For the time steps > 1, choose among the minimum between scale or flux based definition:

```julia
for it = 1:nt
    T_old .= T
    # time step
    dt = if it == 1
        0.1*min(dx,dy)/(αρg*ΔT*k_ηf)
    else
        min(5.0*min(dx,dy)/(αρg*ΔT*k_ηf),ϕ*min(dx/maximum(abs.(qDx)), dy/maximum(abs.(qDy)))/2.1)
    end
    ...
end
```

Introduce the pseudo-transient parameters for the temperature update. Recall that the temperature evolution equation is equivalent to the diffusion-reaction equation with advection. Now, the physical timestep `dt` is determined from the CFL condition and changes every iteration of the time loop. Thus, the pseudo-transient parameters should also be updated every time step:

```julia
# time step
# dt = ...
re_T    = π + sqrt(π^2 + ly^2/λ_ρCp/dt)
θ_dτ_T  = max(lx,ly)/re_T/cfl/min(dx,dy)
β_dτ_T  = (re_T*λ_ρCp)/(cfl*min(dx,dy)*max(lx,ly))
...
```

Add new arrays to the `# array initialisation` section to store the physical time derivative of temperature, temperature equation residual, and the temperature diffusion fluxes:

```julia
dTdt        = zeros(nx-2,ny-2)
r_T         = zeros(nx-2,ny-2)
qTx         = zeros(nx-1,ny-2)
qTy         = zeros(nx-2,ny-1)
```

Note that the sizes of the arrays `qTx` and `qTy` are different from the arrays for the Darcy fluxes `qDx` and `qDy`. The reason for this is that we use the different boundary conditions for the temperature, and don't want to update the temperature at the domain boundaries.

### Task 2
Move the temperature update into the iteration loop. Rename the variable `err` to `err_D` to avoid confusion. Introduce the new variable `err_T` to store the residual for the temperature evolution equation and modify the exit criteria to break iterations when both errors are less than tolerance:
```julia
# iteration loop
iter = 1; err_Pf = 2ϵtol; err_T = 2ϵtol
while max(err_D,err_T) >= ϵtol && iter <= maxiter
...
end
```

Annotate the Darcy fluxes and pressure update with a comment, and introduce the new section for temperature update:

```julia
while max(err_Pf,err_T) >= ϵtol && iter <= maxiter
    # fluid pressure update
    qDx[2:end-1,:] .-= ...
    qDy[:,2:end-1] .-= ...
    Pf             .-= ...
    # temperature update
    ...
end
```

Add the temperature diffusion flux update analogous the the Darcy flux update, but using the different iteration parameters:

```julia
# temperature update
qTx            .-= ...
qTy            .-= ...
```

Compute the material physical time derivative as a combination of partial derivative `(T - T_old)./dt` and upwind advection:

```julia
dTdt           .= (T[2:end-1,2:end-1] .- T_old[2:end-1,2:end-1])./dt .+ (...)./ϕ
```

The upwind advection part could be simply copied from the previous explicit version, ignoring the `dt` factor.
Finally, compute the temperature update and move the boundary conditions to the iteration loop:

```julia
T[2:end-1,2:end-1] .-= (dTdt .+ ...)./(1.0/dt + β_dτ_T)
T[[1,end],:]       .= T[[2,end-1],:]
```

Add the residual calculation for the temperature evolution equation and the iteration progress reporting:

```julia
if iter % ncheck == 0
    r_Pf  .= ...
    r_T   .= dTdt .+ ...
    err_D  = maximum(abs.(r_Pf))
    err_T  = maximum(abs.(r_T))
    @printf("  iter/nx=%.1f, err_D=%1.3e, err_T=%1.3e\n",iter/nx,err_D,err_T)
end
```

Run the code, make sure that it works as expected, produce the animation and add it to the `README.md` within your `lecture4` folder. Well done! 🔥

Did the number of iterations required for convergence change compared to the version with the explicit temperature update? Try to come up with the explanation for why the number of iterations changed the way it changed and write a sentence about your thoughts on the topic.

### Task 3
Using the newly developed implicit code, realise a numerical experiment varying the Rayleigh number. Theoretical critical value of `Ra` above which there is convection is approximately `40`. Confirm that `Ra < 40` results in no convection. Confirm that the values of `Ra > 40` result in the development of convection. Try the following range of values for `Ra`: `10`, `40`, `100`, `1000`. Produce the animation or the final figure after `nt=100` timesteps for each value. Add the produced gif or animation to the `README.md` within your `lecture4` folder.

**Question:** What is the difference in the results for the different values of `Ra`, is there an observable trend? Write a comment explaining your observations.

