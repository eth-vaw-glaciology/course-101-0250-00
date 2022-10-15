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

for iy=??, ix=??
    qDx[??] -= (qDx[??] + k_ηf_dx* ?? )*_1_θ_dτ
end
for iy=??, ix=??
    qDy[??] -= (qDy[??] + k_ηf_dy* ?? )*_1_θ_dτ
end
for iy=??, ix=??
    Pf[??]  -= ??
end

macro d_xa(A)  esc(:( $A[??]-$A[??] )) end
macro d_ya(A)  esc(:( $A[??]-$A[??] )) end

for iy=??, ix=??
    qDx[??] -= (qDx[??] + k_ηf_dx* ?? )*_1_θ_dτ
end
for iy=??, ix=??
    qDy[??] -= (qDy[??] + k_ηf_dy* ?? )*_1_θ_dτ
end
for iy=??, ix=??
    Pf[??]  -= ??
end

