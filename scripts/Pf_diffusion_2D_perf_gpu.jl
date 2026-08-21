using CairoMakie, Printf
using CUDA

macro d_xa(A) esc(:($A[ix+1, iy]-$A[ix, iy])) end
macro d_ya(A) esc(:($A[ix, iy+1]-$A[ix, iy])) end

function compute_flux!(qDx, qDy, Pf, k_ηf_dx, k_ηf_dy, _1_θ_dτ)
    nx, ny=size(Pf)
    ix = (blockIdx().x-1) * blockDim().x + threadIdx().x
    iy = (blockIdx().y-1) * blockDim().y + threadIdx().y
    if (ix<=nx-1 && iy<=ny) qDx[ix+1, iy] -= (qDx[ix+1, iy] + k_ηf_dx*@d_xa(Pf))*_1_θ_dτ end
    if (ix<=nx && iy<=ny-1) qDy[ix, iy+1] -= (qDy[ix, iy+1] + k_ηf_dy*@d_ya(Pf))*_1_θ_dτ end
    return nothing
end

function update_Pf!(Pf, qDx, qDy, _dx, _dy, _β_dτ)
    nx, ny=size(Pf)
    ix = (blockIdx().x-1) * blockDim().x + threadIdx().x
    iy = (blockIdx().y-1) * blockDim().y + threadIdx().y
    if (ix<=nx && iy<=ny) Pf[ix, iy] -= (@d_xa(qDx)*_dx + @d_ya(qDy)*_dy)*_β_dτ end
    return nothing
end

function Pf_diffusion_2D(; nx=511, ny=511, do_check=false, do_save=false)
    # physics
    lx, ly = 20.0, 20.0
    k_ηf   = 1.0
    # numerics
    threads = (32, 4)
    # nx,ny   = 511,511
    blocks  = ceil.(Int, (nx, ny) ./ threads)
    ϵtol    = 1e-8
    maxiter = 500#max(nx,ny)
    ncheck  = ceil(Int, 0.25max(nx, ny))
    cfl     = 1.0/sqrt(2.1)
    re      = 2π
    # derived numerics
    dx, dy  = lx/nx, ly/ny
    xc, yc  = LinRange(dx/2, lx-dx/2, nx), LinRange(dy/2, ly-dy/2, ny)
    θ_dτ    = max(lx, ly)/re/cfl/min(dx, dy)
    β_dτ    = (re*k_ηf)/(cfl*min(dx, dy)*max(lx, ly))
    _1_θ_dτ = 1.0/(1.0 + θ_dτ)
    _β_dτ   = 1.0/(β_dτ)
    _dx, _dy = 1.0/dx, 1.0/dy
    k_ηf_dx, k_ηf_dy = k_ηf/dx, k_ηf/dy
    # array initialisation
    Pf   = CuArray(@. exp(-(xc-lx/2)^2 - (yc'-ly/2)^2))
    qDx  = CUDA.zeros(Float64, nx+1, ny)
    qDy  = CUDA.zeros(Float64, nx, ny+1)
    r_Pf = CUDA.zeros(Float64, nx, ny)
    # visu
    if do_check
        fig, ax, plt = heatmap(xc, yc, Array(Pf);
                               figure=(; size=(600, 500)),
                               axis=(; aspect=DataAspect(), xlabel="x", ylabel="y", title="Pf"),
                               colormap=:turbo, colorrange=(0, 1))
        Colorbar(fig[1, 2], plt)
        io = do_save ? VideoStream(fig; framerate=10) : nothing # `io` collects the frames
    end
    # iteration loop
    iter   = 1
    err_Pf = 2ϵtol
    t_tic  = 0.0
    niter  = 0
    while err_Pf >= ϵtol && iter <= maxiter
        if (iter==11) t_tic = Base.time(); niter = 0 end
        CUDA.@sync @cuda blocks=blocks threads=threads compute_flux!(qDx, qDy, Pf, k_ηf_dx, k_ηf_dy, _1_θ_dτ)
        CUDA.@sync @cuda blocks=blocks threads=threads update_Pf!(Pf, qDx, qDy, _dx, _dy, _β_dτ)
        if do_check && (iter%ncheck == 0)
            r_Pf .= diff(qDx, dims=1) ./ dx .+ diff(qDy, dims=2) ./ dy
            err_Pf = maximum(abs.(r_Pf))
            @printf("  iter/nx=%.1f, err_Pf=%1.3e\n", iter/nx, err_Pf)
            plt[3] = Array(Pf) # update the plot in-place
            do_save ? recordframe!(io) : display(fig)
        end
        iter  += 1
        niter += 1
    end
    if do_check && do_save
        mkpath("viz_out"); save("viz_out/Pf_diffusion_2D.mp4", io)
    end
    t_toc = Base.time() - t_tic
    A_eff = (3*2)/1e9*nx*ny*sizeof(Float64)  # Effective main memory access per iteration [GB]
    t_it = t_toc/niter                      # Execution time per iteration [s]
    T_eff = A_eff/t_it                       # Effective memory throughput [GB/s]
    @printf("Time = %1.3f sec, T_eff = %1.3f GB/s (niter = %d)\n", t_toc, round(T_eff, sigdigits=3), niter)
    return
end

# Pf_diffusion_2D(; do_check=true)                # live display
# Pf_diffusion_2D(; do_check=true, do_save=true)  # save viz_out/Pf_diffusion_2D.mp4

resol = nx = ny = 32 .* 2 .^ (0:9) .- 1

for ires ∈ resol
    println("Running nx=ny=$(ires)")
    Pf_diffusion_2D(; nx=ires, ny=ires, do_check=false)
end
