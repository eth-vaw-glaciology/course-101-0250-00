# This file was generated, do not modify it.

t_toc = ...
A_eff = ...          # Effective main memory access per iteration [GB]
t_it  = ...          # Execution time per iteration [s]
T_eff = A_eff/t_it   # Effective memory throughput [GB/s]

function Pf_diffusion_2D(;??)
    ...
    return
end

k_ηf_dx, k_ηf_dy = k_ηf/dx, k_ηf/dy

_1_θ_dτ = 1.0./(1.0 + θ_dτ)

_dx, _dy = 1.0/dx, 1.0/dy

for iy=??
    for ix=??
        qDx[??] -= (qDx[??] + k_ηf_dx* ?? )*_1_θ_dτ
    end
end
for iy=??
    for ix=??
        qDy[??] -= (qDy[??] + k_ηf_dy* ?? )*_1_θ_dτ
    end
end
for iy=??
    for ix=??
        Pf[??]  -= ??
    end
end

macro d_xa(A)  esc(:( $A[??]-$A[??] )) end
macro d_ya(A)  esc(:( $A[??]-$A[??] )) end

for iy=??
    for ix=??
        qDx[??] -= (qDx[??] + k_ηf_dx* ?? )*_1_θ_dτ
    end
end
for iy=??
    for ix=??
        qDy[??] -= (qDy[??] + k_ηf_dy* ?? )*_1_θ_dτ
    end
end
for iy=??
    for ix=??
        Pf[??]  -= ??
    end
end

function compute_flux!(...)
    nx,ny=size(Pf)
    ...
    return nothing
end

function update_Pf!(Pf,...)
    nx,ny=size(Pf)
    ...
    return nothing
end

function compute!(Pf,qDx,qDy, ???)
    compute_flux!(...)
    update_Pf!(...)
    return nothing
end

t_toc = @belapsed compute!($Pf,$qDx,$qDy,???)
niter = ???

