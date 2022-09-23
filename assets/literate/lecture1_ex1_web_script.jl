# This file was generated, do not modify it.

using Plots

@views function car_travel_1D()
    # Physical parameters

    # Numerical parameters

    # Array initialisation

    # Time loop

    # Visualisation

    return
end

car_travel_1D()

using Plots

@views function car_travel_1D()
    # Physical parameters
    V     =         # speed, km/h
    L     =         # length of segment, km
    ttot  =         # total time, h
    # Numerical parameters
    dt    = 0.1            # time step, h
    nt    = Int(cld(ttot, dt))  # number of time steps
    # Array initialisation
    T     =
    X     =
    # Time loop
    for it = 2:nt
        T[it] = T[it-1] + dt
        X[it] =   # move the car
        if X[it] > L
                # if beyond L, go back (left)
        elseif X[it] < 0
                # if beyond 0, go back (right)
        end
    end
    # Visualisation
    display(scatter(T, X, markersize=5,
                    xlabel="time, hrs", ylabel="distance, km",
                    framestyle=:box, legend=:none))
    return
end

car_travel_1D()

