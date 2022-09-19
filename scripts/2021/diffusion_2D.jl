using Plots

@views function diffusion_2D()
    # Physics
    Lx, Ly = 10.0, 10.0
    D      = 1.0
    ttot   = 2.0
    # Numerics
    nx, ny = 128, 128
    nout   = 50
    # Derived numerics
    dx, dy = Lx/nx, Ly/ny
    dt     = min(dx, dy)^2/D/4.1
    nt     = cld(ttot, dt)
    xc, yc = LinRange(dx/2, Lx-dx/2, nx), LinRange(dy/2, Ly-dy/2, ny)
    # Array initialisation
    C      =  exp.(.-(xc .- Lx/2).^2 .-(yc' .- Ly/2).^2)
    # C[2:end-1,2:end-1] .= rand(Float64, nx-2,ny-2)
    dCdt   = zeros(Float64, nx-2,ny-2)
    qx     = zeros(Float64, nx-1,ny-2)
    qy     = zeros(Float64, nx-2,ny-1)
    # Time loop
    for it = 1:nt
        qx         .= .-D.*diff(C[:,2:end-1],dims=1)./dx
        qy         .= .-D.*diff(C[2:end-1,:],dims=2)./dy
        dCdt       .= .-(diff(qx,dims=1)./dx .+ diff(qy,dims=2)./dy)
        C[2:end-1,2:end-1] .= C[2:end-1,2:end-1] .+ dt.*dCdt
        if it % nout == 0
            opts = (aspect_ratio=1, xlims=(xc[1], xc[end]), ylims=(yc[1], yc[end]), clims=(0.0, 1.0), c=:davos, xlabel="Lx", ylabel="Ly", title="time = $(round(it*dt, sigdigits=3))")
            display(heatmap(xc, yc, C'; opts...))
        end
    end
    return
end

diffusion_2D()
