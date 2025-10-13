using Plots, Plots.Measures, Printf
default(size=(1200, 800), framestyle=:box, label=false, grid=false, margin=10mm, lw=6, labelfontsize=20, tickfontsize=20, titlefontsize=24)

@views avx(A) = 0.5 .* (A[1:end-1] .+ A[2:end])

@views function double_diffusion_1D()
    # physics
    lx      = 20.0
    λ       = 0.001
    k       = 1.0
    α       = 1.0
    # numerics
    nx      = 100
    ϵtol    = 1e-8
    maxiter = 50nx
    ncheck  = ceil(Int, 0.25nx)
    nt      = 50
    nvis    = 5
    # derived numerics
    dx      = lx / nx
    xc      = LinRange(dx / 2, lx - dx / 2, nx)
    cfl     = 0.99
    # pressure PT
    re_D    = 2π
    θ_dτ_D  = lx / re_D / (cfl * dx)
    β_dτ_D  = k * re_D / (cfl * dx * lx)
    # array initialisation
    # temperature
    T       = @. exp(-(xc - lx / 4)^2)
    T_i     = copy(T)
    # pressure
    P       = zeros(nx)
    qDx     = zeros(Float64, nx - 1)
    # time loop
    for it in 1:nt
        @printf("it = %d\n", it)
        # iteration loop
        iter = 1; err = 2ϵtol
        while err >= ϵtol && iter <= maxiter
            # pressure
            qDx         .-= (qDx .+ k .* (diff(P) ./ dx .- α .* avx(T))) ./ (θ_dτ_D + 1.0)
            P[2:end-1]  .-= (diff(qDx) ./ dx) ./ β_dτ_D
            if iter % ncheck == 0
                err = maximum(abs.(diff(qDx) ./ dx))
                @printf("  iter = %.1f × N, err = %1.3e\n", iter / nx, err)
            end
            iter += 1
        end
        dta = dx / maximum(abs.(qDx)) / 1.1
        dtd = dx^2 / λ / 2.1
        dt  = min(dta, dtd)
        # temperature
        T[2:end-1] .+= dt .* diff(λ .* diff(T) ./ dx) ./ dx
        T[2:end-1] .-= dt .* (max.(qDx[1:end-1], 0.0) .* diff(T[1:end-1]) ./ dx .+
                              min.(qDx[2:end  ], 0.0) .* diff(T[2:end  ]) ./ dx)
        if it % nvis == 0
            # visualisation
            p1 = plot(xc, [T_i, T]; xlims=(0, lx), ylabel="Temperature", title="iter/nx=$(round(iter/nx,sigdigits=3))")
            p2 = plot(xc, P       ; xlims=(0, lx), xlabel="lx", ylabel="Pressure")
            display(plot(p1, p2; layout=(2, 1)))
        end
    end
end

double_diffusion_1D()
