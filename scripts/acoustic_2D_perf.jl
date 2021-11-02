using Plots, Printf

@views function acoustic_2D(; do_visu=false)
    # Physics
    Lx, Ly  = 10.0, 10.0
    ρ       = 1.0
    K       = 1.0
    ttot    = 20.0
    # Numerics
    nx, ny  = 512, 512
    nout    = 10
    # Derived numerics
    dx, dy  = Lx/nx, Ly/ny
    dt      = min(dx, dy)/sqrt(K/ρ)/2.1
    nt      = cld(ttot, dt)
    xc, yc  = LinRange(dx/2, Lx-dx/2, nx), LinRange(dy/2, Ly-dy/2, ny)
    dt_ρ_dx = dt/ρ/dx
    dt_ρ_dy = dt/ρ/dy
    dtK     = dt*K
    _dx, _dy= 1.0/dx, 1.0/dy
    # Array initialisation
    P       =  exp.(.-(xc .- Lx/2).^2 .-(yc' .- Ly/2).^2)
    Vx      = zeros(Float64, nx-1,ny-2)
    Vy      = zeros(Float64, nx-2,ny-1)
    t_tic = 0.0; niter = 0
    # Time loop
    for it = 1:nt
        if (it==11) t_tic = Base.time(); niter = 0 end
        Vx  .= Vx .- dt_ρ_dx.*diff(P[:,2:end-1],dims=1)
        Vy  .= Vy .- dt_ρ_dy.*diff(P[2:end-1,:],dims=2)
        P[2:end-1,2:end-1] .= P[2:end-1,2:end-1] .- dtK.*(diff(Vx,dims=1).*_dx .+ diff(Vy,dims=2).*_dy)
        niter += 1
        if do_visu && (it % nout == 0)
            opts = (aspect_ratio=1, xlims=(xc[1], xc[end]), ylims=(yc[1], yc[end]), clims=(-0.25, 0.25), c=:davos, xlabel="Lx", ylabel="Ly", title="time = $(round(it*dt, sigdigits=3))")
            display(heatmap(xc, yc, P'; opts...))
        end
    end
    t_toc = Base.time() - t_tic
    A_eff = (3*2)/1e9*nx*ny*sizeof(Float64)  # Effective main memory access per iteration [GB]
    t_it  = t_toc/niter                      # Execution time per iteration [s]
    T_eff = A_eff/t_it                       # Effective memory throughput [GB/s]
    @printf("Time = %1.3f sec, T_eff = %1.3f GB/s (niter = %d)\n", t_toc, round(T_eff, sigdigits=3), niter)
    return
end

acoustic_2D(; do_visu=false)
