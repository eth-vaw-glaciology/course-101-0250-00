using Plots

@views function advection_1D()
    # Physics
    Lx   = 10.0
    vx   = 1.0
    ttot = 5.0
    # Numerics
    nx   = 128
    nout = 10
    # Derived numerics
    dx   = Lx/nx
    dt   = dx/vx
    nt   = cld(ttot, dt)
    xc   = LinRange(dx/2, Lx-dx/2, nx)
    # Array initialisation
    C    =  exp.(.-(xc .- 0.3*Lx).^2)
    Ci   =  copy(C)
    dCdt = zeros(Float64, nx-1)
    # Time loop
    for it = 1:nt
        dCdt     .= .-vx.*diff(C)./dx
        C[2:end] .= C[2:end] .+ dt.*dCdt
        if it % nout == 0
            plot(xc, Ci, lw=2, label="C initial")
            display(plot!(xc, C, lw=2, xlims=(xc[1], xc[end]), ylims=(0.0, 1.0), 
                          xlabel="Lx", ylabel="Concentration", title="time = $(round(it*dt, sigdigits=3))", 
                          framestyle=:box, label="C"))
        end
    end
    return
end

advection_1D()
