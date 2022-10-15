#src # This is needed to make this run as normal Julia file
using Markdown #src

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
#nb # _Lecture 3_
md"""
# Solving elliptic PDEs
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### The goal of this lecture 3 is to familiarise (or refresh) with:
- The damped wave equation
- Spectral analysis of linear PDEs
- Pseudo-transient method for solving elliptic PDEs
- Spatial discretisation: 1D and 2D
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
In the previous lecture, we established that the solution to the elliptic PDE could be obtained through integrating in time a corresponding parabolic PDE:

$$
\frac{\partial C}{\partial t} - \frac{\partial^2 C}{\partial x^2} = 0
$$
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
and discussed the limitations of this approach for numerical modelling, i.e., the quadratic dependence of the number of time steps on the number of grid points in spatial discretisation.
"""

#md # ~~~
# <center>
#   <video width="80%" autoplay loop controls src="../assets/literate_figures/l2_diffusion_1D_steady_state.mp4"/>
# </center>
#md # ~~~


#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## Accelerating elliptic solver convergence: intuition

In this lecture, we'll improve the convergence rate of the elliptic solver, and consider the generalisation to higher dimensions
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Let's recall the stability conditions for diffusion and acoustic wave propagation:

```julia
dt = dx^2/dc/2      # diffusion
dt = dx/sqrt(1/β/ρ) # acoustic wave propagation
```
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
We can see that the acceptable time step for an acoustic problem is proportional to the grid spacing `dx`, and not `dx^2` as for the diffusion.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
The number of time steps required for the wave to propagate through the domain is only proportional to the number of grid points `nx`.
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Can we use that information to reduce the time required for the elliptic solver to converge?
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
In the solution to the wave equation, the waves do not attenuate with time: _there is no steady state!_
"""

#md # ~~~
# <center>
#   <video width="80%" autoplay loop controls src="../assets/literate_figures/l2_acoustic_1D.mp4"/>
# </center>
#md # ~~~

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### Damped wave equation

Let's add diffusive properties to the wave equation by simply combining the physics:

\begin{align}
\rho\frac{\partial V_x}{\partial t}                 &= -\frac{\partial P}{\partial x} \\[10pt]
\beta\frac{\partial P}{\partial t} + \frac{P}{\eta} &= -\frac{\partial V_x}{\partial x}
\end{align}
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Note the addition of the new term $\frac{P}{\eta}$ to the left-hand side of the mass balance equation, which could be interpreted physically as accounting for the bulk viscosity of the gas.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Equvalently, we could add the time derivative to the diffusion equation

\begin{align}
\rho\frac{\partial q}{\partial t} + \frac{q}{D} &= -\frac{\partial C}{\partial x} \\[10pt]
\frac{\partial C}{\partial t}                   &= -\frac{\partial q}{\partial x}
\end{align}
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
In that case, the new term would be $\rho\frac{\partial q}{\partial t}$, which could be interpreted physically as adding the inertia to the momentum equation for diffusive flux.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
#nb # > 💡 note: In 1D, both modifications are equivalent up to renaming the variables. The conceptual difference is that in the former case we add new terms to the vector quantity (diffusive flux $q$), and in the latter case we modify the equation governing the evolution of the scalar quantity (pressure $P$).
#md # \note{In 1D, both modifications are equivalent up to renaming the variables. The conceptual difference is that in the former case we add new terms to the vector quantity (diffusive flux $q$), and in the latter case we modify the equation governing the evolution of the scalar quantity (pressure $P$).}

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Let's eliminate $V_x$ and $q$ in both systems to get one governing equation for $P$ and $C$, respectively:
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
\begin{align}
\beta\frac{\partial^2 P}{\partial t^2} + \frac{1}{\eta}\frac{\partial P}{\partial t} &= \frac{1}{\rho}\frac{\partial^2 P}{\partial x^2} \\[10pt]
\rho\frac{\partial^2 C}{\partial t^2} + \frac{1}{D}\frac{\partial C}{\partial t}     &= \frac{\partial^2 C}{\partial x^2}
\end{align}
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
We refer to such equations as the _damped wave equations_. They combine wave propagation with diffusion, which manifests as wave attenuation, or decay. The damped wave equation is a hyperbolic PDE.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### Implementing the damped wave equation

In the following, we'll use the damped wave equation for concentration $C$ obtained by augmenting the diffusion equation with density $\rho$.
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Starting from the existing code implementing time-dependent diffusion, let's add the intertial term $\rho\frac{\partial q}{\partial t}$.

👉 You can use the [`l2_diffusion_1D.jl` script](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/) as starting point.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
First step is to add the new physical parameter $\rho$ to the `# physics` section:

```julia
# physics
...
ρ   = 20.0
```
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Then we increase the number of time steps and reduce the frequency of plotting, and modify the initial conditions to have more interesting time evolution:

```julia
# numerics
nvis = 50
...
# derived numerics
...
nt   = nx^2 ÷ 5
...
# array initialisation
C    = @. 1.0 + exp(-(xc-lx/4)^2) - xc/lx; C_i = copy(C)
```
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Then we modify the time loop to incorporate the new physics:

```julia
for it = 1:nt
    qx         .-= dt./(ρ*dc + dt).*(qx + dc.*diff(C)./dx)
    C[2:end-1] .-= dt.*diff(qx)./dx
    ...
end
```
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
👉 Your turn. Try to add the inertial term.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
> **Hint**: There are two ways of adding the inertial term into the update rule.
> - We could either take the known flux `q` in `q/dc` from the previous time step (explicit time integration), or the unknown flux from the next time step (implicit time integration).
> - Could we treat the flux implicitly without having to solve the linear system?
> - What are the benefits of the implicit time integration compared to the explicit one?
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
If the implementation is correct, we should see something like this:
"""

#md # ~~~
# <center>
#   <video width="80%" autoplay loop controls src="../assets/literate_figures/l3_damped_diffusion_1D.mp4"/>
# </center>
#md # ~~~

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
The waves decay, now there is a steady state! 🎉 The time it takes to converge, however, doesn't seem to improve...
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Now we solve the hyperbolic PDE, and with the implicit flux term treatment, the time step should become proportional to the grid spacing `dx` instead of `dx^2`.

Looking at the damped wave equation for $C$, and recalling the stability condition for wave propagation, we modify the time step, reduce the total number of time steps, and increase the frequency of plotting calls:

```julia
# numerics
...
nvis = 5
# derived numerics
...
dt   = dx/sqrt(1/ρ)
nt   = 5nx
```
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Re-run the simulation and see the results:
"""

#md # ~~~
# <center>
#   <video width="80%" autoplay loop controls src="../assets/literate_figures/l3_damped_diffusion_better_1D.mp4"/>
# </center>
#md # ~~~

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Now, this is much better! We observe that in less time steps, we get a much faster convergence. However, we introduced the new parameter, $\rho$. Does the solution depend on the value of $\rho$?
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## Problem of finding the iteration parameters

👉 Try changing the new parameter `ρ`, increasing and decreasing it. What happens to the solution?
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
We notice that depending on the value of the parameter `ρ`, the convergence to steady-state can be faster or slower. If `ρ` is too small, the process becomes diffusion-dominated, and we're back to the non-accelerated version. If `ρ` is too large, waves decay slowly.
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
If the parameter `ρ` has optimal value, the convergence to steady-state could be achieved in the number of time steps proportional to the number of grid points `nx` and not `nx^2` as for the parabolic PDE.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
For linear PDEs it is possible to determine the optimal value for `ρ` analytically:
```julia
ρ    = (lx/(dc*2π))^2
```
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
How does one derive the optimal values for other problems and boundary conditions?
Unfortunately, we don't have time to dive into details in this course...

The idea of accelerating the convergence by increasing the order of PDE dates back to the work by [Frankel (1950)](https://doi.org/10.2307/2002770) where he studied the convergence rates of different iterative methods. Frankel noted the analogy between the iteration process and transient physics. In his work, the accelerated method was called the _second-order Richardson method_

👀 If interested, [Räss et al. (2022)](https://gmd.copernicus.org/articles/15/5757/2022/) paper is a good starting point.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## Pseudo-transient method

In this course, we call any method that builds upon the analogy to the transient physics the _pseudo-transient_ method.
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Using this analogy proves useful when studying multi-physics and nonlinear processes. The pseudo-transient method isn't restricted to solving the Poisson problems, but can be applied to a wide range of problems that are modelled with PDEs.
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
In a pseudo-transient method, we are interested only in a steady-state distributions of the unknown field variables such as concentration, temperature, etc.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
We consider time steps as iterations in a numerical method. Therefore, we replace the time $t$ in the equations with _pseudo-time_ $\tau$, and a time step `it` with iteration counter `iter`. When a pseudo-transient method converges, all the pseudo-time derivatives $\partial/\partial\tau$, $\partial^2/\partial\tau^2$ etc., vanish.
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
#nb # > ⚠️ Warning: We should be careful when introducing the new pseudo-physical terms into the governing equations. We need to make sure that when iterations converge, i.e., if the pseudo-time derivatives are set to 0, the system of equations is identical to the original steady-state formulation.
#md # \warn{We should be careful when introducing the new pseudo-physical terms into the governing equations. We need to make sure that when iterations converge, i.e., if the pseudo-time derivatives are set to 0, the system of equations is identical to the original steady-state formulation.}

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
For example, consider the damped acoustic problem that we introduced in the beginning:

\begin{align}
\rho\frac{\partial V_x}{\partial\tau}                 &= -\frac{\partial P}{\partial x} \\[10pt]
\beta\frac{\partial P}{\partial\tau} + \frac{P}{\eta} &= -\frac{\partial V_x}{\partial x}
\end{align}
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
At the steady-state, the second equation reads:

$$
\frac{P}{\eta} = -\frac{\partial V_x}{\partial x}
$$

The velocity divergence is proportional to the pressure. If we wanted to solve the incompressible problem (i.e. the velocity divergence = 0), and were interested in the velocity distribution, this approach would lead to incorrect results. If we only want to solve the Laplace problem $\partial^2 P/\partial x^2 = 0$, we could consider $V_x$ purely as a numerical variable.
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
In other words: only add those new terms to the governing equations that vanish when the iterations converge!
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### Visualising convergence

Let's modify the code structure of the new elliptic solver. We need to monitor convergence and stop iterations when the error has reached predefined tolerance.
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
To define the measure of error, we introduce the residual:

$$
r_C = D\frac{\partial^2 \widehat{C}}{\partial x^2}
$$

where $\widehat{C}$ is the pseudo-transient solution
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
There are many ways to define the error as the norm of the residual, the most popular ones are the $L_2$ norm and $L_\infty$ norm. We will use the $L_\infty$ norm here:

$$
\|\boldsymbol{r}\|_\infty = \max_i(|r_i|)
$$
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Add new parameters to the `# numerics` section of the code:

```julia
# numerics
nx      = 200
ϵtol    = 1e-8
maxiter = 20nx
ncheck  = ceil(Int,0.25nx)
```

Here `ϵtol` is the tolerance for the pseudo-transient iterations, `maxiter` is the maximal number of iterations, that we use now instead of number of time steps `nt`, and `ncheck` is the frequency of evaluating the residual and the norm of the residual, which is a costly operation.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
We turn the time loop into the iteration loop, add the arrays to store the evolution of the error:

```julia
# iteration loop
iter = 1; err = 2ϵtol; iter_evo = Float64[]; err_evo = Float64[]
while err >= ϵtol && iter <= maxiter
    qx         .-= ...
    C[2:end-1] .-= ...
    if iter % ncheck == 0
        err = maximum(abs.(diff(dc.*diff(C)./dx)./dx))
        push!(iter_evo,iter/nx); push!(err_evo,err)
        p1 = plot(xc,[C_i,C];xlims=(0,lx),ylims=(-0.1,2.0),
                  xlabel="lx",ylabel="Concentration",title="iter/nx=$(round(iter/nx,sigdigits=3))")
        p2 = plot(iter_evo,err_evo;xlabel="iter/nx",ylabel="err",
                  yscale=:log10,grid=true,markershape=:circle,markersize=10)
        display(plot(p1,p2;layout=(2,1)))
    end
    iter += 1
end
```
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Note that we save the number of iteration per grid cell `iter/nx`
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
If the value of pseudo-transient parameter `ρ` is optimal, the number of iterations required for convergence should be proportional to `nx`, thus the `iter/nx` should be approximately constant.

👉 Try to check that by changing the resolution `nx`.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
![steady-diffusion](../assets/literate_figures/l3_steady_diffusion.png)
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## Multi-physics: steady diffusion-reaction

Let's implement our first pseudo-transient multi-physics solver by adding chemical reaction:

$$
D\frac{\partial^2 C}{\partial x^2} = \frac{C - C_{eq}}{\xi}
$$

As you might remember from the exercises, characteristic time scales of diffusion and reaction can be related through the non-dimensional Damköhler number $\mathrm{Da}=l_x^2/D/\xi$.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
👉 Let's add the new physical parameters and modify the iteration loop:

```julia
# physics
...
C_eq    = 0.1
da      = 10.0
ξ       = lx^2/dc/da
...
# iteration loop
iter = 1; err = 2ϵtol; iter_evo = Float64[]; err_evo = Float64[]
while err >= ϵtol && iter <= maxiter
    ...
    C[2:end-1] .-= dτ./(1 + dτ/ξ) .*((C[2:end-1] .- C_eq)./ξ .+ diff(qx)./dx)
    ...
end
```
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
> **Hint**: don't forget to modify the residual!
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Run the simulation and see the results:
![steady-diffusion-reaction](../assets/literate_figures/l3_steady_diffusion_reaction.png)
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
As a final touch, let's refactor the code and extract the magical constant `2π` from the definition of numerical density `ρ`:

```julia
re      = 2π
ρ       = (lx/(dc*re))^2
```

We call this new parameter `re` due to it's association to the non-dimensional [Reynolds number](https://en.wikipedia.org/wiki/Reynolds_number) relating intertial and dissipative forces into the momentum balance.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Interestingly, the convergence rate of the diffusion-reaction systems could be improved significantly by modifying `re` to depend on the previously defined Damköhler number `da`:

```julia
re      = π + sqrt(π^2 + da)
```
👉 Verify that the number of iterations is indeed lower for the higher values of the Damköhler number.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## Going 2D

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
    qx                 .-= dτ./(ρ + dτ/dc).*(qx./dc .+ diff(C,dims=1)./dx)
    qy                 .-= dτ./(ρ + dτ/dc).*(qy./dc .+ diff(C,dims=2)./dy)
    C[2:end-1,2:end-1] .-= dτ./(1 + dτ/ξ) .*((C[2:end-1,2:end-1] .- C_eq)./ξ .+ diff(qx[:,2:end-1],dims=1)./dx .+
                                                                                diff(qy[2:end-1,:],dims=2)./dy)
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
## Wrapping-up

- Switching from parabolic to hyperbolic PDE allows to approach the steady-state in number of iterations, proportional to the number of grid points
- Pseudo-transient (PT) method is the matrix-free iterative method to solve elliptic (and other) PDEs by utilising the analogy to transient physics
- Using the optimal iteration parameters is essential to ensure the fast convergence of the PT method
- Extending the codes to 2D and 3D is straightforward with explicit time integration
"""

