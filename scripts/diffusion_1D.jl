using Plots,Plots.Measures,Printf
default(size=(1200,400),framestyle=:box,label=false,grid=false,margin=10mm,lw=6,labelfontsize=20,tickfontsize=20,titlefontsize=24)

@views function diffusion_1D()
    # physics
    lx   = 20.0
    dc   = 1.0
    # numerics
    nx   = 200
    nvis = 2
    # derived numerics
    dx   = lx/nx
    dt   = dx^2/dc/2
    nt   = nx^2 ÷ 100
    xc   = LinRange(dx/2,lx-dx/2,nx)
    # array initialisation
    C    = @. 0.5cos(9π*xc/lx)+0.5; C_i = copy(C)
    qx   = zeros(Float64, nx-1)
    # time loop
    for it = 1:nt
        qx          .= .-dc.*diff(C )./dx
        C[2:end-1] .-=   dt.*diff(qx)./dx
        if it%nvis == 0
            display( plot(xc,[C_i,C];xlims=(0,lx), ylims=(-0.1,1.1),
                          xlabel="lx", ylabel="Concentration",
                          title="time = $(round(it*dt,digits=1))") )
        end
    end
end

diffusion_1D()
