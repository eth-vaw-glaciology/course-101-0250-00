# juliap -O3 --check-bounds=no --math-mode=fast acoustic_2D_perf_gpu.jl
using Plots, Printf, CUDA

function compute_V!(Vx, Vy, P, dt_ρ_dx, dt_ρ_dy)
    ix = (blockIdx().x-1) * blockDim().x + threadIdx().x
    iy = (blockIdx().y-1) * blockDim().y + threadIdx().y
    if (ix<=size(Vx,1) && iy<=size(Vx,2))
        Vx[ix,iy] = Vx[ix,iy] - dt_ρ_dx*(P[ix+1,iy+1] - P[ix,iy+1])
    end
    if (ix<=size(Vy,1) && iy<=size(Vy,2))
        Vy[ix,iy] = Vy[ix,iy] - dt_ρ_dy*(P[ix+1,iy+1] - P[ix+1,iy])
    end
    return
end

function compute_P!(P, Vx, Vy, dtK, _dx, _dy, size_P1_2, size_P2_2)
    ix = (blockIdx().x-1) * blockDim().x + threadIdx().x
    iy = (blockIdx().y-1) * blockDim().y + threadIdx().y
    if (ix<=size_P1_2 && iy<=size_P2_2)
        P[ix+1,iy+1] = P[ix+1,iy+1] - dtK*((Vx[ix+1,iy] - Vx[ix,iy])*_dx + (Vy[ix,iy+1] - Vy[ix,iy])*_dy)
    end
    return
end

@views function acoustic_2D(; do_visu=false)
    # Physics
    Lx, Ly  = 10.0, 10.0
    ρ       = 1.0
    K       = 1.0
    ttot    = 1e-1
    # Numerics
    BLOCKX  = 32
    BLOCKY  = 8
    GRIDX   = 16*24
    GRIDY   = 64*24
    nx, ny  = BLOCKX*GRIDX, BLOCKY*GRIDY # number of grid points
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
    P       = CuArray(exp.(.-(xc .- Lx/2).^2 .-(yc' .- Ly/2).^2))
    Vx      = CUDA.zeros(Float64, nx-1,ny-2)
    Vy      = CUDA.zeros(Float64, nx-2,ny-1)
    cuthreads = (BLOCKX, BLOCKY, 1)
    cublocks  = (GRIDX,  GRIDY,  1)
    size_P1_2, size_P2_2 = size(P,1)-2, size(P,2)-2
    t_tic = 0.0; niter = 0
    # Time loop
    for it = 1:nt
        if (it==11) t_tic = Base.time(); niter = 0 end
        @cuda blocks=cublocks threads=cuthreads compute_V!(Vx, Vy, P, dt_ρ_dx, dt_ρ_dy)
        synchronize()
        @cuda blocks=cublocks threads=cuthreads compute_P!(P, Vx, Vy, dtK, _dx, _dy, size_P1_2, size_P2_2)
        synchronize()
        niter += 1
        if do_visu && (it % nout == 0)
            opts = (aspect_ratio=1, xlims=(xc[1], xc[end]), ylims=(yc[1], yc[end]), clims=(-0.25, 0.25), c=:davos, xlabel="Lx", ylabel="Ly", title="time = $(round(it*dt, sigdigits=3))")
            display(heatmap(xc, yc, Array(P)'; opts...))
        end
    end
    t_toc = Base.time() - t_tic
    A_eff = (3*2)/1e9*nx*ny*sizeof(Float64)  # Effective main memory access per iteration [GB]
    t_it  = t_toc/niter                      # Execution time per iteration [s]
    T_eff = A_eff/t_it                       # Effective memory throughput [GB/s]
    @printf("Time = %1.3f sec, T_eff = %1.2f GB/s (niter = %d)\n", t_toc, round(T_eff, sigdigits=3), niter)
    return
end

acoustic_2D(; do_visu=false)
