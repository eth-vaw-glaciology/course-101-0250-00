# Visualisation script for the 2D MPI solver
using CairoMakie, MAT

nprocs = (2, 2) # nprocs (x, y) dim

@views function vizme2D_mpi(nprocs)
    C = []; ip = 1
    for ipx = 1:nprocs[1]
        for ipy = 1:nprocs[2]
            file = matopen("mpi2D_out_C_$(ip-1).mat")
            C_loc = read(file, "C"); close(file)
            nx_i, ny_i = size(C_loc, 1) - 2, size(C_loc, 2) - 2
            ix1, iy1 = 1 + (ipx - 1) * nx_i, 1 + (ipy - 1) * ny_i
            if (ip == 1) C = zeros(nprocs[1] * nx_i, nprocs[2] * ny_i) end
            C[ix1:ix1+nx_i-1, iy1:iy1+ny_i-1] .= C_loc[2:end-1, 2:end-1]
            ip += 1
        end
    end
    fig, ax, plt = heatmap(C; figure=(; fontsize=12),
                           axis=(; aspect=DataAspect(), xlabel="Lx", ylabel="Ly",
                                 title="diffusion 2D MPI"), colormap=:turbo)
    hidedecorations!(ax; label=false)
    Colorbar(fig[1, 2], plt)
    display(fig)
    return
end

vizme2D_mpi(nprocs)
