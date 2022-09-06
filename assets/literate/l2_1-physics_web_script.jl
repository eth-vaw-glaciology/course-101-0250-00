# This file was generated, do not modify it.

# physics
lx   = 20.0
dc   = 1.0
# numerics
nx   = 200
nvis = 5
# derived numerics
dx   = lx/nx
dt   = dx^2/dc/2
nt   = nx^2 ÷ 100
xc   = LinRange(dx/2,lx-dx/2,nx)
# array initialisation
C    = @. sin(10π*xc/lx); C_i = copy(C)
qx   = zeros(Float64, nx) # won't work

# Time loop
for it = 1:nt
    #q x         .= # add solution
    #C[2:end-1] .-= # add solution
    # Visualisation
end

# check sizes and staggering
@show size(qx)
@show size(C)
@show size(C[2:end-1])

using Plots
 plot(xc               , C   , label="Concentration", linewidth=:1.0, markershape=:circle, markersize=5, framestyle=:box)
plot!(xc[1:end-1].+dx/2, qx  , label="flux of concentration", linewidth=:1.0, markershape=:circle, markersize=5, framestyle=:box)

