# This file was generated, do not modify it.

using ImplicitGlobalGrid
import MPI

max_g(A) = (max_l = maximum(A); MPI.Allreduce(max_l, MPI.MAX, MPI.COMM_WORLD))

nx,ny       = 2*(nz+1)-1,nz
me, dims    = init_global_grid(nx, ny, nz)  # init global grid and more
b_width     = (8,8,4)                       # for comm / comp overlap

T           = @zeros(nx  ,ny  ,nz  )
T          .= Data.Array([ΔT*exp(-(x_g(ix,dx,T)+dx/2-lx/2)^2
                                 -(y_g(iy,dy,T)+dy/2-ly/2)^2
                                 -(z_g(iz,dz,T)+dz/2-lz/2)^2) for ix=1:size(T,1),iy=1:size(T,2),iz=1:size(T,3)])
T[:,:,1].=ΔT/2; T[:,:,end].=-ΔT/2
update_halo!(T)
T_old       = copy(T)

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

@hide_communication b_width begin
    @parallel compute_Dflux!(qDx,qDy,qDz,Pf,T,k_ηf,_dx,_dy,_dz,αρg,_1_θ_dτ_D)
    update_halo!(qDx,qDy,qDz)
end

@hide_communication b_width begin
    @parallel update_T!(T,qTx,qTy,qTz,dTdt,_dx,_dy,_dz,_1_dt_β_dτ_T)
    @parallel (1:size(T,2),1:size(T,3)) bc_x!(T)
    @parallel (1:size(T,1),1:size(T,3)) bc_y!(T)
    update_halo!(T)
end

# time step
dt = if it == 1
    0.1*min(dx,dy,dz)/(αρg*ΔT*k_ηf)
else
    min(5.0*min(dx,dy,dz)/(αρg*ΔT*k_ηf),ϕ*min(dx/max_g(abs.(qDx)), dy/max_g(abs.(qDy)), dz/max_g(abs.(qDz)))/3.1)
end

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

finalize_global_grid()
return

lx,ly,lz    = 40.0,20.0,20.0
Ra          = 1000
nz          = 63
nx,ny       = 2*(nz+1)-1,nz
b_width     = (8,8,4) # for comm / comp overlap
nt          = 500
nvis        = 50

