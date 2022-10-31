md"""
## Exercise 1 - **2D thermal porous convection xPU implementation**
"""

#md # 👉 See [Logistics](/logistics/#submission) for submission details.

md"""
The goal of this exercise is to:
- Finalise the xPU implementation of the 2D fluid diffusion solvers started in class
- Familiarise with xPU programming, `@parallel` and `@parallel_indices`
- Port your 2D thermal porous convection code to xPU implementation
- Start populating the `PorousConvection` project folder
"""

md"""
In this exercise, you will finalise the 2D fluid diffusion solver started during lecture 7 and use the new xPU scripts as starting point to port your 2D thermal porous convection code.
"""

md"""
For this first exercise, we will finalise and add to the `scripts` folder within the `PorousConvection` folder following scripts:
- `Pf_diffusion_2D_xpu.jl`
- `Pf_diffusion_2D_perf_xpu.jl`
- `PorousConvection_2D_xpu.jl`

### Task 1

Finalise the `Pf_diffusion_2D_xpu.jl` script from class.
- This version should contain compute functions (kernels) definitions using `@parallel` approach together with using `ParallelStencil.FiniteDifferences2D` submodule.
- Include the kwarg `do_visu` (or `do_check`) to allow disabling plotting/error-checking when assessing performance.
- Also, make sure to include and update the performance evaluation section at the end of the script.

### Task 2

Finalise the `Pf_diffusion_2D_perf_xpu.jl` script from class.
- This version should contain compute functions (kernels) definitions using `@parallel_indices` approach.
- You can use macros for the derivative definition.
- Include the kwarg `do_visu` (or `do_check`) to allow disabling plotting/error-checking when assessing performance.
- Also, make sure to include and update the performance evaluation section at the end of the script.

### Task 3

Starting from the `porous_convection_implicit_2D.jl` from Lecture 4, create a xPU version to run on GPUs. Copy and rename the `porous_convection_implicit_2D.jl` script to `PorousConvection_2D_xpu.jl` (if you do not have a working 2D implicit thermal porous convection, fetch a copy in the `solutions` folder on the shared Polybox).

Implement similar changes as you did in the previous 2 tasks, preferring the `@parallel` (instead of `@parallel_indices`) whenever possible.

Make sure to use following physical and numerical parameters and compare the xPU (CPU and GPU using ParallelStencil) implementations versus the reference code from lecture 4 using the following (slightly updated) parameters:
"""

## physics
lx,ly       = 40.0,20.0
k_ηf        = 1.0
αρgx,αρgy   = 0.0,1.0
αρg         = sqrt(αρgx^2+αρgy^2)
ΔT          = 200.0
ϕ           = 0.1
Ra          = 1000
λ_ρCp       = 1/Ra*(αρg*k_ηf*ΔT*ly/ϕ) # Ra = αρg*k_ηf*ΔT*ly/λ_ρCp/ϕ
## numerics
ny          = 63
nx          = 2*(ny+1)-1
nt          = 500
re_D        = 4π
cfl         = 1.0/sqrt(2.1)
maxiter     = 10max(nx,ny)
ϵtol        = 1e-6
nvis        = 20
ncheck      = ceil(max(nx,ny))
## [...]
## time step
dt = if it == 1 
    0.1*min(dx,dy)/(αρg*ΔT*k_ηf)
else
    min(5.0*min(dx,dy)/(αρg*ΔT*k_ηf),ϕ*min(dx/maximum(abs.(qDx)), dy/maximum(abs.(qDy)))/2.1)
end

md"""
The code should produces the same output (as following), 

![2D porous convection](../assets/literate_figures/l7_ex1_porous_convect.png)

### Task 4

Upon having verified the your code, run it with higher resolution on Piz Daint, using one GPU.

🚧 final details to come


### Some tips:

- Array(s) can be initialised on the CPU and then made xPU ready upon wrapping them around `Data.Array` statement.
- Visualisation happens on the CPU; all visualisation arrays can be CPU only and GPU data could be gathered for visualisation as, e.g., following `qDx_c .= avx(Array(qDx))`.
- Boundary condition kernel to replace `T[[1,end],:] .= T[[2,end-1],:]` can be implemented and called as following:
"""

@parallel_indices (iy) function bc_x!(A)
    A[1  ,iy] = A[2    ,iy]
    A[end,iy] = A[end-1,iy]
    return
end

@parallel (1:size(T,2)) bc_x!(T)


