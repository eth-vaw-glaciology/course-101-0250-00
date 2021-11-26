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

function memcopy!(B, A)
    ix = (blockIdx().x-1) * blockDim().x + threadIdx().x
    iy = (blockIdx().y-1) * blockDim().y + threadIdx().y
    for iz = 1:size(A,3)
        @inbounds B[ix,iy,iz] = A[ix,iy,iz]
    end
    return nothing
end

threads = (32, 8, 1)
blocks  = (nx÷threads[1], ny÷threads[2], 1)

# Verification
B .= 0.0;
@cuda blocks=blocks threads=threads memcopy!(B, A); synchronize()
B ≈ A

# Performance
t_it = @belapsed begin @cuda blocks=$blocks threads=$threads memcopy!($B, $A); synchronize() end
T_tot = 2*1/1e9*nx*ny*nz*sizeof(Float64)/t_it

function cumsum_dim3!(B, A)
    ix = (blockIdx().x-1) * blockDim().x + threadIdx().x
    iy = (blockIdx().y-1) * blockDim().y + threadIdx().y
    cumsum_iz = 0.0
    for iz = 1:size(A,3)
        @inbounds cumsum_iz  += A[ix,iy,iz]
        @inbounds B[ix,iy,iz] = cumsum_iz
    end
    return nothing
end

# Verification
@cuda blocks=blocks threads=threads cumsum_dim3!(B, A); synchronize()
CUDA.cumsum!(B_ref, A; dims=3);
B ≈ B_ref

# Performance
t_it = @belapsed begin @cuda blocks=$blocks threads=$threads cumsum_dim3!($B, $A); synchronize() end
T_eff_cs = 2*1/1e9*nx*ny*nz*sizeof(Float64)/t_it

t_it = @belapsed begin CUDA.cumsum!($B, $A; dims=3); synchronize() end
T_eff_cs = 2*1/1e9*nx*ny*nz*sizeof(Float64)/t_it

function memcopy!(B, A)
    ix = (blockIdx().x-1) * blockDim().x + threadIdx().x
    iz = (blockIdx().z-1) * blockDim().z + threadIdx().z
    for iy = 1:size(A,2)
        @inbounds B[ix,iy,iz] = A[ix,iy,iz]
    end
    return nothing
end

threads = (256, 1, 1)
blocks  = (nx÷threads[1], 1, nz÷threads[3])

# Verification
B .= 0.0;
@cuda blocks=blocks threads=threads memcopy!(B, A); synchronize()
B ≈ A

# Performance
t_it = @belapsed begin @cuda blocks=$blocks threads=$threads memcopy!($B, $A); synchronize() end
T_tot = 2*1/1e9*nx*ny*nz*sizeof(Float64)/t_it

function cumsum_dim2!(B, A)
    ix = (blockIdx().x-1) * blockDim().x + threadIdx().x
    iz = (blockIdx().z-1) * blockDim().z + threadIdx().z
    cumsum_iy = 0.0
    for iy = 1:size(A,2)
        @inbounds cumsum_iy  += A[ix,iy,iz]
        @inbounds B[ix,iy,iz] = cumsum_iy
    end
    return nothing
end

# Verification
@cuda blocks=blocks threads=threads cumsum_dim2!(B, A); synchronize()
CUDA.cumsum!(B_ref, A; dims=2);
B ≈ B_ref

# Performance
t_it = @belapsed begin @cuda blocks=$blocks threads=$threads cumsum_dim2!($B, $A); synchronize() end
T_eff_cs = 2*1/1e9*nx*ny*nz*sizeof(Float64)/t_it

t_it = @belapsed begin CUDA.cumsum!($B, $A; dims=2); synchronize() end
T_eff_cs = 2*1/1e9*nx*ny*nz*sizeof(Float64)/t_it

function memcopy!(B, A)
    iy = (blockIdx().y-1) * blockDim().y + threadIdx().y
    iz = (blockIdx().z-1) * blockDim().z + threadIdx().z
    for ix = 1:size(A,1)
        @inbounds B[ix,iy,iz] = A[ix,iy,iz]
    end
    return nothing
end

threads = (1, 256, 1)
blocks  = (1, ny÷threads[2], nz÷threads[3])

# Verification
B .= 0.0;
@cuda blocks=blocks threads=threads memcopy!(B, A); synchronize()
B ≈ A

# Performance
t_it = @belapsed begin @cuda blocks=$blocks threads=$threads memcopy!($B, $A); synchronize() end
T_tot = 2*1/1e9*nx*ny*nz*sizeof(Float64)/t_it

function memcopy!(B, A)
    iy = (blockIdx().y-1) * blockDim().y + threadIdx().y
    iz = (blockIdx().z-1) * blockDim().z + threadIdx().z
    for ix_offset = 0 : blockDim().x : size(A,1)-1
        ix = threadIdx().x + ix_offset
        @inbounds B[ix,iy,iz] = A[ix,iy,iz]
    end
    return nothing
end

threads = (32, 1, 1)
blocks  = (1, ny÷threads[2], nz÷threads[3])

# Verification
B .= 0.0;
@cuda blocks=blocks threads=threads memcopy!(B, A); synchronize()
B ≈ A

# Performance
t_it = @belapsed begin @cuda blocks=$blocks threads=$threads memcopy!($B, $A); synchronize() end
T_tot = 2*1/1e9*nx*ny*nz*sizeof(Float64)/t_it

function cumsum_dim1!(B, A)
    iy = (blockIdx().y-1) * blockDim().y + threadIdx().y
    iz = (blockIdx().z-1) * blockDim().z + threadIdx().z
    tx = threadIdx().x
    shmem = @cuDynamicSharedMem(eltype(A), blockDim().x)
    cumsum_ix = 0.0
    for ix_offset = 0 : blockDim().x : size(A,1)-1
        ix = threadIdx().x + ix_offset
        @inbounds shmem[tx] = A[ix,iy,iz]       # Read the x-dimension chunk into shared memory.
        sync_threads()
        if tx == 1                            # Compute the cumsum only with the first thread, accessing only shared memory
            for i = 1:blockDim().x
                @inbounds cumsum_ix += shmem[i]
                @inbounds shmem[i] = cumsum_ix
            end
        end
        sync_threads()
        @inbounds B[ix,iy,iz] = shmem[tx]       # Write the x-dimension chunk to main memory.
    end
    return nothing
end

# Verification
@cuda blocks=blocks threads=threads shmem=prod(threads)*sizeof(Float64) cumsum_dim1!(B, A); synchronize()
CUDA.cumsum!(B_ref, A; dims=1);
B ≈ B_ref

# Performance
t_it = @belapsed begin @cuda blocks=$blocks threads=$threads shmem=2*prod($threads)*sizeof(Float64) cumsum_dim1!($B, $A); synchronize() end
T_eff_cs = 2*1/1e9*nx*ny*nz*sizeof(Float64)/t_it

t_it = @belapsed begin CUDA.cumsum!($B, $A; dims=1); synchronize() end
T_eff_cs = 2*1/1e9*nx*ny*nz*sizeof(Float64)/t_it

