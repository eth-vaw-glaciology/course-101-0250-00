<!--This file was generated, do not modify it.-->
## Exercise 2 — **Using Makie.jl for visualisation**

👉 See [Logistics](/logistics/#submission) for submission details.

The goals of this exercise are to:

- learn visualisation techniques in scientific computing;
- use Makie.jl to visualise the 2D simulation.

Create a script `implicit_advection_diffusion_makie_2D.jl` for this exercise and add it to the `homework-4` folder in your private GitHub repository. Summarise your results in a new section of the `README`.

### Getting started

1. Duplicate the `implicit_advection_diffusion_2D.jl` code you created in Exercise 1 and rename it to `implicit_advection_diffusion_makie_2D.jl`.
2. Remove all visualisation that uses Plots.jl.
3. Recreate the animation from Exercise 1 with Makie.jl, and add an [**arrow (quiver) plot**](https://docs.makie.org/stable/reference/plots/arrows#arrows) to visualise the flux vector field.

Create the figure, two axes, a heatmap, a quiver plot, and a line plot with markers before the time loop:

```julia
# time loop
fig = Figure(size=(400, 650))
ax1 = Axis(...)
ax2 = Axis(...)
hm  = heatmap!(ax1, ...)
cb  = Colorbar(...)
ar  = arrows2d!(ax1, ...)
plt = scatterlines!(ax2, Float64[], Float64[])
record(fig, "heatmap_arrows.mp4"; fps=20) do io
    for it = 1:nt
        # ...
        # visualisation
        # update plots here
        recordframe!(io)
    end
end

```

In an arrow plot, showing one arrow per grid point would result in too much visual noise.
Show an arrow to every 10th cell in x and y directions.

#### Hints

- Use the `colormap` and `colorrange` attributes to configure the heatmap.
- To update plot data, index into the plot’s arguments.
  For example, for a heatmap created with `hm = heatmap!(ax, x, y, z)`, update the field with
  `hm[3] = z_new`. Here, `hm[1]` and `hm[2]` correspond to the `x` and `y` data, respectively.
- To get every nth value of a 2D array, use syntax `Q[1:n:end, 1:n:end]`. Same applies to 1D and 3D arrays.

\note{Make sure to update the flux array initialisation and include the flux in the y-direction `qy` and use now 2D arrays: `qx,qy = zeros(nx-1,??), zeros(??,ny-1)`.}

### Task 1

Make a short animation showing the time evolution of the concentration field `C` during `nt = 100` physical time steps. The numerical algorithm should be the same as in Exercise 1.

The figure should contain 2 subplots, the first displaying the `heatmap` of the `C` field with the "roma" colormap, and the quiver plot showing magnitude and direction of the flux vector `q`. The second subplot should show the evolution of the iteration count normalised by `nx`.
In the time loop, only update the existing plot, don't create new figure every time step.

You should get an animation like this:

~~~
<center>
  <video width="50%" autoplay loop controls src="../assets/literate_figures/l4_heatmap_arrows.mp4"/>
</center>
~~~

