# This file was generated, do not modify it.

# Numerics
nx, ny  = 512, 512
nt      = 2e4
# array initialisation
C       = rand(Float64, nx, ny)
C2      = copy(C)
A       = copy(C)

if bench == :loop
    # iteration loop
    t_tic = 0.0
    for iter=1:nt
      ...
    end
    t_toc = Base.time() - t_tic
elseif bench == :btool
    t_toc = @belapsed ...
end

nx = ny = 16 * 2 .^ (1:8)

