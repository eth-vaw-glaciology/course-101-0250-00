# This file was generated, do not modify it.

using Plots

function car_travel_1D()
    # Physical parameters
    V     = 113.0          # speed, km/h
    L     = 200.0          # length of segment, km
    dir   = 1              # switch 1 = go right, -1 = go left
    ttot  = 16.0           # total time, h
    # Numerical parameters
    dt    = 0.1            # time step, h
    nt    = Int(cld(ttot, dt))  # number of time steps
    # Array initialisation
    T     = zeros(nt)
    X     = zeros(nt)
    # Time loop
    for it = 2:nt
        T[it] = T[it-1] + dt
        X[it] = X[it-1] + dir*V*dt  # move the car
        if X[it] > L
            dir = -1      # if beyond L, go back (left)
        elseif X[it] < 0
            dir = 1       # if beyond 0, go back (right)
        end
    end
    # Visualisation
    # display(scatter(T, X, markersize=5, xlabel="time, hrs", ylabel="distance, km", framestyle=:box, legend=:none))
    return T, X
end

T, X = car_travel_1D()

