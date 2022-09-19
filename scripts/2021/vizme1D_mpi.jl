# Visualisation script for the 1D MPI solver
using Plots, MAT

nprocs = 4

@views function vizme1D_mpi(nprocs)
    C = []
    for ip = 1:nprocs
        file = matopen("mpi1D_out_C_$(ip-1).mat"); C_loc = read(file, "C"); close(file)
        nx_i = length(C_loc)-2
        i1   = 1 + (ip-1)*nx_i
        if (ip==1)  C = zeros(nprocs*nx_i)  end
        C[i1:i1+nx_i-1] .= C_loc[2:end-1]
    end
    fontsize = 12
    display(plot(C, legend=false, framestyle=:box, linewidth=3, xlims=(1, length(C)), ylims=(0, 1), xlabel="nx", title="diffusion 1D MPI", yaxis=font(fontsize, "Courier"), xaxis=font(fontsize, "Courier"), titlefontsize=fontsize, titlefont="Courier"))
    return
end

vizme1D_mpi(nprocs)
