# This file was generated, do not modify it.

const USE_GPU = false
using ParallelStencil
using ParallelStencil.FiniteDifferences2D
@static if USE_GPU
    @init_parallel_stencil(CUDA, Float64, 2)
else
    @init_parallel_stencil(Threads, Float64, 2)
end
using Plots, Printf

@parallel function compute_q!(qx, qy, C, D, dx, dy)
    @all(qx) = -D*@d_xi(C)/dx
    @all(qy) = -D*@d_yi(C)/dy
    return
end

@parallel function compute_C!(C, qx, qy, dt, dx, dy)
   # C = C - dt * (∂qx/dx + ∂qy/dy)
    return
end

@views function diffusion_2D(; do_visu=false)
    # Physics
    Lx, Ly  = 10.0, 10.0
    D       = 1.0
    ttot    = 1e2
    # Numerics
    nx, ny  = 32*4, 32*4 # number of grid points
    nout    = 50
    # [...]
    return
end

# [...]
# Derived numerics
dx, dy  = Lx/nx, Ly/ny
dt      = min(dx,dy)^2/D/4.1
nt      = cld(ttot, dt)
xc, yc  = LinRange(dx/2, Lx-dx/2, nx), LinRange(dy/2, Ly-dy/2, ny)
# [...]

# [...]
# Array initialisation
C       = Data.Array(exp.(.-(xc .- Lx/2).^2 .-(yc' .- Ly/2).^2))
qx      = @zeros(nx-1,ny-2)
qy      = @zeros(nx-2,ny-1)
# [...]

# [...]
t_tic = 0.0; niter = 0
# Time loop
for it = 1:nt
    if (it==11) t_tic = Base.time(); niter = 0 end
    @parallel compute_q!(qx, qy, C, D, dx, dy)
    @parallel compute_C!(C, qx, qy, dt, dx, dy)
    niter += 1
    if do_visu && (it % nout == 0)
        # visualisation unchanged
    end
end
# [...]

# macros to avoid array allocation
macro qx(ix,iy)  esc(:( -D_dx*(C[$ix+1,$iy+1] - C[$ix,$iy+1]) )) end
macro qy(ix,iy)  esc(:( -D_dy*(C[$ix+1,$iy+1] - C[$ix+1,$iy]) )) end

@parallel_indices (ix,iy) function compute!(C2, C, D_dx, D_dy, dt, _dx, _dy, size_C1_2, size_C2_2)
    if (ix<=size_C1_2 && iy<=size_C2_2)
        C2[ix+1,iy+1] = C[ix+1,iy+1] - dt*( (@qx(ix+1,iy) - @qx(ix,iy))*_dx + (@qy(ix,iy+1) - @qy(ix,iy))*_dy )
    end
    return
end

# Time loop
for it = 1:nt
    if (it==11) t_tic = Base.time(); niter = 0 end
    @parallel compute!(C2, C, D_dx, D_dy, dt, _dx, _dy, size_C1_2, size_C2_2)
    C, C2 = C2, C # pointer swap
    niter += 1
    if do_visu && (it % nout == 0)
        # visu unchanged
    end
end

