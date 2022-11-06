# Linear 1D diffusion with 2 fake mpi processes
using Plots

@views function diffusion_1D_2procs(; do_visu=false)
    # Physics
    Cl  = 10.0   # left  H
    Cr  = 1.0    # right H
    D   = 1.0    # diffusion coeff
    nt  = 200    # number of time steps
    # Numerics
    nx  = 32     # number of local grid points
    dx  = 1.0    # cell size
    # Derived numerics
    dt  = dx^2/D/2.1
    # Initial condition
    CL  = Cl*ones(nx)
    CR  = Cr*ones(nx)
    C   = [CL[1:end-1]; CR[2:end]]
    Cg  = copy(C)
    # Time loop
    for it = 1:nt
        # Compute physics locally
        CL[2:end-1] .= CL[2:end-1] .+ dt*D*diff(diff(CL)/dx)/dx
        CR[2:end-1] .= CR[2:end-1] .+ dt*D*diff(diff(CR)/dx)/dx
        # Update boundaries (MPI)
        # CL[end] = ...
        # CR[1]   = ...
        # Global picture
        C .= [CL[1:end-1]; CR[2:end]]
        # Compute physics globally (check)
        Cg[2:end-1] .= Cg[2:end-1] .+ dt*D*diff(diff(Cg)/dx)/dx
        # Visualise
        if do_visu
            fontsize = 12
            plot(Cg, legend=false, linewidth=0, markershape=:circle, markersize=5, yaxis=font(fontsize, "Courier"), xaxis=font(fontsize, "Courier"), titlefontsize=fontsize, titlefont="Courier")
            display(plot!(C, legend=false, linewidth=3, framestyle=:box, xlabel="Lx", ylabel="H", title="diffusion (it=$(it))"))
        end
    end
    return
end

diffusion_1D_2procs(; do_visu=true)
