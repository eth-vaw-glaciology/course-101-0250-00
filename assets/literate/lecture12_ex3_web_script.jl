# This file was generated, do not modify it.

] activate .

] instantiate

using CUDA
using BenchmarkTools
using Plots

A = CUDA.ones(4,4,4)
B = CUDA.zeros(4,4,4)
cumsum!(B, A; dims=1)
cumsum!(B, A; dims=2)
cumsum!(B, A; dims=3)

nx = ny = nz = 512
A = CUDA.rand(Float64, nx, ny, nz);
B = CUDA.zeros(Float64, nx, ny, nz);

B_ref = CUDA.zeros(Float64, nx, ny, nz);

function memcopy!(B, A)
    ix = (blockIdx().x-1) * blockDim().x + threadIdx().x
    iy = (blockIdx().y-1) * blockDim().y + threadIdx().y
    iz = (blockIdx().z-1) * blockDim().z + threadIdx().z
    @inbounds B[ix,iy,iz] = A[ix,iy,iz]
    return nothing
end

threads = (32, 8, 1)
blocks  = nx.÷threads
t_it = @belapsed begin @cuda blocks=$blocks threads=$threads memcopy!($B, $A); synchronize() end
T_tot = 2*1/1e9*nx*ny*nz*sizeof(Float64)/t_it

# hint
function memcopy!(B, A)
    ix = (blockIdx().x-1) * blockDim().x + threadIdx().x
    iy = (blockIdx().y-1) * blockDim().y + threadIdx().y
    for iz #...
        #...
    end
    return nothing
end

threads = (32, 8, 1)
blocks  = (nx÷threads[1], ny÷threads[2], 1)

# Verification
B .= 0.0;
@cuda #...
B ≈ A

# Performance
t_it = @belapsed begin #...# end
T_tot = 2*1/1e9*nx*ny*nz*sizeof(Float64)/t_it

# hint
function cumsum_dim3!(B, A)
    ix = (blockIdx().x-1) * blockDim().x + threadIdx().x
    iy = (blockIdx().y-1) * blockDim().y + threadIdx().y
    cumsum_iz = 0.0
    for iz #...
        #...
    end
    return nothing
end

# Verification
@cuda #...
CUDA.cumsum!(B_ref, A; dims=3);
B ≈ B_ref

# Performance
t_it = @belapsed begin @cuda #...# end
T_eff_cs = 2*1/1e9*nx*ny*nz*sizeof(Float64)/t_it

t_it = @belapsed begin CUDA.cumsum!($B, $A; dims=3); synchronize() end
T_eff_cs = 2*1/1e9*nx*ny*nz*sizeof(Float64)/t_it

# hint
function memcopy!(B, A)
    #...
    return nothing
end

threads = (256, 1, 1)
blocks  = #...

# Verification
B .= 0.0;
@cuda #...
B ≈ A

# Performance
t_it = @belapsed begin @cuda #...# end
T_tot = 2*1/1e9*nx*ny*nz*sizeof(Float64)/t_it

# hint
function cumsum_dim2!(B, A)
    ix = (blockIdx().x-1) * blockDim().x + threadIdx().x
    iz = (blockIdx().z-1) * blockDim().z + threadIdx().z
    cumsum_iy = 0.0
    #...
    return nothing
end

# Verification
@cuda #...
CUDA.cumsum!(B_ref, A; dims=2);
B ≈ B_ref

# Performance
t_it = @belapsed begin #...# end
T_eff_cs = 2*1/1e9*nx*ny*nz*sizeof(Float64)/t_it

t_it = @belapsed #...
T_eff_cs = 2*1/1e9*nx*ny*nz*sizeof(Float64)/t_it

# hint
function memcopy!(B, A)
    #...
    return nothing
end

threads = (1, 256, 1)
blocks  = #...

# Verification
#...

# Performance
t_it = #...
T_tot = #...

# hint
function memcopy!(B, A)
    #...
    return nothing
end

threads = #...
blocks  = #...

# Verification
#...

# Performance
t_it = #...
T_tot = #...

# hint
function cumsum_dim1!(B, A)
    iy = (blockIdx().y-1) * blockDim().y + threadIdx().y
    iz = (blockIdx().z-1) * blockDim().z + threadIdx().z
    tx = threadIdx().x
    shmem = @cuDynamicSharedMem(eltype(A), blockDim().x)
    cumsum_ix = 0.0
    #...
    return nothing
end

# Verification
#...

# Performance
t_it = #...
T_eff_cs = #...

t_it = @belapsed begin CUDA.cumsum!($B, $A; dims=1); synchronize() end
T_eff_cs = 2*1/1e9*nx*ny*nz*sizeof(Float64)/t_it
