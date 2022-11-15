md"""
## Exercise 1 - **Multi-xPU computing projects**
"""

#md # 👉 See [Logistics](/logistics/#submission) for submission details.

md"""
The goal of this exercise is to:
- Further familiarise with distributed computing
- Combine [ImplicitGlobalGrid.jl](https://github.com/eth-cscs/ImplicitGlobalGrid.jl) and [ParallelStencil.jl](https://github.com/omlins/ParallelStencil.jl)
- Learn about GPU MPI on the way
"""

md"""
In this exercise, you will:
- Create a multi-xPU version of the 3D thermal porous convection code from lecture 7
- Keep it xPU compatible using `ParallelStencil.jl`
- Deploy it on multiple xPUs using `ImplicitGlobalGrid.jl`

👉 You'll find a version of the `PorousConvection_3D_xpu.jl` code in the solutions folder on Polybox after exercises deadline if needed to get you started.

1. Copy the `PorousConvection_3D_xpu.jl` code from exercises in Lecture 7 and rename it `PorousConvection_3D_multixpu.jl`.

2. Refer to the steps outlined in the [Multi-xPU 3D thermal porous convection](#multi-xpu_3d_thermal_porous_convection) section from Lecture 9 to implement the changes needed to port the 3D single xPU code (from Lecture 7) to multi-xPU.

3. Upon completion, verify the script converges and produces expected output for following parameters:
"""

lx,ly,lz    = 40.0,20.0,20.0
Ra          = 1000
nz          = 63
nx,ny       = 2*(nz+1)-1,nz
b_width     = (8,8,4) # for comm / comp overlap
nt          = 500
nvis        = 50

md"""

Use 8 GPUs on Piz Daint adapting the `runme_mpi_daint.sh` or `sbatch sbatch_mpi_daint.sh` scripts (see [here](/software_install/#cuda-aware_mpi_on_piz_daint)) to use CUDA-aware MPI 🚀

The final 2D slice (at `ny_g()/2`) produced should look similar as the figure depicted in [Lecture 9](#benchmark_run).

### Task

Now that you made sure the code runs as expected, launch `PorousConvection_3D_multixpu.jl` for 2000 steps on 8 GPUs at higher resolution (global grid of `508x252x252`) setting:
"""
nz          = 127
nx,ny       = 2*(nz+1)-1,nz
nt          = 2000
nvis        = 100

md"""
and keeping other parameters unchanged.

Use `sbtach` command to launch a non-interactive job which may take about 5h30-6h to execute.

Produce a figure or animation showing the final stage of temperature distribution in 3D and add it to a new section titled `## Porous convection 3D MPI` in the `PorousConvection` project subfolder's `README.md`. You can use the Makie visualisation helper script from Lecture 7 for this purpose (making sure to adapt the resolution and other input params if needed).
"""

