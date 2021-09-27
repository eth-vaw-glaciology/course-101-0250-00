# This file was generated, do not modify it. # hide
# Numerics
nx   = 128
# Derived numerics
dx   = Lx/nx
dt   = ξ/2.0
nt   = cld(ttot, dt)
xc   = LinRange(dx/2, Lx-dx/2, nx)