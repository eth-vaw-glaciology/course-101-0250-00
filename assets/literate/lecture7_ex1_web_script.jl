# This file was generated, do not modify it.

# physics
lx,ly       = 40.0,20.0
k_ηf        = 1.0
αρgx,αρgy   = 0.0,1.0
αρg         = sqrt(αρgx^2+αρgy^2)
ΔT          = 200.0
ϕ           = 0.1
Ra          = 1000
λ_ρCp       = 1/Ra*(αρg*k_ηf*ΔT*ly/ϕ) # Ra = αρg*k_ηf*ΔT*ly/λ_ρCp/ϕ
# numerics
ny          = 63
nx          = 2*(ny+1)-1
nt          = 500
re_D        = 4π
cfl         = 1.0/sqrt(2.1)
maxiter     = 10max(nx,ny)
ϵtol        = 1e-6
nvis        = 20
ncheck      = ceil(max(nx,ny))
# [...]
# time step
dt = if it == 1
    0.1*min(dx,dy)/(αρg*ΔT*k_ηf)
else
    min(5.0*min(dx,dy)/(αρg*ΔT*k_ηf),ϕ*min(dx/maximum(abs.(qDx)), dy/maximum(abs.(qDy)))/2.1)
end

Ra      = 1000
# [...]
nx,ny   = 511,1023
nt      = 4000
ϵtol    = 1e-6
nvis    = 50
ncheck  = ceil(2max(nx,ny))

@parallel_indices (iy) function bc_x!(A)
    A[1  ,iy] = A[2    ,iy]
    A[end,iy] = A[end-1,iy]
    return
end

@parallel (1:size(T,2)) bc_x!(T)

