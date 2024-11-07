#!/bin/bash -l
#SBATCH --job-name="convect3D"
#SBATCH --output=convect3D.%j.o
#SBATCH --error=convect3D.%j.e
#SBATCH --time=03:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --partition=normal
#SBATCH --constraint=gpu
#SBATCH --account class04

srun julia --project PorousConvection_3D_xpu.jl
