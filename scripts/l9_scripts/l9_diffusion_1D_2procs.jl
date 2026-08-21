# Linear 1D diffusion with 2 fake mpi processes
using CairoMakie

@views function diffusion_1D_2procs(; do_visu=false)
    # Physics
    Cl  = 10.0   # left  C
    Cr  = 1.0    # right C
    D   = 1.0    # diffusion coeff
    nt  = 200    # number of time steps
    # Numerics
    nx  = 32     # number of local grid points
    dx  = 1.0    # cell size
    # Derived numerics
    dt  = dx^2 / D / 2.1
    # Initial condition
    CL  = Cl * ones(nx)
    CR  = Cr * ones(nx)
    C   = [CL[1:end-1]; CR[2:end]]
    Cg  = copy(C)
    # Visualisation
    if do_visu
        fig  = Figure(; fontsize=12)
        ax   = Axis(fig[1, 1]; xlabel="Lx", ylabel="C")
        pltg = scatter!(ax, Cg; markersize=10)  # global reference
        pltc = lines!(ax, C; linewidth=3)       # "MPI" result
    end
    # Time loop
    for it = 1:nt
        # Compute physics locally
        CL[2:end-1] .= CL[2:end-1] .+ dt * D * diff(diff(CL) / dx) / dx
        CR[2:end-1] .= CR[2:end-1] .+ dt * D * diff(diff(CR) / dx) / dx
        # Update boundaries (MPI)
        # CL[end] = ...
        # CR[1]   = ...
        # Global picture
        C .= [CL[1:end-1]; CR[2:end]]
        # Compute physics globally (check)
        Cg[2:end-1] .= Cg[2:end-1] .+ dt * D * diff(diff(Cg) / dx) / dx
        # Visualise
        if do_visu
            ax.title = "diffusion (it=$(it))"
            pltg[1] = Cg
            pltc[1] = C
            display(fig)
        end
    end
    return
end

diffusion_1D_2procs(; do_visu=true)
