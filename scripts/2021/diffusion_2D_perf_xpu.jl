# juliap -O3 --check-bounds=no --math-mode=fast diffusion_2D_perf_xpu.jl
const USE_GPU = true
using ParallelStencil
using ParallelStencil.FiniteDifferences2D
@static if USE_GPU
    @init_parallel_stencil(CUDA, Float64, 2)
else
    @init_parallel_stencil(Threads, Float64, 2)
end
using Plots, Printf

# macros to avoid array allocation
macro qx(ix,iy)  esc(:( -D_dx*(C[$ix+1,$iy+1] - C[$ix,$iy+1]) )) end
macro qy(ix,iy)  esc(:( -D_dy*(C[$ix+1,$iy+1] - C[$ix+1,$iy]) )) end

@parallel_indices (ix,iy) function compute!(C2, C, D_dx, D_dy, dt, _dx, _dy, size_C1_2, size_C2_2)
    if (ix<=size_C1_2 && iy<=size_C2_2)
        C2[ix+1,iy+1] = C[ix+1,iy+1] - dt*( (@qx(ix+1,iy) - @qx(ix,iy))*_dx + (@qy(ix,iy+1) - @qy(ix,iy))*_dy )
    end
    return
end

@views function diffusion_2D(; do_visu=false)
    # Physics
    Lx, Ly  = 10.0, 10.0
    D       = 1.0
    ttot    = 1e0
    # Numerics
    nx, ny  = 32*2, 32*2 # number of grid points
    nout    = 20
    # Derived numerics
    dx, dy  = Lx/nx, Ly/ny
    dt      = min(dx, dy)^2/D/4.1
    nt      = cld(ttot, dt)
    xc, yc  = LinRange(dx/2, Lx-dx/2, nx), LinRange(dy/2, Ly-dy/2, ny)
    D_dx    = D/dx
    D_dy    = D/dy
    _dx, _dy= 1.0/dx, 1.0/dy
    # Array initialisation
    C       = Data.Array(exp.(.-(xc .- Lx/2).^2 .-(yc' .- Ly/2).^2))
    C2      = copy(C)
    size_C1_2, size_C2_2 = size(C,1)-2, size(C,2)-2
    t_tic = 0.0; niter = 0
    if do_visu ENV["GKSwstype"]="nul"; if isdir("viz2D_xpu_out")==false mkdir("viz2D_xpu_out") end; loadpath = "./viz2D_xpu_out/"; anim = Animation(loadpath,String[]); println("Animation directory: $(anim.dir)") end
    # Time loop
    for it = 1:nt
        if (it==11) t_tic = Base.time(); niter = 0 end
        @parallel compute!(C2, C, D_dx, D_dy, dt, _dx, _dy, size_C1_2, size_C2_2)
        C, C2 = C2, C # pointer swap
        niter += 1
        if do_visu && (it % nout == 0)
            opts = (aspect_ratio=1, xlims=(xc[1], xc[end]), ylims=(yc[1], yc[end]), clims=(0.0, 1.0), c=:davos, xlabel="Lx", ylabel="Ly", title="time = $(round(it*dt, sigdigits=3))")
            heatmap(xc, yc, Array(C)'; opts...); frame(anim)
        end
    end
    t_toc = Base.time() - t_tic
    A_eff = 2/1e9*nx*ny*sizeof(Float64)  # Effective main memory access per iteration [GB]
    t_it  = t_toc/niter                  # Execution time per iteration [s]
    T_eff = A_eff/t_it                   # Effective memory throughput [GB/s]
    @printf("Time = %1.3f sec, T_eff = %1.2f GB/s (niter = %d)\n", t_toc, round(T_eff, sigdigits=3), niter)
    if do_visu gif(anim, "diffusion_2D_xpu.gif", fps = 5)  end
    return
end

diffusion_2D(; do_visu=true)
