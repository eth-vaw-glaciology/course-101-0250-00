#!/bin/bash -l

export MPICH_RDMA_ENABLED_CUDA=0
export IGG_CUDAAWARE_MPI=0

julia --project diffusion_2D_perf_multixpu.jl
