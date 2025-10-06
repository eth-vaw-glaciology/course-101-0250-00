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
- Learn the difference between different time integration schemes in the PT method
- Better understand the coupling between physical processes
- Solve partial differential equations in 2D
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## Explicit vs semi-implicit fluxes

In Lecture 3, you learned how to solve elliptic PDEs using the **pseudo-transient (PT) method** by augmenting the definition of the diffusion flux with a pseudo-time derivative:

$$
\rho\frac{\partial q}{\partial t} + \frac{q}{D} = -\frac{\partial C}{\partial x}~.
$$

When discretising the first term on the left-hand side, we use first-order finite differences to approximate the pseudo-time derivative:

$$
\rho\frac{\partial q}{\partial t} \approx \rho\frac{q^{n+1} - q^n}{\Delta\tau}~.
$$

For the second term, $q/D$, there are two possible choices:

1. Use the flux from the **current** pseudo-time layer $n$;
2. Use the flux from the **next** pseudo-time layer $n+1$.

In the first case, we use an **explicit** flux discretization; in the second case, we use a *semi-implicit* discretization.

In Lecture 3, we used the explicit discretization of fluxes.
Let’s now implement the semi-implicit version!

1. 👉 Use your script for the 1D steady diffusion problem from the previous lecture, or start from [this script](TODO);
2. Create a new file called `steady_diffusion_implicit_flux_1d.jl` for this exercise;
3. Think about how to compute the flux when using $q^{n+1}/D$ in the flux update rule, and implement the semi-implicit scheme.

This script should produce the **same final result** as the explicit version. So why bother with another scheme?

👉 Modify the definition of the pseudo-time step. Replace this line:

```julia
dτ      = dx / sqrt(1 / ρ) / 1.1
```

with

```julia
dτ      = dx / sqrt(1 / ρ)
```

Observe how the PT iterations **converge** in the semi-implicit case with the _theoretically maximal_ pseudo-time step, while the explicit flux discretization **diverges**.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## Going 2D

Converting the 1D code to higher dimensions is remarkably easy thanks to the explicit time integration scheme.
First, we define the domain size and the number of grid points in the y-direction:

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
Next, we compute the grid spacing, the coordinates of grid cell centers, and update the pseudo-time step to satisfy the 2D stability criterion:

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
We now allocate 2D arrays for the concentration field and the fluxes:

```julia
# array initialisation
C       = @. 1.0 + exp(-(xc-lx/4)^2-(yc'-ly/4)^2) - xc/lx
qx,qy   = zeros(nx-1,ny),zeros(nx,ny-1)
```
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Finally, we add the update rules for the second dimension:

```julia
while err >= ϵtol && iter <= maxiter
    # qx                 .-= ...
    # qy                 .-= ...
    # C[2:end-1,2:end-1] .-= ...
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
#   <video width="80%" autoplay loop controls src="../assets/literate_figures/l3_steady_diffusion_reaction_2D.mp4"/>
# </center>
#md # ~~~

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## Coupled systems of PDEs

You’ve learned how to solve second-order partial differential equations with a single independent variable — nice work!

Now, let’s take a step further and look at a slightly more advanced example with two independent variables. This is a small but important move toward real-world applications.

Here's the system of equations:

\begin{align*}
q & = -k\left(\frac{\partial P}{\partial x} - \alpha T \right)~, \\[10pt]
\frac{\partial q}{\partial x} &= 0~, \\[10pt]
\frac{\partial T}{\partial t} + q \frac{\partial T}{\partial x} &= \frac{\partial}{\partial x}\left(\lambda \frac{\partial T}{\partial x}\right)
\end{align*}
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
#nb # > 💡 note: Even though the system contains three equations, we still consider it a system with two independent variables, since the flux $q$ can be eliminated. It’s written explicitly here only for better readability.
#md # \note{Even though the system contains three equations, we still consider it a system with two independent variables, since the flux $q$ can be eliminated. It’s written explicitly here only for better readability.}


#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
In this system, the two main variables are $P$ and $T$, which we interpret as the **pressure** and **temperature** of a fluid:

1. The flux $q$ is defined so that the fluid flows from regions of higher pressure to lower pressure.
2. The flow is enhanced by temperature perturbations — hotter fluid is more buoyant.
3. The temperature changes due to thermal conduction, but heat is also transported by the moving fluid.
"""


#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
#nb # ### That's it for the "intro" part on iterative approaches to solve PDEs.
#nb #
#nb # 💻 Starting next week, we will port codes for (multi-) GPUs implementations


