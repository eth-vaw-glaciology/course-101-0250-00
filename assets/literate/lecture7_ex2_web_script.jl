# This file was generated, do not modify it.

# physics
lx,ly,lz    = 40.0,20.0,20.0
αρg         = 1.0
Ra          = 1000
λ_ρCp       = 1/Ra*(αρg*k_ηf*ΔT*lz/ϕ) # Ra = αρg*k_ηf*ΔT*lz/λ_ρCp/ϕ
# numerics
nz          = 63
ny          = nz
nx          = 2*(nz+1)-1
nt          = 500
cfl         = 1.0/sqrt(3.1)

dt = if it == 1
    0.1*min(dx,dy,dz)/(αρg*ΔT*k_ηf)
else
    min(5.0*min(dx,dy,dz)/(αρg*ΔT*k_ηf),ϕ*min(dx/maximum(abs.(qDx)), dy/maximum(abs.(qDy)), dz/maximum(abs.(qDz)))/3.1)
end

Ra       = 1000
# [...]
nx,ny,nz = 255,127,127
nt       = 2000
ϵtol     = 1e-6
nvis     = 50
ncheck   = ceil(2max(nx,ny,nz))

function save_array(Aname,A)
    fname = string(Aname,".bin")
    out = open(fname,"w"); write(out,A); close(out)
end

save_array("out_T",convert.(Float32,Array(T)))

using GLMakie

function load_array(Aname,A)
    fname = string(Aname,".bin")
    fid=open(fname,"r"); read!(fid,A); close(fid)
end

function visualise()
    lx,ly,lz = 40.0,20.0,20.0
    nx = 255
    ny = nz = 127
    T  = zeros(Float32,nx,ny,nz)
    load_array("out_T",T)
    xc,yc,zc = LinRange(0,lx,nx),LinRange(0,ly,ny),LinRange(0,lz,nz)
    fig      = Figure(resolution=(1600,1000),fontsize=24)
    ax       = Axis3(fig[1,1];aspect=(1,1,0.5),title="Temperature",xlabel="lx",ylabel="ly",zlabel="lz")
    surf_T   = contour!(ax,xc,yc,zc,T;alpha=0.05,colormap=:turbo)
    save("T_3D.png",fig)
    return fig
end

visualise()

