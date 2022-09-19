using Plots

@views function diffusion_1D()
    # Physics
    Lx   = 10.0
    D    = 1.0
    ttot = 2.0
    # Numerics
    nx   = 128
    nout = 10
    # Derived numerics
    dx   = Lx/nx
    dt   = dx^2/D/2.1
    nt   = cld(ttot, dt)
    xc   = LinRange(dx/2, Lx-dx/2, nx)
    # Array initialisation
    C    =  exp.(.-(xc .- 0.5*Lx).^2)
    # C    =  rand(Float64, nx)
    Ci   =  copy(C)
    dCdt = zeros(Float64, nx-2)
    qx   = zeros(Float64, nx-1)
    # Time loop
    for it = 1:nt
        qx         .= .-D.*diff(C )./dx
        dCdt       .= .-   diff(qx)./dx
        C[2:end-1] .= C[2:end-1] .+ dt.*dCdt
        if it % nout == 0
            plot(xc, Ci, lw=2, label="C initial")
            display(plot!(xc, C, lw=3, xlims=(xc[1], xc[end]), ylims=(0.0, 1.0),
                          xlabel="Lx", ylabel="Concentration", title="time = $(round(it*dt, sigdigits=3))",
                          framestyle=:box, label="concentration"))
        end
    end
    return
end

diffusion_1D()
