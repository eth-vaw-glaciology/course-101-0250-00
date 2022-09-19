using Plots,Plots.Measures,Printf
default(size=(1200,400),framestyle=:box,label=false,grid=false,margin=10mm,lw=6,labelfontsize=20,tickfontsize=20,titlefontsize=24)

@views function acoustic_1D()
    # physics
    lx   = 20.0
    ρ,β  = 1.0,1.0
    # numerics
    nx   = 200
    nvis = 2
    # derived numerics
    dx   = lx/nx
    dt   = dx/sqrt(1/ρ/β)
    nt   = 2nx
    xc   = LinRange(dx/2,lx-dx/2,nx)
    # array initialisation
    Pr   = @. exp(-(xc-lx/4)^2); Pr_i = copy(Pr)
    Vx   = zeros(Float64, nx-1)
    # time loop
    ispath("anim")&&rm("anim",recursive=true);mkdir("anim");iframe = -1
    for it = 1:nt
        Vx          .-= dt./ρ.*diff(Pr)./dx
        Pr[2:end-1] .-= dt./β.*diff(Vx)./dx
        ((it%nvis) == 0) && display(
        plot(xc,[Pr_i,Pr];xlims=(0,lx), ylims=(-1.1,1.1),
                          xlabel="lx", ylabel="Pressure",
                          title="time = $(round(it*dt,digits=1))")
        )
    end
end

acoustic_1D()
