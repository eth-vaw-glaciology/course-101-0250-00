# This file was generated, do not modify it. # hide
"""md
Report the total wealth of the client after `tot_yrs`:
"""

println("Wealth after $(tot_yrs) years with interest rate: $(M_evol2[end]) CHF")

"""md
And display the graphical evolution on top of previous one:
"""

plot!(M_evol2 ./ 1000, linewidth=3, label="with interest")