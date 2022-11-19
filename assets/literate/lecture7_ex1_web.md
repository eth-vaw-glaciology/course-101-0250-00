<!--This file was generated, do not modify it.-->
## Exercise 1 - **2D thermal porous convection xPU implementation**

👉 See [Logistics](/logistics/#submission) for submission details.

The goal of this exercise is to:
- Finalise the xPU implementation of the 2D fluid diffusion solvers started in class
- Familiarise with xPU programming, `@parallel` and `@parallel_indices`
- Port your 2D thermal porous convection code to xPU implementation
- Start populating the `PorousConvection` project folder

In this exercise, you will finalise the 2D fluid diffusion solver started during lecture 7 and use the new xPU scripts as starting point to port your 2D thermal porous convection code.

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

````julia:ex1
# physics
lx,ly       = 40.0,20.0
k_ηf        = 1.0
αρgx,αρgy   = 0.0,1.0
αρg         = sqrt(αρgx^2+αρgy^2)
ΔT          = 200.0
ϕ           = 0.1
Ra          = 1000
λ_ρCp       = 1/Ra*(αρg*k_ηf*ΔT*ly/ϕ) # Ra = αρg*k_ηf*ΔT*ly/λ_ρCp/ϕ
# numerics
ny          = 63
nx          = 2*(ny+1)-1
nt          = 500
re_D        = 4π
cfl         = 1.0/sqrt(2.1)
maxiter     = 10max(nx,ny)
ϵtol        = 1e-6
nvis        = 20
ncheck      = ceil(max(nx,ny))
# [...]
# time step
dt = if it == 1
    0.1*min(dx,dy)/(αρg*ΔT*k_ηf)
else
    min(5.0*min(dx,dy)/(αρg*ΔT*k_ηf),ϕ*min(dx/maximum(abs.(qDx)), dy/maximum(abs.(qDy)))/2.1)
end
````

The code running with parameters set to 👆 should produces following output for the final stage:

![2D porous convection](../assets/literate_figures/l7_ex1_porous_convect.png)

### Task 4

Upon having verified the your code, run it with following parameters on Piz Daint, using one GPU:

````julia:ex2
Ra      = 1000
# [...]
nx,ny   = 511,1023
nt      = 4000
ϵtol    = 1e-6
nvis    = 50
ncheck  = ceil(2max(nx,ny))
````

The run may take about one to two hours so make sure to allocate sufficiently resources and time on daint. You can use a non-interactive `sbatch` submission script in such cases (see [here](https://user.cscs.ch/access/running/) for the "official" docs). _You can find a `l7_runme2D.sh` script in the [scripts](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/) folder._

Produce a final animation (as following) showing the evolution of temperature with velocity quiver and add it to a section titled `## Porous convection 2D` in the `PorousConvection` project subfolder `README`.
~~~
<center>
  <video width="80%" autoplay loop controls src="../assets/literate_figures/l7_ex1_porous_convect_final.mp4"/>
</center>
~~~

\note{You should use the existing 2D visualisation routine to produce the final animation. On Piz Daint the easiest may be to save `png` every `nvis` and further assemble them into a `gif` or `mp4`. Ideally, the final animation size does not exceeds 2-3 MB.}

### Some tips:

- Array(s) can be initialised on the CPU and then made xPU ready upon wrapping them around `Data.Array` statement (use `Array` to gather them back on CPU host).
- Visualisation happens on the CPU; all visualisation arrays can be CPU only and GPU data could be gathered for visualisation as, e.g., following `Array(T)'` or `qDx_c .= avx(Array(qDx))`.
- Boundary condition kernel to replace `T[[1,end],:] .= T[[2,end-1],:]` can be implemented and called as following:

````julia:ex3
@parallel_indices (iy) function bc_x!(A)
    A[1  ,iy] = A[2    ,iy]
    A[end,iy] = A[end-1,iy]
    return
end

@parallel (1:size(T,2)) bc_x!(T)
````

