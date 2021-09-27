# This file was generated, do not modify it.

using Plots

@views function reaction_1D()
    # Physics
    Lx   = 10.0
    ξ    = 10.0
    Ceq  = 0.5
    ttot = 20.0
    # Numerics
    nx   = 128
    # Derived numerics
    dx   = Lx/nx
    dt   = ξ/2.0
    nt   = cld(ttot, dt)
    xc   = LinRange(dx/2, Lx-dx/2, nx)
    # Array initialisation
    C    =  rand(Float64, nx)
    Ci   =  copy(C)
    dCdt = zeros(Float64, nx)
    # Time loop
    for it = 1:nt
        #dCdt = ...
        #C    = ...
        #display(plot(xc, C, lw=2, xlims=(xc[1], xc[end]), ylims=(0.0, 1.0),
                     #xlabel="Lx", ylabel="Concentration", title="time = $(it*dt)",
                     #framestyle=:box, label="Concentration"))
    end
    #plot!(xc, Ci, lw=2, label="C initial")
    #display(plot!(xc, Ceq*ones(nx), lw=2, label="Ceq"))
    return
end

reaction_1D()

# Physics
Lx   = 10.0
D    = 1.0
ttot = 2.0
# Numerics
nx   = 12
nout = 10
# Derived numerics
dx   = Lx/nx
dt   = dx^2/D/2.1
nt   = cld(ttot, dt)
xc   = LinRange(dx/2, Lx-dx/2, nx)
# Array initialisation
C    =  rand(Float64, nx)
Ci   =  copy(C)
dCdt = zeros(Float64, nx-2)
qx   = zeros(Float64, nx-1);

# Time loop
for it = 1:nt
    qx         .= .-D.*diff(C )./dx
    dCdt       .= .-   diff(qx)./dx
    C[2:end-1] .= C[2:end-1] .+ dt.*dCdt
    # Visualisation
end

# check sizes and staggering
@show size(qx)
@show size(dCdt)
@show size(C)
@show size(C[2:end-1]);

using Plots
 plot(xc               , C   , label="Concentration", linewidth=:1.0, markershape=:circle, markersize=5, framestyle=:box)
plot!(xc[1:end-1].+dx/2, qx  , label="flux of concentration", linewidth=:1.0, markershape=:circle, markersize=5, framestyle=:box)
plot!(xc[2:end-1]      , dCdt, label="rate of change", linewidth=:1.0, markershape=:circle, markersize=5, framestyle=:box)

