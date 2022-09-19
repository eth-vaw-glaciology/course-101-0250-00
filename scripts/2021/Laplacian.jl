# Laplacian 2D
using Plots

@views function laplacian2D()
    fact    = 1
    # Physics
    lx, ly  = 10, 10
    D       = 1
    # Numerics
    nx, ny  = fact*50, fact*50
    dx, dy  = lx/nx, ly/ny
    niter   = 20*nx
    dmp     = 2.0/nx
    dt      = dx^2/D/4.1
    # Initial conditions
    A       = zeros(Float64, nx,ny)
    dAdt    = zeros(Float64, nx,ny)
    A[2:end-1,2:end-1] .= rand(nx-2,ny-2)
    # display(heatmap(A', aspect_ratio=1, xlims=(1,nx), ylims=(1,ny))); error("initial condition")
    errv = []
    # iteration loop
    for it = 1:niter
        dAdt[2:end-1,2:end-1] .= D.*(diff(diff(A[:,2:end-1],dims=1),dims=1)/dx^2 .+
                                     diff(diff(A[2:end-1,:],dims=2),dims=2)/dy^2)
        A                     .= A .+ dt.*dAdt
        if it % nx == 0
            err = maximum(abs.(A)); push!(errv, err)
            p1=plot(nx:nx:it,log10.(errv), linewidth=3, markersize=4, markershape=:circle, framestyle=:box, legend=false, xlabel="iter", ylabel="log10(max(|A|))", title="iter=$it")
            p2=heatmap(A', aspect_ratio=1, xlims=(1,nx), ylims=(1,ny), title="max(|A|)=$(round(err,sigdigits=3))")
            display(plot(p1,p2, dpi=150))
        end
    end
    return
end

@time laplacian2D()
