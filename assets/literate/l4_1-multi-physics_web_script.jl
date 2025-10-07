# This file was generated, do not modify it.

# physics
lx, ly  = 20.0, 20.0
# ...
# numerics
nx, ny  = 100, 101

# array initialisation
C       = @. 1.0 + exp(-(xc - lx / 4)^2 - (yc' - ly / 4)^2) - xc / lx
qx, qy  = zeros(nx-1, ny), zeros(nx, ny-1)

while err >= ϵtol && iter <= maxiter
    #qx                 .-= ...
    #qy                 .-= ...
    #C[2:end-1,2:end-1] .-= ...
    # ...
end

p1 = heatmap(xc, yc, C'; xlims=(0, lx), ylims=(0, ly), clims=(0, 1), aspect_ratio=1,
             xlabel="lx", ylabel="ly", title="iter/nx=$(round(iter / nx, sigdigits=3))")

# physics
lx      = 20.0
λ       = 0.001
k       = 1.0
α       = 1.0

qx         .-= dτ ./ (ρ * dc .+ dτ) .* (qx .+ dc .* diff(C) ./ dx)
C[2:end-1] .-= dτ .* diff(qx) ./ dx

qDx        .-= (qDx .+ k .* diff(P) ./ dx) ./ (θ_dτ_D + 1.0)
P[2:end-1] .-= (diff(qDx) ./ dx) ./ β_dτ_D

cfl     = 0.99
re_D    = 2π
θ_dτ_D  = lx / re_D / (cfl * dx)
β_dτ_D  = k * re_D / (cfl * dx * lx)

for it in 1:nt
    @printf("it = %d\n", it)
    iter = 1; err = 2ϵtol
    while err >= ϵtol && iter <= maxiter
        #qDx        .-= ...
        #P[2:end-1] .-= ...
        if iter % ncheck == 0
            #err = ...
            @printf("  iter = %.1f × N, err = %1.3e\n", iter / nx, err)
        end
        iter += 1
    end
    # TODO
end

# temperature
T   = @. exp(-(xc - lx/4)^2)
T_i = copy(T)
# pressure
P   = zeros(nx)
qDx = zeros(Float64, nx - 1)

dt  = min(dta, dtd)
# temperature
#T[2:end-1] .+= ...
#T[2:end-1] .-= ...
if it % nvis == 0
    # visualisation
    p1 = plot(xc, [T_i, T]; xlims=(0, lx), ylabel="Temperature", title="iter/nx=$(round(iter/nx,sigdigits=3))")
    p2 = plot(xc, P       ; xlims=(0, lx), xlabel="lx", ylabel="Pressure")
    display(plot(p1, p2; layout=(2, 1)))
end
