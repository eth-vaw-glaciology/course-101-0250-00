# This file was generated, do not modify it.

const USE_GPU = false
using ParallelStencil
using ParallelStencil.FiniteDifferences2D
@static if USE_GPU
    @init_parallel_stencil(CUDA, Float64, 2)
else
    @init_parallel_stencil(Threads, Float64, 2)
end
using Plots,Plots.Measures,Printf

@parallel function compute_flux!(qDx,qDy,Pf,k_ηf_dx,k_ηf_dy,_1_θ_dτ)
    @inn_x(qDx) = @inn_x(qDx) - (@inn_x(qDx) + k_ηf_dx*@d_xa(Pf))*_1_θ_dτ
    @inn_y(qDy) = @inn_y(qDy) - (@inn_y(qDy) + k_ηf_dy*@d_ya(Pf))*_1_θ_dτ
    return nothing
end

@parallel function update_Pf!(Pf,qDx,qDy,_dx,_dy,_β_dτ)
    @all(Pf) = @all(Pf) - (@d_xa(qDx)*_dx + @d_ya(qDy)*_dy)*_β_dτ
    return nothing
end

function Pf_diffusion_2D(;do_check=false)
    # physics
    # [...]
    # numerics
    nx, ny  = 16*32, 16*32 # number of grid points
    maxiter = 500
    # [...]
    return
end

# [...]
# array initialisation
Pf      = Data.Array( @. exp(-(xc-lx/2)^2 -(yc'-ly/2)^2) )
qDx     = @zeros(nx+1,ny  )
qDy     = @zeros(nx  ,ny+1)
r_Pf    = @zeros(nx  ,ny  )
# [...]

# [...]
# iteration loop
iter = 1; err_Pf = 2ϵtol
t_tic = 0.0; niter = 0
while err_Pf >= ϵtol && iter <= maxiter
    if (iter==11) t_tic = Base.time(); niter = 0 end
    @parallel compute_flux!(qDx,qDy,Pf,k_ηf_dx,k_ηf_dy,_1_θ_dτ)
    @parallel update_Pf!(Pf,qDx,qDy,_dx,_dy,_β_dτ)
    if do_check && (iter%ncheck == 0)
        #  [...]
    end
    iter += 1; niter += 1
end
# [...]

macro d_xa(A)  esc(:( $A[ix+1,iy]-$A[ix,iy] )) end
macro d_ya(A)  esc(:( $A[ix,iy+1]-$A[ix,iy] )) end

@parallel_indices (ix,iy) function compute_flux!(qDx,qDy,Pf,k_ηf_dx,k_ηf_dy,_1_θ_dτ)
    nx,ny=size(Pf)
    if (ix<=nx-1 && iy<=ny  )  qDx[ix+1,iy] -= (qDx[ix+1,iy] + k_ηf_dx*@d_xa(Pf))*_1_θ_dτ  end
    if (ix<=nx   && iy<=ny-1)  qDy[ix,iy+1] -= (qDy[ix,iy+1] + k_ηf_dy*@d_ya(Pf))*_1_θ_dτ  end
    return nothing
end

# [...]
# iteration loop
iter = 1; err_Pf = 2ϵtol
t_tic = 0.0; niter = 0
while err_Pf >= ϵtol && iter <= maxiter
    if (iter==11) t_tic = Base.time(); niter = 0 end
    @parallel compute_flux!(qDx,qDy,Pf,k_ηf_dx,k_ηf_dy,_1_θ_dτ)
    @parallel update_Pf!(Pf,qDx,qDy,_dx,_dy,_β_dτ)
    if do_check && (iter%ncheck == 0)
        # [...]
    end
    iter += 1; niter += 1
end
# [...]

Pf = Data.Array([exp(-(xc[ix]-lx/2)^2 -(yc[iy]-ly/2)^2 -(zc[iz]-lz/2)^2) for ix=1:nx,iy=1:ny,iz=1:nz])

