using Plots

@views function reaction_1D()
    # Physics
    Lx   = 10.0
    ξ    = 10.0
    Ceq  = 0.5
    ttot = 20.0
    # Numerics
    nx   = 128
    # Derived numerics
    dx   = Lx/nx
    dt   = ξ/2.0
    nt   = cld(ttot, dt)
    xc   = LinRange(dx/2, Lx-dx/2, nx)
    # Array initialisation
    C    =  rand(Float64, nx)
    Ci   =  copy(C)
    dCdt = zeros(Float64, nx)
    # Time loop
    for it = 1:nt
        dCdt .= .- (C .- Ceq)./ξ
        C    .= C .+ dt.*dCdt
        display(plot(xc, C, lw=2, xlims=(xc[1], xc[end]), ylims=(0.0, 1.0),
                     xlabel="Lx", ylabel="Concentration", title="time = $(it*dt)",
                     framestyle=:box, label="Concentration"))
    end
    plot!(xc, Ci, lw=2, label="C initial")
    display(plot!(xc, Ceq*ones(nx), lw=2, label="Ceq"))
    return
end

reaction_1D()
