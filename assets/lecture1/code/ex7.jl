# This file was generated, do not modify it. # hide
using Plots
plot(M_evol1 ./ 1000, linewidth=3,
     xlabel="time, yrs", ylabel="savings, kchf", label="without interest",
     framestyle=:box, legend=:topleft, foreground_color_legend = nothing)