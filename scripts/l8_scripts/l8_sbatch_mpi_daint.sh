#!/bin/bash -l
#SBATCH --job-name="diff2D"
#SBATCH --output=diff2D.%j.o
#SBATCH --error=diff2D.%j.e
#SBATCH --time=00:05:00
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=1
#SBATCH --partition=normal
#SBATCH --constraint=gpu
#SBATCH --account class04

export MPICH_RDMA_ENABLED_CUDA=0
export IGG_CUDAAWARE_MPI=0

srun -n4 bash -c 'julia --project diffusion_2D_perf_multixpu.jl'
