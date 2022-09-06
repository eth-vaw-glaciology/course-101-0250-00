<!--This file was generated, do not modify it.-->
# PDEs and physical processes --- diffusion, wave propagation, advection

### The goal of this lecture 2 is to familiarise (or refresh) with
- Ordinary differential equations - ODEs (e.g. reaction equation)
- Partial differential equations - PDEs (e.g. diffusion and advection equations)

- Finite-difference discretisation
- Explicit solutions
- Multi-process (physics) coupling

> A **partial differential equation (PDE)** is an equation which imposes relations between the various partial derivatives of a multivariable function. [_Wikipedia_](https://en.wikipedia.org/wiki/Partial_differential_equation)

> _**Note on classification of PDEs:**_
> - **Elliptic:**\
>   $∇^2 u - b = 0$ (e.g. steady state diffusion, Laplacian)
> - **Parabolic:**\
>   $∂u/∂t - α ∇^2 u - b = 0$ (e.g. transient heat diffusion)
> - **Hyperbolic:**\
>   $∂^2u/∂t^2 - c^2 ∇^2 u = 0$ (e.g. wave equation)

## PDEs - diffusion

![diffusion](../assets/literate_figures/diffusion1.gif)

The [diffusion equation](https://en.wikipedia.org/wiki/Diffusion_equation) was introduced by Fourier in 1822 to understand heat distribution ([heat equation](https://en.wikipedia.org/wiki/Heat_equation)) in various materials.

Diffusive processes were also employed by Fick in 1855 with application to chemical and particle diffusion ([Fick's law](https://en.wikipedia.org/wiki/Fick%27s_laws_of_diffusion)).

The diffusion equation is often reported as a second order parabolic PDE, here for a multivariable function $C(x,t)$ showing derivatives in both temporal $∂t$ and spatial $∂x$ derivatives (here for the 1D case)

$$
\frac{∂C}{∂t} = D\frac{∂^2 C}{∂ x^2}~,
$$

where $D$ is the diffusion coefficient.

The second order formulation is only possible if the diffusion coefficient $D$ is a single value valid in all the considered domain.

A more general description allowing for non-uniform, non-linear diffusion coefficient combines a diffusive flux:

$$ q = -D\frac{∂C}{∂x}~,$$

and a conservation or flux balance equations:

$$ \frac{∂C}{∂t} = -\frac{∂q}{∂x}~. $$

To discretise the diffusion equation, we will keep the explicit forward Euler method as temporal discretisation and use [finite-differences](https://en.wikipedia.org/wiki/Finite_difference) for the spatial discretisation.

Finite-differences discretisation on regular staggered grid allows for concise and performance oriented algorithms, because only neighbouring cell access is needed to evaluate gradient and data alignment is natively pretty optimal.

A long story short, we will approximate the gradient of concentration $C$ over a distance $∂x$, a first derivative $\frac{∂C}{∂x}$, we will perform following discrete operation

$$ \frac{C_{x+dx} - C_{x}}{dx}~, $$

where $dx$ is the discrete size of the cell.

The same reasoning also applies to the flux balance equation.

We can use Julia's `diff()` operator to apply the $ C_{x+dx} - C_{x} $,
```julia
C[ix+1] - C[ix]
```
in a vectorised fashion to our entire `C` vector as
```julia
diff(C)
```

So, we are ready to solve the 1D diffusion equation.

We introduce the physical parameters that are relevant for the considered problem, i.e., the domain length `lx` and the diffusion coefficient `dc`:

```julia
# Physics
lx   = 10.0
dc   = 1.0
```

Then we declare numerical parameters: the number of grid cells used to discretize the computational domain `nx`, and the frequency of updating the visualisation:

```julia
# numerics
nx   = 200
nvis = 5
```

In the `# array initialisation` section, we need to initialise one array to store the concentration field `C`, and the diffusive flux in the x direction `qx`:

```julia
# array initialisation
C    = @. sin(10π*xc/lx); C_i = copy(C)
qx   = zeros(Float64, nx) # won't work
```

Wait... why it wouldn't work?

👉 Your turn. Let's implement our first diffusion solver trying to think about how to solve the staggering issue.

The initialisation steps of the diffusion code should contain

````julia:ex1
# physics
lx   = 20.0
dc   = 1.0
# numerics
nx   = 200
nvis = 5
# derived numerics
dx   = lx/nx
dt   = dx^2/dc/2
nt   = nx^2 ÷ 100
xc   = LinRange(dx/2,lx-dx/2,nx)
# array initialisation
C    = @. sin(10π*xc/lx); C_i = copy(C)
qx   = zeros(Float64, nx) # won't work
````

Followed by the 3 physics computations (lines) in the time loop

````julia:ex2
# Time loop
for it = 1:nt
    #q x         .= # add solution
    #C[2:end-1] .-= # add solution
    # Visualisation
end
````

One can examine the size of the various vectors ...

````julia:ex3
# check sizes and staggering
@show size(qx)
@show size(C)
@show size(C[2:end-1])
````

... and visualise it

````julia:ex4
using Plots
 plot(xc               , C   , label="Concentration", linewidth=:1.0, markershape=:circle, markersize=5, framestyle=:box)
plot!(xc[1:end-1].+dx/2, qx  , label="flux of concentration", linewidth=:1.0, markershape=:circle, markersize=5, framestyle=:box)
````

Note: plotting and visualisation is slow. A convenient workaround is to only visualise or render the figure every `nout` iteration within the time loop

```julia
if it % nout == 0
    plot()
end
```

## PDEs - advection

![advection](../assets/literate_figures/advection3.gif)

> Advection is a partial differential equation that governs the motion of a conserved scalar field as it is advected by a known velocity vector field. [_Wikipedia_](https://en.wikipedia.org/wiki/Advection)

We will here briefly discuss advection of a quantity $C$ by a constant velocity $v_x$ in the one-dimensional x-direction.

$$ \frac{∂C}{∂t} = -\frac{∂(v_x~C)}{∂x} ~.$$

In case the flow is incompressible ($∇⋅v = 0$ -- here $\frac{∂v_x}{∂x}=0$), the advection equation can be rewritten as

$$ \frac{∂C}{∂t} = -v_x \frac{∂C}{∂x} ~.$$

Let's once more start from the simple 1D reaction code, modifying it to implement the advection equation.

Starting from the reaction code, turn `ξ` into `vx=1.0`, the advection velocity, remove `C_eq`, set total simulation time `ttot = 5.0`

```julia
# Physics
Lx   = 10.0
vx   = 1.0
ttot = 5.0
```

The only change in the `# Derived numerics` section is the stable advection time step definition, to comply with the [CFL stability condition](https://en.wikipedia.org/wiki/Courant–Friedrichs–Lewy_condition) for explicit time integration.

```julia
# Derived numerics
dt   = dx/vx
```

In the `# Array initialisation` section, initialise the quantity `C` as a Gaussian profile of amplitude 1, standard deviation 1, with centre located at $c = 0.3 Lx$.

```julia
C = exp.( ... )
```

\note{Gaussian distribution as function of coordinate $x_c$, $ C = \exp(x_c - c)^2 $}

One should also pay attention regarding the correct initialisation of `dCdt` in terms of vector dimension, since the rate of change of `C`, `dCdt`, is the derivative of `C`.

Defining `dCdt` as following

```julia
dCdt     .= .-vx.*diff(C)./dx
```

implements the right and side of the 1D advection equation.

Now, the question is how to add `dCdt` to `C` within the update rule ?

3 (main) possibilities exist.

👉 Your turn. Try it out yourself and motivate your best choice.

Here we go, an upwind approach is needed to implement a stable advection algorithm

```julia
C[2:end]   .= C[2:end]   .+ dt.*dCdt # if vx>0
C[1:end-1] .= C[1:end-1] .+ dt.*dCdt # if vx<0
```

## Wrapping-up

- We implemented and solved PDEs for reaction, diffusion and advection processes in 1D

- We used conservative staggered grid finite-differences, explicit forward Euler time stepping and upwind scheme (advection).

Note that this is far from being the only way to tackle numerical solutions to these PDEs. In this course, we will stick to those concepts as they will allow for efficient GPU (parallel) implementations.

