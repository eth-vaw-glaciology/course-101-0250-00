# This file was generated, do not modify it.

using CUDA

function copy!(A, B)
    ix = (blockIdx().x-1) * blockDim().x + threadIdx().x
    iy = (blockIdx().y-1) * blockDim().y + threadIdx().y
    A[ix,iy] = B[ix,iy]
    return
end

threads = (4, 3)
blocks  = (2, 2)
nx, ny  = threads[1]*blocks[1], threads[2]*blocks[2]
A       = CUDA.zeros(Float64, nx, ny)
B       =  CUDA.rand(Float64, nx, ny)

@cuda blocks=blocks threads=threads copy!(A, B)
synchronize()

import Pkg; Pkg.add("BenchmarkTools");
using CUDA
using BenchmarkTools

collect(devices())
device!(0) # select a GPU between 0-7

nx = ny = 32
A = CUDA.zeros(Float64, nx, ny);
B = CUDA.rand(Float64, nx, ny);
@benchmark begin copyto!($A, $B); synchronize() end

t_it = @belapsed begin copyto!($A, $B); synchronize() end

T_tot = 2*1/1e9*nx*ny*sizeof(Float64)/t_it

array_sizes = []
throughputs = []
for pow = 0:11
    nx = ny = 32*2^pow
    if (3*nx*ny*sizeof(Float64) > CUDA.available_memory()) break; end
    A = CUDA.zeros(Float64, nx, ny);
    B = CUDA.rand(Float64, nx, ny);
    t_it = @belapsed begin copyto!($A, $B); synchronize() end
    T_tot = 2*1/1e9*nx*ny*sizeof(Float64)/t_it
    push!(array_sizes, nx)
    push!(throughputs, T_tot)
    println("(nx=ny=$nx) T_tot = $(T_tot)")
    CUDA.unsafe_free!(A)
    CUDA.unsafe_free!(B)
end

T_tot_max, index = findmax(throughputs)
nx = ny = array_sizes[index]
A = CUDA.zeros(Float64, nx, ny);
B = CUDA.rand(Float64, nx, ny);

@inbounds memcopy_AP!(A, B) = (A .= B)

t_it = @belapsed begin memcopy_AP!($A, $B); synchronize() end
T_tot = 2*1/1e9*nx*ny*sizeof(Float64)/t_it

@inbounds function memcopy_KP!(A, B)
    ix = (blockIdx().x-1) * blockDim().x + threadIdx().x
    iy = (blockIdx().y-1) * blockDim().y + threadIdx().y
    A[ix,iy] = B[ix,iy]
    return nothing
end

threads = (1, 1)
blocks  = (nx, ny)
t_it = @belapsed begin @cuda blocks=$blocks threads=$threads memcopy_KP!($A, $B); synchronize() end
T_tot = 2*1/1e9*nx*ny*sizeof(Float64)/t_it

threads = (32, 1)
blocks  = (nx÷threads[1], ny)
t_it = @belapsed begin @cuda blocks=$blocks threads=$threads memcopy_KP!($A, $B); synchronize() end
T_tot = 2*1/1e9*nx*ny*sizeof(Float64)/t_it

max_threads  = attribute(device(),CUDA.DEVICE_ATTRIBUTE_MAX_THREADS_PER_BLOCK)
thread_count = []
throughputs  = []
for pow = Int(log2(32)):Int(log2(max_threads))
    threads = (2^pow, 1)
    blocks  = (nx÷threads[1], ny)
    t_it = @belapsed begin @cuda blocks=$blocks threads=$threads memcopy_KP!($A, $B); synchronize() end
    T_tot = 2*1/1e9*nx*ny*sizeof(Float64)/t_it
    push!(thread_count, prod(threads))
    push!(throughputs, T_tot)
    println("(threads=$threads) T_tot = $(T_tot)")
end

thread_count = []
throughputs  = []
for pow = 0:Int(log2(max_threads/32))
    threads = (32, 2^pow)
    blocks  = (nx÷threads[1], ny÷threads[2])
    t_it = @belapsed begin @cuda blocks=$blocks threads=$threads memcopy_KP!($A, $B); synchronize() end
    T_tot = 2*1/1e9*nx*ny*sizeof(Float64)/t_it
    push!(thread_count, prod(threads))
    push!(throughputs, T_tot)
    println("(threads=$threads) T_tot = $(T_tot)")
end

@inbounds function memcopy2_KP!(A, B, C)
    ix = (blockIdx().x-1) * blockDim().x + threadIdx().x
    iy = (blockIdx().y-1) * blockDim().y + threadIdx().y
    A[ix,iy] = B[ix,iy] + C[ix,iy]
    return nothing
end

C = CUDA.rand(Float64, nx, ny);
thread_count = []
throughputs  = []
for pow = 0:Int(log2(max_threads/32))
    threads = (32, 2^pow)
    blocks  = (nx÷threads[1], ny÷threads[2])
    t_it = @belapsed begin @cuda blocks=$blocks threads=$threads memcopy2_KP!($A, $B, $C); synchronize() end
    T_tot = 3*1/1e9*nx*ny*sizeof(Float64)/t_it
    push!(thread_count, prod(threads))
    push!(throughputs, T_tot)
    println("(threads=$threads) T_tot = $(T_tot)")
end

@inbounds function memcopy_triad_KP!(A, B, C, s)
    ix = (blockIdx().x-1) * blockDim().x + threadIdx().x
    iy = (blockIdx().y-1) * blockDim().y + threadIdx().y
    A[ix,iy] = B[ix,iy] + s*C[ix,iy]
    return nothing
end

s = rand()

T_tot_max, index = findmax(throughputs)
threads = (32, thread_count[index]÷32)
blocks  = (nx÷threads[1], ny÷threads[2])
t_it = @belapsed begin @cuda blocks=$blocks threads=$threads memcopy_triad_KP!($A, $B, $C, $s); synchronize() end
T_tot = 3*1/1e9*nx*ny*sizeof(Float64)/t_it

@inbounds memcopy_triad_AP!(A, B, C, s) = (A .= B.+ s.*C)

t_it = @belapsed begin memcopy_triad_AP!($A, $B, $C, $s); synchronize() end
T_tot = 3*1/1e9*nx*ny*sizeof(Float64)/t_it

println("nx=ny=$nx; threads=$threads; blocks=$blocks")

