# This file was generated, do not modify it.

# Physics
Lx, Ly  = 10.0, 10.0
D       = 1.0
ttot    = 1.0
# Numerics
nx, ny  = 126, 126
nout    = 20

# Physics
Lx, Ly  = 10.0, 10.0
D       = 1.0
ttot    = 1e0
# Numerics
nx, ny  = 64, 64 # number of grid points
nout    = 20
# Derived numerics
me, dims = init_global_grid(nx, ny, 1)  # Initialization of MPI and more...

 nx = ny = 16 * 2 .^ (1:10)

@hide_communication (2,2)
@hide_communication (16,4)
@hide_communication (16,16)

