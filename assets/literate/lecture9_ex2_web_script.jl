# This file was generated, do not modify it.

] activate .

] instantiate

using CUDA
using BenchmarkTools
using Plots

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
    @gif for it = 1:nt
        diffusion2D_step!(T2, T, Ci, lam, dt, _dx, _dy)     # Diffusion time step.
        heatmap(Array(T)'; opts...)                         # Visualization
        T, T2 = T2, T                                       # Swap the aliases T and T2 (does not perform any array copy)
    end
end

function diffusion2D_step!(T2, T, Ci, lam, dt, _dx, _dy)
    threads = (32, 8)
    blocks  = (size(T2,1)÷threads[1], size(T2,2)÷threads[2])
    @cuda blocks=blocks threads=threads update_temperature!(T2, T, Ci, lam, dt, _dx, _dy)
end

function update_temperature!(T2, T, Ci, lam, dt, _dx, _dy)
    ix = (blockIdx().x-1) * blockDim().x + threadIdx().x
    iy = (blockIdx().y-1) * blockDim().y + threadIdx().y
    if (ix>1 && ix<size(T2,1) && iy>1 && iy<size(T2,2))
        @inbounds T2[ix,iy] = T[ix,iy] + dt*Ci[ix,iy]*(
                              - ((-lam*(T[ix+1,iy] - T[ix,iy])*_dx) - (-lam*(T[ix,iy] - T[ix-1,iy])*_dx))*_dx
                              - ((-lam*(T[ix,iy+1] - T[ix,iy])*_dy) - (-lam*(T[ix,iy] - T[ix,iy-1])*_dy))*_dy
                              )
    end
    return
end

nx = ny = 512*32
T    = CUDA.rand(Float64, nx, ny);
T2   = CUDA.rand(Float64, nx, ny);
Ci   = CUDA.rand(Float64, nx, ny);
lam = _dx = _dy = dt = rand();

max_threads  = attribute(device(),CUDA.DEVICE_ATTRIBUTE_MAX_THREADS_PER_BLOCK)
thread_count = []
throughputs  = []
for pow = 0:Int(log2(max_threads/32))
    threads = (32, 2^pow)
    blocks  = (nx÷threads[1], ny÷threads[2])
    t_it = @belapsed begin @cuda blocks=$blocks threads=$threads update_temperature!($T2, $T, $Ci, $lam, $dt, $_dx, $_dy); synchronize() end
    T_eff = (2*1+1)*1/1e9*nx*ny*sizeof(Float64)/t_it
    push!(thread_count, prod(threads))
    push!(throughputs, T_eff)
    println("(threads=$threads) T_eff = $(T_eff)")
end

T_tot_max, index = findmax(throughputs)
threads = (32, thread_count[index]÷32)
blocks  = (nx÷threads[1], ny÷threads[2])

function update_temperature!(T2, T, Ci, lam, dt, _dx, _dy)
    ix = (blockIdx().x-1) * blockDim().x + threadIdx().x
    iy = (blockIdx().y-1) * blockDim().y + threadIdx().y
    if (ix>1 && ix<size(T2,1) && iy>1 && iy<size(T2,2))
        @inbounds T2[ix,iy] = T[ix,iy] + dt*Ci[ix,iy]
    end
    return
end

t_it = @belapsed begin @cuda blocks=$blocks threads=$threads update_temperature!($T2, $T, $Ci, $lam, $dt, $_dx, $_dy); synchronize() end
T_eff = (2*1+1)*1/1e9*nx*ny*sizeof(Float64)/t_it

# solution
function update_temperature!(T2, T, Ci, lam, dt, _dx, _dy)
    ix = (blockIdx().x-1) * blockDim().x + threadIdx().x
    iy = (blockIdx().y-1) * blockDim().y + threadIdx().y
    tx = threadIdx().x
    ty = threadIdx().y
    T_l = @cuDynamicSharedMem(eltype(T), (blockDim().x, blockDim().y))
    @inbounds T_l[tx,ty] = T[ix,iy]
    if (ix>1 && ix<size(T2,1) && iy>1 && iy<size(T2,2))
        @inbounds T2[ix,iy] = T_l[tx,ty] + dt*Ci[ix,iy]
    end
    return
end

# solution
t_it = @belapsed begin @cuda blocks=$blocks threads=$threads shmem=prod($threads)*sizeof(Float64) update_temperature!($T2, $T, $Ci, $lam, $dt, $_dx, $_dy); synchronize() end
T_eff = (2*1+1)*1/1e9*nx*ny*sizeof(Float64)/t_it

# solution
function update_temperature!(T2, T, Ci, lam, dt, _dx, _dy)
    ix = (blockIdx().x-1) * blockDim().x + threadIdx().x
    iy = (blockIdx().y-1) * blockDim().y + threadIdx().y
    tx = threadIdx().x+1
    ty = threadIdx().y+1
    T_l = @cuDynamicSharedMem(eltype(T), (blockDim().x+2, blockDim().y+2))
    @inbounds T_l[tx,ty] = T[ix,iy]
    if (ix>1 && ix<size(T2,1) && iy>1 && iy<size(T2,2))
        @inbounds T2[ix,iy] = T_l[tx,ty] + dt*Ci[ix,iy]
    end
    return
end

t_it = @belapsed begin @cuda blocks=$blocks threads=$threads shmem=prod($threads.+2)*sizeof(Float64) update_temperature!($T2, $T, $Ci, $lam, $dt, $_dx, $_dy); synchronize() end
T_eff = (2*1+1)*1/1e9*nx*ny*sizeof(Float64)/t_it

# solution
function update_temperature!(T2, T, Ci, lam, dt, _dx, _dy)
    ix = (blockIdx().x-1) * blockDim().x + threadIdx().x
    iy = (blockIdx().y-1) * blockDim().y + threadIdx().y
    tx = threadIdx().x+1
    ty = threadIdx().y+1
    T_l = @cuDynamicSharedMem(eltype(T), (blockDim().x+2, blockDim().y+2))
    @inbounds T_l[tx,ty] = T[ix,iy]
    if (ix>1 && ix<size(T2,1) && iy>1 && iy<size(T2,2))
        @inbounds if (threadIdx().x == 1)            T_l[tx-1,ty] = T[ix-1,iy] end
        @inbounds if (threadIdx().x == blockDim().x) T_l[tx+1,ty] = T[ix+1,iy] end
        @inbounds if (threadIdx().y == 1)            T_l[tx,ty-1] = T[ix,iy-1] end
        @inbounds if (threadIdx().y == blockDim().y) T_l[tx,ty+1] = T[ix,iy+1] end
        @inbounds T2[ix,iy] = T_l[tx,ty] + dt*Ci[ix,iy]
    end
    return
end

t_it = @belapsed begin @cuda blocks=$blocks threads=$threads shmem=prod($threads.+2)*sizeof(Float64) update_temperature!($T2, $T, $Ci, $lam, $dt, $_dx, $_dy); synchronize() end
T_eff = (2*1+1)*1/1e9*nx*ny*sizeof(Float64)/t_it

# solution
function update_temperature!(T2, T, Ci, lam, dt, _dx, _dy)
    ix = (blockIdx().x-1) * blockDim().x + threadIdx().x
    iy = (blockIdx().y-1) * blockDim().y + threadIdx().y
    tx = threadIdx().x+1
    ty = threadIdx().y+1
    T_l = @cuDynamicSharedMem(eltype(T), (blockDim().x+2, blockDim().y+2))
    @inbounds T_l[tx,ty] = T[ix,iy]
    if (ix>1 && ix<size(T2,1) && iy>1 && iy<size(T2,2))
        @inbounds if (threadIdx().x == 1)            T_l[tx-1,ty] = T[ix-1,iy] end
        @inbounds if (threadIdx().x == blockDim().x) T_l[tx+1,ty] = T[ix+1,iy] end
        @inbounds if (threadIdx().y == 1)            T_l[tx,ty-1] = T[ix,iy-1] end
        @inbounds if (threadIdx().y == blockDim().y) T_l[tx,ty+1] = T[ix,iy+1] end
        sync_threads()
        @inbounds T2[ix,iy] = T_l[tx,ty] + dt*Ci[ix,iy]*(
                    - ((-lam*(T_l[tx+1,ty] - T_l[tx,ty])*_dx) - (-lam*(T_l[tx,ty] - T_l[tx-1,ty])*_dx))*_dx
                    - ((-lam*(T_l[tx,ty+1] - T_l[tx,ty])*_dy) - (-lam*(T_l[tx,ty] - T_l[tx,ty-1])*_dy))*_dy
                    )
    end
    return
end

function diffusion2D_step!(T2, T, Ci, lam, dt, _dx, _dy)
    threads = (32, 8)
    blocks  = (size(T2,1)÷threads[1], size(T2,2)÷threads[2])
    @cuda blocks=blocks threads=threads shmem=prod(threads.+2)*sizeof(Float64) update_temperature!(T2, T, Ci, lam, dt, _dx, _dy); synchronize()
end

diffusion2D()

t_it = @belapsed begin @cuda blocks=$blocks threads=$threads shmem=prod($threads.+2)*sizeof(Float64) update_temperature!($T2, $T, $Ci, $lam, $dt, $_dx, $_dy); synchronize() end
T_eff = (2*1+1)*1/1e9*nx*ny*sizeof(Float64)/t_it

# solution
T_peak = 561 # Peak memory throughput of the Tesla P100 GPU
T_eff/T_peak

