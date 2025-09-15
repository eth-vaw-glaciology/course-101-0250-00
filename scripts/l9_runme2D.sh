#!/bin/bash -l
#SBATCH --job-name="convect2D"
#SBATCH --output=convect2D.%j.o
#SBATCH --error=convect2D.%j.e
#SBATCH --time=03:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --partition=normal
#SBATCH --constraint=gpu
#SBATCH --account class04

srun julia --project PorousConvection_2D_xpu.jl
