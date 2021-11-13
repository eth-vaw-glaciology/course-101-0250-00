# This file was generated, do not modify it.

] activate .

#using IJulia
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

# solution

# solution

# solution

# solution

# solution

# solution

# solution

