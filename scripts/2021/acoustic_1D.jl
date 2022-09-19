using Plots

@views function acoustic_1D()
    # Physics
    Lx    = 10.0
    ρ     = 1.0
    K     = 1.0
    ttot  = 20.0
    # Numerics
    nx    = 128
    nout  = 10
    # Derived numerics
    dx    = Lx/nx
    dt    = dx/sqrt(K/ρ)/2.1
    nt    = cld(ttot, dt)
    xc    = LinRange(dx/2, Lx-dx/2, nx)
    # Array initialisation
    P     =  exp.(.-(xc .- Lx/2).^2)
    Pi    =  copy(P)
    dPdt  = zeros(Float64, nx-2)
    qx    = zeros(Float64, nx-1)
    Vx    = zeros(Float64, nx-1)
    # Time loop
    for it = 1:nt
        qx         .= .-1.0/ρ.*diff(P )./dx
        Vx         .= Vx         .+ dt.*qx
        dPdt       .= .-    K.*diff(Vx)./dx
        P[2:end-1] .= P[2:end-1] .+ dt.*dPdt
        if it % nout == 0
            plot(xc, Pi, lw=2, label="P initial")
            display(plot!(xc, P, lw=3, xlims=(xc[1], xc[end]), ylims=(-1.1, 1.1),
                          xlabel="Lx", ylabel="Pressure", title="time = $(round(it*dt, sigdigits=3))",
                          framestyle=:box, label="P"))
        end
    end
    return
end

acoustic_1D()
