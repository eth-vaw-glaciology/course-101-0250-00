# This file was generated, do not modify it.

using IJulia
using CUDA
using BenchmarkTools
using Plots

GPU_ID = 7 # select a GPU between 0-7
device!(GPU_ID)

function diffusion2D()
    # Physics
    lam      = 1.0                                          # Thermal conductivity
    c0       = 2.0                                          # Heat capacity
    lx, ly   = 10.0, 10.0                                   # Length of computational domain in dimension x and y

    # Numerics
    nx, ny   = 32*2, 32*2                                   # Number of gridpoints in dimensions x and y
    nt       = 100                                          # Number of time steps
    dx       = lx/(nx-1)                                    # Space step in x-dimension
    dy       = ly/(ny-1)                                    # Space step in y-dimension
    _dx, _dy = 1.0/dx, 1.0/dy

    # Array initializations
    T    = CUDA.zeros(Float64, nx, ny)                      # Temperature
    Ci   = CUDA.zeros(Float64, nx, ny)                      # 1/Heat capacity
    qTx  = CUDA.zeros(Float64, nx-1, ny-2)                  # Heat flux, x component
    qTy  = CUDA.zeros(Float64, nx-2, ny-1)                  # Heat flux, y component
    dTdt = CUDA.zeros(Float64, nx-2, ny-2)                  # Change of Temperature in time

    # Initial conditions
    Ci .= 1/c0                                              # 1/Heat capacity (could vary in space)
    T  .= CuArray([10.0*exp(-(((ix-1)*dx-lx/2)/2)^2-(((iy-1)*dy-ly/2)/2)^2) for ix=1:size(T,1), iy=1:size(T,2)]) # Initialization of Gaussian temperature anomaly

    # Time loop
    dt  = min(dx^2,dy^2)/lam/maximum(Ci)/4.1                # Time step for 2D Heat diffusion
    opts = (aspect_ratio=1, xlims=(1, nx), ylims=(1, ny), clims=(0.0, 10.0), c=:davos, xlabel="Lx", ylabel="Ly") # plotting options
    for it = 1:nt
        diffusion2D_step!(T, Ci, qTx, qTy, dTdt, lam, dt, _dx, _dy) # Diffusion time step.
        if it % 10 == 0
            IJulia.clear_output(true)
            display(heatmap(Array(T)'; opts...))            # Visualization
            sleep(0.1)
        end
    end
end

@inbounds @views macro d_xa(A) esc(:( ($A[2:end  , :     ] .- $A[1:end-1, :     ]) )) end
@inbounds @views macro d_xi(A) esc(:( ($A[2:end  ,2:end-1] .- $A[1:end-1,2:end-1]) )) end
@inbounds @views macro d_ya(A) esc(:( ($A[ :     ,2:end  ] .- $A[ :     ,1:end-1]) )) end
@inbounds @views macro d_yi(A) esc(:( ($A[2:end-1,2:end  ] .- $A[2:end-1,1:end-1]) )) end
@inbounds @views macro  inn(A) esc(:( $A[2:end-1,2:end-1]                          )) end

@inbounds @views function diffusion2D_step!(T, Ci, qTx, qTy, dTdt, lam, dt, _dx, _dy)
    qTx     .= .-lam.*@d_xi(T).*_dx                              # Fourier's law of heat conduction: qT_x  = -λ ∂T/∂x
    qTy     .= .-lam.*@d_yi(T).*_dy                              # ...                               qT_y  = -λ ∂T/∂y
    dTdt    .= @inn(Ci).*(.-@d_xa(qTx).*_dx .- @d_ya(qTy).*_dy)  # Conservation of energy:           ∂T/∂t = 1/cp (-∂qT_x/∂x - ∂qT_y/∂y)
    @inn(T) .= @inn(T) .+ dt.*dTdt                               # Update of temperature             T_new = T_old + ∂t ∂T/∂t
end

diffusion2D()

nx = ny = # complete!
T    = CUDA.rand(Float64, nx, ny);
Ci   = CUDA.rand(Float64, nx, ny);
qTx  = CUDA.zeros(Float64, nx-1, ny-2);
qTy  = CUDA.zeros(Float64, nx-2, ny-1);
dTdt = CUDA.zeros(Float64, nx-2, ny-2);
lam = _dx = _dy = dt = rand();

# solution
t_it = @belapsed begin ... end
T_tot_lb = .../1e9*nx*ny*sizeof(Float64)/t_it

t_it_task1 = t_it
T_tot_lb_task1 = T_tot_lb
CUDA.unsafe_free!(qTx)
CUDA.unsafe_free!(qTy)
CUDA.unsafe_free!(dTdt)

function diffusion2D()
    # Physics
    lam      = 1.0                                          # Thermal conductivity
    c0       = 2.0                                          # Heat capacity
    lx, ly   = 10.0, 10.0                                   # Length of computational domain in dimension x and y

    # Numerics
    nx, ny   = 32*2, 32*2                                   # Number of gridpoints in dimensions x and y
    nt       = 100                                          # Number of time steps
    dx       = lx/(nx-1)                                    # Space step in x-dimension
    dy       = ly/(ny-1)                                    # Space step in y-dimension
    _dx, _dy = 1.0/dx, 1.0/dy

    # Array initializations
    T    = CUDA.zeros(Float64, nx, ny)                      # Temperature
    T2   = CUDA.zeros(Float64, nx, ny)                      # 2nd array for Temperature
    Ci   = CUDA.zeros(Float64, nx, ny)                      # 1/Heat capacity

    # Initial conditions
    Ci .= 1/c0                                              # 1/Heat capacity (could vary in space)
    T  .= CuArray([10.0*exp(-(((ix-1)*dx-lx/2)/2)^2-(((iy-1)*dy-ly/2)/2)^2) for ix=1:size(T,1), iy=1:size(T,2)]) # Initialization of Gaussian temperature anomaly
    T2 .= T;                                                 # Assign also T2 to get correct boundary conditions.

    # Time loop
    dt  = min(dx^2,dy^2)/lam/maximum(Ci)/4.1                # Time step for 2D Heat diffusion
    opts = (aspect_ratio=1, xlims=(1, nx), ylims=(1, ny), clims=(0.0, 10.0), c=:davos, xlabel="Lx", ylabel="Ly") # plotting options
    for it = 1:nt
        diffusion2D_step!(T2, T, Ci, lam, dt, _dx, _dy)     # Diffusion time step.
        if it % 10 == 0
            IJulia.clear_output(true)
            display(heatmap(Array(T)'; opts...))            # Visualization
            sleep(0.1)
        end
        T, T2 = T2, T                                       # Swap the aliases T and T2 (does not perform any array copy)
    end
end

# solution
@inbounds @views function diffusion2D_step!(T2, T, Ci, lam, dt, _dx, _dy)
    T2[2:end-1,2:end-1] .= T[2:end-1,2:end-1] .+ dt.* ...
end

# solution
T2 = ...
t_it = @belapsed begin ...; synchronize() end
speedup = t_it_task1/t_it
T_tot_lb = .../1e9*nx*ny*sizeof(Float64)/t_it
ratio_T_tot_lb = ...

t_it_task3 = t_it
T_tot_lb_task3 = T_tot_lb

# solution
function diffusion2D_step!(...)
    threads = (..., ...)
    blocks  = (size(...)÷threads[1], size(...)÷threads[2])
    @cuda ...
end

function update_temperature!(...)
    ix = ...
    iy = ...
    if (ix... && iy... )
        @inbounds T2[ix,iy] = T[ix,iy] + dt*(Ci[ix,iy]*( ... ))
    end
    return
end

# solution
t_it = @belapsed begin ...; synchronize() end
speedup = ...
T_tot_lb = .../1e9*nx*ny*sizeof(Float64)/t_it
ratio_T_tot_lb = ...

# solution
T_eff_task1 = .../t_it_task1
T_eff_task3 = .../t_it_task3
T_eff_task5 = .../t_it
speedup_Teff_task3 = T_eff_task3/T_eff_task1
speedup_Teff_task5 = T_eff_task5/T_eff_task1

#solution for V100
T_peak = ... # Peak memory throughput of the Tesla V100 GPU
@show T_eff/T_peak
