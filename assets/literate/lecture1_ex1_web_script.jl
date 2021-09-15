# This file was generated, do not modify it.

M_init  = 20000.0   # initial wealth
M_save  = 500.0;    # yearly savings

tot_yrs = 35;       # number of years

M_evol1 = zeros(tot_yrs)
length(M_evol1)

M_evol1[1] = M_init;

for it=2:tot_yrs
    M_evol1[it] =  M_evol1[it-1] + M_save
end

println("Wealth after $(tot_yrs) years: $(M_evol1[end]) CHF")

using Plots
plot(M_evol1 ./ 1000, linewidth=3,
     xlabel="time, yrs", ylabel="savings, kchf", label="without interest",
     framestyle=:box, legend=:topleft, foreground_color_legend = nothing)

intrst     = 0.006     # fixed interest rate
M_evol2    = zeros(tot_yrs)
M_evol2[1] = M_init;

# TO DO: add correct formula !
for it=2:tot_yrs
    M_evol2[it] = M_evol2[it-1] + M_save
end


"""md
Report the total wealth of the client after `tot_yrs`:
"""

println("Wealth after $(tot_yrs) years with interest rate: $(M_evol2[end]) CHF")

"""md
And display the graphical evolution on top of previous one:
"""

plot!(M_evol2 ./ 1000, linewidth=3, label="with interest")

∆evo = M_evol2[end] - M_evol1[end]
println("∆evo = $(round(∆evo, sigdigits=5))")

