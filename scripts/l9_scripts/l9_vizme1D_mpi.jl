# Visualisation script for the 1D MPI solver
using CairoMakie, MAT

nprocs = 4

@views function vizme1D_mpi(nprocs)
    C = []
    for ip = 1:nprocs
        file = matopen("mpi1D_out_C_$(ip-1).mat")
        C_loc = read(file, "C"); close(file)
        nx_i = length(C_loc) - 2
        i1 = 1 + (ip - 1) * nx_i
        if (ip == 1) C = zeros(nprocs * nx_i) end
        C[i1:i1+nx_i-1] .= C_loc[2:end-1]
    end
    fig, ax, plt = lines(C; figure=(; fontsize=12),
                         axis=(; xlabel="nx", title="diffusion 1D MPI",
                               limits=(1, length(C), 0, 1)), linewidth=3)
    display(fig)
    return
end

vizme1D_mpi(nprocs)
