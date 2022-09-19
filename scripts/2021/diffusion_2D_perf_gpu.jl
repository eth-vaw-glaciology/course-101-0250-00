# juliap -O3 --check-bounds=no --math-mode=fast diffusion_2D_perf_gpu.jl
using Plots, Printf, CUDA

# macros to avoid array allocation
macro qx(ix,iy)  esc(:( -D_dx*(C[$ix+1,$iy+1] - C[$ix,$iy+1]) )) end
macro qy(ix,iy)  esc(:( -D_dy*(C[$ix+1,$iy+1] - C[$ix+1,$iy]) )) end

function compute!(C2, C, D_dx, D_dy, dt, _dx, _dy, size_C1_2, size_C2_2)
    ix = (blockIdx().x-1) * blockDim().x + threadIdx().x
    iy = (blockIdx().y-1) * blockDim().y + threadIdx().y
    if (ix<=size_C1_2 && iy<=size_C2_2)
        C2[ix+1,iy+1] = C[ix+1,iy+1] - dt*( (@qx(ix+1,iy) - @qx(ix,iy))*_dx + (@qy(ix,iy+1) - @qy(ix,iy))*_dy )
    end
    return
end

@views function diffusion_2D(; do_visu=false)
    # Physics
    Lx, Ly  = 10.0, 10.0
    D       = 1.0
    ttot    = 1e-4
    # Numerics
    BLOCKX  = 32
    BLOCKY  = 8
    GRIDX   = 16*24
    GRIDY   = 64*24
    nx, ny  = BLOCKX*GRIDX, BLOCKY*GRIDY # number of grid points
    nout    = 50
    # Derived numerics
    dx, dy  = Lx/nx, Ly/ny
    dt      = min(dx, dy)^2/D/4.1
    nt      = cld(ttot, dt)
    xc, yc  = LinRange(dx/2, Lx-dx/2, nx), LinRange(dy/2, Ly-dy/2, ny)
    D_dx    = D/dx
    D_dy    = D/dy
    _dx, _dy= 1.0/dx, 1.0/dy
    # Array initialisation
    C       = CuArray(exp.(.-(xc .- Lx/2).^2 .-(yc' .- Ly/2).^2))
    C2      = copy(C)
    cuthreads = (BLOCKX, BLOCKY, 1)
    cublocks  = (GRIDX,  GRIDY,  1)
    size_C1_2, size_C2_2 = size(C,1)-2, size(C,2)-2
    t_tic = 0.0; niter = 0
    # Time loop
    for it = 1:nt
        if (it==11) t_tic = Base.time(); niter = 0 end
        @cuda blocks=cublocks threads=cuthreads compute!(C2, C, D_dx, D_dy, dt, _dx, _dy, size_C1_2, size_C2_2)
        synchronize()
        C, C2 = C2, C # pointer swap
        niter += 1
        if do_visu && (it % nout == 0)
            opts = (aspect_ratio=1, xlims=(xc[1], xc[end]), ylims=(yc[1], yc[end]), clims=(0.0, 1.0), c=:davos, xlabel="Lx", ylabel="Ly", title="time = $(round(it*dt, sigdigits=3))")
            display(heatmap(xc, yc, Array(C)'; opts...))
        end
    end
    t_toc = Base.time() - t_tic
    A_eff = 2/1e9*nx*ny*sizeof(Float64)  # Effective main memory access per iteration [GB]
    t_it  = t_toc/niter                  # Execution time per iteration [s]
    T_eff = A_eff/t_it                   # Effective memory throughput [GB/s]
    @printf("Time = %1.3f sec, T_eff = %1.2f GB/s (niter = %d)\n", t_toc, round(T_eff, sigdigits=3), niter)
    return
end

diffusion_2D(; do_visu=false)
