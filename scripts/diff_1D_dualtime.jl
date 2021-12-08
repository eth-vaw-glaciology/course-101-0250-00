using Printf, LinearAlgebra, Plots

@views inn(A) = A[2:end-1]

@views function diffusion_1D(;steady=false)
    # Physics
    lx    = 10.0             # domain size
    D     = 1.0              # diffusion coefficient
    ttot  = 1.0              # total simulation time
    dt    = 0.2              # physical time step
    # Numerics
    nx    = 128
    tol   = 1e-8             # tolerance
    itMax = 1e5              # max number of iterations
    nout  = 10               # tol check
    # Derived numerics    
    dx    = lx/nx            # cell sizes
    dtau  = (1.0/(dx^2/D/2.1) + 1.0/dt)^-1 # iterative timestep
    xc    = LinRange(dx/2, lx-dx/2, nx)
    # Array allocation
    qHx   = zeros(nx-1)
    dHdt  = zeros(nx-2)
    ResH  = zeros(nx-2)
    # Initial condition
    H0    = 2.0 .* exp.(.-(xc .- 0.5*lx).^2)
    Hold  = ones(nx).*H0
    H     = ones(nx).*H0
    t = 0.0; it = 0; ittot = 0
    if !steady
        println("Running with dual-time")
        damp  = 1-29/nx          # damping (this is a tuning parameter, dependent on e.g. grid resolution)
        # Physical time loop
        while t<ttot
            iter = 0; err = 2*tol
            # Pseudo-transient iteration
            while err>tol && iter<itMax
                qHx        .= .- D.*diff(H)./dx
                ResH       .= .- (inn(H) .- inn(Hold))./dt .- diff(qHx)./dx
                # ResH     .=                              .- diff(qHx)./dx
                dHdt       .= ResH   .+ damp .* dHdt
                H[2:end-1] .= inn(H) .+ dtau .* dHdt
                iter += 1; if (iter % nout == 0)  err = norm(ResH)/sqrt(length(nx))  end
            end
            ittot += iter; it += 1; t += dt
            Hold .= H
            if isnan(err) error("NaN") end
        end
    else
        println("Running in pseudo-time to steady-state")
        damp  = 1-4/nx          # damping (this is a tuning parameter, dependent on e.g. grid resolution)
        H[1]  = 1.0
        # Pseudo-transient iteration
        iter = 0; err = 2*tol
        while err>tol && iter<itMax
            qHx        .= .- D.*diff(H)./dx
            ResH       .=                              .- diff(qHx)./dx
            # ResH     .= .- (inn(H) .- inn(Hold))./dt .- diff(qHx)./dx
            dHdt       .= ResH   .+ damp .* dHdt
            H[2:end-1] .= inn(H) .+ dtau .* dHdt
            iter += 1; if (iter % nout == 0)  err = norm(ResH)/sqrt(length(nx))  end
        end
        ittot += iter; it += 1
        if isnan(err) error("NaN") end
    end
    @printf("Total time = %1.2f, time steps = %d, nx = %d, iterations tot = %d \n", round(ttot, sigdigits=3), it, nx, ittot)
    # Visualise
    plot(xc, H0, linewidth=3, label="H initial")
    display(plot!(xc, H, linewidth=3, label="H final", framestyle=:box, xlims=extrema(xc), ylims=extrema(H0), xlabel="lx", ylabel="H", title="linear diffusion (nt=$it, iters=$ittot)"))
    return
end

diffusion_1D(;steady=false)
