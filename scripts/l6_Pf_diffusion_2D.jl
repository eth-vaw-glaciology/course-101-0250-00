using CairoMakie, Printf

function Pf_diffusion_2D()
    # physics
    lx, ly = 20.0, 20.0
    k_ηf   = 1.0
    # numerics
    nx, ny  = 127, 127
    ϵtol    = 1e-8
    maxiter = 10max(nx, ny)
    ncheck  = ceil(Int, 0.25max(nx, ny))
    cfl     = 1.0 / sqrt(2.1)
    re      = 2π
    # derived numerics
    dx, dy  = lx / nx, ly / ny
    xc, yc  = LinRange(dx / 2, lx - dx / 2, nx), LinRange(dy / 2, ly - dy / 2, ny)
    θ_dτ    = max(lx, ly) / re / cfl / min(dx, dy)
    β_dτ    = (re * k_ηf) / (cfl * min(dx, dy) * max(lx, ly))
    # array initialisation
    Pf      = @. exp(-(xc - lx / 2)^2 - (yc' - ly / 2)^2)
    qDx     = zeros(Float64, nx + 1, ny)
    qDy     = zeros(Float64, nx, ny + 1)
    r_Pf    = zeros(nx, ny)
    # iteration loop
    fig, ax, plt = heatmap(xc, yc, Array(Pf);
                           figure=(; size=(600, 500)),
                           axis=(; aspect=DataAspect(), xlabel="x", ylabel="y", title="Pf"),
                           colormap=:turbo)
    Colorbar(fig[1, 2], plt)
    iter = 1; err_Pf = 2ϵtol
    while err_Pf >= ϵtol && iter <= maxiter
        qDx[2:end-1, :] .-= (qDx[2:end-1, :] .+ k_ηf .* (diff(Pf, dims=1) ./ dx)) ./ (1.0 + θ_dτ)
        qDy[:, 2:end-1] .-= (qDy[:, 2:end-1] .+ k_ηf .* (diff(Pf, dims=2) ./ dy)) ./ (1.0 + θ_dτ)
        Pf              .-= (diff(qDx, dims=1) ./ dx .+ diff(qDy, dims=2) ./ dy) ./ β_dτ
        if iter % ncheck == 0
            r_Pf .= diff(qDx, dims=1) ./ dx .+ diff(qDy, dims=2) ./ dy
            err_Pf = maximum(abs.(r_Pf))
            @printf("  iter/nx=%.1f, err_Pf=%1.3e\n", iter / nx, err_Pf)
            plt[3] = Array(Pf)
            display(fig)
        end
        iter += 1
    end
    return
end

Pf_diffusion_2D()
