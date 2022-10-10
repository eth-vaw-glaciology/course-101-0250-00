md"""
## Exercise 2 - **Thermal porous convection with implicit temperature update**
"""

#md # 👉 See [Logistics](/logistics/#submission) for submission details.

md"""
The goal of this exercise is to:
- Investigate second-order acceleration
- Derive scaling relation (number of iterations as function of number of grid points)
"""

md"""
In this exercise you will investigate the scalability of the first and second order iterative schemes discussed during lecture 4.

Start from the `Laplacian_damped.jl` script we realised in class, which should contain two "switches":
- `order` (1st or 2nd order scheme)
- `fact` (factor to multiply the number of grid points)

👉 Download the `Laplacian_damped.jl` script [here](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/) if needed (available after the course).

Add a copy of the `Laplacian_damped.jl` script we did in class to your exercise folder. Modify that script to perform systematics to assess the scalability of the damped versus the non-damped Laplacian 2D implementation.
"""

md"""
### Task 1
Move the temperature update into the iteration loop.

```julia
# action
for it = 1:nt
    T_old .= T
    # time step
    dt = if it == 1 
        0.1*min(dx,dy)/(αρg*ΔT*k_ηf)
    else
        ϕ*min(dx/maximum(abs.(qDx)), dy/maximum(abs.(qDy)))/2.1
    end
    re_therm    = 1.5*(π + sqrt(π^2 + ly^2/λ_ρCp/dt))
    θ_dτ_therm  = max(lx,ly)/re_therm/cfl/min(dx,dy)
    β_dτ_therm  = (re_therm*λ_ρCp)/(cfl*min(dx,dy)*max(lx,ly))
    # iteration loop
    iter = 1; err_Pf = 2ϵtol; err_T = 2ϵtol
    while max(err_Pf,err_T) >= ϵtol && iter <= maxiter
        # hydro
        qDx[2:end-1,:] .-= ...
        qDy[:,2:end-1] .-= ...
        Pf             .-= ...
        # thermo
        qTx            .-= ...
        qTy            .-= ...
        dTdt           .= (T[2:end-1,2:end-1] .- T_old[2:end-1,2:end-1])./dt .+ (...)./ϕ
        T[2:end-1,2:end-1] .-= ...
        T[[1,end],:]        .= T[[2,end-1],:]
        if iter % ncheck == 0
            r_Pf  .= ...
            r_T   .= ...
            err_Pf = maximum(abs.(r_Pf))
            err_T  = maximum(abs.(r_T))
            @printf("  iter/nx=%.1f, err_Pf=%1.3e, err_T=%1.3e\n",iter/nx,err_Pf,err_T)
        end
        iter += 1
    end
    @printf("it = %d, iter/nx=%.1f, err_Pf=%1.3e, err_T=%1.3e\n",it,iter/nx,err_Pf,err_T)
    # visualisation
    if it % nvis == 0
        qDx_c .= avx(qDx)
        qDy_c .= avy(qDy)
        qDmag .= sqrt.(qDx_c.^2 .+ qDy_c.^2)
        qDx_c ./= qDmag
        qDy_c ./= qDmag
        qDx_p = qDx_c[1:st:end,1:st:end]
        qDy_p = qDy_c[1:st:end,1:st:end]
        heatmap(xc,yc,T';xlims=(xc[1],xc[end]),ylims=(yc[1],yc[end]),aspect_ratio=1,c=:turbo)
        display(quiver!(Xp[:], Yp[:], quiver=(qDx_p[:], qDy_p[:]), lw=0.5, c=:black))
        iframe += 1
    end
end
```

### Task 2
Introduce the Rayleigh number:
```julia
Ra = αρg*k_ηf*ΔT*ly/λ_ρCp/ϕ
```

Calculate the thermal diffusivity `λ_ρCp` using the specified `Ra=2e3` number.
Using this modified code, realise a numerical experiment varying the Rayleigh number. Theoretical critical value of `Ra` above which there is convection is approximately `40`. Confirm that `Ra < 40` results in no convection, and values of `Ra > 40` result in convection development. Try the range of values `10`, `40`, `100`, `1000`. Produce the final figure after `nt=100` timesteps.
"""

#nb # > 💡 hint: Use `![fig_name](./<relative-path>/my_fig.png)` to insert a figure in the `README.md`.
#md # \note{Use `![fig_name](./<relative-path>/my_fig.png)` to insert a figure in the `README.md`.}
