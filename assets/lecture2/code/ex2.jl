# This file was generated, do not modify it. # hide
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