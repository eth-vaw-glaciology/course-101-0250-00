<!--This file was generated, do not modify it.-->
## Exercise 1 - **Multi-xPU computing projects**

👉 See [Logistics](/logistics/#submission) for submission details.

The goal of this exercise is to:
- Further familiarise with distributed computing
- Combine [ImplicitGlobalGrid.jl](https://github.com/eth-cscs/ImplicitGlobalGrid.jl) and [ParallelStencil.jl](https://github.com/omlins/ParallelStencil.jl)
- Learn about GPU MPI on the way

\warn{Code from this exercise 2 has to be uploaded to the `scripts` folder within your `PorousConvection` project.}

In this exercise, you will:
- Create a multi-xPU version of your thermal porous convection 3D xPU code you finalised in lecture 7
- Keep it xPU compatible using `ParallelStencil.jl`
- Deploy it on multiple xPUs using `ImplicitGlobalGrid.jl`

👉 You'll find a version of the `PorousConvection_3D_xpu.jl` code in the solutions folder on Polybox after exercises deadline if needed to get you started.

1. Copy your working `PorousConvection_3D_xpu.jl` code developed for the exercises in Lecture 7 and rename it `PorousConvection_3D_multixpu.jl`.

2. Add at the beginning of the code

````julia:ex1
using ImplicitGlobalGrid,MPI
````

3. Also add global maximum computation using MPI

````julia:ex2
max_g(A) = (max_l = maximum(A); MPI.Allreduce(max_l, MPI.MAX, MPI.COMM_WORLD))
````

4. In the `# numerics` section, initialise the global grid right after defining `nx,ny,nz` and use now global grid `nx_g()`,`ny_g()` and `nz_g()` for defining `maxiter` and `ncheck`, as well as in any other places when needed.

````julia:ex3
nx,ny       = 2*(nz+1)-1,nz
me, dims    = init_global_grid(nx, ny, nz)  # init global grid and more
b_width     = (8,8,4)                       # for comm / comp overlap
````

5. Modify the temperature initialisation using ImplicitGlobalGrid's global coordinate helpers (`x_g`, etc...), including one internal boundary condition update (update halo):

````julia:ex4
T           = @zeros(nx  ,ny  ,nz  )
T          .= Data.Array([ΔT*exp(-(x_g(ix,dx,T)+dx/2-lx/2)^2 -(y_g(iy,dy,T)+dy/2-ly/2)^2 -(z_g(iz,dz,T)+dz/2-lz/2)^2) for ix=1:size(T,1),iy=1:size(T,2),iz=1:size(T,3)])
T[:,:,1].=ΔT/2; T[:,:,end].=-ΔT/2
update_halo!(T)
T_old       = copy(T)
````

6. Prepare for visualisation, making sure only `me==0` creates the output directory. Also, prepare an array for storing inner points only (no halo) `T_inn` as well as global array to gather subdomains `T_v`

````julia:ex5
if do_viz
    ENV["GKSwstype"]="nul"
    if (me==0) if isdir("viz3Dmpi_out")==false mkdir("viz3Dmpi_out") end; loadpath="viz3Dmpi_out/"; anim=Animation(loadpath,String[]); println("Animation directory: $(anim.dir)") end
    nx_v,ny_v,nz_v = (nx-2)*dims[1],(ny-2)*dims[2],(nz-2)*dims[3]
    if (nx_v*ny_v*nz_v*sizeof(Data.Number) > 0.8*Sys.free_memory()) error("Not enough memory for visualization.") end
    T_v   = zeros(nx_v, ny_v, nz_v) # global array for visu
    T_inn = zeros(nx-2, ny-2, nz-2) # no halo local array for visu
    xi_g,zi_g = LinRange(-lx/2+dx+dx/2, lx/2-dx-dx/2, nx_v), LinRange(-lz+dz+dz/2, -dz-dz/2, nz_v) # inner points only
    iframe = 0
end
````

7. Use the `max_g` function in the timestep `dt` definition (instead of `maximum`) as one now needs to gather the global maximum among all MPI processes.

8. Moving to the time loop, add halo update function `update_halo!` after the kernel that computes the fluid fluxes. You can additionally wrap it in the `@hide_communication` block to enable communication/computation overlap (using `b_width` defined above)

````julia:ex6
@hide_communication b_width begin
    @parallel compute_Dflux!(qDx,qDy,qDz,Pf,T,k_ηf,_dx,_dy,_dz,αρg,_1_θ_dτ_D)
    update_halo!(qDx,qDy,qDz)
end
````

9. Apply a similar step to the temperature update, where you can also include boundary condition computation as following (⚠️ no other construct is currently allowed)

````julia:ex7
@hide_communication b_width begin
    @parallel update_T!(T,qTx,qTy,qTz,dTdt,_dx,_dy,_dz,_1_dt_β_dτ_T)
    @parallel (1:size(T,2),1:size(T,3)) bc_x!(T)
    @parallel (1:size(T,1),1:size(T,3)) bc_y!(T)
    update_halo!(T)
end
````

10. Use now the `max_g` function instead of `maximum` to collect the global maximum among all local arrays spanning all MPI processes.

````julia:ex8
# time step
dt = if it == 1
    0.1*min(dx,dy,dz)/(αρg*ΔT*k_ηf)
else
    min(5.0*min(dx,dy,dz)/(αρg*ΔT*k_ηf),ϕ*min(dx/max_g(abs.(qDx)), dy/max_g(abs.(qDy)), dz/max_g(abs.(qDz)))/3.1)
end
````

11. Make sure all printing statements are only executed by `me==0` in order to avoid each MPI process to print to screen, and use `nx_g()` instead of local `nx` in the printed statements when assessing the iteration per number of grid points.

12. Update the visualisation and output saving part

````julia:ex9
# visualisation
if do_viz && (it % nvis == 0)
    T_inn .= Array(T)[2:end-1,2:end-1,2:end-1]; gather!(T_inn, T_v)
    if me==0
        p1=heatmap(xi_g,zi_g,T_v[:,ceil(Int,ny_g()/2),:]';xlims=(xi_g[1],xi_g[end]),ylims=(zi_g[1],zi_g[end]),aspect_ratio=1,c=:turbo)
        # display(p1)
        png(p1,@sprintf("viz3Dmpi_out/%04d.png",iframe+=1))
        save_array(@sprintf("viz3Dmpi_out/out_T_%04d",iframe),convert.(Float32,T_v))
    end
end
````

13. Finalise the global grid before returning from the main function

````julia:ex10
finalize_global_grid()
return
````

If you made it up to here, you should now be able to launch your `PorousConvection_3D_multixpu.jl` code on multiple GPUs. Let's give it a try 🔥

Make sure to have set following parameters

````julia:ex11
lx,ly,lz    = 40.0,20.0,20.0
Ra          = 1000
nz          = 63
nx,ny       = 2*(nz+1)-1,nz
b_width     = (8,8,4) # for comm / comp overlap
nt          = 500
nvis        = 50
````

Then, launch the script on Piz Daint on 8 GPU nodes upon adapting the the `runme_mpi_daint.sh` or `sbatch sbatch_mpi_daint.sh` scripts (see [here](/software_install/#cuda-aware_mpi_on_piz_daint)) using CUDA-aware MPI 🚀

The final 2D slice (at `ny_g()/2`) produced should look as following and take about 25min to run:

![3D porous convection MPI](../assets/literate_figures/l9_ex2_porous_convect_mpi_sl.png)

### Task

Now that you made sure the code runs as expected, launch `PorousConvection_3D_multixpu.jl` for 2000 steps on 8 GPUs at higher resolution (global grid of `508x252x252`) setting:

````julia:ex12
nz          = 127
nx,ny       = 2*(nz+1)-1,nz
nt          = 4000
nvis        = 100
````

and keeping other parameters unchanged.

Use `sbtach` command to launch a non-interactive job which may take about 5h30 hours to execute.

Produce a figure or animation showing the final stage of temperature distribution in 3D and add it to a new section titled `## Porous convection 3D MPI` in the `PorousConvection` project subfolder's `README.md`. You can use the Makie visualisation helper script from Lecture 7 for this purpose.

