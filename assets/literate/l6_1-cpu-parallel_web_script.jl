# This file was generated, do not modify it.

t_toc = Base.time() - t_tic
A_eff = (3*2)/1e9*nx*ny*sizeof(Float64)  # Effective main memory access per iteration [GB]
t_it  = t_toc/niter                      # Execution time per iteration [s]
T_eff = A_eff/t_it                       # Effective memory throughput [GB/s]

function Pf_diffusion_2D(;do_check=false)
    if do_check && (iter%ncheck == 0)
    ...
    end
    return
end

k_ηf_dx, k_ηf_dy = k_ηf/dx, k_ηf/dy

_1_θ_dτ = 1.0./(1.0 + θ_dτ)

_dx, _dy = 1.0/dx, 1.0/dy

for iy=1:ny
    for ix=1:nx-1
        qDx[ix+1,iy] -= (qDx[ix+1,iy] + k_ηf_dx*(Pf[ix+1,iy]-Pf[ix,iy]))*_1_θ_dτ
    end
end
for iy=1:ny-1
    for ix=1:nx
        qDy[ix,iy+1] -= (qDy[ix,iy+1] + k_ηf_dy*(Pf[ix,iy+1]-Pf[ix,iy]))*_1_θ_dτ
    end
end
for iy=1:ny
    for ix=1:nx
        Pf[ix,iy]  -= ((qDx[ix+1,iy]-qDx[ix,iy])*_dx + (qDy[ix,iy+1]-qDy[ix,iy])*_dy)*_β_dτ
    end
end

macro d_xa(A)  esc(:( $A[ix+1,iy]-$A[ix,iy] )) end
macro d_ya(A)  esc(:( $A[ix,iy+1]-$A[ix,iy] )) end

for iy=1:ny
    for ix=1:nx-1
        qDx[ix+1,iy] -= (qDx[ix+1,iy] + k_ηf_dx*@d_xa(Pf))*_1_θ_dτ
    end
end
for iy=1:ny-1
    for ix=1:nx
        qDy[ix,iy+1] -= (qDy[ix,iy+1] + k_ηf_dy*@d_ya(Pf))*_1_θ_dτ
    end
end
for iy=1:ny
    for ix=1:nx
        Pf[ix,iy]  -= (@d_xa(qDx)*_dx + @d_ya(qDy)*_dy)*_β_dτ
    end
end

function compute_flux!(qDx,qDy,Pf,k_ηf_dx,k_ηf_dy,_1_θ_dτ)
    nx,ny=size(Pf)
    for iy=1:ny,
        for ix=1:nx-1
            qDx[ix+1,iy] -= (qDx[ix+1,iy] + k_ηf_dx*@d_xa(Pf))*_1_θ_dτ
        end
    end
    for iy=1:ny-1
        for ix=1:nx
            qDy[ix,iy+1] -= (qDy[ix,iy+1] + k_ηf_dy*@d_ya(Pf))*_1_θ_dτ
        end
    end
    return nothing
end

function update_Pf!(Pf,qDx,qDy,_dx,_dy,_β_dτ)
    nx,ny=size(Pf)
    for iy=1:ny
        for ix=1:nx
            Pf[ix,iy]  -= (@d_xa(qDx)*_dx + @d_ya(qDy)*_dy)*_β_dτ
        end
    end
    return nothing
end

function compute!(Pf,qDx,qDy,k_ηf_dx,k_ηf_dy,_1_θ_dτ,_dx,_dy,_β_dτ)
    compute_flux!(qDx,qDy,Pf,k_ηf_dx,k_ηf_dy,_1_θ_dτ)
    update_Pf!(Pf,qDx,qDy,_dx,_dy,_β_dτ)
    return nothing
end

t_toc = @belapsed compute!($Pf,$qDx,$qDy,$k_ηf_dx,$k_ηf_dy,$_1_θ_dτ,$_dx,$_dy,$_β_dτ)
niter = 1
