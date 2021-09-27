# This file was generated, do not modify it. # hide
using Plots
 plot(xc               , C   , label="Concentration", linewidth=:1.0, markershape=:circle, markersize=5, framestyle=:box)
plot!(xc[1:end-1].+dx/2, qx  , label="flux of concentration", linewidth=:1.0, markershape=:circle, markersize=5, framestyle=:box)
plot!(xc[2:end-1]      , dCdt, label="rate of change", linewidth=:1.0, markershape=:circle, markersize=5, framestyle=:box)