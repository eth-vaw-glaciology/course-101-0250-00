#src # This is needed to make this run as normal Julia file
using Markdown #src

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
#nb # _Lecture 4_
md"""
# Julia plots with Makie.jl
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Until now, we used Plots.jl for visualisation.

The cool thing about Plots.jl is how simple it is to plot something.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
For more control and advanced graphics there is Makie.jl.

The docs are [here](https://docs.makie.org/stable/).
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Like Plots.jl, Makie.jl supports multiple backends, e.g.:

- GLMakie.jl for hardware-accelerated graphics, supports most features;
- CairoMakie.jl for headless systems and publication ready vector graphics;
- WGLMakie.jl for interactive graphics on the web.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## Basic usage

For basic usage, Makie.jl offers a simple high-level API:
"""

using CairoMakie

plot(1:3)  # a scatter plot, for a line use `line`
A = rand(50, 50);
#try heatmap

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## Advanced usage

For more control, you can create and manipulate figures, axes, plots etc. as separate objects.
"""

f = Figure()
scatter(f[1, 1], rand(100, 2))
lines(f[1, 2], cumsum(randn(100)))

ax = Axis(f[2, 1]; xlabel="x", ylabel="y", title="subplot")
lines!(ax, cumsum(randn(20)); label="line", linewidth=3, color=:red)
scatter!(ax, cumsum(randn(20)); label="scatter", marker=:cross, markersize=rand(5:20, 20))
axislegend(ax)


