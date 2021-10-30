using Plots, Printf

@views function diffusion_2D(; do_visu=false)
    # Physics
    Lx, Ly = 10.0, 10.0
    D      = 1.0
    ttot   = 0.1
    # Numerics
    nx, ny = 512, 512
    nout   = 50
    # Derived numerics
    dx, dy = Lx/nx, Ly/ny
    dt     = min(dx, dy)^2/D/4.1
    nt     = cld(ttot, dt)
    xc, yc = LinRange(dx/2, Lx-dx/2, nx), LinRange(dy/2, Ly-dy/2, ny)
    # Array initialisation
    C      =  exp.(.-(xc .- Lx/2).^2 .-(yc' .- Ly/2).^2)
    dCdt   = zeros(Float64, nx-2,ny-2)
    qx     = zeros(Float64, nx-1,ny-2)
    qy     = zeros(Float64, nx-2,ny-1)
    t_tic = 0.0; niter = 0
    # Time loop
    for it = 1:nt
        if (it==11) t_tic = Base.time(); niter = 0 end
        qx         .= .-D.*diff(C[:,2:end-1],dims=1)./dx
        qy         .= .-D.*diff(C[2:end-1,:],dims=2)./dy
        dCdt       .= .-(diff(qx,dims=1)./dx .+ diff(qy,dims=2)./dy)
        C[2:end-1,2:end-1] .= C[2:end-1,2:end-1] .+ dt.*dCdt
        niter += 1
        if do_visu && (it % nout == 0)
            opts = (aspect_ratio=1, xlims=(xc[1], xc[end]), ylims=(yc[1], yc[end]), clims=(0.0, 1.0), c=:davos, xlabel="Lx", ylabel="Ly", title="time = $(round(it*dt, sigdigits=3))")
            display(heatmap(xc, yc, C'; opts...))
        end
    end
    t_toc = Base.time() - t_tic
    A_eff = (1*2)/1e9*nx*ny*sizeof(Float64)  # Effective main memory access per iteration [GB]
    t_it  = t_toc/niter                      # Execution time per iteration [s]
    T_eff = A_eff/t_it                       # Effective memory throughput [GB/s]
    @printf("Time = %1.3f sec, T_eff = %1.3f GB/s (niter = %d)\n", t_toc, round(T_eff, sigdigits=3), niter)
    return
end

diffusion_2D(; do_visu=false)
