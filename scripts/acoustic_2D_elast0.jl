using Plots

@views function acoustic_2D()
    # Physics
    Lx, Ly = 10.0, 10.0
    ρ      = 1.0
    K      = 1.0
    ttot   = 20.0
    # Numerics
    nx, ny = 128, 128
    nout   = 10
    # Derived numerics
    dx, dy = Lx/nx, Ly/ny
    dt     = min(dx,dy)/sqrt(K/ρ)/2.1
    nt     = cld(ttot, dt)
    xc, yc = LinRange(dx/2, Lx-dx/2, nx), LinRange(dy/2, Ly-dy/2, ny)
    # Array initialisation
    P      =  exp.(.-(xc .- Lx/2).^2 .-(yc' .- Ly/2).^2)
    dPdt   = zeros(Float64, nx-2,ny-2)
    qx     = zeros(Float64, nx-1,ny-2)
    Vx     = zeros(Float64, nx-1,ny-2)
    qy     = zeros(Float64, nx-2,ny-1)
    Vy     = zeros(Float64, nx-2,ny-1)
    # Time loop
    for it = 1:nt
        qx   .= .-1.0./ρ.*diff(P[:,2:end-1],dims=1)./dx
        qy   .= .-1.0./ρ.*diff(P[2:end-1,:],dims=2)./dy
        Vx   .= Vx .+ dt.*qx
        Vy   .= Vy .+ dt.*qy
        dPdt .= .-K.*(diff(Vx,dims=1)./dx .+ diff(Vy,dims=2)./dy)
        P[2:end-1,2:end-1] .= P[2:end-1,2:end-1] .+ dt.*dPdt
        if it % nout == 0
            opts = (aspect_ratio=1, xlims=(xc[1], xc[end]), ylims=(yc[1], yc[end]), clims=(-0.25, 0.25), c=:davos, xlabel="Lx", ylabel="Ly", title="time = $(round(it*dt, sigdigits=3))")
            display(heatmap(xc, yc, P'; opts...))
        end
    end
    return
end

acoustic_2D()
