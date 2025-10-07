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
- Solve partial differential equations in 2D
- Better understand the coupling between physical processes
- Plot advanced graphics with Makie.jl
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

For the second term in (1), $q/D$, there are two possible choices:

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
lx, ly  = 20.0, 20.0
...
# numerics
nx, ny  = 100, 100
```
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Next, we compute the grid spacing, the coordinates of grid cell centers, and update the pseudo-time step to satisfy the 2D stability criterion:

```julia
# derived numerics
dx, dy  = lx / nx, ly / ny
xc, yc  = LinRange(dx / 2, lx - dx / 2, nx), LinRange(dy / 2, ly - dy / 2, ny)
dτ      = dx / sqrt(1 / ρ) / sqrt(2)
```
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
We now allocate 2D arrays for the concentration field and the fluxes:

```julia
# array initialisation
C       = @. 1.0 + exp(-(xc - lx / 4)^2 - (yc' - ly / 4)^2) - xc / lx
qx, qy  = zeros(nx-1, ny), zeros(nx, ny-1)
```
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Finally, we add the update rules for the second dimension:

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

#nb # > 💡 note: We have to specify the direction for taking the partial derivatives: `diff(C,dims=1)./dx`, `diff(C,dims=2)./dy`
#md # \note{We have to specify the direction for taking the partial derivatives: `diff(C,dims=1)./dx`, `diff(C,dims=2)./dy`}

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Last thing to fix is the visualisation, as now we want the top-down view of the computational domain:
```julia
p1 = heatmap(xc, yc, C'; xlims=(0, lx), ylims=(0, ly), clims=(0, 1), aspect_ratio=1,
             xlabel="lx", ylabel="ly", title="iter/nx=$(round(iter / nx, sigdigits=3))")
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
md"""
## Coupled systems of PDEs

You’ve learned how to solve second-order partial differential equations with a single independent variable — nice work!

Now, let’s take a step further and look at a slightly more advanced example with two independent variables.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
This is a small but important move toward real-world applications.

Here's the system of equations:

\begin{align*}
q & = -k\left(\frac{\partial P}{\partial x} - \alpha T \right)~, \\[10pt]
\frac{\partial q}{\partial x} &= 0~, \\[10pt]
\frac{\partial T}{\partial t} + q \frac{\partial T}{\partial x} &= \frac{\partial}{\partial x}\left(\lambda \frac{\partial T}{\partial x}\right)~.
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
md"""
👉 If we ignore coupling terms, what PDE types are the equations for $P$ and $T$?
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
We’ll use an **operator splitting** approach, similar to [Exercise 2 from Lecture 3](/lecture3/#exercise_2_operator_splitting_for_advection-diffusion).

- **Step 1:** Solve the elliptic equation for pressure $P$, assuming the temperature $T$ remains fixed.
- **Step 2:** Update $T$ using the flux $q$ computed in Step 1.
"""


#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
👉 Start from making a copy of your own 1D steady diffusion script or use
[this one](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/l3_steady_diffusion_1D.jl)

Rename the file to `double_diffusion_1D.jl`, and the main functoin to `double_diffusion_1D()` accordingly.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
First, rename variables `C` and `qx` to `P` and `qDx`, respectively. Rename the diffusion coefficient `dc` to `k`.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Add new physical parameters:

```julia
# physics
lx      = 20.0
λ       = 0.001
k       = 1.0
α       = 1.0
```
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Next, we will streamline a bit the PT parameters (it will be helpful in the next lecture).
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Rename and replace the PT parameters:

```julia
qx         .-= dτ ./ (ρ * dc .+ dτ) .* (qx .+ dc .* diff(C) ./ dx)
C[2:end-1] .-= dτ .* diff(qx) ./ dx
```
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
with

```julia
qDx        .-= (qDx .+ k .* diff(P) ./ dx) ./ (θ_dτ_D + 1.0)
P[2:end-1] .-= (diff(qDx) ./ dx) ./ β_dτ_D
```
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Use the following definitions for the new parameters in the `# derived numerics` section:

```julia
cfl     = 0.99
re_D    = 2π
θ_dτ_D  = lx / re_D / (cfl * dx)
β_dτ_D  = k * re_D / (cfl * dx * lx)
```
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
#nb # > 💡 note: Verify that these definitions are indeed equivalent to the previous ones.
#md # \note{Verify that these definitions are indeed equivalent to the previous ones.}

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""

Implement the physical time stepping. Add the number of time steps and visualisation frequency into `# numerics` section of the script:

```julia
...
ncheck  = ceil(Int, 0.25nx)
nt      = 50
nvis    = 5
```
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Remove the arrays storing the error evolution history, and wrap the iterative PT loop with the physical time loop:

```julia
for it in 1:nt
    @printf("it = %d\n", it)
    iter = 1; err = 2ϵtol
    while err >= ϵtol && iter <= maxiter
        #hint=# qDx        .-= ...
        #sol=qDx         .-= (qDx .+ k .* diff(P) ./ dx) ./ (θ_dτ_D + 1.0)
        #hint=# P[2:end-1] .-= ...
        #sol=P[2:end-1]  .-= (diff(qDx) ./ dx) ./ β_dτ_D
        if iter % ncheck == 0
            hint=# err = ...
            #sol=err = maximum(abs.(diff(qDx) ./ dx))
            @printf("  iter = %.1f × N, err = %1.3e\n", iter / nx, err)
        end
        iter += 1
    end
    # TODO
end
```
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Add temperature arrays; keep pressure and fluid flux zero:

```julia
# temperature
T   = @. exp(-(xc + lx/4)^2)
T_i = copy(T)
# pressure
P   = zeros(nx)
qDx = zeros(Float64, nx - 1)
```
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
After the iterative loop for the pressure: 

- Add the computation of the stable time step
- Implement diffusion and advection of temperature as two separate substeps:
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
```julia
#sol=dta = dx / maximum(abs.(qDx)) / 1.1
#sol=dtd = dx^2 / λ / 2.1
dt  = min(dta, dtd)
# temperature
#sol=T[2:end-1] .+= dt .* diff(λ .* diff(T) ./ dx) ./ dx
#sol=T[2:end-1] .-= dt .* (max.(qDx[1:end-1], 0.0) .* diff(T[1:end-1]) ./ dx .+
#sol=                      min.(qDx[2:end  ], 0.0) .* diff(T[2:end  ]) ./ dx)
#hint=# T[2:end-1] .+= ...
#hint=# T[2:end-1] .-= ...
if it % nvis == 0
    # visualisation
    p1 = plot(xc, [T_i, T]; xlims=(0, lx), ylabel="Temperature", title="iter/nx=$(round(iter/nx,sigdigits=3))")
    p2 = plot(xc, P       ; xlims=(0, lx), xlabel="lx", ylabel="Pressure")
    display(plot(p1, p2; layout=(2, 1)))
end
```
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Finally, add the coupling between the fluid flux `qDx` and the temperature `T` in the form of the term $\alpha T$. Run the script.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Can you explain what you see?
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
#nb # ### That's it for the "intro" part on iterative approaches to solve PDEs.
#nb #
#nb # 💻 Starting next week, we will port codes for (multi-) GPUs implementations
