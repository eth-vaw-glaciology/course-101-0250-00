# This file was generated, do not modify it.

using CairoMakie

plot(1:3)  # a scatter plot, for a line use `line`
A = rand(50, 50);
#try heatmap

f = Figure()
scatter(f[1, 1], rand(100, 2))
lines(f[1, 2], cumsum(randn(100)))

ax = Axis(f[2, 1]; xlabel="x", ylabel="y", title="subplot")
lines!(ax, cumsum(randn(20)); label="line", linewidth=3, color=:red)
scatter!(ax, cumsum(randn(20)); label="scatter", marker=:cross, markersize=rand(5:20, 20))
axislegend(ax)

f = Figure()
ax = Axis(f[1, 1][1, 1]; aspect=DataAspect())
hm = heatmap!(ax, rand(10, 10))
cb = Colorbar(f[1, 1][1, 2], hm)

record(f, "anim.mp4"; fps=30) do io
    for i = 1:100
        hm[1] = rand(10,10) # simple way to update the plot in-place
        recordframe!(io)
    end
end

for i = 1:10
    hm[1] = rand(10,10) # simple way to update the plot in-place
    display(f)
end
