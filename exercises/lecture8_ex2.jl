md"""
## Exercise 2 — **3D thermal porous convection xPU implementation**
"""

#md # 👉 See [Logistics](/logistics/#submission) for submission details.

md"""
The goal of this exercise is to:
- Create a 3D xPU implementation of the 2D thermal porous convection code
- Familiarise with 3D and xPU programming, `@parallel` and `@parallel_indices`
- Include 3D visualisation using [`Makie.jl`](https://docs.makie.org/stable/)
"""

md"""
In this exercise, you will finalise the 3D fluid diffusion solver started during lecture 8 and use the new xPU scripts as starting point to port your 3D thermal porous convection code.
"""

md"""
For this first exercise, we will finalise and add to the `scripts` folder within the `PorousConvection` folder following scripts:
- `Pf_diffusion_3D_xpu.jl`
- `PorousConvection_3D_xpu.jl`

### Task 1

Finalise the `Pf_diffusion_3D_xpu.jl` script from class.
- This version should contain compute functions (kernels) definitions using `@parallel` approach together with using `ParallelStencil.FiniteDifferences3D` submodule.
- Include the `kwargs` `do_visu` (or `do_check`) to allow disabling plotting/error-checking when assessing performance.
- Also, make sure to include and update the performance evaluation section at the end of the script.

### Task 2

Merge the `PorousConvection_2D_xpu.jl` from Exercise 1 and the `Pf_diffusion_3D_xpu.jl` script from previous task to create a 3D single xPU `PorousConvection_3D_xpu.jl` version to run on GPUs.

Implement similar changes as you did for the 2D script in Exercise 1, preferring the `@parallel` (instead of `@parallel_indices`) whenever possible.

Make sure to use the `z`-direction as the vertical coordinate changing all relevant expressions in the code, and assume `αρg` to be the gravity acceleration acting only in the `z`-direction. Implement following domain extend and numerical resolution (ratio):
"""

## physics
lx, ly, lz = 40.0, 20.0, 20.0
αρg        = 1.0
Ra         = 1000
λ_ρCp      = 1 / Ra * (αρg * k_ηf * ΔT * lz / ϕ) # Ra = αρg*k_ηf*ΔT*lz/λ_ρCp/ϕ
## numerics
nz         = 63
ny         = nz
nx         = 2 * (nz + 1) - 1
nt         = 500
cfl        = 1.0 / sqrt(3.1)

md"""
Also, modify the physical time-step definition accordingly:
"""

dt = if it == 1
    0.1 * min(dx, dy, dz) / (αρg * ΔT * k_ηf)
else
    min(5.0 * min(dx, dy, dz) / (αρg * ΔT * k_ηf), ϕ * min(dx / maximum(abs.(qDx)), dy / maximum(abs.(qDy)), dz / maximum(abs.(qDz))) / 3.1)
end

md"""
Initial conditions for temperature can be done by analogy to the 2D case, but using the iterative approach presented in class (see [here](#towards_3d_thermal_porous_convection)).
"""

T = [ΔT * exp(-xc[ix]^2 - yc[iy]^2 - (zc[iz] + lz / 2)^2) for ix = 1:nx, iy = 1:ny, iz = 1:nz]

md"""
Make sure to have `yc` defined using extents similar to `xc` (with the center at zero), and `zc` being the vertical dimension.

For boundary conditions, apply heating from the bottom (zc=-lz) and cooling from top `zc=0` in the vertical `z`-direction. Extend the adiabatic condition for the walls to the `xz` and `yz` planes. The `yz` BC kernel could be defined and called as following:
"""

@parallel_indices (iy, iz) function bc_x!(A)
    A[1  , iy, iz] = A[2    , iy, iz]
    A[end, iy, iz] = A[end-1, iy, iz]
    return
end

@parallel (1:size(T, 2), 1:size(T, 3)) bc_x!(T)

md"""

Verify that the code runs using the above low-resolution configuration and produces sensible output. To this end, you can recycle the 2D visualisation (removing the quiver plotting) in order to visualise a 2D slice of your 3D data, e.g., at `ly/2`:
"""

## before the time loop
fig, ax, plt = heatmap(xc, zc, Array(T)[:, ceil(Int, ny / 2), :];
                       axis=(; aspect=DataAspect(), xlabel="lx", ylabel="lz", title="Temperature"),
                       colormap=:turbo)
Colorbar(fig[1, 2], plt)
io = VideoStream(fig; framerate=5) # `io` collects the frames

## within the time loop
if do_viz && (it % nvis == 0)
    plt[3] = Array(T)[:, ceil(Int, ny / 2), :]
    recordframe!(io)
end

## after the time loop
mkpath("viz3D_out")
save("viz3D_out/porous_convect_3D.mp4", io)

md"""

### Task 3

Upon having verified your code, run it with following parameters on Daint.Alps, using one GPU:
"""

Ra         = 1000
## [...]
nx, ny, nz = 255, 127, 127
nt         = 2000
ϵtol       = 1e-6
nvis       = 50
ncheck     = ceil(2max(nx, ny, nz))

md"""
The run may take about three hours so make sure to allocate sufficiently resources and time on Daint.Alps. You can use a non-interactive `sbatch` submission script in such cases (see [here](https://user.cscs.ch/access/running/) for the "official" docs). _You can find a `l8_runme3D.sh` script in the [scripts](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/) folder._

Produce a figure showing the final stage of temperature distribution and add it to a new section titled `## Porous convection 3D` in the `PorousConvection` project subfolder's `README`.

For the figure, you can use `GLMakie` to produce some isocontours visualisation; add the following binary dump function to your code
"""

function save_array(Aname,A)
    fname = string(Aname, ".bin")
    out = open(fname, "w"); write(out, A); close(out)
end

md"""
which you can call as following at the end of your simulation
"""

save_array("out_T", convert.(Float32, Array(T)))

md"""
Then, once you've created the `out_T.bin` file, read it in using the following code and produce a figure
"""

using GLMakie

function load_array(Aname, A)
    fname = string(Aname, ".bin")
    fid=open(fname, "r"); read!(fid, A); close(fid)
end

function visualise()
    lx, ly, lz = 40.0, 20.0, 20.0
    nx = 255
    ny = nz = 127
    T  = zeros(Float32, nx, ny, nz)
    load_array("out_T", T)
    xc, yc, zc = LinRange(0, lx, nx), LinRange(0, ly, ny), LinRange(0, lz, nz)
    fig = Figure(size=(800, 500))
    ax  = Axis3(fig[1, 1]; aspect=(1, 1, 0.5), title="Temperature", xlabel="lx", ylabel="ly", zlabel="lz")
    surf_T = contour!(ax, xc, yc, zc, T; alpha=0.05, colormap=:turbo)
    save("T_3D.png", fig)
    return fig
end

visualise()

md"""
This figure you can further add to your `README.md`. Note that GLMakie will probably not run on Daint.Alps as GL rendering is not enabled on the compute nodes.

For reference, the 3D figure produced could look as following

![3D porous convection](./figures/l8_ex2_porous_convect.png)

And the 2D slice at `y/2` displays as

![3D porous convection](./figures/l8_ex2_porous_convect_sl.png)
"""
