#src # This is needed to make this run as normal Julia file
using Markdown #src

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
#nb # _Lecture 4_
md"""
# Coupled multi-physics in 2D
"""


#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## The goal of this lecture 4 is to:
- Better understand the coupling between physical processes
- Solve partial differential equations in 2D
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Converting the 1D code to higher dimensions is remarkably easy thanks to the explicit time integration.
Firstly, we introduce the domain extent and the number of grid points in the y-direction:

```julia
# physics
lx,ly   = 20.0,20.0
...
# numerics
nx,ny   = 100,100
```
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Then, we calculate the grid spacing, grid cell centers locations, and modify the time step to comply with the 2D stability criteria:

```julia
# derived numerics
dx,dy   = lx/nx,ly/ny
xc,yc   = LinRange(dx/2,lx-dx/2,nx),LinRange(dy/2,ly-dy/2,ny)
dτ      = dx/sqrt(1/ρ)/sqrt(2)
```
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
We allocate 2D arrays for concentration and fluxes:

```julia
# array initialisation
C       = @. 1.0 + exp(-(xc-lx/4)^2-(yc'-ly/4)^2) - xc/lx
qx,qy   = zeros(nx-1,ny),zeros(nx,ny-1)
```
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
and add the physics for the second dimension:

```julia
while err >= ϵtol && iter <= maxiter
    #hint=# qx                 .-= ...
    #hint=# qy                 .-= ...
    #hint=# C[2:end-1,2:end-1] .-= ...
    #sol=qx                 .-= dτ./(ρ + dτ/dc).*(qx./dc .+ diff(C,dims=1)./dx)
    #sol=qy                 .-= dτ./(ρ + dτ/dc).*(qy./dc .+ diff(C,dims=2)./dy)
    #sol=C[2:end-1,2:end-1] .-= dτ./(1 + dτ/ξ) .*((C[2:end-1,2:end-1] .- C_eq)./ξ .+ diff(qx[:,2:end-1],dims=1)./dx .+
    #sol=                                                                            diff(qy[2:end-1,:],dims=2)./dy)
    ...
end
```
"""

#nb # > 💡 note: we have to specify the direction for taking the partial derivatives: `diff(C,dims=1)./dx`, `diff(C,dims=2)./dy`
#md # \note{we have to specify the direction for taking the partial derivatives: `diff(C,dims=1)./dx`, `diff(C,dims=2)./dy`}

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Last thing to fix is the visualisation, as now we want the top-down view of the computational domain:
```julia
p1 = heatmap(xc,yc,C';xlims=(0,lx),ylims=(0,ly),clims=(0,1),aspect_ratio=1,
             xlabel="lx",ylabel="ly",title="iter/nx=$(round(iter/nx,sigdigits=3))")
```
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Let's run the simulation:
"""

#md # ~~~
# <center>
#   <video width="80%" autoplay loop controls src="./figures/l3_steady_diffusion_reaction_2D.mp4"/>
# </center>
#md # ~~~

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
#nb # ### That's it for the "intro" part on iterative approaches to solve PDEs.
#nb #
#nb # 💻 Starting next week, we will port codes for (multi-) GPUs implementations
