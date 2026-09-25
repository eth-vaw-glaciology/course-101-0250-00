### A Pluto.jl notebook ###
# v1.0.3

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    return quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ 14f1b80f-1518-4016-87a1-5b6139e96680
using LinearAlgebra

# ╔═╡ 2ddec1a4-f9ae-4518-bd2e-7ffc0eee8490
begin
using CairoMakie
using PlutoUI
using PlutoTeachingTools
TableOfContents()
end

# ╔═╡ 63841d7d-2520-433e-b09a-630c73c084c0
md"""
# Solving elliptic PDEs

The goal of this lecture is to become familiar with:

- The damped wave equation.
- Accelerated pseudo-transient method for solving elliptic PDEs.

In the previous lecture, we established that the solution to the elliptic PDE could be obtained through integrating in time a corresponding parabolic PDE:

```math
u_t = λ \nabla^2 u ~.
```

As time approaches infinity, the time derivative vanishes. Of course, we cannot integrate to infinity, but if we integrate long enough, the time derivative will hopefully become very small, resulting in the approximate solution.
"""

# ╔═╡ 0b357917-fc2c-48d1-93bd-7591cffc7238
Foldable("""How long is "long enough"?""",
md"""
## 

Let's make a quick estimate. Assume that we solve our heat equation in 1D in a domain ``x \in [0, \pi]``, we set ``\lambda = 1``, and we impose Dirichlet boundary conditions at both boundaries.

Let ``u_\mathrm{s}(x)`` be the exact steady-state solution to the elliptic equation ``u_{xx} = 0``. Let the error, i.e. the difference between the transient solution ``u(t, x)`` and ``u_\mathrm{s}(x)`` be ``\epsilon(t, x) = u(t, x) - u_\mathrm{s}(x)``. Substituting ``\epsilon(t, x)`` to the heat equation yields the evolution PDE for the error:

```math
\epsilon_t = \epsilon_{xx}~.
```

Because both the steady solution and the transient solution satisfy the same Dirichlet boundary conditions, ``\epsilon(t, 0) = \epsilon(t, \pi) = 0``.

Let's look for the exact solution to this error equation of the following [separable](https://en.wikipedia.org/wiki/Separation_of_variables) form:

```math
\epsilon(t, x) = E(t) \sin(x)~.
```

Here, ``E(t)`` is the unknown function representing the **error amplitude**. Note that this solution satisfies the homogeneous Dirichlet boundary conditions. Substituting this ["ansatz"](https://en.wikipedia.org/wiki/Ansatz) to the the error equation we get the following ODE for ``E``:

```math
E' = -E~.
```

Solving this ODE, assuming ``E(0) = E^0`` yields:

```math
E(t) = E^0 \exp(-t)~.
```

We can see that the magnitude of the error is decaying **exponentially** with time.
Let's calculate how long it will take to reduce the error by a given factor. Assuming we want ``E(t)/E^0 < \varepsilon_\mathrm{tol}``, we can invert the solution to find the total time ``t_\mathrm{tot}``:

```math
t_\mathrm{tot} = -\log\varepsilon_\mathrm{tol}
```

Now, let's convert this time to the number of time steps that it takes to integrate the solution to ``t_\mathrm{tot}``. If we discretize the domain ``[0, \pi]`` into ``n`` grid cells, the cell size will be:

```math
\Delta x = \frac{\pi}{n} ~.
```

The stable time step for explicit Euler time integration of the heat equation is:

```math
\Delta t = \frac{\Delta x^2}{2} = \frac{1}{2}\frac{\pi^2}{n^2}~.
```

To cover ``t_\mathrm{tot}`` with time steps ``\Delta t``, the number of time steps should be:

```math
n_\mathrm{it} = \left\lceil -2\frac{n^2}{\pi^2} \log \varepsilon_\mathrm{tol} \right\rceil~.
```

As you can see, the number of time steps **increases quadratically** with ``n``.

!!! note "Wait a minute"
	There are other solutions that satisfy the Dirichlet boundary conditions, namely, ``\epsilon(t, x) = E_k(t) \sin(k x)`` with integer ``k \neq 1``. The general solution is a superposition of all these waves. Why don't we consider these too? It turns out, the rate of decay of these errors will be larger than that for ``k = 1``, so the convergence will be limited by the slowest wave with the smallest [wave number](https://en.wikipedia.org/wiki/Wavenumber) ``k = 1``.
""")

# ╔═╡ f11d07aa-ab22-4c8a-83dc-31e984244cec
md"""
## Pseudo-transient method

In this course, we call any method that builds upon the analogy to the transient physics the **pseudo-transient (PT)** method.

Using this analogy proves useful when studying multi-physics and nonlinear processes. The PT method isn't restricted to solving the elliptic equations, but can be applied to a wide range of problems that are modelled with PDEs, as long as the steady state exists.

In a pseudo-transient method, we are interested only in steady distributions of the unknown field variables such as concentration, temperature, etc. We thus consider time steps as iterations in a numerical method, and call time a **"pseudo-time"**. To distinguish the physical time ``t`` from pseudo-time, we replace ``t`` in the equations with ``\tau``, and a time step `it` with iteration counter `iter`. When a pseudo-transient method converges, all the pseudo-time derivatives ``\partial/\partial\tau``, ``\partial^2/\partial\tau^2`` etc., vanish.
"""

# ╔═╡ cc685fe8-db51-471d-a2a4-6acec55e3c5a
md"""
## Accelerated elliptic solver: intuition

As discussed previously, the number of time steps required to converge the first-order pseudo-transient solver scales quadratically with increasing resolution, which is too expensive for 2D and 3D problems.

In this lecture, we'll improve the convergence rate of the elliptic solver in 1D. Recall the stability conditions for diffusion and acoustic wave propagation:

```julia
dτ = dx^2/dc/2      # diffusion
dτ = dx/sqrt(1/β/ρ) # acoustic wave propagation
```

We can see that the acceptable time step for an acoustic problem is proportional to the grid spacing `dx`, and not `dx^2` as for the diffusion. So, can we just integrate the wave equation instead?

Unfortunately, in the solution to the wave equation, the waves do not attenuate with time: **there is no steady state**! However, we can quite easily combine the physical processes of diffusion and wave propagation, and then we will have the best of both worlds: larger time steps, and existence of steady state.
"""

# ╔═╡ 94ec3349-294e-40f5-8501-4d7fe5510452
md"""
### Damped wave equation

Consider the diffusion equation with diffusivity ``\lambda = 1``, and a wave equation with wavespeed ``c = 1``:

```math
\begin{align}
u_\tau       &= \nabla^2 u~,\\[2pt]
u_{\tau\tau} &= \nabla^2 u~.
\end{align}
```

Let's "combine" the heat equation and the wave equation in the following way:

```math
u_{\tau\tau} + \zeta u_\tau = \nabla^2 u~.
```

The parameter ``\zeta > 0`` is called a [**damping parameter**](https://en.wikipedia.org/wiki/Damping).

This PDE is called a **damped wave equation**. It is **hyperbolic**, but in contrast to the wave equation, the waves decay over time, and eventually the solution reaches a steady state.

When ``\zeta \ll 1``, the equation behaves more like the wave equation, and it takes a long time for the pseudo-transient process to converge to the steady state. In that case, the equations is said to be **underdamped**. For ``\zeta \gg 1``, the second pseudo-time derivative ``u_{\tau\tau}`` becomes insignificant, and the solution evolves more like a diffusion process, i.e., the equation is **overdamped**. In the latter case, the time step also becomes limited by the square of the grid spacing, `dx^2`, and the number of time steps is large again.

There is an optimal value of ``\zeta``, a "sweet spot" for which the waves decay at the fastest rate possible. This is called **critical damping**.

The effect of damping can be seen on the simpler **damped oscillator equation**:

```math
\ddot{u} + \zeta \dot{u} = -u~.
```

This is ODE describing the oscillatory motion of a point mass, that is damped by some dissipative physical process, such as the air resistance:
"""

# ╔═╡ c351741d-347e-4fc3-bce1-d8dd84a3a992
html"""
<p align="center">
  <img src="https://upload.wikimedia.org/wikipedia/commons/2/2b/Damped_spring.gif" />
</p>
"""

# ╔═╡ 79e201d7-0183-4861-ad30-993f1308f39f
md"""
!!! note
	The damped oscillator equation actually describes how the magnitude of the error betweed the exact solution to the elliptic equation and the pseudo-transient damped wave equation evolves over time. This can be derived similarly to the case described in the "How long is long enough?" section above.

Below is the solution to the damped oscillator equation. Tweak the value of `ζ` and see how different regimes look like:
"""

# ╔═╡ 9e910f47-59ad-4591-bd17-064acf1f31fa
md"""
``\zeta`` = $(@bind __ζ PlutoUI.Slider(range(0.5, 5, 46); show_value=true))
"""

# ╔═╡ c24d6699-1e22-40a6-a469-3ef6b249f8be
let
function damped_oscillator(ζ)
	t = LinRange(0, 20, 201)
	uc = @. (1 + t) * exp(-t)
	if ζ^2 < 4
		# underdamped
		ω = sqrt(1 - ζ^2/4)
		u = @. exp(-ζ * t / 2) * (cos(ω  * t) + ζ / (2ω) * sin(ω * t))
		txt = "underdamped"
	elseif ζ^2 > 4
		# overdamped
		r⁺ = -ζ/2 + sqrt(ζ^2/4 - 1)
		r⁻ = -ζ/2 - sqrt(ζ^2/4 - 1)
		A  = -r⁻ / (r⁺ - r⁻)
		B  =  r⁺ / (r⁺ - r⁻)
		u  = @. A * exp(r⁺ * t) + B * exp(r⁻ * t)
		txt = "overdamped"
	else
		# critically damped
		u = uc
		txt = "critically damped!!!"
	end
	lines(t, uc; color=:blue, label="ζ = 2",
		  figure=(size=(600, 250), ),
		  axis=(; xlabel="t", ylabel="u", limits=(0, 20, -0.5, 1)))
	lines!(t, u; color=:red, label=string("ζ = ", round(ζ; digits=2)))
	text!(10, 0.7; text=txt, align=(:center, :bottom), font=:bold, fontsize=16)
	axislegend(current_axis())
	current_figure()
end
damped_oscillator(__ζ)
end

# ╔═╡ 11f41834-6688-4cfb-aa70-56c46db4a63d
md"""
You can see that at `ζ = 2` the system is **critically damped**, and the steady state is reached as fast as possible.
"""

# ╔═╡ e3f5c992-b76f-11f1-b33c-3b9472606fe3
md"""
### Implementing the damped wave equation

Let's implement simple numerical solver for the damped wave equation in 1D:

```math
u_{\tau\tau} + \zeta u_\tau = \nabla^2 u
```

First, we introduce another variable ``v`` for the rate-of-change of ``u``:

```math
\begin{align}
u_\tau           &= v~, \\[2pt]
v_\tau + \zeta v &= \nabla^2 u~.
\end{align}
```

!!! note
	In the previous lecture, we converted the wave equation to the first-order system. This is another way to integrate hyperbolic equations in time using semi-implicit Euler method.

Now, we can discretise the pseudo-time derivatives:

```math
u_\tau \approx \frac{u^{n+1} - u^n}{\Delta\tau}~.
```

As before, superscript ``n`` indicates the time layer, not a power. We can discretise ``v_\tau`` similarly.

In the `# physics` section, use `lx = π`:

```julia
# physics
# lx   = ...
```

In the `# preprocessing` section, we select the pseudo-time step `dτ` as `0.95dx`. This is consistent with the wave equation, with the speed of sound set to `1`:

```julia
# preprocessing
dx = lx / nx
dτ = 0.95dx
xc = LinRange(dx/2, lx-dx/2, nx)
```

Use the sine wave as the initial condition for `u`. Initialise the rate-of-change vector `v` as a zero vector:

```julia
# initialisation
u = ...
v = zeros(...)
```

!!! hint
	The size of `v` should be smaller than the size of `u`.

We also track the maximum amplitude of the wave. With this initial condition, the maximum is in the middle of the domain:

```julia
# τ and u_max history
τs  = [0.0]
us  = [u[end÷2]]
```

In the time loop, we first update the solution `u`, and then the rate-of-change `v`:

```julia
# update solution
# u[2:end-1] .= ...
# update rate of change
# v .= ...
```

!!! hint
	- To discretise the second derivative, either use nested `diff(diff(...)./dx)./dx` call or introduce flux vector `q` similarly to the previous exercises.
	- In the term `ζ v`, you can either pick `v` from the previous pseudo-time iteration, or from the next one. You can choose either version, or implement both and check which works better for you.

In the visualisation section, we need to update the pseudo-time history vectors `τs` and the amplitude history `us`, then update the plots:

```julia
if iter % nvis == 0
	# push!(τs, ...)
	# push!(us, ...)
	plt[1][2] = u
	plt[2][1] = τs
	plt[2][2] = us
end
```

👉 Your turn. Finish the implementation of the damped wave equation:
"""

# ╔═╡ 56f4af2b-06f0-4aa2-b4f9-e2342f614c40
md"""
If your code is correct, you should see this animation at `ζ = 0.5`:
"""

# ╔═╡ 56cde71c-1926-4628-bcd5-2467b6009f77
md"""
Try different values of `ζ` in the range 0--10, and compare the evolution of the amplitude with the solution to the damped oscillator equation above. Verify that at `ζ = 2` the behavior corresponds to the critically damped oscillator.
"""

# ╔═╡ 025f2984-bc92-4576-8cc8-8559f5c0e327
# Uncomment when finished the implementation
# damped_wave_equation_1d(0.5)

# ╔═╡ c6d8a983-b4c6-48bf-a0e3-f7cf945a0edb
answer_box(
md"""
```julia
function damped_wave_equation_1d(ζ)
	# physics
	lx   = π
	# numerics
	nx   = 200
	nt   = 10nx
	nvis = 20
	# preprocessing
	dx   = lx / nx
	dτ   = 0.95dx
	xc   = LinRange(dx/2, lx-dx/2, nx)
	# initialisation
	u    = @. sin(xc)
	v    = zeros(nx-2)
	# τ and u(max) history
	τs  = [0.0]
	us  = [u[end÷2]]
	# figure
	fig = Figure(size=(600, 400))
	ax  = (Axis(fig[1, 1]; xlabel="x", ylabel="u"),
           Axis(fig[2, 1]; xlabel="τ", ylabel="uᵐ", limits=(0, nt*dτ, -0.5, 1)))
	ylims!(ax[1], -1.1, 1.1)
	lines!(ax[1], xc, u; color=:blue)
	plt = (lines!(ax[1], xc, u; color=:red),
           lines!(ax[2], τs, us; color=:red))
	# time loop
	@animate fig nvis for iter in 1:nt
		# update solution
		u[2:end-1] .= u[2:end-1] .+ dτ .* v
		# update rate of change
		v .= v .* (1 - dτ * ζ) .+ dτ .* diff(diff(u)./dx)./dx
		if iter % nvis == 0
			push!(τs, iter * dτ)
			push!(us, u[end÷2])
			plt[1][2] = u
			plt[2][1] = τs
			plt[2][2] = us
		end
	end
end
```
""")

# ╔═╡ 67dd1075-e9d8-4644-8ea5-cbaeea8c1916
md"""
Yay, you've implemented a damped wave equation, which almost a full second-order pseudo-transient solver! But here, we were just building an intuition of the physical analogy between the relaxation solvers and a transient physical process.

The idea of accelerating the convergence by increasing the order of PDE dates back to the work by [Frankel (1950)](https://doi.org/10.2307/2002770) where he studied the convergence rates of different iterative methods. Frankel noted the analogy between the iteration process and transient physics. In his work, the accelerated method was called the **second-order Richardson method**.

👀 If interested in how to analytically derive the optimal damping parameter for different equations including elliptic and Stokes equations, [Räss et al. (2022)](https://gmd.copernicus.org/articles/15/5757/2022/) paper is a good starting point.
"""

# ╔═╡ 51b15738-f473-40a4-b76a-3ea5ccc20e4a
md"""
!!! warning
	We should be careful when introducing the new pseudo-physical terms into the governing equations. We need to make sure that when iterations converge, i.e., if the pseudo-time derivatives are set to 0, the system of equations is identical to the original steady-state formulation.

For example, consider the acoustic problem from the previous lecture:

```math
\begin{align}
\rho v_\tau  &= -p_x ~, \\[2pt]
\beta p_\tau &= -v_x ~.
\end{align}
```

We can introduce damping into this system in few ways. For example, let's add a damping term to a second equation:

```math
\begin{align}
\rho v_\tau  &= -p_x ~, \\[2pt]
\beta p_\tau + p\eta &= -v_x ~.
\end{align}
```

Here, we added a term ``p/\eta`` where parameter ``\eta`` can be interpreted as bulk viscosity. It can be easily demonstrated by eliminating ``v`` that this is indeed a damped wave equation. At the steady-state, the second equation reads:

```math
p / \eta = -v_x~.
```

The velocity divergence is proportional to the pressure. If we wanted to solve the incompressible problem (i.e. the velocity divergence = 0), and were interested in the velocity distribution, this approach would lead to incorrect results. If we only want to solve the Laplace problem ``p_{xx} = 0``, we could consider ``v`` purely as a numerical variable.

In other words: **only add those new terms to the governing equations that vanish when the iterations converge!**
"""

# ╔═╡ 9ea2a20e-2c44-41f7-9806-512831ec519c
md"""
## Accelerated pseudo-transient solver: implementation

Now that we have a good idea about the physical analogy between solving the elliptic equation and the damped wave equation, we can implement the full steady diffusion solver for the spatially variable diffusion coefficient ``\lambda``:

```math
\boldsymbol{\nabla}\cdot(\lambda \boldsymbol{\nabla} u) = 0~.
```

Before we proceed, we need formulate how to we measure the convergence.
"""

# ╔═╡ 05a2e73a-3433-44f6-b14a-345778e54655
md"""
### Measuring convergence

To define the measure of error, we introduce the residual:

```math
r = \boldsymbol{\nabla}\cdot(\lambda \boldsymbol{\nabla} u)~.
```

There are many ways to define the error as the norm of the residual, the most popular ones are the ``L_1``, ``L_2``, and ``L_\infty`` norms. We will use the ``L_\infty`` norm here:

```math
\|\boldsymbol{r}\|_\infty = \max_i(|r_i|)
```

In Julia, this can be computed by calling `maximum(abs, r)`.

If our damping parameter is optimal, the number of iterations required to achieve convergence will scale linearly with increasing resolution. This means that the number of iterations divided by number of grid cells should stay approximately constant. We therefore track convergence by saving the history of the number of iterations per number of grid cells and the history of the ``L_\infty`` norm of the residual. We stop iterations when ``\|r\|_\infty < \varepsilon_\mathrm{tol}``.
"""

# ╔═╡ c5151cee-5ce3-4baf-8e51-d64c448763f8
md"""
### Preconditioning

In many problems, the material properties such as the diffusion coefficient can vary significantly in space, which can make the convergence of the iterative solvers slow. Such problems are usually called **ill-conditioned**, which means that they have large [condition number](https://en.wikipedia.org/wiki/Condition_number), which measures how accurate the approximate solution to the linear system of equations can be made. In problems with large material contrasts, the condition number is large. To reduce it, the equations are transformed into a form with a better, i.e. lower, condition number. This technique is called [preconditioning](https://en.wikipedia.org/wiki/Preconditioner).

In our case, assume the discretised the elliptic equation is equivalent to the linear system:

```math
A u = b~.
```

Solving this is system is equivalent to solving another system:

```math
Q(b - A u) = 0~,
```

where ``Q`` is a known nonsingular matrix. If ``Q`` approximates ``A^{-1}`` well, the condition number of this transformed system will be lower.

In this course, we will only consider the simplest possible kind of preconditioner --- the [Jacobi](https://en.wikipedia.org/wiki/Preconditioner#Jacobi_(or_diagonal)_preconditioner), or diagonal, preconditioner:

```math
Q = \mathrm{diag}\,(A)^{-1}~.
```
"""

# ╔═╡ f065b525-5dc4-46a1-8df0-c1a29d751159
md"""
### Accelerated PT solver

The PT solver has the following structure:

1. Initialize the step size ``\alpha``, and the damping parameter ``\beta``.
2. Initialize the solution vector ``u``, search vector ``d``, residual vector ``r``, preconditioner ``Q``, preconditioned residual ``z``.
3. Each iteration:
   - ``u^{n+1} = u^{n} + \alpha d^n``.
   - ``r^{n+1} = r(u^{n+1})``.
   - if ``\|r^{n+1}\|_\infty < \varepsilon_\mathrm{tol}``, break.
   - ``z^{n+1} = Q r^{n+1}``
   - ``d^{n+1} = d^{n} \beta + z^{n+1}``

If you compare the two lines updating the solution vector ``u`` and the search vector ``d`` with the two lines updating the solution ``u`` and the rate-of-change vector ``v`` from the damped equation solver, you will notice that the accelerated PT solver is actually a damped wave equation solver, but with some variables renamed.

With this information, we can implement the PT solver.

We will solve the steady diffusion problem with spatially variable diffusivity field `λ` parameterised by the background diffusivity `λbg = 1.0` and the perturbation amplitude `λamp = 10.0`. We impose the Dirichlet boundary conditions: `u = 0` at `x = 0` and `u = 1` at `x = lx`.

The physics section will now contain the new diffusivity parameters:

```julia
# physics
lx   = 20.0
λbg  = 1.0
λamp = 10.0
```

In the `# numerics` section, we will introduce the solver parmeters: the PT solver tolerance `εtol  = 1e-6`, the maximum number of iterations `niter = 15nx`, and the convergence check frequency `nchck = ceil(Int, 0.1nx)`:

```julia
# numerics
nx    = 200
εtol  = 1e-6
niter = 15nx
nchck = ceil(Int, 0.1nx)
```

In the `# preprocessing` section, we introduce the grid point coordinates `xv` that will be necessary to initialise the `λ` field, which is located at the grid points, and not cell centres. Then we introduce the damping parameter `β`, and the step size `α`:

```julia
# preprocessing
dx   = lx / nx
xc   = LinRange(dx/2,lx-dx/2,nx)
xv   = LinRange(dx,lx-dx,nx-1)
β    = 1 - 1.3π / nx
α 	 = 0.99 * (1 + β)
```

!!! note
    - Look at these parameters `α` and `β`. They are closely related to the pseudo-time step `dτ` and the damping `ζ` from the damped wave equation solver. We won't look into their derivation closely in the course, but if you're interested, you can try to convert the damped wave formulation to the PT formulation using pen and paper (or ask LLM).
    - The value of `β = 1 - 1.3π / nx` here is manually tuned for the specific problem setup. If the diffusivity `λ` was constant, the optimal value would be `β = 1 - 2π / nx`, where the factor `2` is the critical damping value `ζ` from the damped wave equation, and `π` is the scaling factor to convert between the domain length `π` in the damped wave equation solver and `lx`.

In the array initialisation section, we initialise the solution `u` with zeros (this will be simply an initial guess for the solver, since the solution to the elliptic equation can only depend on the boundary conditions). Then initialize `λ` with a sum of a constant background value `λbg` and a Gaussian profile centered at `lx/2` with an amplitude `λamp`. Then initialize the flux vector as in the previous exercises. Then we introduce the direction vector `d`, the residual vector `r`, and the preconditoned residual vector `z`, all initialized with zeros:

```julia
# array initialisation
# u    = ...
# λ    = @. ...
# qx   = ...
# d    = ...
# r    = ...
# z    = ...
```

!!! hint
    The sizes of the search vector, residual vector, and preconditioned residual vector differ from the size of the solution vector, because at the boundaries the value of `u` is specified by the Dirichlet boundary conditions.

Then we intialize the Jacobi preconditioner:

```julia
# preconditioner
Q    = @. dx^2 / (λ[1:end-1] + λ[2:end])
```

!!! note
    Verify that this formula for `Q` is indeed the inverse of the diagonal of the system matrix. Write down the discretised residual at a grid cell `i` as a function of the unknown function `u` and collect terms in front of `u[i]`.

Then we initialise the convergence history:

```julia
# convergence history
itr_h = Float64[]
res_h = Float64[]
```

We will save the number of iterations per `nx` and the ``L_\infty`` norm of the residual every `nchck` iterations.

In the iteration loop, we update the solution first:

```julia
for iter = 1:niter
    # update solution
    # @. u[2:end-1] += ...
    ...
end
```

Then we specify the boundary conditions `u = 0` at `x = 0` and `u = 1` at `x = lx`:

```julia
# boundary conditions
# u[1]   = ...
# u[end] = ...
```

Then we compute residual `r = ∇ ⋅ (λ∇u)` by first computing the diffusive flux `qx = -λ∇u`, and then the residual `r = -∇⋅q`:

```julia
# compute residual
# @. qx = ...
# @. r  = ...
```

!!! hint
    Use `u[2:end] - u[1:end-1]` instead of `diff(u)` for better performance.

Then, we check convergence by comparing the ``L_\infty`` norm of residual to the tolerance `εtol`. At the same time, we push the \# of iterations per `nx` and the residual norm to the convergence history vectors:

```julia
# check convergence
if iter % nchck == 0
    # err = ...
    push!(itr_h, ...)
    push!(res_h, ...)
    if err < εtol
        println(" solver converged in $(iter/nx) × N iterations! 🚀")
        break
    end
end
```

Then we compute the preconditioned residual `z` and update the search vector `d` using newly computed `z` and a damping parameter `β`:

```julia
# compute preconditioned residual
# @. z = ...
# update search direction
# @. d = ...
```

Finally, after the iteration loop finishes, we visualise the solution and the convergence history:

```julia
# create plot
fig = Figure(size=(600, 450))
ax  = (Axis(fig[1,1]; xlabel="x", ylabel="u", title="solution"),
       Axis(fig[2,1]; xlabel="iter/nx", ylabel="|r|",
                          yscale=log10,
                          title="convergence history",
                          limits=(0, niter/nx, 0.1εtol, 1e2)))
# plt = (lines!(ax[1], ..., ...; color=:red),
#        lines!(ax[2], ..., ...; color=:black))
```


👉 Your turn. Finish the implementation of the elliptic PT solver:
"""

# ╔═╡ b5d5c28a-7b83-4f48-b6a0-ec617ae1ccb7
@views function elliptic_1d()
	# physics
	lx   = 20.0
	λbg  = 1.0
	λamp = 10.0
	# numerics
	nx    = 200
	εtol  = 1e-6
	niter = 15nx
	nchck = ceil(Int, 0.1nx)
	# preprocessing
	dx   = lx / nx
	xc   = LinRange(dx/2,lx-dx/2,nx)
	xv   = LinRange(dx,lx-dx,nx-1)
	β    = 1 - 1.3π / nx
	α 	 = 0.99 * (1 + β)
	# array initialisation
	# u    = ...
	# λ    = ...
	# qx   = ...
	# d    = ...
	# r    = ...
	# z    = ...
	# preconditioner
	Q    = @. dx^2 / (λ[1:end-1] + λ[2:end])
	# convergence history
	itr_h = Float64[]
	res_h = Float64[]
	# time loop
	for iter = 1:niter
		# update solution
		#. @. u[2:end-1] += ...
		# boundary conditions
		# u[1]   = ...
		# u[end] = ...
		# compute residual
	    # @. qx = ...
		# @. r  = ...
		# check convergence
		if iter % nchck == 0
			# err = ...
			# push!(itr_h, ...)
			# push!(res_h, ...)
			if err < εtol
				println(" solver converged in $(iter/nx) × N iterations! 🚀")
				break
			end
		end
		# compute preconditioned residual
		# @. z = ...
		# update search direction
		# @. d = ...
	end
	# create plot
	fig = Figure(size=(600, 450))
	ax  = (Axis(fig[1,1]; xlabel="x", ylabel="u", title="solution"),
           Axis(fig[2,1]; xlabel="iter/nx", ylabel="|r|",
                              yscale=log10,
                              title="convergence history",
                              limits=(0, niter/nx, 0.1εtol, 1e2)))
	# plt = (lines!(ax[1], ..., ...; color=:red),
    #        lines!(ax[2], ..., ...; color=:black))
	return fig
end

# ╔═╡ a28bdaa2-82f9-4949-b3af-34a0bf4c18ab
md"""
If you correctly implemented the solver, you should see the following figure:
"""

# ╔═╡ e2a22f7c-34a0-4d67-b9a3-1c76213921a9
answer_box(
md"""
```julia
@views function elliptic_1d()
	# physics
	lx   = 20.0
	λbg  = 1.0
	λamp = 10.0
	# numerics
	nx    = 200
	εtol  = 1e-6
	niter = 15nx
	nchck = ceil(Int, 0.1nx)
	# preprocessing
	dx   = lx / nx
	xc   = LinRange(dx/2,lx-dx/2,nx)
	xv   = LinRange(dx,lx-dx,nx-1)
	β    = 1 - 1.3π / nx
	α 	 = 0.99 * (1 + β)
	# array initialisation
	u    = zeros(nx)
	λ    = @. λbg + λamp * exp(-(xv-lx/2)^2)
	qx   = zeros(nx-1)
	d    = zeros(nx-2)
	r    = zeros(nx-2)
	z    = zeros(nx-2)
	# preconditioner
	Q    = @. dx^2 / (λ[1:end-1] + λ[2:end])
	# convergence history
	itr_h = Float64[]
	res_h = Float64[]
	# time loop
	for iter = 1:niter
		# update solution
		@. u[2:end-1] += α * d
		# boundary conditions
		u[1]   = 0
		u[end] = 1
		# compute residual
	    @. qx = -λ * (u[2:end] - u[1:end-1]) / dx
		@. r  = -(qx[2:end] - qx[1:end-1]) / dx
		# check convergence
		if iter % nchck == 0
			err = maximum(abs, r)
			push!(itr_h, iter / nx)
			push!(res_h, err)
			if err < εtol
				println(" solver converged in $(iter/nx) × N iterations! 🚀")
				break
			end
		end
		# compute preconditioned residual
		@. z = Q * r
		# update search direction
		@. d = d * β + z
	end
	# create plot
	fig = Figure(size=(600, 450))
	ax  = (Axis(fig[1,1]; xlabel="x", ylabel="u", title="solution"),
           Axis(fig[2,1]; xlabel="iter/nx", ylabel="|r|",
                              yscale=log10,
                              title="convergence history",
                              limits=(0, niter/nx, 0.1εtol, 1e2)))
	plt = (lines!(ax[1], xc, u; color=:red),
           lines!(ax[2], itr_h, res_h; color=:black))
	return fig
end;
```
"""
)

# ╔═╡ 015de44b-aeb8-407e-b9f5-5e8086ef0689
md"""
Congrats, you have implemented a full iterative solver!

Now, you can experiment a bit with the solver. Try to vary a litte the damping parameter `β`. You will see that pretty quickly the iterations stop converging if `β` is far from the optimal value.

Set the diffusivity perturbation amplitude `λamp` to `0`, then verify that the optimal value of `β` is `1 - 2π/nx`. You can see that when increasing the number of grid points `nx` the total number of iterations per nx  stays approximately the same.

If you change the center of the diffusivity perturbation, or the amplitude, or add source terms to the equation, then the `β` parameter is no longer optimal and needs manual fine-tuning. For larger material contrasts (i.e. larger `λamp`) no single choice of `β` will guarantee satisfactory convergence rate. Fortunately, there is a simple way to compute it automatically and adjust during iterations.
"""

# ╔═╡ 53ead820-57da-4430-9e62-3bab0aca81f2
md"""
### Dynamic relaxation

Historically, the accelerated PT method with automatically computed damping parameter `β` is called **dynamic relaxation (DR)** in the literature (e.g. [Papadrakakis (1981)](https://doi.org/10.1016/0045-7825(81)90066-9)).

!!! note
	Read [Duretz et al. (2026)](https://doi.org/10.5194/gmd-19-5343-2026) if you want to know how the dynamic relaxation can be applied to the nonlinear large-scael problems in geodynamics.

The automatic computation of `β` is as follows:

```math
\begin{align}
\gamma^{n+1} &= \frac{|\boldsymbol{d}^n \cdot (\boldsymbol{z}^{n+1} - \boldsymbol{z}^n)|}{\boldsymbol{d}^n\cdot\boldsymbol{d}^n}~, \\[5pt]
\beta^{n+1} &= \left(1 - \sqrt{\gamma^{n+1}}\right)^2~.
\end{align}
```

Update of `β` doesn't need to happen every iteration, which is good because the dot products involve global "reduce" operation, and therefore are quite expensive, especially on GPU. Updating `β` every ~10 iterations is usually a good balance between efficiency and accuracy.

Let's implement this DR strategy in our elliptic solver.

Introduce the storage vector for the preconditioned residual from the previous iteration ``z^n``:

```julia
# array initialisaition
# ...
# z    = ...
# z0   = ... # new array
# ...
```

Then, in the `# numerics` section, we add a new parameter `ndrel` controlling the frequency of `β` updates:

```julia
# numerics
# ...
nchck = ceil(Int, 0.1nx)
ndrel = 10
# ...
```

In the iterative loop we now need to compute `α` before updating the solution:

```julia
α = 0.99 * (1 + β)
# u[2:end-1] += ...
```

Then, before computing the preconditioned residual `z`, we need to save the old `z`, and before updating the direction vector `d`, we need to recompute `β` (but only every `ndrel` iterations):

```julia
# save old z
if iter % ndrel == 0
	@. ...
end
# compute preconditioned residual
@. z = Q * r
# update β
if iter % ndrel == 0
	# A = ...
	# β = ...
end
# update search direction
@. d = ...
```

!!! hint
	Use `dot` function from LinearAlgebra package for computing dot products of vectors.

👉 Your turn. Starting from the previous scprit, implement the DR elliptic solver:
"""

# ╔═╡ d5726aa5-dd9e-4cc8-8c67-7160bba9c133
function elliptic_1d_dr()
	# Enter your code here
end

# ╔═╡ 25181dae-3eac-4a21-8f8a-2b1d95fd6c36
md"""
If the code is implemented correctly, you will see the following figure:
"""

# ╔═╡ bd7bbd44-95e5-4f9d-bed7-81c8c6dbd0f6
answer_box(
md"""
```julia
@views function elliptic_1d_dr()
	# physics
	lx   = 20.0
	λbg  = 1.0
	λamp = 10.0
	# numerics
	nx    = 1000
	εtol  = 1e-6
	niter = 15nx
	nchck = ceil(Int, 0.1nx)
	ndrel = 10
	# preprocessing
	dx   = lx / nx
	xc   = LinRange(dx/2,lx-dx/2,nx)
	xv   = LinRange(dx,lx-dx,nx-1)
	β    = 1 - 2π / nx
	# array initialisation
	u    = zeros(nx)
	λ    = @. λbg + λamp * exp(-(xv-lx/2)^2)
	qx   = zeros(nx-1)
	d    = zeros(nx-2)
	r    = zeros(nx-2)
	z    = zeros(nx-2)
	z0   = zeros(nx-2)
	# preconditioner
	Q    = @. dx^2 / (λ[1:end-1] + λ[2:end])
	# convergence history
	itr_h = Float64[]
	res_h = Float64[]
	# time loop
	for iter = 1:niter
		# update solution
		α = 0.99 * (1 + β)
		@. u[2:end-1] += α * d
		# boundary conditions
		u[1]   = 0
		u[end] = 1
		# compute residual
	    @. qx = -λ * (u[2:end] - u[1:end-1]) / dx
		@. r  = -(qx[2:end] - qx[1:end-1]) / dx
		# check convergence
		if iter % nchck == 0
			err = maximum(abs, r)
			push!(itr_h, iter / nx)
			push!(res_h, err)
			if err < εtol
				println(" solver converged in $(iter/nx) × N iterations! 🚀")
				break
			end
		end
		# save old z
		if iter % ndrel == 0
			@. z0 = z
		end
		# compute preconditioned residual
		@. z = Q * r
		# update β
		if iter % ndrel == 0
			A = abs(dot(d, z .- z0)) / dot(d, d)
			β = (1 - sqrt(A))^2
		end
		# update search direction
		@. d = d * β + z
	end
	# create plot
	fig = Figure(size=(600, 450))
	ax  = (Axis(fig[1,1]; xlabel="x", ylabel="u", title="solution"),
           Axis(fig[2,1]; xlabel="iter/nx", ylabel="|r|",
                              yscale=log10,
                              title="convergence history",
                              limits=(0, niter/nx, 0.1εtol, 1e2)))
	plt = (lines!(ax[1], xc, u; color=:red),
           lines!(ax[2], itr_h, res_h; color=:black))
	return fig
end;
```
"""
)

# ╔═╡ ae8fc6a2-84f6-41f9-92bd-a02cce10a8b6
md"""
You can see that the number of iterations with the DR solver is lower than that with any manually specified constant value of `β`. If you increase the material contrast `λamp` to larger values, e.g. 1000, the DR solver will still converge, but will require much more iterations per `nx`. The manually tuned PT solver will convergence will be impractically slow.
"""

# ╔═╡ 7c955efd-edd3-4dc9-9ccf-8508d48872ed
md"""
### Multi-physics: steady diffusion-reaction

Let's implement our first multi-physics DR solver by adding chemical reaction:

```math
\boldsymbol{\nabla}\cdot(\lambda\boldsymbol{\nabla} u) = \frac{u - u_{eq}}{\xi}
```


👉 Let's add the new physical parameters, modify the Jacobi preconditioner and the residual computation:

```julia
function steady_diffusion_reaction_1d()
	# physics
	...
	u_eq    = 0.1
	ξ       = 50.0
	...
	# preconditioner
	Q    = @. inv((λ[1:end-1] + λ[2:end]) / dx^2 + 1 / ξ)
	# iteration loop
	for iter in 1:niter
	    ...
	    @. r = ... - ...
	    ...
	end
	...
end
```

👉 Your turn. Finish the implementation of the steady diffusion-reaction solver:
"""

# ╔═╡ cc32ced0-d154-46a7-847a-824521bfb044
function steady_diffusion_reaction_1d()
	# Enter your implementation here
end

# ╔═╡ d3268cd5-3be9-4568-abba-dcce3b51ae92
md"""
If your implementation is correct, you will see this figure:
"""

# ╔═╡ 42a19502-7936-4ae6-96db-049c8bab3596
answer_box(
md"""
```julia
@views function steady_diffusion_reaction_1d()
	# physics
	lx   = 20.0
	λbg  = 1.0
	λamp = 10.0
	u_eq = 0.1
	ξ    = 50.0
	# numerics
	nx    = 1000
	εtol  = 1e-6
	niter = 15nx
	nchck = ceil(Int, 0.1nx)
	ndrel = 10
	# preprocessing
	dx   = lx / nx
	xc   = LinRange(dx/2,lx-dx/2,nx)
	xv   = LinRange(dx,lx-dx,nx-1)
	β    = 1 - 2π / nx
	# array initialisation
	u    = zeros(nx)
	λ    = @. λbg + λamp * exp(-(xv-lx/2)^2)
	qx   = zeros(nx-1)
	d    = zeros(nx-2)
	r    = zeros(nx-2)
	z    = zeros(nx-2)
	z0   = zeros(nx-2)
	# preconditioner
	Q    = @. inv((λ[1:end-1] + λ[2:end]) / dx^2 + 1 / ξ)
	# convergence history
	itr_h = Float64[]
	res_h = Float64[]
	# time loop
	for iter = 1:niter
		# update solution
		α = 0.99 * (1 + β)
		@. u[2:end-1] += α * d
		# boundary conditions
		u[1]   = 0
		u[end] = 1
		# compute residual
	    @. qx = -λ * (u[2:end] - u[1:end-1]) / dx
		@. r  = -(qx[2:end] - qx[1:end-1]) / dx - (u[2:end-1] - u_eq) / ξ
		# check convergence
		if iter % nchck == 0
			err = maximum(abs, r)
			push!(itr_h, iter / nx)
			push!(res_h, err)
			if err < εtol
				println(" solver converged in $(iter/nx) × N iterations! 🚀")
				break
			end
		end
		# save old z
		if iter % ndrel == 0
			@. z0 = z
		end
		# compute preconditioned residual
		@. z = Q * r
		# update β
		if iter % ndrel == 0
			A = abs(dot(d, z .- z0)) / dot(d, d)
			β = (1 - sqrt(A))^2
		end
		# update search direction
		@. d = d * β + z
	end
	# create plot
	fig = Figure(size=(600, 450))
	ax  = (Axis(fig[1,1]; xlabel="x", ylabel="u", title="solution"),
           Axis(fig[2,1]; xlabel="iter/nx", ylabel="|r|",
                              yscale=log10,
                              title="convergence history",
                              limits=(0, niter/nx, 0.1εtol, 1e2)))
	plt = (lines!(ax[1], xc, u; color=:red),
           lines!(ax[2], itr_h, res_h; color=:black))
	return fig
end;
```
"""
)

# ╔═╡ 72fa4fde-0300-4abe-8f72-9f9b85a7c70c
md"""
Interestingly, for smaller reaction timescales `ξ` the convergence becomes faster. This is because the term `1/ξ` on the diagonal of the matrix associated with the linear system of discretised equation makes the matrix better conditioned.
"""

# ╔═╡ f574be7f-945d-45d6-a16e-00bd9d85581b
md"""
## Wrapping-up

- Switching from parabolic to hyperbolic PDE allows to approach the steady-state in number of iterations, proportional to the number of grid points.
- Pseudo-transient (PT) method is the matrix-free iterative method to solve elliptic PDEs by utilising the analogy to transient physics.
- Using the optimal iteration parameters is essential to ensure the fast convergence of the PT method.
"""

# ╔═╡ 413647f6-7a93-49e3-a517-b8ef158f670f
md"""
# Julia's REPL, the Package manager (Pkg.jl), and essential packages

## Julia package manager

Docs:
- [short](https://docs.julialang.org/en/v1/stdlib/Pkg/)
- [detailed](https://pkgdocs.julialang.org/v1/)

Powerful package manager:
- installing, updating and removing packages
  - this also includes dependencies such as C/Fortan libs, Python/Conda environments, etc.
- separate environments for separate projects

## Essential packages for your global environment

Packages installed in your global environment are always available, thus useful for utility packages.

I have installed in my global environment:
- [Revise.jl](https://github.com/timholy/Revise.jl) --
  To load it at startup: `mkdir -p ~/.julia/config/ && echo "using Revise" >> ~/.julia/config/startup.jl`
- [BenchmarkTools.jl](https://github.com/timholy/Revise.jl) --
  Accurate timers for benchmarking, even quick fast running functions
- [IJulia.jl](https://github.com/JuliaLang/IJulia.jl) --
  The Julia Jupyter kernel.  Needs to be installed globally.
- [Makie.jl](https://github.com/MakieOrg/Makie.jl)
- [Infiltrator.jl](https://github.com/JuliaDebug/Infiltrator.jl) --
  A debugger.  Pretty basic but works well without slowing down program execution (unlike Debugger.jl which has more features).
- [StatProfilerHTML.jl](https://github.com/tkluck/StatProfilerHTML.jl) or [ProfileView.jl](https://github.com/timholy/ProfileView.jl/) --
  To be used with the built in `Profile` module.  Displays nice flame graphs (probably does not work on the GPU)

## Julia Project environments: usage in this course

You will make use of Julia environments to submit your homework:

- In your project folder, which is push to GitHub, make sure to create a new folder for each week's exercises.
- Each week's folder should be a Julia project, i.e. it should contain a `Project.toml` file.

## How to do this

This can be achieved by typing entering the Pkg mode from the Julia REPL in the target folder

```julia-repl
julia> ]

(@v1.12) pkg> activate .

(lectureXX) pkg> add Plots
```

and adding at least one package.

In addition, it is recommended to have the following structure and content:
- lectureXX
  - `README.md`
  - `Project.toml`
  - `Manifest.toml`
  - docs/
  - scripts/

Codes could be placed in the `scripts/` folder. Output material to be displayed in the `README.md` could be placed in the `docs/` folder.

!!! note
    The `Manifest.toml` file should be kept local. An automated way of doing so is to add it as entry to a `.gitignore` file in the root of your repo. Mac users may also add `.DS_Store` to their **global** `.gitignore`.
"""

# ╔═╡ 9ec2acf5-850d-4d7b-b185-f65965a19250
# helper function to animate the loop in Pluto live
macro animate(fig, nvis, loop)
	loop.head == :for || error("`@animate` can only be used with `for` loops")
	iter_expr = loop.args[1]
	iter_var = iter_expr.args[1]
	iter_range = iter_expr.args[2]
	body = loop.args[2]
	return quote
		iframe = first($(esc(iter_range)))
		CairoMakie.Makie.Record($(esc(fig)), $(esc(iter_range))[1:$(esc(nvis)):end]; framerate=30, compression=35) do _
			for i in 1:$(esc(nvis))
				$(esc(iter_var)) = iframe
				$(esc(body))
				iframe += 1
			end
		end
	end
end;

# ╔═╡ 422426d3-cad1-4e18-a73b-aa02cfe4422d
function damped_wave_equation_1d(ζ)
	# physics
	# lx   = ...
	# numerics
	nx   = 200
	nt   = 10nx
	nvis = 20
	# preprocessing
	dx   = lx / nx
	dτ   = 0.95dx
	xc   = LinRange(dx/2, lx-dx/2, nx)
	# initialisation
	# u    = ...
	# v    = zeros(...)
	# τ and u(max) history
	τs  = [0.0]
	us  = [u[end÷2]]
	# figure
	fig = Figure(size=(600, 400))
	ax  = (Axis(fig[1, 1]; xlabel="x", ylabel="u"),
           Axis(fig[2, 1]; xlabel="τ", ylabel="uᵐ", limits=(0, nt*dτ, -0.5, 1)))
	ylims!(ax[1], -1.1, 1.1)
	lines!(ax[1], xc, u; color=:blue)
	plt = (lines!(ax[1], xc, u; color=:red),
           lines!(ax[2], τs, us; color=:red))
	# time loop
	@animate fig nvis for iter in 1:nt
		# update solution
		# u[2:end-1] .= ...
		# update rate of change
		# v .= ...
		if iter % nvis == 0
			# push!(τs, ...)
			# push!(us, ...)
			plt[1][2] = u
			plt[2][1] = τs
			plt[2][2] = us
		end
	end
end

# ╔═╡ 1b168a45-12ad-4ef6-bd4c-347c2d0737a7
function __damped_wave_equation_1d(ζ)
	# physics
	lx   = π
	# numerics
	nx   = 200
	nt   = 10nx
	nvis = 20
	# preprocessing
	dx   = lx / nx
	dτ   = 0.95dx
	xc   = LinRange(dx/2, lx-dx/2, nx)
	# initialisation
	u    = @. sin(xc)
	v    = zeros(nx-2)
	# τ and u(max) history
	τs  = [0.0]
	us  = [u[end÷2]]
	# figure
	fig = Figure(size=(600, 400))
	ax  = (Axis(fig[1, 1]; xlabel="x", ylabel="u"),
           Axis(fig[2, 1]; xlabel="τ", ylabel="uᵐ", limits=(0, nt*dτ, -0.5, 1)))
	ylims!(ax[1], -1.1, 1.1)
	lines!(ax[1], xc, u; color=:blue)
	plt = (lines!(ax[1], xc, u; color=:red),
           lines!(ax[2], τs, us; color=:red))
	# time loop
	@animate fig nvis for iter in 1:nt
		# update solution
		u[2:end-1] .= u[2:end-1] .+ dτ .* v
		# update rate of change
		v .= v .* (1 - dτ * ζ) .+ dτ .* diff(diff(u)./dx)./dx
		if iter % nvis == 0
			push!(τs, iter * dτ)
			push!(us, u[end÷2])
			plt[1][2] = u
			plt[2][1] = τs
			plt[2][2] = us
		end
	end
end;

# ╔═╡ 9ac461dc-f268-4e36-ad24-c0b783913eb0
Foldable("Show animation", __damped_wave_equation_1d(0.5))

# ╔═╡ 2a99ad7e-bf27-4201-ad9f-937465f39983
@views function __elliptic_1d()
	# physics
	lx   = 20.0
	λbg  = 1.0
	λamp = 10.0
	# numerics
	nx    = 200
	εtol  = 1e-6
	niter = 15nx
	nchck = ceil(Int, 0.1nx)
	# preprocessing
	dx   = lx / nx
	xc   = LinRange(dx/2,lx-dx/2,nx)
	xv   = LinRange(dx,lx-dx,nx-1)
	β    = 1 - 1.3π / nx
	α 	 = 0.99 * (1 + β)
	# array initialisation
	u    = zeros(nx)
	λ    = @. λbg + λamp * exp(-(xv-lx/2)^2)
	qx   = zeros(nx-1)
	d    = zeros(nx-2)
	r    = zeros(nx-2)
	z    = zeros(nx-2)
	# preconditioner
	Q    = @. dx^2 / (λ[1:end-1] + λ[2:end])
	# convergence history
	itr_h = Float64[]
	res_h = Float64[]
	# time loop
	for iter = 1:niter
		# update solution
		@. u[2:end-1] += α * d
		# boundary conditions
		u[1]   = 0
		u[end] = 1
		# compute residual
	    @. qx = -λ * (u[2:end] - u[1:end-1]) / dx
		@. r  = -(qx[2:end] - qx[1:end-1]) / dx
		# check convergence
		if iter % nchck == 0
			err = maximum(abs, r)
			push!(itr_h, iter / nx)
			push!(res_h, err)
			if err < εtol
				println(" solver converged in $(iter/nx) × N iterations! 🚀")
				break
			end
		end
		# compute preconditioned residual
		@. z = Q * r
		# update search direction
		@. d = d * β + z
	end
	# create plot
	fig = Figure(size=(600, 450))
	ax  = (Axis(fig[1,1]; xlabel="x", ylabel="u", title="solution"),
           Axis(fig[2,1]; xlabel="iter/nx", ylabel="|r|",
                              yscale=log10,
                              title="convergence history",
                              limits=(0, niter/nx, 0.1εtol, 1e2)))
	plt = (lines!(ax[1], xc, u; color=:red),
           lines!(ax[2], itr_h, res_h; color=:black))
	return fig
end;

# ╔═╡ 52f8350d-69ab-4ae7-a7a5-f9ba73af3558
Foldable("See the result", __elliptic_1d())

# ╔═╡ cfbead9d-3f84-4d2f-8b5b-a537a428f9ab
@views function __elliptic_1d_dr()
	# physics
	lx   = 20.0
	λbg  = 1.0
	λamp = 10.0
	# numerics
	nx    = 1000
	εtol  = 1e-6
	niter = 15nx
	nchck = ceil(Int, 0.1nx)
	ndrel = 10
	# preprocessing
	dx   = lx / nx
	xc   = LinRange(dx/2,lx-dx/2,nx)
	xv   = LinRange(dx,lx-dx,nx-1)
	β    = 1 - 2π / nx
	# array initialisation
	u    = zeros(nx)
	λ    = @. λbg + λamp * exp(-(xv-lx/2)^2)
	qx   = zeros(nx-1)
	d    = zeros(nx-2)
	r    = zeros(nx-2)
	z    = zeros(nx-2)
	z0   = zeros(nx-2)
	# preconditioner
	Q    = @. dx^2 / (λ[1:end-1] + λ[2:end])
	# convergence history
	itr_h = Float64[]
	res_h = Float64[]
	# time loop
	for iter = 1:niter
		# update solution
		α = 0.99 * (1 + β)
		@. u[2:end-1] += α * d
		# boundary conditions
		u[1]   = 0
		u[end] = 1
		# compute residual
	    @. qx = -λ * (u[2:end] - u[1:end-1]) / dx
		@. r  = -(qx[2:end] - qx[1:end-1]) / dx
		# check convergence
		if iter % nchck == 0
			err = maximum(abs, r)
			push!(itr_h, iter / nx)
			push!(res_h, err)
			if err < εtol
				println(" solver converged in $(iter/nx) × N iterations! 🚀")
				break
			end
		end
		# save old z
		if iter % ndrel == 0
			@. z0 = z
		end
		# compute preconditioned residual
		@. z = Q * r
		# update β
		if iter % ndrel == 0
			A = abs(dot(d, z .- z0)) / dot(d, d)
			β = (1 - sqrt(A))^2
		end
		# update search direction
		@. d = d * β + z
	end
	# create plot
	fig = Figure(size=(600, 450))
	ax  = (Axis(fig[1,1]; xlabel="x", ylabel="u", title="solution"),
           Axis(fig[2,1]; xlabel="iter/nx", ylabel="|r|",
                              yscale=log10,
                              title="convergence history",
                              limits=(0, niter/nx, 0.1εtol, 1e2)))
	plt = (lines!(ax[1], xc, u; color=:red),
           lines!(ax[2], itr_h, res_h; color=:black))
	return fig
end;

# ╔═╡ c476cec3-a5b3-4941-b8d3-3325f58407dc
Foldable("See the result", __elliptic_1d_dr())

# ╔═╡ 26f5dba7-41cd-492c-a9e8-918231979d4f
@views function __steady_diffusion_reaction_1d()
	# physics
	lx   = 20.0
	λbg  = 1.0
	λamp = 10.0
	u_eq = 0.1
	ξ    = 50.0
	# numerics
	nx    = 1000
	εtol  = 1e-6
	niter = 15nx
	nchck = ceil(Int, 0.1nx)
	ndrel = 10
	# preprocessing
	dx   = lx / nx
	xc   = LinRange(dx/2,lx-dx/2,nx)
	xv   = LinRange(dx,lx-dx,nx-1)
	β    = 1 - 2π / nx
	# array initialisation
	u    = zeros(nx)
	λ    = @. λbg + λamp * exp(-(xv-lx/2)^2)
	qx   = zeros(nx-1)
	d    = zeros(nx-2)
	r    = zeros(nx-2)
	z    = zeros(nx-2)
	z0   = zeros(nx-2)
	# preconditioner
	Q    = @. inv((λ[1:end-1] + λ[2:end]) / dx^2 + 1 / ξ)
	# convergence history
	itr_h = Float64[]
	res_h = Float64[]
	# time loop
	for iter = 1:niter
		# update solution
		α = 0.99 * (1 + β)
		@. u[2:end-1] += α * d
		# boundary conditions
		u[1]   = 0
		u[end] = 1
		# compute residual
	    @. qx = -λ * (u[2:end] - u[1:end-1]) / dx
		@. r  = -(qx[2:end] - qx[1:end-1]) / dx - (u[2:end-1] - u_eq) / ξ
		# check convergence
		if iter % nchck == 0
			err = maximum(abs, r)
			push!(itr_h, iter / nx)
			push!(res_h, err)
			if err < εtol
				println(" solver converged in $(iter/nx) × N iterations! 🚀")
				break
			end
		end
		# save old z
		if iter % ndrel == 0
			@. z0 = z
		end
		# compute preconditioned residual
		@. z = Q * r
		# update β
		if iter % ndrel == 0
			A = abs(dot(d, z .- z0)) / dot(d, d)
			β = (1 - sqrt(A))^2
		end
		# update search direction
		@. d = d * β + z
	end
	# create plot
	fig = Figure(size=(600, 450))
	ax  = (Axis(fig[1,1]; xlabel="x", ylabel="u", title="solution"),
           Axis(fig[2,1]; xlabel="iter/nx", ylabel="|r|",
                              yscale=log10,
                              title="convergence history",
                              limits=(0, niter/nx, 0.1εtol, 1e2)))
	plt = (lines!(ax[1], xc, u; color=:red),
           lines!(ax[2], itr_h, res_h; color=:black))
	return fig
end;

# ╔═╡ c0d1d48f-29ae-4d41-817d-1a15f03b0c92
Foldable("See the result", __steady_diffusion_reaction_1d())

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CairoMakie = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
PlutoTeachingTools = "661c6b06-c737-4d37-b85c-46df65de6f69"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
CairoMakie = "~0.15.15"
PlutoTeachingTools = "~0.4.7"
PlutoUI = "~0.7.83"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.12.7"
manifest_format = "2.0"
project_hash = "57635ee8d043dbf27643e69fb54e55bd5840356a"

[[deps.AbstractFFTs]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "d92ad398961a3ed262d8bf04a1a2b8340f915fef"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.5.0"
weakdeps = ["ChainRulesCore", "Test"]

    [deps.AbstractFFTs.extensions]
    AbstractFFTsChainRulesCoreExt = "ChainRulesCore"
    AbstractFFTsTestExt = "Test"

[[deps.AbstractPlutoDingetjes]]
git-tree-sha1 = "e71ee7b4aa06b045259a7d6101e1cb45ad140bce"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.4.1"

[[deps.AbstractTrees]]
git-tree-sha1 = "2d9c9a55f9c93e8887ad391fbae72f8ef55e1177"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.4.5"

[[deps.Accessors]]
deps = ["CompositionsBase", "ConstructionBase", "Dates", "InverseFunctions", "MacroTools"]
git-tree-sha1 = "7063ad1083578215c7c4bf410368150abe8d5524"
uuid = "7d9f7c33-5ae7-4f3b-8dc6-eff91059b697"
version = "0.1.45"

    [deps.Accessors.extensions]
    AxisKeysExt = "AxisKeys"
    IntervalSetsExt = "IntervalSets"
    LinearAlgebraExt = "LinearAlgebra"
    StaticArraysExt = "StaticArrays"
    StructArraysExt = "StructArrays"
    TestExt = "Test"
    UnitfulExt = "Unitful"

    [deps.Accessors.weakdeps]
    AxisKeys = "94b1ba4f-4ee9-5380-92f1-94cde586c3c5"
    IntervalSets = "8197267c-284f-5f27-9208-e0e47529a953"
    LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"
    StructArrays = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
    Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[[deps.Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "7c2c19b5a26e601634bf718490b89d59685f122e"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "4.7.1"
weakdeps = ["SparseArrays", "StaticArrays"]

    [deps.Adapt.extensions]
    AdaptSparseArraysExt = "SparseArrays"
    AdaptStaticArraysExt = "StaticArrays"

[[deps.AdaptivePredicates]]
git-tree-sha1 = "7e651ea8d262d2d74ce75fdf47c4d63c07dba7a6"
uuid = "35492f91-a3bd-45ad-95db-fcad7dcfedb7"
version = "1.2.0"

[[deps.AliasTables]]
deps = ["PtrArrays", "Random"]
git-tree-sha1 = "9876e1e164b144ca45e9e3198d0b689cadfed9ff"
uuid = "66dad0bd-aa9a-41b7-9441-69ab47430ed8"
version = "1.1.3"

[[deps.Animations]]
deps = ["Colors"]
git-tree-sha1 = "e092fa223bf66a3c41f9c022bd074d916dc303e7"
uuid = "27a7e980-b3e6-11e9-2bcd-0b925532e340"
version = "0.4.2"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Automa]]
deps = ["PrecompileTools", "TranscodingStreams"]
git-tree-sha1 = "94eab0b3ccdcac361188cc661daf69d4433c1818"
uuid = "67c07d97-cdcb-5c2c-af73-a7f9c32a568b"
version = "1.2.0"

[[deps.AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "01b8ccb13d68535d73d2b0c23e39bd23155fb712"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.1.0"

[[deps.AxisArrays]]
deps = ["Dates", "IntervalSets", "IterTools", "RangeArrays"]
git-tree-sha1 = "4126b08903b777c88edf1754288144a0492c05ad"
uuid = "39de3d68-74b9-583c-8d2d-e117c070f3a9"
version = "0.4.8"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.BaseDirs]]
git-tree-sha1 = "8c290a1b223deaeea9aea44b235d24546da8eb98"
uuid = "18cc8868-cbac-4acf-b575-c8ff214dc66f"
version = "1.4.0"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1b96ea4a01afe0ea4090c5c8039690672dd13f2e"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.9+0"

[[deps.CEnum]]
git-tree-sha1 = "389ad5c84de1ae7cf0e28e381131c98ea87d54fc"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.5.0"

[[deps.CRC32c]]
uuid = "8bf52ea8-c179-5cab-976a-9e18b702a9bc"
version = "1.11.0"

[[deps.CRlibm]]
deps = ["CRlibm_jll"]
git-tree-sha1 = "66188d9d103b92b6cd705214242e27f5737a1e5e"
uuid = "96374032-68de-5a5b-8d9e-752f78720389"
version = "1.0.2"

[[deps.CRlibm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e329286945d0cfc04456972ea732551869af1cfc"
uuid = "4e9b3aee-d8a1-5a3d-ad8b-7d824db253f0"
version = "1.0.1+0"

[[deps.Cairo]]
deps = ["Cairo_jll", "Colors", "Glib_jll", "Graphics", "Libdl", "Pango_jll"]
git-tree-sha1 = "71aa551c5c33f1a4415867fe06b7844faadb0ae9"
uuid = "159f3aea-2a34-519c-b102-8c37f9878175"
version = "1.1.1"

[[deps.CairoMakie]]
deps = ["CRC32c", "Cairo", "Cairo_jll", "Colors", "FileIO", "FreeType", "GeometryBasics", "LinearAlgebra", "Makie", "PrecompileTools"]
git-tree-sha1 = "1cda0b7d5abfc95357dae18aca934d401f7869ad"
uuid = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
version = "0.15.15"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "Libdl", "Pixman_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "1fa950ebc3e37eccd51c6a8fe1f92f7d86263522"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.18.7+0"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra"]
git-tree-sha1 = "12177ad6b3cad7fd50c8b3825ce24a99ad61c18f"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.26.1"
weakdeps = ["SparseArrays"]

    [deps.ChainRulesCore.extensions]
    ChainRulesCoreSparseArraysExt = "SparseArrays"

[[deps.CodecZstd]]
deps = ["TranscodingStreams", "Zstd_jll"]
git-tree-sha1 = "da54a6cd93c54950c15adf1d336cfd7d71f51a56"
uuid = "6b39b394-51ab-5f42-8807-6242bab2b4c2"
version = "0.8.7"

[[deps.ColorBrewer]]
deps = ["Colors", "JSON"]
git-tree-sha1 = "07da79661b919001e6863b81fc572497daa58349"
uuid = "a2cac450-b92f-5266-8821-25eda20663c8"
version = "0.4.2"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "b0fd3f56fa442f81e0a47815c92245acfaaa4e34"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.31.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "67e11ee83a43eb71ddc950302c53bf33f0690dfe"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.12.1"
weakdeps = ["StyledStrings"]

    [deps.ColorTypes.extensions]
    StyledStringsExt = "StyledStrings"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "Requires", "Statistics", "TensorCore"]
git-tree-sha1 = "8b3b6f87ce8f65a2b4f857528fd8d70086cd72b1"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.11.0"
weakdeps = ["SpecialFunctions"]

    [deps.ColorVectorSpace.extensions]
    SpecialFunctionsExt = "SpecialFunctions"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "37ea44092930b1811e666c3bc38065d7d87fcc74"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.13.1"

[[deps.CommonSolve]]
deps = ["PrecompileTools"]
git-tree-sha1 = "6c389fa857f6ca5a95474b52a52023fd77f24cb7"
uuid = "38540f10-b2f7-11e9-35d8-d573e4eb0ff2"
version = "0.2.14"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "9d8a54ce4b17aa5bdce0ea5c34bc5e7c340d16ad"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.18.1"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.3.1+2"

[[deps.CompositionsBase]]
git-tree-sha1 = "802bb88cd69dfd1509f6670416bd4434015693ad"
uuid = "a33af91c-f02d-484b-be07-31d278c5ca2b"
version = "0.1.2"
weakdeps = ["InverseFunctions"]

    [deps.CompositionsBase.extensions]
    CompositionsBaseInverseFunctionsExt = "InverseFunctions"

[[deps.ComputePipeline]]
deps = ["Observables", "Preferences"]
git-tree-sha1 = "7bc84b769c1d384315e7b5c4ac03a6c303e6cf35"
uuid = "95dc2771-c249-4cd0-9c9f-1f3b4330693c"
version = "0.1.8"

[[deps.ConstructionBase]]
git-tree-sha1 = "b4b092499347b18a015186eae3042f72267106cb"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.6.0"
weakdeps = ["IntervalSets", "LinearAlgebra", "StaticArrays"]

    [deps.ConstructionBase.extensions]
    ConstructionBaseIntervalSetsExt = "IntervalSets"
    ConstructionBaseLinearAlgebraExt = "LinearAlgebra"
    ConstructionBaseStaticArraysExt = "StaticArrays"

[[deps.Contour]]
git-tree-sha1 = "439e35b0b36e2e5881738abc8857bd92ad6ff9a8"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.3"

[[deps.CoreMath]]
deps = ["CoreMath_jll"]
git-tree-sha1 = "8c0480f92b1b1796239156a1b9b1bfb1b39499b4"
uuid = "b7a15901-be09-4a0e-87d2-2e66b0e09b5a"
version = "0.1.0"

[[deps.CoreMath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a692a4c1dc59a4b8bc0b6403876eb3250fde2bc3"
uuid = "a38c48d9-6df1-5ac9-9223-b6ada3b5572b"
version = "0.1.0+0"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataStructures]]
deps = ["OrderedCollections"]
git-tree-sha1 = "b0bc6d2cad1fed8b7fd59a1551a991cb3d2809e6"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.19.6"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.DelaunayTriangulation]]
deps = ["AdaptivePredicates", "EnumX", "ExactPredicates", "Random"]
git-tree-sha1 = "4ac548adcad90c1d5d677af13568a748af4c952b"
uuid = "927a84f5-c5f4-47a5-9785-b46e178433df"
version = "1.6.7"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"
version = "1.11.0"

[[deps.Distributions]]
deps = ["AliasTables", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "Roots", "SpecialFunctions", "Statistics", "StatsAPI", "StatsBase", "StatsFuns"]
git-tree-sha1 = "a958ab3a40c755563f5e1405c0846cb0446bf19d"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.131"

    [deps.Distributions.extensions]
    DistributionsChainRulesCoreExt = "ChainRulesCore"
    DistributionsDensityInterfaceExt = "DensityInterface"
    DistributionsSparseConnectivityTracerExt = "SparseConnectivityTracer"
    DistributionsTestExt = "Test"

    [deps.Distributions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    DensityInterface = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
    SparseConnectivityTracer = "9f842d2f-2579-4b1d-911e-f412cf18a3f5"
    Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.DocStringExtensions]]
git-tree-sha1 = "7442a5dfe1ebb773c29cc2962a8980f47221d76c"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.5"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.7.0"

[[deps.EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e3290f2d49e661fbd94046d7e3726ffcb2d41053"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.4+0"

[[deps.EnumX]]
git-tree-sha1 = "c49898e8438c828577f04b92fc9368c388ac783c"
uuid = "4e289a0a-7415-4d19-859d-a7e5c4648b56"
version = "1.0.7"

[[deps.ExactPredicates]]
deps = ["IntervalArithmetic", "Random", "StaticArrays"]
git-tree-sha1 = "83231673ea4d3d6008ac74dc5079e77ab2209d8f"
uuid = "429591f6-91af-11e9-00e2-59fbe8cec110"
version = "2.2.9"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "2bfb1e047e2ad0a5ca94365340bde8005d637568"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.8.4+0"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libva_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "e3c081ec777297fb8fc433012d15a6eaf806b4d2"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "9.0.1+0"

[[deps.FFTA]]
deps = ["AbstractFFTs", "DocStringExtensions", "LinearAlgebra", "MuladdMacro", "Primes", "Random", "Reexport"]
git-tree-sha1 = "65e55303b72f4a567a51b174dd2c47496efeb95a"
uuid = "b86e33f2-c0db-4aa1-a6e0-ab43e668529e"
version = "0.3.1"

[[deps.FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "6621fef488e496356c9c9625d0562c12a6070819"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.20.0"

    [deps.FileIO.extensions]
    HTTPExt = "HTTP"

    [deps.FileIO.weakdeps]
    HTTP = "cd3eb016-35fb-5094-929b-558a96fad6f3"

[[deps.FilePaths]]
deps = ["FilePathsBase", "MacroTools", "Reexport"]
git-tree-sha1 = "a1b2fbfe98503f15b665ed45b3d149e5d8895e4c"
uuid = "8fc22ac5-c921-52a6-82fd-178b2807b824"
version = "0.9.0"

    [deps.FilePaths.extensions]
    FilePathsGlobExt = "Glob"
    FilePathsURIParserExt = "URIParser"
    FilePathsURIsExt = "URIs"

    [deps.FilePaths.weakdeps]
    Glob = "c27321d9-0574-5035-807b-f59d2c89b15c"
    URIParser = "30578b45-9adc-5946-b283-645ec420af67"
    URIs = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"

[[deps.FilePathsBase]]
deps = ["Compat", "Dates"]
git-tree-sha1 = "3bab2c5aa25e7840a4b065805c0cdfc01f3068d2"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.24"
weakdeps = ["Mmap", "Test"]

    [deps.FilePathsBase.extensions]
    FilePathsBaseMmapExt = "Mmap"
    FilePathsBaseTestExt = "Test"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FillArrays]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "086b5fbd032baf544678cc15b52b015e4c4aceb8"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "1.17.1"
weakdeps = ["PDMats", "SparseArrays", "StaticArrays", "Statistics"]

    [deps.FillArrays.extensions]
    FillArraysPDMatsExt = "PDMats"
    FillArraysSparseArraysExt = "SparseArrays"
    FillArraysStaticArraysExt = "StaticArrays"
    FillArraysStatisticsExt = "Statistics"

[[deps.FixedPointNumbers]]
deps = ["Random", "Statistics"]
git-tree-sha1 = "59af96b98217c6ef4ae0dfe065ac7c20831d1a84"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.6"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Zlib_jll"]
git-tree-sha1 = "f85dac9a96a01087df6e3a749840015a0ca3817d"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.17.1+0"

[[deps.Format]]
git-tree-sha1 = "9c68794ef81b08086aeb32eeaf33531668d5f5fc"
uuid = "1fa38f19-a742-5d3f-a2b9-30dd87b9d5f8"
version = "1.3.7"

[[deps.FreeType]]
deps = ["CEnum", "FreeType2_jll"]
git-tree-sha1 = "907369da0f8e80728ab49c1c7e09327bf0d6d999"
uuid = "b38be410-82b0-50bf-ab77-7b57e271db43"
version = "4.1.1"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "70329abc09b886fd2c5d94ad2d9527639c421e3e"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.14.3+1"

[[deps.FreeTypeAbstraction]]
deps = ["BaseDirs", "ColorVectorSpace", "Colors", "FreeType", "GeometryBasics", "Mmap"]
git-tree-sha1 = "4ebb930ef4a43817991ba35db6317a05e59abd11"
uuid = "663a7486-cb36-511b-a19d-713bb74d65c9"
version = "0.10.8"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "7a214fdac5ed5f59a22c2d9a885a16da1c74bbc7"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.17+0"

[[deps.Gamma]]
deps = ["LogExpFunctions"]
git-tree-sha1 = "becc397f7cfb06e343496ae6ffb04818a851da51"
uuid = "a0844989-3bd2-4988-8bea-c9407ab0941b"
version = "1.2.0"

[[deps.GeometryBasics]]
deps = ["EarCut_jll", "LinearAlgebra", "PrecompileTools", "Random", "StaticArrays"]
git-tree-sha1 = "ec46c5825710fa1a15d468acb2d93cc939a7a5fe"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.5.13"

    [deps.GeometryBasics.extensions]
    ExtentsExt = "Extents"
    GeometryBasicsGeoInterfaceExt = "GeoInterface"
    IntervalSetsExt = "IntervalSets"

    [deps.GeometryBasics.weakdeps]
    Extents = "411431e0-e8b7-467b-b5e0-f676ba4f2910"
    GeoInterface = "cf35fbd7-0cd7-5166-be24-54bfbe79505f"
    IntervalSets = "8197267c-284f-5f27-9208-e0e47529a953"

[[deps.GettextRuntime_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll"]
git-tree-sha1 = "45288942190db7c5f760f59c04495064eedf9340"
uuid = "b0724c58-0f36-5564-988d-3bb0596ebc4a"
version = "0.22.4+0"

[[deps.Ghostscript_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Zlib_jll"]
git-tree-sha1 = "38044a04637976140074d0b0621c1edf0eb531fd"
uuid = "61579ee1-b43e-5ca0-a5da-69d92c66a64b"
version = "9.55.1+0"

[[deps.Giflib_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a3efbbc027441271444dcd0c0a46f2d119dc4329"
uuid = "59f7168a-df46-5410-90c8-f2779963d0ec"
version = "6.1.3+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "GettextRuntime_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Zlib_jll"]
git-tree-sha1 = "090526e65de8f69648ac156daae153de8b56df62"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.88.3+0"

[[deps.Graphics]]
deps = ["Colors", "LinearAlgebra", "NaNMath"]
git-tree-sha1 = "a641238db938fff9b2f60d08ed9030387daf428c"
uuid = "a2bd30eb-e257-5431-a919-1863eab51364"
version = "1.1.3"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "69ffb934a5c5b7e086a0b4fee3427db2556fba6e"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.16+0"

[[deps.GridLayoutBase]]
deps = ["GeometryBasics", "InteractiveUtils", "Observables"]
git-tree-sha1 = "ef70da5e123a06a29e2d6ddff0f09985bc226491"
uuid = "3955a311-db13-416c-9275-1d80ed98e5e9"
version = "0.11.3"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll"]
git-tree-sha1 = "9d9531a9cb63a9edc33836414e82a07e81710de2"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "100.14004.0+0"

[[deps.HypergeometricFunctions]]
deps = ["Gamma", "LinearAlgebra"]
git-tree-sha1 = "31bb6c92405c084617facc1d7ed9eb6c402d061e"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.30"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "d1a86724f81bcd184a38fd284ce183ec067d71a0"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "1.0.0"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "0ee181ec08df7d7c911901ea38baf16f755114dc"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "1.0.0"

[[deps.ImageAxes]]
deps = ["AxisArrays", "ImageBase", "ImageCore", "Reexport", "SimpleTraits"]
git-tree-sha1 = "e12629406c6c4442539436581041d372d69c55ba"
uuid = "2803e5a7-5153-5ecf-9a86-9b4c37f5f5ac"
version = "0.6.12"

[[deps.ImageBase]]
deps = ["ImageCore", "Reexport"]
git-tree-sha1 = "eb49b82c172811fd2c86759fa0553a2221feb909"
uuid = "c817782e-172a-44cc-b673-b171935fbb9e"
version = "0.1.7"

[[deps.ImageCore]]
deps = ["ColorVectorSpace", "Colors", "FixedPointNumbers", "MappedArrays", "MosaicViews", "OffsetArrays", "PaddedViews", "PrecompileTools", "Reexport"]
git-tree-sha1 = "8c193230235bbcee22c8066b0374f63b5683c2d3"
uuid = "a09fc81d-aa75-5fe9-8630-4744c3626534"
version = "0.10.5"

[[deps.ImageIO]]
deps = ["FileIO", "IndirectArrays", "JpegTurbo", "LazyModules", "Netpbm", "OpenEXR", "PNGFiles", "QOI", "Sixel", "TiffImages", "UUIDs", "WebP"]
git-tree-sha1 = "f0f005f997dfb8c5fe23920d99458a9619873893"
uuid = "82e4d734-157c-48bb-816b-45c225c6df19"
version = "0.6.10"

[[deps.ImageMetadata]]
deps = ["AxisArrays", "ImageAxes", "ImageBase", "ImageCore"]
git-tree-sha1 = "2a81c3897be6fbcde0802a0ebe6796d0562f63ec"
uuid = "bc367c6b-8a6b-528e-b4bd-a4b897500b49"
version = "0.9.10"

[[deps.Imath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "dcc8d0cd653e55213df9b75ebc6fe4a8d3254c65"
uuid = "905a6f67-0a94-5f89-b386-d35d92009cd1"
version = "3.2.2+0"

[[deps.IndirectArrays]]
git-tree-sha1 = "012e604e1c7458645cb8b436f8fba789a51b257f"
uuid = "9b13fd28-a010-5f03-acff-a1bbcff69959"
version = "1.0.0"

[[deps.Inflate]]
git-tree-sha1 = "d1b1b796e47d94588b3757fe84fbf65a5ec4a80d"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.5"

[[deps.IntegerMathUtils]]
git-tree-sha1 = "c72458f1962faeb003bf23cbdb75164fe6280906"
uuid = "18e54dd8-cb9d-406c-a71d-865a43cbb235"
version = "0.1.4"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.Interpolations]]
deps = ["Adapt", "AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "48922d06068130f87e43edef52382e6a94305ae6"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.16.3"

    [deps.Interpolations.extensions]
    InterpolationsForwardDiffExt = "ForwardDiff"
    InterpolationsUnitfulExt = "Unitful"

    [deps.Interpolations.weakdeps]
    ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[[deps.IntervalArithmetic]]
deps = ["CRlibm", "CoreMath", "MacroTools", "OpenBLASConsistentFPCSR_jll", "Printf", "Random", "RoundingEmulator"]
git-tree-sha1 = "1c531bf0f8a5c60a340926e058fd3f209b5eef5d"
uuid = "d1acc4aa-44c8-5952-acd4-ba5d80a2a253"
version = "1.0.12"

    [deps.IntervalArithmetic.extensions]
    IntervalArithmeticArblibExt = "Arblib"
    IntervalArithmeticDiffRulesExt = "DiffRules"
    IntervalArithmeticForwardDiffExt = "ForwardDiff"
    IntervalArithmeticIntervalSetsExt = "IntervalSets"
    IntervalArithmeticIrrationalConstantsExt = "IrrationalConstants"
    IntervalArithmeticLinearAlgebraExt = "LinearAlgebra"
    IntervalArithmeticMakieExt = "Makie"
    IntervalArithmeticRecipesBaseExt = "RecipesBase"
    IntervalArithmeticSparseArraysExt = "SparseArrays"

    [deps.IntervalArithmetic.weakdeps]
    Arblib = "fb37089c-8514-4489-9461-98f9c8763369"
    DiffRules = "b552c78f-8df3-52c6-915a-8e097449b14b"
    ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
    IntervalSets = "8197267c-284f-5f27-9208-e0e47529a953"
    IrrationalConstants = "92d709cd-6900-40b7-9082-c6be49f344b6"
    LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
    Makie = "ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a"
    RecipesBase = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.IntervalSets]]
git-tree-sha1 = "79d6bd28c8d9bccc2229784f1bd637689b256377"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.7.14"

    [deps.IntervalSets.extensions]
    IntervalSetsRandomExt = "Random"
    IntervalSetsRecipesBaseExt = "RecipesBase"
    IntervalSetsStatisticsExt = "Statistics"

    [deps.IntervalSets.weakdeps]
    Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
    RecipesBase = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
    Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.InverseFunctions]]
git-tree-sha1 = "a779299d77cd080bf77b97535acecd73e1c5e5cb"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.17"
weakdeps = ["Dates", "Test"]

    [deps.InverseFunctions.extensions]
    InverseFunctionsDatesExt = "Dates"
    InverseFunctionsTestExt = "Test"

[[deps.IrrationalConstants]]
git-tree-sha1 = "b2d91fe939cae05960e760110b328288867b5758"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.6"

[[deps.Isoband]]
deps = ["isoband_jll"]
git-tree-sha1 = "f9b6d97355599074dc867318950adaa6f9946137"
uuid = "f1662d9f-8043-43de-a69a-05efc1cc6ff4"
version = "0.1.1"

[[deps.IterTools]]
git-tree-sha1 = "42d5f897009e7ff2cf88db414a389e5ed1bdd023"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.10.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "7204148362dafe5fe6a273f855b8ccbe4df8173e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.8.0"

[[deps.JSON]]
deps = ["Dates", "Logging", "Parsers", "PrecompileTools", "StructUtils", "UUIDs", "Unicode"]
git-tree-sha1 = "633b5a34494e711f694ccbc88a6e00102f10238c"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "1.9.0"

    [deps.JSON.extensions]
    JSONArrowExt = ["ArrowTypes"]

    [deps.JSON.weakdeps]
    ArrowTypes = "31f734f8-188a-4ce0-8406-c8a06bd891cd"

[[deps.JpegTurbo]]
deps = ["CEnum", "FileIO", "ImageCore", "JpegTurbo_jll", "TOML"]
git-tree-sha1 = "9496de8fb52c224a2e3f9ff403947674517317d9"
uuid = "b835a17e-a41a-41e7-81f0-2f016b05efe0"
version = "0.1.6"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "037babc10853eeb8e585418922246cb97b8e5b74"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "3.2.0+1"

[[deps.JuliaSyntaxHighlighting]]
deps = ["StyledStrings"]
uuid = "ac6e5ff7-fb65-4e79-a425-ec3bc9c03011"
version = "1.12.0"

[[deps.KernelDensity]]
deps = ["Distributions", "DocStringExtensions", "FFTA", "Interpolations", "StatsBase"]
git-tree-sha1 = "9eda8292dd3268b3b7ec9df21bbfac24e177ec52"
uuid = "5ab0869b-81aa-558d-bb23-cbf5423bbe9b"
version = "0.6.12"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "059aabebaa7c82ccb853dd4a0ee9d17796f7e1bc"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.3+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "39bca05343661c347aae0bca57a5994a0bf4f08d"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "4.2.0+0"

[[deps.LLVMOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e5b100780d4d30d63b4618d7930d48af409c1772"
uuid = "1d63c593-3942-5779-bab2-d838dc0a180e"
version = "23.1.1+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f88f3ccef05a6a72a0cf0ed417c8fd68530f4ab2"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.4.1"

[[deps.Latexify]]
deps = ["Format", "Ghostscript_jll", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Requires"]
git-tree-sha1 = "df7566479bd64f20bd16b09960145e70160ffb3b"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.16.12"

    [deps.Latexify.extensions]
    DataFramesExt = "DataFrames"
    SparseArraysExt = "SparseArrays"
    SymEngineExt = "SymEngine"
    TectonicExt = "tectonic_jll"

    [deps.Latexify.weakdeps]
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    SymEngine = "123dc426-2d89-5057-bbad-38513e3affd8"
    tectonic_jll = "d7dd28d6-a5e6-559c-9131-7eb760cdacc5"

[[deps.LazyModules]]
git-tree-sha1 = "a560dd966b386ac9ae60bdd3a3d3a326062d3c3e"
uuid = "8cdb02fc-e678-4876-92c5-9defec4f444e"
version = "0.3.1"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "OpenSSL_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.15.0+0"

[[deps.LibGit2]]
deps = ["LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"
version = "1.11.0"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "OpenSSL_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.9.0+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "OpenSSL_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.3+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "c8da7e6a91781c41a863611c7e966098d783c57a"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.4.7+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "d36c21b9e7c172a44a10484125024495e2625ac0"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.7.1+1"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "be484f5c92fad0bd8acfef35fe017900b0b73809"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.18.0+0"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "cc3ad4faf30015a3e8094c9b5b7f19e85bdf2386"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.42.0+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "XZ_jll", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "aebd334d06cee9f24cea70bd19a39749daf73881"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.7.3+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "d620582b1f0cbe2c72dd1d5bd195a9ce73370ab1"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.42.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.12.0"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "bba2d9aa057d8f126415de240573e86a8f39d2a1"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "1.0.1"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"
version = "1.11.0"

[[deps.MIMEs]]
git-tree-sha1 = "c64d943587f7187e751162b3b84445bbbd79f691"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "1.1.0"

[[deps.MacroTools]]
git-tree-sha1 = "1e0228a030642014fe5cfe68c2c0a818f9e3f522"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.16"

[[deps.Makie]]
deps = ["Animations", "Base64", "CRC32c", "ColorBrewer", "ColorSchemes", "ColorTypes", "Colors", "ComputePipeline", "Contour", "Dates", "DelaunayTriangulation", "Distributions", "DocStringExtensions", "Downloads", "FFMPEG_jll", "FileIO", "FilePaths", "FixedPointNumbers", "Format", "FreeType", "FreeTypeAbstraction", "GeometryBasics", "GridLayoutBase", "ImageBase", "ImageIO", "InteractiveUtils", "Interpolations", "IntervalSets", "InverseFunctions", "Isoband", "KernelDensity", "LaTeXStrings", "LinearAlgebra", "MacroTools", "Markdown", "MathTeXEngine", "Observables", "OffsetArrays", "PNGFiles", "Packing", "Pkg", "PlotUtils", "PolygonOps", "PrecompileTools", "Printf", "REPL", "Random", "RelocatableFolders", "Scratch", "ShaderAbstractions", "SignedDistanceFields", "SparseArrays", "Statistics", "StatsBase", "StatsFuns", "StructArrays", "TriplotBase", "UnicodeFun", "Unitful"]
git-tree-sha1 = "5f6f5d1b1fb7ff98c9a083bbfd4c661a9808e758"
uuid = "ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a"
version = "0.24.15"

    [deps.Makie.extensions]
    MakieDynamicQuantitiesExt = "DynamicQuantities"

    [deps.Makie.weakdeps]
    DynamicQuantities = "06fc5a27-2a28-4c7c-a15d-362465fb6821"

[[deps.MappedArrays]]
git-tree-sha1 = "0ee4497a4e80dbd29c058fcee6493f5219556f40"
uuid = "dbb5928d-eab1-5f90-85c2-b9b0edb7c900"
version = "0.4.3"

[[deps.Markdown]]
deps = ["Base64", "JuliaSyntaxHighlighting", "StyledStrings"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.MathTeXEngine]]
deps = ["AbstractTrees", "Automa", "DataStructures", "FreeTypeAbstraction", "GeometryBasics", "LaTeXStrings", "REPL", "RelocatableFolders", "UnicodeFun"]
git-tree-sha1 = "aa1078778be5a8e5259ff04fbc3d258b3e78d464"
uuid = "0a4f8689-d25c-4efe-a92b-7142dfc1aa53"
version = "0.6.9"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "ec4f7fbeab05d7747bdf98eb74d130a2a2ed298d"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.2.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"
version = "1.11.0"

[[deps.MosaicViews]]
deps = ["MappedArrays", "OffsetArrays", "PaddedViews", "StackViews"]
git-tree-sha1 = "7b86a5d4d70a9f5cdf2dacb3cbe6d251d1a61dbe"
uuid = "e94cdb99-869f-56ef-bcf0-1ae2bcbe0389"
version = "0.3.4"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2025.11.4"

[[deps.MuladdMacro]]
deps = ["PrecompileTools"]
git-tree-sha1 = "283bf85d4a767481dd924dff0eee1735e95f449e"
uuid = "46d2c3a1-f734-5fdb-9937-b9b9aeba4221"
version = "0.2.7"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "dbd2e8cd2c1c27f0b584f6661b4309609c5a685e"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.1.4"

[[deps.Netpbm]]
deps = ["FileIO", "ImageCore", "ImageMetadata"]
git-tree-sha1 = "d92b107dbb887293622df7697a2223f9f8176fcd"
uuid = "f09324ee-3d7c-5217-9330-fc30815ba969"
version = "1.1.1"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.3.0"

[[deps.Observables]]
git-tree-sha1 = "7438a59546cf62428fc9d1bc94729146d37a7225"
uuid = "510215fc-4207-5dde-b226-833fc4488ee2"
version = "0.5.5"

[[deps.OffsetArrays]]
git-tree-sha1 = "117432e406b5c023f665fa73dc26e79ec3630151"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.17.0"
weakdeps = ["Adapt"]

    [deps.OffsetArrays.extensions]
    OffsetArraysAdaptExt = "Adapt"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "b6aa4566bb7ae78498a5e68943863fa8b5231b59"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.6+0"

[[deps.OpenBLASConsistentFPCSR_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "38a93f17e431141c6470bb67a88952a7c4f0e928"
uuid = "6cdc7f73-28fd-5e50-80fb-958a8875b1af"
version = "0.3.34+0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.29+0"

[[deps.OpenEXR]]
deps = ["Colors", "FileIO", "OpenEXR_jll"]
git-tree-sha1 = "97db9e07fe2091882c765380ef58ec553074e9c7"
uuid = "52e1d378-f018-4a11-a4be-720524705ac7"
version = "0.3.3"

[[deps.OpenEXR_jll]]
deps = ["Artifacts", "Imath_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "1bcebd887dd33f1108210b3954049b1bb8af0e7a"
uuid = "18a262bb-aa17-5467-a713-aee519bc75cb"
version = "3.4.15+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.7+0"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.5.6+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1346c9208249809840c91b26703912dff463d335"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.6+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e2bb57a313a74b8104064b7efd01406c0a50d2ff"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.6.1+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "05f45c2e0de6259db764adbfd2f1dc6d3f8de13c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "2.0.1"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.44.0+1"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "123266c25174ef6c8d4718920abc206452cf8de6"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.41"
weakdeps = ["StatsBase"]

    [deps.PDMats.extensions]
    StatsBaseExt = "StatsBase"

[[deps.PNGFiles]]
deps = ["Base64", "CEnum", "ImageCore", "IndirectArrays", "OffsetArrays", "libpng_jll"]
git-tree-sha1 = "32b657a0d57c310a1a172bfc8c8cf68c5e674323"
uuid = "f57f5aa1-a3ce-4bc8-8ab9-96f992907883"
version = "0.4.5"

[[deps.Packing]]
deps = ["GeometryBasics"]
git-tree-sha1 = "bc5bf2ea3d5351edf285a06b0016788a121ce92c"
uuid = "19eb6ba3-879d-56ad-ad62-d5c202156566"
version = "0.5.1"

[[deps.PaddedViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "0fac6313486baae819364c52b4f483450a9d793f"
uuid = "5432bcbf-9aad-5242-b902-cca2824c8663"
version = "0.5.12"

[[deps.Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1912a9f1b9ca55005b03ba075f8e19993583e237"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.58.2+0"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools"]
git-tree-sha1 = "663e8b48b789916221e0765393b289ca6c88f24e"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "3.0.0"

[[deps.Pixman_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LLVMOpenMP_jll", "Libdl"]
git-tree-sha1 = "e4a6721aa89e62e5d4217c0b21bd714263779dda"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.46.4+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.12.1"
weakdeps = ["REPL"]

    [deps.Pkg.extensions]
    REPLExt = "REPL"

[[deps.PkgVersion]]
deps = ["Pkg"]
git-tree-sha1 = "f9501cc0430a26bc3d156ae1b5b0c1b47af4d6da"
uuid = "eebad327-c553-4316-9ea0-9fa01ccd7688"
version = "0.3.3"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "PrecompileTools", "Printf", "Reexport", "Statistics"]
git-tree-sha1 = "f20e945b895d2009c6c28d8bbf40a5cd846f7c2f"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.5.0"

[[deps.PlutoTeachingTools]]
deps = ["Downloads", "HypertextLiteral", "Latexify", "Markdown", "PlutoUI"]
git-tree-sha1 = "90b41ced6bacd8c01bd05da8aed35c5458891749"
uuid = "661c6b06-c737-4d37-b85c-46df65de6f69"
version = "0.4.7"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Downloads", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "e189d0623e7ce9c37389bac17e80aac3b0302e75"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.83"

[[deps.PolygonOps]]
git-tree-sha1 = "77b3d3605fc1cd0b42d95eba87dfcd2bf67d5ff6"
uuid = "647866c9-e3ac-4575-94e7-e3d426903924"
version = "0.1.2"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "edbeefc7a4889f528644251bdb5fc9ab5348bc2c"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.3.4"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "5005266de4bfe50e53ff44a5cb5c540b6e47a254"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.6.0"

[[deps.Primes]]
deps = ["IntegerMathUtils"]
git-tree-sha1 = "25cdd1d20cd005b52fc12cb6be3f75faaf59bb9b"
uuid = "27ebfcd6-29c5-5fa9-bf4b-fb8fc14df3ae"
version = "0.5.7"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.ProgressMeter]]
deps = ["Distributed", "Printf"]
git-tree-sha1 = "fbb92c6c56b34e1a2c4c36058f68f332bec840e7"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.11.0"

[[deps.PtrArrays]]
git-tree-sha1 = "4fbbafbc6251b883f4d2705356f3641f3652a7fe"
uuid = "43287f4e-b6f4-7ad1-bb20-aadabca52c3d"
version = "1.4.0"

[[deps.QOI]]
deps = ["ColorTypes", "FileIO", "FixedPointNumbers"]
git-tree-sha1 = "472daaa816895cb7aee81658d4e7aec901fa1106"
uuid = "4b34888f-f399-49d4-9bb3-47ed5cae4e65"
version = "1.0.2"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "5e8e8b0ab68215d7a2b14b9921a946fee794749e"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.11.3"

    [deps.QuadGK.extensions]
    QuadGKEnzymeExt = "Enzyme"

    [deps.QuadGK.weakdeps]
    Enzyme = "7da242da-08ed-463a-9acd-ee780be4f1d9"

[[deps.REPL]]
deps = ["InteractiveUtils", "JuliaSyntaxHighlighting", "Markdown", "Sockets", "StyledStrings", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.RangeArrays]]
git-tree-sha1 = "b9039e93773ddcfc828f12aadf7115b4b4d225f5"
uuid = "b3c3ace0-ae52-54e7-9d0b-2c1406fd6b9d"
version = "0.3.2"

[[deps.Ratios]]
deps = ["Requires"]
git-tree-sha1 = "1342a47bf3260ee108163042310d26f2be5ec90b"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.5"
weakdeps = ["FixedPointNumbers"]

    [deps.Ratios.extensions]
    RatiosFixedPointNumbersExt = "FixedPointNumbers"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "ffdaf70d81cf6ff22c2b6e733c900c3321cab864"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.1"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "62389eeff14780bfe55195b7204c0d8738436d64"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.1"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "5b3d50eb374cea306873b371d3f8d3915a018f0b"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.9.0"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6d40b2fe70437b01397d2a4d5b020008da4e7019"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.5.2+0"

[[deps.Roots]]
deps = ["Accessors", "CommonSolve", "Printf"]
git-tree-sha1 = "4db094d5e079abbda658acfe1c4d098430417717"
uuid = "f2b01f46-fcfa-551c-844a-d8ac1e96c665"
version = "3.0.8"

    [deps.Roots.extensions]
    RootsChainRulesCoreExt = "ChainRulesCore"
    RootsForwardDiffExt = "ForwardDiff"
    RootsIntervalRootFindingExt = "IntervalRootFinding"
    RootsSymPyExt = "SymPy"
    RootsSymPyPythonCallExt = "SymPyPythonCall"
    RootsUnitfulExt = "Unitful"

    [deps.Roots.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
    IntervalRootFinding = "d2bf35a9-74e0-55ec-b149-d360ff49b807"
    SymPy = "24249f21-da20-56a4-8eb1-6a02cf4ae2e6"
    SymPyPythonCall = "bc8888f7-b21e-4b7c-a06a-5d9c9496438c"
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[[deps.RoundingEmulator]]
git-tree-sha1 = "40b9edad2e5287e05bd413a38f61a8ff55b9557b"
uuid = "5eaf0fd0-dfba-4ccb-bf02-d820a40db705"
version = "0.2.1"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SIMD]]
deps = ["PrecompileTools"]
git-tree-sha1 = "e24dc23107d426a096d3eae6c165b921e74c18e4"
uuid = "fdea26ae-647d-5447-a871-4b548cad5224"
version = "3.7.2"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "9b81b8393e50b7d4e6d0a9f14e192294d3b7c109"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.3.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.ShaderAbstractions]]
deps = ["ColorTypes", "FixedPointNumbers", "GeometryBasics", "LinearAlgebra", "Observables", "StaticArrays"]
git-tree-sha1 = "57aa595158717ef165e6f5ab639fe2e3178c0a2b"
uuid = "65257c39-d410-5151-9873-9b3e5be5013e"
version = "0.5.1"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"
version = "1.11.0"

[[deps.SignedDistanceFields]]
deps = ["Statistics"]
git-tree-sha1 = "3949ad92e1c9d2ff0cd4a1317d5ecbba682f4b92"
uuid = "73760f76-fbc4-59ce-8f25-708e95d2df96"
version = "0.4.1"

[[deps.SimpleTraits]]
deps = ["InteractiveUtils", "MacroTools"]
git-tree-sha1 = "7ddb0b49c109481b046972c0e4ab02b2127d6a75"
uuid = "699a6c99-e7fa-54fc-8d76-47d257e15c1d"
version = "0.9.6"

[[deps.Sixel]]
deps = ["Dates", "FileIO", "ImageCore", "IndirectArrays", "OffsetArrays", "REPL", "libsixel_jll"]
git-tree-sha1 = "0494aed9501e7fb65daba895fb7fd57cc38bc743"
uuid = "45858cf5-a6b0-47a3-bbea-62219f50df47"
version = "0.1.5"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"
version = "1.11.0"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "13cd91cc9be159e3f4d95b857fa2aa383b53772a"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.3"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.12.0"

[[deps.SpecialFunctions]]
deps = ["IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "429071b23f4c9a13fb6582f807cc2ef454082408"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.9.0"
weakdeps = ["ChainRulesCore"]

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

[[deps.StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "be1cf4eb0ac528d96f5115b4ed80c26a8d8ae621"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.2"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "PrecompileTools", "Random", "StaticArraysCore"]
git-tree-sha1 = "39e70e0ab5d7f89833a62ab7c79df15d4fc417c1"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.9.22"
weakdeps = ["ChainRulesCore", "Statistics"]

    [deps.StaticArrays.extensions]
    StaticArraysChainRulesCoreExt = "ChainRulesCore"
    StaticArraysStatisticsExt = "Statistics"

[[deps.StaticArraysCore]]
git-tree-sha1 = "6ab403037779dae8c514bad259f32a447262455a"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.4"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "e2b53ce13a53367e96601081e33d34746b571bad"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.5"
weakdeps = ["SparseArrays"]

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "178ed29fd5b2a2cfc3bd31c13375ae925623ff36"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.8.0"

[[deps.StatsBase]]
deps = ["AliasTables", "DataAPI", "DataStructures", "IrrationalConstants", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "adb9da019510162e67a4493fc235c23203d8b09e"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.13"

[[deps.StatsFuns]]
deps = ["HypergeometricFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "91a5737baed20ee31f3faea0e51f57461f6a689e"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "2.2.1"
weakdeps = ["ChainRulesCore", "InverseFunctions"]

    [deps.StatsFuns.extensions]
    StatsFunsChainRulesCoreExt = "ChainRulesCore"
    StatsFunsInverseFunctionsExt = "InverseFunctions"

[[deps.StructArrays]]
deps = ["ConstructionBase", "DataAPI", "Tables"]
git-tree-sha1 = "ad8002667372439f2e3611cfd14097e03fa4bccd"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.7.3"

    [deps.StructArrays.extensions]
    StructArraysAdaptExt = "Adapt"
    StructArraysGPUArraysCoreExt = ["GPUArraysCore", "KernelAbstractions"]
    StructArraysLinearAlgebraExt = "LinearAlgebra"
    StructArraysSparseArraysExt = "SparseArrays"
    StructArraysStaticArraysExt = "StaticArrays"

    [deps.StructArrays.weakdeps]
    Adapt = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
    GPUArraysCore = "46192b85-c4d5-4398-a991-12ede77f4527"
    KernelAbstractions = "63c18a36-062a-441e-b654-da1e3ab1ce7c"
    LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.StructUtils]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "b814d5005d6a529d740ffe06f8a86396f6501138"
uuid = "ec057cc2-7a8d-4b58-b3b3-92acb9f63b42"
version = "2.9.2"

    [deps.StructUtils.extensions]
    StructUtilsLazilyInitializedFieldsExt = ["LazilyInitializedFields"]
    StructUtilsMeasurementsExt = ["Measurements"]
    StructUtilsStaticArraysCoreExt = ["StaticArraysCore"]
    StructUtilsTablesExt = ["Tables"]

    [deps.StructUtils.weakdeps]
    LazilyInitializedFields = "0e77f7df-68c5-4e49-93ce-4cd80f5598bf"
    Measurements = "eff96d63-e80a-5855-80a2-b1b0885c5ab7"
    StaticArraysCore = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
    Tables = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"

[[deps.StyledStrings]]
uuid = "f489334b-da3d-4c2e-b8f0-e476e12c162b"
version = "1.11.0"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.8.3+2"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "a94d9bdda1b7bed0046cea645639ab3f62196fac"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.14.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

[[deps.TiffImages]]
deps = ["CodecZstd", "ColorTypes", "DataStructures", "DocStringExtensions", "FileIO", "FixedPointNumbers", "IndirectArrays", "Inflate", "Mmap", "OffsetArrays", "PkgVersion", "PrecompileTools", "ProgressMeter", "SIMD", "UUIDs"]
git-tree-sha1 = "9ca5f1f2d42f80df4b8c9f6ab5a64f438bbd9976"
uuid = "731e570b-9d59-4bfa-96dc-6df516fadf69"
version = "0.11.9"

[[deps.TranscodingStreams]]
git-tree-sha1 = "0c45878dcfdcfa8480052b6ab162cdd138781742"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.11.3"

[[deps.Tricks]]
git-tree-sha1 = "311349fd1c93a31f783f977a71e8b062a57d4101"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.13"

[[deps.TriplotBase]]
git-tree-sha1 = "4d4ed7f294cda19382ff7de4c137d24d16adc89b"
uuid = "981d1d27-644d-49a2-9326-4793e63143c3"
version = "0.1.0"

[[deps.URIs]]
git-tree-sha1 = "908fec9df6c5de98548ead82a468c95ccf6cd263"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.7.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
version = "1.11.0"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unitful]]
deps = ["Dates", "LinearAlgebra", "Random"]
git-tree-sha1 = "1f0f9f401753701a7e4113b5056ca38d33875b55"
uuid = "1986cc42-f94f-5a68-af5c-568840ba703d"
version = "1.29.0"

    [deps.Unitful.extensions]
    ConstructionBaseUnitfulExt = "ConstructionBase"
    ForwardDiffExt = "ForwardDiff"
    InverseFunctionsUnitfulExt = "InverseFunctions"
    LatexifyExt = ["Latexify", "LaTeXStrings"]
    NaNMathExt = "NaNMath"
    PrintfExt = "Printf"

    [deps.Unitful.weakdeps]
    ConstructionBase = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
    ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"
    LaTeXStrings = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
    Latexify = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
    NaNMath = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
    Printf = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.WebP]]
deps = ["CEnum", "ColorTypes", "FileIO", "FixedPointNumbers", "ImageCore", "libwebp_jll"]
git-tree-sha1 = "aa1ca3c47f119fbdae8770c29820e5e6119b83f2"
uuid = "e3aaa7dc-3e4b-44e0-be63-ffb868ccd7c1"
version = "0.1.3"

[[deps.WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "248a7031b3da79a127f14e5dc5f417e26f9f6db7"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "1.1.0"

[[deps.XZ_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e52eca002a11c30a858185efdfb15311e1c7a6bf"
uuid = "ffd25f8a-64ca-5728-b0f7-c24cf3aae800"
version = "5.8.4+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "808090ede1d41644447dd5cbafced4731c56bd2f"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.8.13+0"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "aa1261ebbac3ccc8d16558ae6799524c450ed16b"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.13+0"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "52858d64353db33a56e13c341d7bf44cd0d7b309"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.6+0"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "1a4a26870bf1e5d26cd585e38038d399d7e65706"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.8+0"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "75e00946e43621e09d431d9b95818ee751e6b2ef"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "6.0.2+0"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "7ed9347888fac59a618302ee38216dd0379c480d"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.12+0"

[[deps.Xorg_libpciaccess_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "58972370b81423fc546c56a60ed1a009450177c3"
uuid = "a65dc6b1-eb27-53a1-bb3e-dea574b5389e"
version = "0.19.0+0"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXau_jll", "Xorg_libXdmcp_jll"]
git-tree-sha1 = "bfcaf7ec088eaba362093393fe11aa141fa15422"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.17.1+0"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a63799ff68005991f9d9491b6e95bd3478d783cb"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.6.0+0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.3.1+2"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "446b23e73536f84e8037f5dce465e92275f6a308"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.7+1"

[[deps.isoband_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51b5eeb3f98367157a7a12a1fb0aa5328946c03c"
uuid = "9a68df92-36a6-505f-a73e-abb412b6bfb4"
version = "0.2.3+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1210ba774d3427387d307bf1f416d699b7c39417"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.15.1+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "cb007192783c56d8249db4cf0e3495001edfe414"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.17.5+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.15.0+0"

[[deps.libdrm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libpciaccess_jll"]
git-tree-sha1 = "28e57478e8a160d346a19c28b3fffb9273bcc9c2"
uuid = "8e53e030-5e6c-5a89-a30b-be5b7263a166"
version = "2.4.134+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "646634dd19587a56ee2f1199563ec056c5f228df"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.4+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "e51150d5ab85cee6fc36726850f0e627ad2e4aba"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.58+0"

[[deps.libsixel_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "libpng_jll"]
git-tree-sha1 = "c1733e347283df07689d71d61e14be986e49e47a"
uuid = "075b6546-f08a-558a-be8f-8157d0f608a5"
version = "1.10.5+0"

[[deps.libva_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll", "Xorg_libXext_jll", "Xorg_libXfixes_jll", "libdrm_jll"]
git-tree-sha1 = "7dbf96baae3310fe2fa0df0ccbb3c6288d5816c9"
uuid = "9a156e7d-b971-5f62-b2c9-67348b8fb97c"
version = "2.23.0+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll"]
git-tree-sha1 = "11e1772e7f3cc987e9d3de991dd4f6b2602663a5"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.8+0"

[[deps.libwebp_jll]]
deps = ["Artifacts", "Giflib_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libglvnd_jll", "Libtiff_jll", "libpng_jll"]
git-tree-sha1 = "52d3b9475133c3bc8c0a7f90f18bfc8cdb5a443a"
uuid = "c5f90fcd-3b7e-5836-afba-fc50a0988cb2"
version = "1.6.1+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.64.0+1"

[[deps.p7zip_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.7.0+0"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "14cc7083fc6dff3cc44f2bc435ee96d06ed79aa7"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "10164.0.1+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e7b67590c14d487e734dcb925924c5dc43ec85f3"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "4.1.0+0"
"""

# ╔═╡ Cell order:
# ╟─63841d7d-2520-433e-b09a-630c73c084c0
# ╟─0b357917-fc2c-48d1-93bd-7591cffc7238
# ╟─f11d07aa-ab22-4c8a-83dc-31e984244cec
# ╟─cc685fe8-db51-471d-a2a4-6acec55e3c5a
# ╟─94ec3349-294e-40f5-8501-4d7fe5510452
# ╟─c351741d-347e-4fc3-bce1-d8dd84a3a992
# ╟─79e201d7-0183-4861-ad30-993f1308f39f
# ╟─c24d6699-1e22-40a6-a469-3ef6b249f8be
# ╟─9e910f47-59ad-4591-bd17-064acf1f31fa
# ╟─11f41834-6688-4cfb-aa70-56c46db4a63d
# ╟─e3f5c992-b76f-11f1-b33c-3b9472606fe3
# ╠═422426d3-cad1-4e18-a73b-aa02cfe4422d
# ╟─56f4af2b-06f0-4aa2-b4f9-e2342f614c40
# ╟─9ac461dc-f268-4e36-ad24-c0b783913eb0
# ╟─56cde71c-1926-4628-bcd5-2467b6009f77
# ╠═025f2984-bc92-4576-8cc8-8559f5c0e327
# ╟─c6d8a983-b4c6-48bf-a0e3-f7cf945a0edb
# ╟─67dd1075-e9d8-4644-8ea5-cbaeea8c1916
# ╟─51b15738-f473-40a4-b76a-3ea5ccc20e4a
# ╟─9ea2a20e-2c44-41f7-9806-512831ec519c
# ╟─05a2e73a-3433-44f6-b14a-345778e54655
# ╟─c5151cee-5ce3-4baf-8e51-d64c448763f8
# ╟─f065b525-5dc4-46a1-8df0-c1a29d751159
# ╠═b5d5c28a-7b83-4f48-b6a0-ec617ae1ccb7
# ╟─a28bdaa2-82f9-4949-b3af-34a0bf4c18ab
# ╟─52f8350d-69ab-4ae7-a7a5-f9ba73af3558
# ╟─e2a22f7c-34a0-4d67-b9a3-1c76213921a9
# ╟─015de44b-aeb8-407e-b9f5-5e8086ef0689
# ╟─53ead820-57da-4430-9e62-3bab0aca81f2
# ╠═14f1b80f-1518-4016-87a1-5b6139e96680
# ╠═d5726aa5-dd9e-4cc8-8c67-7160bba9c133
# ╟─25181dae-3eac-4a21-8f8a-2b1d95fd6c36
# ╟─c476cec3-a5b3-4941-b8d3-3325f58407dc
# ╟─bd7bbd44-95e5-4f9d-bed7-81c8c6dbd0f6
# ╟─ae8fc6a2-84f6-41f9-92bd-a02cce10a8b6
# ╟─7c955efd-edd3-4dc9-9ccf-8508d48872ed
# ╠═cc32ced0-d154-46a7-847a-824521bfb044
# ╟─d3268cd5-3be9-4568-abba-dcce3b51ae92
# ╟─c0d1d48f-29ae-4d41-817d-1a15f03b0c92
# ╟─42a19502-7936-4ae6-96db-049c8bab3596
# ╟─72fa4fde-0300-4abe-8f72-9f9b85a7c70c
# ╟─f574be7f-945d-45d6-a16e-00bd9d85581b
# ╟─413647f6-7a93-49e3-a517-b8ef158f670f
# ╟─2ddec1a4-f9ae-4518-bd2e-7ffc0eee8490
# ╟─9ec2acf5-850d-4d7b-b185-f65965a19250
# ╟─1b168a45-12ad-4ef6-bd4c-347c2d0737a7
# ╟─2a99ad7e-bf27-4201-ad9f-937465f39983
# ╟─cfbead9d-3f84-4d2f-8b5b-a537a428f9ab
# ╟─26f5dba7-41cd-492c-a9e8-918231979d4f
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
