# This file was generated, do not modify it. # hide
# Time loop
for it = 1:nt
    qx         .= .-D.*diff(C)./dx
    dCdt       .= .-diff(qx)./dx
    C[2:end-1] .= C[2:end-1] .+ dt.*dCdt
    # Visualisation
end