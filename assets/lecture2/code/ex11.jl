# This file was generated, do not modify it. # hide
using Plots
 plot(xc               , C   , legend=false, linewidth=:1.0, markershape=:circle, markersize=5, framestyle=:box)
plot!(xc[1:end-1].+dx/2, qx  , legend=false, linewidth=:1.0, markershape=:circle, markersize=5, framestyle=:box)
plot!(xc[2:end-1]      , dCdt, legend=false, linewidth=:1.0, markershape=:circle, markersize=5, framestyle=:box)