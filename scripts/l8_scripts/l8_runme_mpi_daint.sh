#!/bin/bash -l

module load daint-gpu
module load Julia/1.7.2-CrayGNU-21.09-cuda

export MPICH_RDMA_ENABLED_CUDA=1
export IGG_CUDAAWARE_MPI=1

LD_PRELOAD="/usr/lib64/libcuda.so:/usr/local/cuda/lib64/libcudart.so" julia -O3 --check-bounds=no diffusion_2D_perf_multixpu.jl
