# This file was generated, do not modify it.

using Plots

@views function orbital()
    # Physics
    G    = 1.0
    # TODO - add physics input
    tt   = 6.0
    # Numerics
    dt   = 0.05
    # Initial conditions
    xpos = ??
    ypos = ??
    # TODO - add further initial conditions
    # Time loop
    for it = 1:nt
        # TODO - Add physics equations
        # Visualisation
        display(scatter!([xpos], [ypos], title="$it",
                         aspect_ratio=1, markersize=5, markercolor=:blue, framestyle=:box,
                         legend=:none, xlims=(-1.1, 1.1), ylims=(-1.1, 1.1)))
    end
    return
end

orbital()

