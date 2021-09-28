# This file was generated, do not modify it. # hide
# Time loop
for it = 1:nt
    #qx         .= # add solution
    #dCdt       .= # add solution
    C[2:end-1] .= C[2:end-1] .+ dt.*dCdt
    # Visualisation
end