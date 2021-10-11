<!--This file was generated, do not modify it.-->
# Nonlinear and implicit solutions

### The goal of this lecture 4 is to explore:
- Nonlinear solutions
- Steady-state and implicit iterative solutions

### Building upon:
- The diffusion equation
- Spatial discretisation: 1D and 2D
- Finite-differences and staggered grids

## Nonlinear solutions

Until now we investigated linear and transient processes using a forward Euler explicit time integration.

However many interesting application may exhibit nonlinear behaviours, e.g.,

$$\frac{∂H}{∂t}=\frac{∂}{∂x}\left(H^n\frac{∂H}{∂x}\right)~,$$

where $H$ could be the ice thickness and $n$ power-law exponent, as in depth-integrated or shallow approximation (SIA).

![SIA](../assets/literate_figures/diffusion_nl_1D_1.gif)

> So-called depth-integrated or shallow approximation equations are, e.g., the shallow ice equations or the [shallow water equations](https://en.wikipedia.org/wiki/Shallow_water_equations)

Adding nonlinearities in the explicit time integration approach discussed until now is fairly straight forward.

So let's turn the [linear 1D diffusion from lecture 2](/lecture2/#pdes_-_diffusion) into a shallow ice-like as push-up exercise.

👉 [Download the `diffusion_1D.jl` script](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/) to get you started.

We want to modify the linear 1D diffusion equation

$$\frac{∂C}{∂t}=-\frac{∂}{∂x}\left(-D\frac{∂H}{∂x}\right)~,$$

into

$$\frac{∂H}{∂t}=-\frac{∂}{∂x}\left(-D_H\frac{∂H}{∂x}\right)~,$$

where $D_H = (D_0~H)^n$, the effective diffusion coefficient, and $H$ the, e.g., ice thickness.

Starting from the linear 1D diffusion code, we need to
- change `C` to `H`
- implement the `H`-dependent diffusion coefficient
- update `dt` definition

Using the following parameters:

```julia
D0   = 5.0
n    = 5
```

💻 Let's get started 🚀

\note{Think about the staggering of the `H`-dependent effective diffusion coefficient. Since D is no longer constant, special care is needed for the time step definition `dt`.}

## Steady-state and implicit iterative solutions

Let's now discuss how to implement steady-state and implicit iterative solvers.

But why ?

- One may only be interested in the final distribution, the "steady-state"

- Strong nonlinearities may not be captured with sufficient accuracy in explicit time integration

## Steady-state

Let's assume we are interested in a steady-state reached by a time-dependent diffusive processes

$$\frac{∂C}{∂t}=D~∇^2C~,$$

for time $t→∞$ (or $∂t→∞$). This parabolic PDE then turn into an elliptic PDE as $∂C/∂t → 0$,

$$0=D~∇^2C~.$$

How to solve $0=D~∇^2C$ ?

#### Solution 1
Use a direct sparse solver approach: build a system of linear equations in the form $A~x=b$, then apply the inverse of $A$, $A^{-1}$, on $b$ to retrieve $x$, the solution vector (you may be familiar with `x = A \ b`).

#### Solution 2
Use an iterative matrix-free approach: introduce (or bring back) the transient term (from explicit time integration) $∂A/∂t$ such that $∂A/∂t=b - A~x$ and use it to iteratively reach the steady state, i.e. when $∂A/∂t→0$.

### Pros and cons (non-exhaustive)

#### Solution 1
- +unconditionally stable
- +insensitive to variation in material parameters (e.g. $D$)
- +fast for "few" degrees of freedom (dofs)
- -nonlinear growth of memory usage
- -slow or impossible to apply to large systems (many dofs)
- -complex to implement

### Pros and cons (non-exhaustive)

#### Solution 2
- +unconditionally stable for physical time (in the residual)
- +simple to implement
- +low memory usage linearly growing with problem size
- -somewhat sensitive to variation in material parameters
- -needs tuning of numerical parameters ($∂t$)
- 👉 **needs second order implementation**

### Investigating **solution 2**:
- the limitations from the "naive" first order implementation and,
- the second order implementation and its benefits.

We will first implement

$$0=D~∇^2A~,$$

which we will use as "smoother", applying it to diffuse away initial random noise distribution.

💻 Let's get started implementing the 2D Laplacian

```julia
# Laplacian 2D
using Plots

@views function laplacian2D()

    return
end

@time laplacian2D()
```

We can add the following model configuration

```julia
fact    = 1
# Physics
lx, ly  = 10, 10
D       = 1
# Numerics
nx, ny  = fact*50, fact*50
dx, dy  = lx/nx, ly/ny
niter   = 20*nx
dt      = dx^2/D/4.1
```

and
```julia
# Initial conditions
A       = ...
dAdt    = ...
A[...] .= rand(...)
```

To display the initial condition:
```julia
display(heatmap(A', aspect_ratio=1, xlims=(1,nx), ylims=(1,ny)))
```

![init_rnd](../assets/literate_figures/init_rnd.png)

Second, we can implement the time loop.

_But, is it iteration loop or time loop?_

If we were to solve a physical transient problem (parabolic PDE), this would be the physical time loop.

However, we are here interested in minimising the residual function $D~∇^2A$ (such that $∂A/∂t→0$). Thus, we are speaking about **iterations or pseudo-time (i.e. numerics)**.

This means that actually, $t$ has the meaning of $τ$, pseudo-time or numerics.

```julia
errv = [] # storage for error
# iteration loop
for it = 1:niter
   dAdt[...] .= ...
   A                     .= ...
    if it % nx == 0
        err = maximum(abs.(A)); push!(errv, err)
       # visualisation (error evol plot + heatmap(A))
    end
end
```

Hint for visualisation

```julia
p1=plot(nx:nx:it,log10.(errv), linewidth=3, markersize=4,
        markershape=:circle, framestyle=:box, legend=false,
        xlabel="iter", ylabel="log10(max(|A|))", title="iter=$it")
p2=heatmap(A', aspect_ratio=1, xlims=(1,nx), ylims=(1,ny),
           title="max(|A|)=$(round(err,sigdigits=3))")
display(plot(p1,p2, dpi=150))
```

Running the `Laplacian.jl` code with `nx, ny = 50, 50` (thus `niter = 1000`) produces the following output

![Laplacian2D](../assets/literate_figures/Laplacian2D.png)

So over 2000 iterations, the magnitude of the error ($\max(|A|)$) only dropped about 1/2 an order of magnitude.

How can we improve this ?

👉 **One needs a second order implementation**

The goal is to reach a steady-state, we seek the left-hand-side of the "numerical" parabolic equation

$$\frac{∂A}{∂t}=D~∇^2A~,$$

to vanish upon convergence, i.e., $∂A/∂t→0$. To this end, we are free to any additional terms as long as they will also tend towards 0 with iterations.

We could thus add a second order term:

$$\frac{∂^2A}{∂t^2} + α \frac{∂A}{∂t}=D~∇^2A~,$$

where $α$ is a numerical parameter to optimise.

Adding specifically this second order term makes the parabolic PDE to switch to an hyperbolic system, i.e., as for acoustic wave propagation.

Even better, we actually have now a **damped wave equation**!

_So what's exciting about it?_

The first order method, a diffusion-like process (parabolic PDE), converges really slowly because the speed at which information travels during smoothing steps is limited by the diffusive CFL, $1/dx^2$. This limitation will also make the method scale **quadratically** with numerical resolution increase.

A non-damped wave equation (hyperbolic PDE) has the advantage of information travelling at $1/dx$, and thus the method scales **linearly** with numerical resolution increase. However, it would never converge.

The second order method is actually a damped wave equation; the damping introduces a dissipative term that will make it reach a steady state.

We can now tune the damping parameter to minimise the iteration count, finding the sweet spot between slowly converging diffusion and non-dissipative waves.

> One classical reference to this method can be found in [Frankel (1950)](https://doi.org/10.2307/2002770), reported as _**the second order Richardson method**_.\
> In the coming weeks, a preprint will be available that further discuss the second-order method, also named _**pseudo-transient method**_.

💻 Let's try it out. Starting from the `Laplacian.jl` script we just made, we'll turn it into a `Laplacian_damped.jl`.

Changes include now the addition of an `order` flag, damping term, a wave-like time step definition
```julia
order   = 2
dmp     = 2.0/nx
dt      = dx/sqrt(D)/2.1
```

and the second order pseudo-physics
```julia
dAdt[2:end-1,2:end-1] .= ... *(1-dmp)*(order-1) +
A                     .= ...
```

Running the `Laplacian_damped.jl` code with `nx, ny = 50, 50` (thus `niter = 1000`) produces the following output

![Laplacian2D damped](../assets/literate_figures/Laplacian2D_damped.png)

So over 2000 iterations, the magnitude of the error ($\max(|A|)$) now dropped about 8 orders of magnitude.

This is massive improvement over the first order method for minor changes in code 🙂

Also the second order method
- only adds 1 array read (`dAdt`), and
- is fully local (no global reduction is needed)

Finally, we can verify that the second order method iteration count scales linearly with increase in numerical grid resolution.

## Implicit solutions

A couple of words about implicit, which is actually minimising all terms in the residual such that one has a "steady-state" to converge.

# Julia's Project environment

On GitHub, make sure to upload each of the exercises into a new folder specific to each week.

This folder should be a Julia project, i.e. contain a `Project.toml` file.

The `Manifest.toml` file could be kept local. An automated way of doing so is to add it as entry to a `.gitignore` file in the root of your repo.

Any question?

