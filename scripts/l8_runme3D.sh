#!/bin/bash -l
#SBATCH --account class04
#SBATCH --job-name="convect3D"
#SBATCH --output=convect3D.%j.o
#SBATCH --error=convect3D.%j.e
#SBATCH --time=03:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --gpus-per-task=1

srun --uenv julia/25.5:v1 --view=juliaup julia --project PorousConvection_3D_xpu.jl
