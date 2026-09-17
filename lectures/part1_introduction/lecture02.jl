### A Pluto.jl notebook ###
# v1.0.3

#> [frontmatter]
#> chapter = "1"
#> section = "2"
#> order = "2"
#> title = "PDEs and physical processes"
#> date = "2026-09-22"
#> tags = ["module1"]
#> layout = "layout.jlhtml"
#> 
#>     [[frontmatter.author]]
#>     name = "Ivan Utkin"
#>     [[frontmatter.author]]
#>     name = "Ludovic Räss"
#>     [[frontmatter.author]]
#>     name = "Mauro Werder"
#>     [[frontmatter.author]]
#>     name = "Samuel Omlin"

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

# ╔═╡ 646b24fe-f47b-4554-86fd-a4f8bf2099ff
begin
using PlutoTeachingTools
using PlutoUI
TableOfContents()
end

# ╔═╡ 8c2afa19-cd8e-4f7c-a7d5-fe5a8313f684
using CairoMakie

# ╔═╡ ee6dedf2-b105-11f1-9ab4-b5e3b10de8fa
md"""
# PDEs and physical processes

The goal of this lecture is to become familiar with:

- Classification of partial differential equations
- Finite-difference discretisation
- Explicit time integration
- Git version control system

A [**partial differential equation (PDE)**](https://en.wikipedia.org/wiki/Partial_differential_equation) relates an unknown function of several variables to its partial derivatives.

## Notation

Consider a function ``u(t, x, y, z)``. You can think of ``t`` as time, and ``x``, ``y``, and ``z`` as spatial coordinates. We will call such functions **fields**. If this function is scalar-valued, we call it a **scalar field**, and if it is vector-valued, a **vector field**. Vector fields are written in **bold**. For example, a velocity field is ``\boldsymbol{v}(t, x, y, z)``. We will denote the components of vector fields with superscripts, e.g. ``v^x``, ``v^y``, ``v^z`` or ``v^1``, ``v^2``, ``v^3``.

A [partial derivative](https://en.wikipedia.org/wiki/Partial_derivative) is a derivative with respect to one of the variables, with the other variables held constant.

We use two notations for partial derivatives:

- ``u_t`` is equivalent to ``\partial u/\partial t``
- ``u_{xx}`` is equivalent to ``\partial^2 u / \partial x^2``
- ``u_{xy}`` is equivalent to ``\partial^2 u / \partial x \partial y``

As with ordinary derivatives, the **order** of a partial derivative is the number of times differentiation is applied to a function. For example, ``u_x`` is a first derivative, ``u_{xx}`` and ``u_{xy}`` are second derivatives, ``u_{ttt}`` is a third derivative, and so on.

It is possible to define differential operators using **vector calculus notation**, which lets us write equations in a form that is independent of the number of spatial dimensions.
"""

# ╔═╡ 0f85d4f3-8e27-478d-a7b3-c8a5f902adec
md"""
Select the number of spatial dimensions to see what various differential operators look like in coordinate form:

``N`` = $(@bind N PlutoUI.Slider(1:3; default=3, show_value=true))
"""

# ╔═╡ 24c0921c-ac89-4987-82d5-c209f7f131d1
md"""
The [**gradient**](https://en.wikipedia.org/wiki/Gradient) of a scalar field is a vector field whose components are the partial derivatives with respect to the spatial coordinates:
"""

# ╔═╡ a1960792-dfe9-426b-8dc5-7746b3190da4
let
terms = ["u_x", "u_y", "u_z"]
str = string("```math\n\\mathbf{grad}\\, u = [", join(terms[1:N], "\\quad "), "]^\\mathrm{T}~.\n```")
Markdown.parse(str)
end

# ╔═╡ 41ad8ec5-0fb2-459c-93b4-121331a4c2f2
md"""
Where it is nonzero, ``\mathbf{grad}\,u`` points in the direction of steepest increase of ``u``, and its magnitude corresponds to the rate of this increase.

The [**divergence**](https://en.wikipedia.org/wiki/Divergence) of a vector field is a scalar field obtained by summing the partial derivatives of each vector component with respect to its corresponding spatial coordinate:
"""

# ╔═╡ 12795455-66e2-436a-b993-46957783cc0f
let
terms = ["v^1_x", "v^2_y", "v^3_z"]
str = string("```math\n\\mathrm{div}\\, \\boldsymbol{v} =", join(terms[1:N], " + "), "~.\n```")
Markdown.parse(str)
end

# ╔═╡ d2560b51-155e-411e-a414-093f9694273a
md"""
Physically, the divergence indicates the rate at which the vector field alters an infinitesimally small volume located at the point. Positive divergence means that the point is a source, negative divergence indicates a sink, and zero divergence means that the volume doesn't change. Divergence-free velocity fields thus describe the motion of an incompressible fluid such as water.

The [**Laplacian**](https://en.wikipedia.org/wiki/Laplace_operator) is a second-order differential operator. Applied to a scalar field, it is the divergence of the gradient:

```math
\mathrm{lap}\, u = \mathrm{div}(\mathbf{grad}\,u)~.
```

👉 Here's a little exercise: write the Laplacian in terms of partial derivatives. Use pen and paper 😉.
"""

# ╔═╡ 85e2f8fa-f284-4e6e-ae8c-1cd203643f64
let
terms = ["u_{xx}", "u_{yy}", "u_{zz}"]
str = string("```math\n\\mathrm{lap}\\, u =", join(terms[1:N], " + "), "~.\n```")
answer_box(Markdown.parse(str))
end

# ╔═╡ 3704f55f-96e1-415a-902d-159314818f12
md"""
!!! note "Actually..."
	These component formulas apply in a [Cartesian coordinate system](https://en.wikipedia.org/wiki/Cartesian_coordinate_system). For a general curvilinear coordinate system, the [metric tensor](https://en.wikipedia.org/wiki/Metric_tensor) needs to be taken into account. In this course, we will only work with Cartesian coordinates.

It is convenient to express gradient and divergence using the **del** operator ``\boldsymbol{\nabla}``:

```math
\begin{aligned}
\mathbf{grad}\, u &\equiv \boldsymbol{\nabla} u~, \\
\mathrm{div}\, \boldsymbol{v} &\equiv \boldsymbol{\nabla}\cdot\boldsymbol{v}~, \\
\mathrm{lap}\, u &\equiv \boldsymbol{\nabla}\cdot\boldsymbol{\nabla} u \equiv \nabla^2 u~.
\end{aligned}
```
"""

# ╔═╡ 316505fa-14d6-4f22-876c-e6e1dabbe4d9
md"""
## Classification of PDEs

There are several ways to classify PDEs. We will look at a few of them.

The **order** of a PDE is the highest order among its partial derivatives. In this course, we will mostly look at first-order and second-order PDEs.

Besides order, PDEs can be classified as **linear** or **nonlinear**. Linear PDEs are linear **with respect to the unknown function and its derivatives**.

👉 Here are a few PDEs. Select the order of each equation and indicate whether it is linear:

|Equation                                |Order                          |Is it linear?             |
|---------------------------------------:|-------------------------------|:-------------------------|
|``u_t + u_x = u``                       |$(@bind __o_1 NumberField(1:2))|$(@bind __l_1 CheckBox())|
|``u_t + u u_x = 0``                     |$(@bind __o_2 NumberField(1:2))|$(@bind __l_2 CheckBox())|
|``u_t - x^2 \nabla^2 u = x``            |$(@bind __o_3 NumberField(1:2))|$(@bind __l_3 CheckBox())|
|``u_{tt} + \alpha u_t - u_{xx} = -u^2`` |$(@bind __o_4 NumberField(1:2))|$(@bind __l_4 CheckBox())|
"""

# ╔═╡ fc1a07dc-8540-4b08-aec6-7fca73cf5b94
let
correct_orders = [1, 1, 2, 2]
correct_linear = [true, false, true, false]

orders = [__o_1, __o_2, __o_3, __o_4]
linear = [__l_1, __l_2, __l_3, __l_4]

if orders == correct_orders
	if linear == correct_linear
		correct()
	else
		almost(md"Almost there! Check your answers about linearity.")
	end
elseif linear == correct_linear
	almost(md"Almost there! Check if the orders are correct.")
else
	keep_working()
end
end

# ╔═╡ 6f66c134-6060-4f78-9c16-51bf3b1311d1
md"""
## Second-order PDEs

For second-order PDEs, another useful classification exists. By analogy with the classification of [conic sections](https://en.wikipedia.org/wiki/Conic_section), it is convenient to classify second-order PDEs into **hyperbolic**, **parabolic** and **elliptic** types:

|     Type     |         Equation         |Physical process|
|:-------------|:------------------------:|---------------:|
|**Parabolic** | ``u_t = λ\nabla^2 u``    |       Diffusion|
|**Hyperbolic**|``u_{tt} = c^2\nabla^2 u``|Wave propagation|
|**Elliptic**  |  ``\nabla^2 u = 0``      |Steady diffusion|

This classification is important because solutions to different kinds of PDEs show different behaviours, and obtaining these solutions numerically requires different approaches.
"""

# ╔═╡ 4e464867-020a-4143-a027-2c968c30a960
md"""
## Initial and boundary conditions

Just knowing the equation is not enough to solve it. If the equation is first order in time, we also need [**initial conditions**](https://en.wikipedia.org/wiki/Initial_value_problem) (ICs), i.e. the distribution of the unknown at the initial time ``t=0``. If the equation is second order in time, in addition to the initial distribution of ``u`` we need the initial distribution of ``u_t`` at ``t=0``. For higher-order derivatives, more initial conditions are needed.

If the equation contains spatial derivatives, we need to specify [**boundary conditions**](https://en.wikipedia.org/wiki/Boundary_value_problem) (BCs) that constrain the unknown quantity ``u`` or its derivatives at the boundary of the domain. There are many possibilities for specifying the BCs. In this course, we will only consider two types of BCs: [**Dirichlet**](https://en.wikipedia.org/wiki/Dirichlet_boundary_condition) and [**Neumann**](https://en.wikipedia.org/wiki/Neumann_boundary_condition) boundary conditions.

A **Dirichlet** boundary condition prescribes the value of the unknown quantity ``u`` on the boundary.

**Neumann** boundary conditions prescribe the derivative of ``u`` in the direction normal to the boundary. In 1D, this amounts to prescribing ``u_x`` at the ends of the domain, with a sign change at the left endpoint when using the outward normal.
"""

# ╔═╡ 985a7cbd-185a-4129-9ef1-98463f991745
md"""
## Finite-difference approximation

In the [**finite-difference method**](https://en.wikipedia.org/wiki/Finite_difference_method), we approximate derivatives by differences between values at grid points. These approximations can be derived using truncated [Taylor series](https://en.wikipedia.org/wiki/Taylor_series).

For example, we can approximate the first derivative ``c_x`` at the point ``x`` using the **central difference** rule:

```math
c_x(t, x) \approx \frac{c(t, x+dx/2) - c(t, x-dx/2)}{dx}~,
```

where ``dx`` is a *finite* parameter which controls the accuracy of the approximation. For a sufficiently smooth function, as ``dx \rightarrow 0``, the approximation converges to the true value of the derivative.

To compute differences between neighbouring values in Julia, we can use the built-in `diff` function:
"""

# ╔═╡ 0411bd65-d3db-4b1f-a58e-a88cbccfacd7
diff([1, 2, 2, 6, 3])

# ╔═╡ 129996e6-739c-4745-929e-583a15842fca
md"""
For a vector `C`, calling `diff(C)` is equivalent to computing `C[2:end] - C[1:end-1]`. Divide by `dx` to approximate the derivative at the midpoints between neighbouring grid points.

## Explicit Euler time integration

The [Euler method](https://en.wikipedia.org/wiki/Euler_method) is a simple first-order method for integrating initial value problems in time. It consists of approximating the time derivative using the **forward finite difference rule**:

```math
u_t(t, x) \approx \frac{u(t + dt, x) - u(t, x)}{dt}~,
```

where ``dt`` is the **time step**. Assume that our PDE has the following form:

```math
u_t = R(t, x, u, u_x, u_{xx}, ...)~,
```

where ``R`` denotes the right-hand side, which does not contain time derivatives of ``u``. If we want to numerically integrate this equation from ``t=0`` to ``t=T``, we can discretise the time interval `[0, T]` by selecting `nt+1` equally spaced points ``t^0 < t^1 < \dots < t^\mathrm{nt}`` such that ``t^0 = 0`` and ``t^\mathrm{nt} = T``. We denote the distributions of ``u`` and ``R`` at ``t=t^n`` as ``u^n`` and ``R^n``, respectively. The initial condition specifies ``u^0``. Then, according to the Euler method, we can compute [``u^1``, ``u^2``, ... ] by evaluating the right-hand side at the current time step:

```math
u^{n+1} = u^n + d t\, R^n
```

"""

# ╔═╡ 3ed7e2de-7a0f-46bb-95d7-e6b6f4149585
md"""
## Parabolic equations — diffusion

The [diffusion equation](https://en.wikipedia.org/wiki/Diffusion_equation) was presented in Fourier’s 1822 treatise in the form of the [heat equation](https://en.wikipedia.org/wiki/Heat_equation) to understand heat distribution in various materials.

Fick formulated laws of diffusion in 1855 to describe the transport of dissolved substances ([Fick's laws](https://en.wikipedia.org/wiki/Fick%27s_laws_of_diffusion)).

For a positive diffusion coefficient ``λ``, the diffusion equation is a second-order parabolic PDE:

```math
c_t = λ c_{xx}~.
```

The quantity ``c`` could represent the temperature of a material or the concentration of a substance in a fluid. The parameter ``\lambda`` is the **diffusion coefficient** (thermal diffusivity when ``c`` is temperature): higher values of ``\lambda`` result in faster diffusion.

Alternatively, we can write this equation as a conservation law for ``c``:

```math
c_t = -q_x~,
```

where ``q`` is the diffusive flux:

```math
q = -\lambda c_x~.
```

!!! note
	These two forms are equivalent only when the diffusion coefficient ``\lambda`` is not a function of ``x`` or ``c``. If this is not the case, the conservation form should be used.

In the following, we will approximate the spatial derivatives in the diffusion equation using [finite differences](https://en.wikipedia.org/wiki/Finite_difference), and integrate this discretised equation in time using the explicit [Euler method](https://en.wikipedia.org/wiki/Euler_method).
"""

# ╔═╡ 1230392d-eff2-4c96-9e5c-c95f790a5004
md"""
### Numerical solver

We are ready to solve the diffusion equation in 1D. In this section, we will discuss the ingredients of a solver, and then ask you to write it yourself.

We discretise the computational domain `[0, lx]` by dividing it into `nx` non-overlapping intervals of length `lx/nx` each. We will call these intervals **grid cells**.

First, we introduce the physical parameters that are relevant to this problem, i.e., the domain length `lx` and the diffusion coefficient `dc`:

```julia
# physics
lx   = 20.0
dc   = 1.0
```

Then we declare the numerical parameters: the number of grid cells `nx` and the number of time steps between visualisation updates `nvis`:

```julia
# numerics
nx   = 200
nvis = 5
```

We introduce additional numerical parameters: the grid spacing `dx` and the coordinates of cell centres `xc`:

```julia
# preprocessing
dx   = lx/nx
xc   = LinRange(dx/2,lx-dx/2,nx)
```

Then we compute the time step and set the number of time steps in the simulation:

```julia
dt   = dx^2 / dc / 2
nt   = 500
```

!!! note "🤔 Why is the time step computed like this?"
	The reason for this is numerical stability. The explicit Euler scheme cannot be used with arbitrarily large time steps. If `dt` is larger than some threshold, the small errors in the numerical solution grow unboundedly, which looks like a "sawtooth" pattern. The detailed derivation is outside the scope of this course, unfortunately. If you're interested, check the literature in the [Extras](https://pde-on-gpu.vaw.ethz.ch/cheatsheets/). In short, this stability bound can be derived using the [von Neumann stability analysis](https://en.wikipedia.org/wiki/Von_Neumann_stability_analysis) procedure.

In the `# array initialisation` section, we initialise two arrays: `C` for the concentration field and `qx` for the diffusive flux in the x direction:

```julia
# array initialisation
C    = @. exp(-(xc-lx/2)^2)
qx   = zeros(nx) # 😉
```

Then we create objects needed to visualise the results with CairoMakie.jl:

```julia
# create plot
fig = Figure(size=(600, 200))
ax  = Axis(fig[1,1]; xlabel="x", ylabel="Concentration")
lines!(xc, C; color=:blue)
plt = lines!(xc, C; color=:red)
```

Note that we plot `C` twice: the first line plot will stay unchanged and will show the initial condition, while the second plot will be updated every `nvis` steps.

Finally, implement the time loop:

```julia
# time loop
@animate fig nvis for it = 1:nt
	# qx          .=
	# C[2:end-1] .-=
	if it % nvis == 0
		plt[2] = C
	end
end
```

!!! note "Animating the plots"
	[Animating plots](https://docs.makie.org/dev/explanations/animation) with Makie.jl in Pluto notebooks is complicated because the result of running the cell is only displayed when the computation is finished. We implemented a macro `@animate` that will create a video stream of the animated result. This macro requires a figure, an update frequency, and a for loop over time steps. This macro is based on [this trick](https://discourse.julialang.org/t/real-time-animations-with-makie-in-pluto/63684) from the community.

👉 Your turn. Implement your first diffusion solver:
"""

# ╔═╡ 9dd60033-2f5a-4e8b-a0e6-b2bb89b7bd1c
# ╠═╡ disabled = true
#=╠═╡
# split: statement
function diffusion_1d()
	# physics
	lx   = 20.0
	dc   = 1.0
	# numerics
	nx   = 200
	nvis = 5
	# preprocessing
	dx   = lx / nx
	xc   = LinRange(dx/2,lx-dx/2,nx)
	dt   = dx^2 / dc / 2
	nt   = 500
	# array initialisation
	C    = @. exp(-(xc-lx/2)^2)
	qx   = zeros(nx) # 😉
	# create plot
	fig = Figure(size=(600, 200))
	ax  = Axis(fig[1,1]; xlabel="x", ylabel="Concentration")
	lines!(xc, C; color=:blue)
	plt = lines!(xc, C; color=:red)
	# time loop
	@animate fig nvis for it = 1:nt
	    # qx          .=
		# C[2:end-1] .-=
		if it % nvis == 0
			plt[2] = C
		end
	end
end
  ╠═╡ =#

# ╔═╡ 241cf2b3-dd9c-41d0-b69e-aef71d3ee162
# ╠═╡ disabled = true
#=╠═╡
# split: statement
# Uncomment this when implemented the solver
# diffusion_1d()
  ╠═╡ =#

# ╔═╡ 8534ddd3-6097-4a53-a403-429397b0df61
md"""
!!! hint
	We actually deceived you before! 😈 The size of the array `qx` cannot be `nx`. To figure out what the actual size is, check how the sizes of arrays `C` and `diff(C)` are related.

Well done! You can experiment with the solver, changing physical and numerical parameters to see how the solution will change.

!!! tip
	Check what the numerical instability looks like: multiply the time step `dt` in the definition by a small factor, say `1.1`, and see the 💥!

### What about BCs?

You probably noticed that we never explicitly implemented any boundary conditions, despite the claim that the BCs are needed for a well-posed problem. Actually, there is a BC implemented in the solver, but you need to look carefully at the code to find it.

👉 Figure out what boundary condition is imposed at the left and right domain boundaries. Change its value to something else and see what happens. Then think about how to implement a different type of boundary condition (Dirichlet or Neumann).

Now let's move to a different kind of second-order PDE.
"""

# ╔═╡ e9c4fcc1-09f8-4a00-8368-2d5b67e11e5f
md"""
## Hyperbolic equations — wave propagation

A prototypical hyperbolic PDE is the [wave equation](https://en.wikipedia.org/wiki/Wave_equation), which describes the propagation of waves in many natural processes, such as sound waves, waves on the water surface, seismic waves, or electromagnetic waves.

The wave equation in 1D reads:

```math
p_{tt} = c^2 p_{xx}~,
```

where

- ``p`` is pressure (or displacement, or another quantity...)
- ``c`` is a positive constant representing the wave speed (for example, the speed of sound)

Alternatively, the wave equation can be written as a first-order system of PDEs:

```math
\begin{aligned}
v_t &= -\frac{1}{\rho}p_x~, \\[0.5em]
p_t &= -\frac{1}{\beta}v_x~.
\end{aligned}
```

Here, ``v`` is the fluid velocity, ``\rho`` is the density, and ``\beta`` is the compressibility. We assume that ``\rho`` and ``\beta`` are positive constants.

👉 Demonstrate that these two forms are equivalent. Derive how the parameter ``c`` is related to parameters ``\rho`` and ``\beta``.

!!! hint
	Eliminate ``v`` by differentiating the first equation with respect to ``x`` and the second with respect to ``t``, then substituting the expression for ``v_{tx}`` into the second equation.
"""

# ╔═╡ 563965f8-ef6c-4b12-91dd-1e3a25f65248
answer_box(
md"""
```math
c = \sqrt{\frac{1}{\rho\beta}}
```
""")

# ╔═╡ d6d9d531-4a2f-4e44-a018-04e2e4046041
md"""
The objective is to implement the wave equation in 1D using an explicit time integration (forward Euler) as for the diffusion physics.

### Numerical solver

We can start by modifying the diffusion code, adding `ρ` and `β` in the `# physics` section, and using a Gaussian (centred at `lx/4`) as the initial condition for the pressure `Pr`:

```julia
# physics
lx   = 20.0
ρ,β  = 1.0,1.0

# array initialisation
Pr   =  exp.(...)
```

!!! note
	The time step needs a new definition: `dt = dx/sqrt(1/ρ/β)`

The diffusion update:

```julia
qx          .= .-dc.*diff(C )./dx
C[2:end-1] .-=   dt.*diff(qx)./dx
```

should be modified to use pressure `Pr` instead of concentration `C`. Add an update for the velocity `Vx` and adjust the coefficients:

```julia
Vx          .-= ...
Pr[2:end-1] .-= ...
```

!!! warn "Use the new velocity in the pressure update"
	When updating pressure `Pr`, use the freshly computed values of `Vx`, instead of saving somewhere the old array. This method is called [semi-implicit Euler](https://en.wikipedia.org/wiki/Semi-implicit_Euler_method) and it works specifically well for the wave equation: it preserves the stored acoustic energy, so the waves never attenuate.

👉 Your turn. Finish the implementation of acoustic wave propagation:
"""

# ╔═╡ 6c85a0bf-9156-43ef-a1ad-3ae80ebdb966
# ╠═╡ disabled = true
#=╠═╡
# split: statement
function acoustic_1D()
    # physics
    lx   = 20.0
    ρ, β = 1.0, 1.0
    # numerics
    nx   = 200
    nvis = 2
    # preprocessing
    dx   = lx / nx
    xc   = LinRange(dx/2,lx-dx/2,nx)
    # dt   = ...
    nt   = 2nx
    # array initialisation
    # Pr   = @. exp(...)
    # Vx   = zeros(...)
    # create plot
	fig = Figure(size=(600, 200))
	ax  = Axis(fig[1,1]; xlabel="x", ylabel="Pressure")
    ylims!(ax, -0.6, 1.1)
	lines!(xc, Pr; color=:blue)
	plt = lines!(xc, Pr; color=:red)
    # time loop
    @animate fig nvis for it = 1:nt
        # Vx          .-= ...
        # Pr[2:end-1] .-= ...
        if it % nvis == 0
            plt[2] = Pr
        end
    end
end
  ╠═╡ =#

# ╔═╡ 0ae59d37-ba0e-435a-b1e8-7ebd35eb98d3
# ╠═╡ disabled = true
#=╠═╡
# split: statement
# Uncomment this when implemented the solver
# acoustic_1D()
  ╠═╡ =#

# ╔═╡ c48327ce-2829-441b-a2eb-ff5397d17d09
md"""
## First-order PDEs


The simplest first-order PDE is the so-called [advection equation](https://en.wikipedia.org/wiki/Advection):

```math
c_t + \boldsymbol{v} \cdot \boldsymbol{\nabla}c = 0~.
```

It represents the transport of some scalar quantity ``c``, defined per unit mass of the fluid, due to the bulk motion of a fluid flowing with velocity ``\boldsymbol{v}``.
"""

# ╔═╡ 37362ad9-3383-4171-bc37-bc85acf642fc
Foldable(md"Want to know the derivation?",
md"""
Assume that the fluid has density ``\rho``. We start from a [mass conservation equation](https://en.wikipedia.org/wiki/Continuity_equation) for the quantity ``\rho c``:

```math
(\rho c)_t + \boldsymbol{\nabla}\cdot(\rho c\boldsymbol{v}) = 0
```

Using the product rule gives:

```math
c\,[\rho_t + \boldsymbol{\nabla}\cdot(\rho \boldsymbol{v})] + \rho\,[c_t + \boldsymbol{v}\cdot\boldsymbol{\nabla}c] = 0
```

In the first term, the quantity in brackets, ``\rho_t + \boldsymbol{\nabla}\cdot(\rho \boldsymbol{v})``, is always equal to ``0``: this is the mass conservation equation for the bulk flow. Dividing both sides of the remaining equation by ``\rho``, which is always positive, we get the advection equation.
""")

# ╔═╡ c3fb9efa-0728-448c-a992-79926dea6f7c
md"""
### Exact solution

For constant velocity ``\boldsymbol{v}``, the advection equation has a simple exact solution: it simply translates the initial shape of the field ``c`` in space.

For example, in 1D, if initially (at ``t = 0``) the shape of ``c`` was given by ``f(x)``, then the solution at time ``t`` is simply:

```math
c(t, x) = f(x - vt)
```

Let's visualise it. Here's the function for the initial condition (it's a Gaussian, but feel free to try something else):
"""

# ╔═╡ 197f44d5-76e1-4aee-b576-811d6923310f
function initial_condition(x)
	return exp(-x^2)
end

# ╔═╡ 770c08ce-bce5-4542-8ca7-92179d43a45d
md"""
Adjust the velocity and time and see what happens:
"""

# ╔═╡ f1a20d7e-4069-4a5d-a77b-56a07b6ea2fc
md"""
velocity: $(@bind __vel NumberField(default=5.0)) \
time: $(@bind __time PlutoUI.Slider(0:0.01:1; default=1, show_value=true))
"""

# ╔═╡ 4c843ddf-bc16-4a33-8683-41cfa88762de
let
lx = 20.0 # domain length
xs = LinRange(-lx/2, lx/2, 201)
fs = initial_condition.(xs .- __vel * __time)
lines(xs, initial_condition.(xs);
	  figure=(size=(600, 200),),
	  color=:blue,
	  label="t = 0")
lines!(xs, fs; color=:red, label="t = $(round(__time; digits=2))")
axislegend(current_axis())
current_figure()
end

# ╔═╡ 31129331-fbd5-4d66-8108-d84e43b14747
md"""
!!! note "What about the boundary conditions?"
	This solution is only valid in an unbounded region. If the domain has finite extent, we will need to specify the values of ``c`` at the inflow parts of the boundary.

### Numerical solver

Let's solve the advection equation numerically, following the same code structure as for diffusion and acoustic wave propagation.

The only physical parameter besides the domain extent now is the advection velocity:

```julia
# physics
lx   = 20.0
vx   = 1.0
```

In the `# array initialisation` section, initialise the quantity `C` as a Gaussian profile of amplitude 1, centred at `lx / 4`.

```julia
C = @. exp( ... )
```

The only change in the `# preprocessing` section is the numerical time step definition to comply with the [CFL condition](https://en.wikipedia.org/wiki/Courant–Friedrichs–Lewy_condition) for explicit time integration.

```julia
# preprocessing
dt   = dx / abs(vx)
```

Update `C` in the time loop as follows:

```julia
C .-= dt .* vx .* diff(C) ./ dx # won't work
```

As with the diffusion and wave equations, this assignment doesn't work because of the mismatching array sizes. But unlike the second-order equations, we don't have two derivatives to make sure that we can update the inner points of `C`.

There are at least three (naive) ways to solve the problem: update `C[1:end-1]`, `C[2:end]`, or one could even update `C[2:end-1]` with the spatial average of the increment `dt .* vx .* diff(C) ./ dx`.

To make things more interesting, let's also flip the sign of the velocity when reaching `it=nt÷2`. Recall the conditional statements and short-circuit operators from Lecture 1 for a hint on how to implement this.

👉 Your turn. Implement all three options for updating `C` and see what works best:
"""

# ╔═╡ e4406be5-fae9-402d-abb2-0d01aa9d80f9
# ╠═╡ disabled = true
#=╠═╡
# split: statement
function advection_1D()
    # physics
    lx   = 20.0
    vx   = 1.0
    # numerics
    nx   = 200
    nvis = 2
    # derived numerics
    dx   = lx / nx
    xc   = LinRange(dx / 2, lx - dx / 2, nx)
    dt   = dx / abs(vx)
    nt   = nx
    # array initialisation
    # C    = @. exp(...)
    # make visualisation
    fig = Figure(size=(600, 200))
    ax = Axis(fig[1, 1], xlabel="lx", ylabel="Concentration")
    lines!(ax, xc, C; color=:blue)
    plt = lines!(ax, xc, C; color=:red)
    # time loop
    @animate fig nvis for it = 1:nt
        # C ...
        # flip the sign of vx when it == nt ÷ 2
        plt[2] = C
    end
end
  ╠═╡ =#

# ╔═╡ df956745-ec01-49b8-8e7b-0717ce60a159
# ╠═╡ disabled = true
#=╠═╡
# split: statement
# Uncomment this when implemented the solver
# advection_1D()
  ╠═╡ =#

# ╔═╡ 6bd96e91-83be-4f19-b2dd-267187521fdf
md"""
!!! hint
	Depending on the sign of velocity, you need a different scheme. One of the choices (where to store `dt .* vx .* diff(C) ./ dx`) will only work for `vx >= 0`, while the other will only work for `vx <= 0`. We suggest implementing both these schemes in the same code, but in one case use `max(vx, 0)` and in other use `min(vx, 0)` for velocity.
"""

# ╔═╡ 9f3ecb1f-0a0c-4c6a-bed8-b6aff27fb625
Foldable("Why does only one scheme work?",
md"""
The reason is again numerical stability. It turns out that both the time step and the spatial discretisation affect stability. The scheme that is stable for the explicit Euler time integration is the so-called [upwind scheme](https://en.wikipedia.org/wiki/Upwind_scheme). Interestingly, the other two choices, the "downwind" scheme and the [central scheme](https://en.wikipedia.org/wiki/FTCS_scheme) are **unconditionally unstable**, i.e. the solution explodes for any time step.
""")

# ╔═╡ f6270619-d412-465b-a3af-e6c3c6f8e257
md"""
!!! warn "Numerical diffusion"
	Interestingly, the numerical solution looks just just like the exact one. But this is possible only when the velocity is constant and in 1D. In general case, the finite-difference schemes for advection suffer from the **numerical diffusion**. Try multiplying the time step `dt` by `0.5` and see how the Gaussian starts diffusing while advecting. To reduce numerical diffusion, high-order methods such as [WENO](https://en.wikipedia.org/wiki/WENO_methods) can be used.
"""

# ╔═╡ 5c9b9479-d89e-44d6-9081-ddae9a6291ba
md"""
## First steps towards solving elliptic problems

We have considered numerical solutions to hyperbolic and parabolic PDEs. In both cases, we used explicit time integration.

An elliptic PDE is different:

```math
c_{xx} = 0
```

It doesn't depend on time! How do we solve it numerically then?

There are many ways, but in this course we will focus on **relaxation solvers**. The idea is that the solution to the elliptic PDE can be obtained as a **steady state** of a corresponding **time-dependent** parabolic equation:

```math
c_t = \lambda c_{xx}~.
```

The steady state is approached as ``t \rightarrow \infty`` when ``c_t \rightarrow 0``.

!!! note 
	The existence of such a steady state is not guaranteed for all PDEs, but it is the case for elliptic equations.

We already know how to solve parabolic equations, so solving elliptic equations should be easy then, right?

👉 Increase the number of time steps `nt` in our diffusion code to see whether the solution converges, and decrease the frequency of plotting:

```julia
nt   = 5000
nvis = 50
```

Observe how the solution approaches the steady state. However, the number of time steps required to converge to a solution is proportional to `nx^2`:

- For simulations in 1D and low resolutions in 2D, the quadratic scaling is acceptable;
- For high-resolution simulations in 2D and 3D, the `nx^2` factor becomes prohibitively expensive!

So, solving elliptic equations efficiently is not that simple. We'll tackle this challenge in the next lecture, **stay tuned!** 🚀

!!! note
	The described routine is far from being the only way to solve these PDEs numerically. In this course, we will stick to those concepts as they will allow for efficient parallel implementations on GPUs and are relatively easy to implement.
"""

# ╔═╡ 50cb4141-1cb1-428b-938b-fd81f8102a91
md"""
# Software and numeric engineering skills

We try to make this course "wholesome" by not just teaching you numerics but also the skills to actually work with numerical (and other) code.
Just like with the numerics we take a hands-on approach to these topics. We will cover:

- version control with Git to keep track of the code and to allow collaboration
- package and environment management to make your software stack reproducible
- running software on super computers
- etc


# Introduction to Git

Git is version control software. It helps you to:

- Keep track of changes to code (and other files)
- Collaborate on code
- Share code across your computers and with others

!!! note
	Avoid committing large files, especially binary files, to Git. For this course, consider storing files larger than 1 MB elsewhere.

**Some questions for you:**

- How often do you use Git?
- Who has Git installed on their laptop?
- Do you use: `commit`, `push`, `pull`, `clone`?
- Do you use: `branch`, `merge`, `rebase`?
- Do you use GitHub, GitLab, or similar platforms?

Here are a few online resources about Git:

- [git - the simple guide](https://rogerdudler.github.io/git-guide/)
- [Git cheatsheet](https://git-scm.com/cheat-sheet)
- [Using Git in VS Code](https://code.visualstudio.com/docs/sourcecontrol/quickstart)
- [Official tutorial videos (~24 min)](https://git-scm.com/videos)

## A brief Git demo

👉 If you don't have Git on your computer, [install it](https://git-scm.com/install/)!

- Git setup:

```sh
git config --global user.name "Your Name"
git config --global user.email "youremail@yourdomain.com"
```

- Make a repo (`init`)
- Add some files (`add`, `commit`)
- Make some changes (`commit` some more)
- Make a feature branch (`branch`, `diff`, `difftool`)
- Merge the branch (`merge`)
- Tag (`tag`)

## Other tools for Git

Many tools let you interact with Git, including graphical clients, command-line tools, and VS Code. Feel free to use them.

But we will only be able to help you with standard command-line Git.

## Getting started on GitHub (similar on GitLab, or elsewhere)

GitHub and GitLab are collaborative software development platforms:

- They host code
- They help developers collaborate
- They provide infrastructure for software testing, deployment, etc

!!! note
	ETH has a GitLab instance which you can use with your NETHZ credentials [https://gitlab.ethz.ch/](https://gitlab.ethz.ch/).

If you don't have a GitHub account, make one (most of Julia development happens on GitHub)

[https://github.com/](https://github.com/) → "Sign up"

### GitHub setup

Set up authentication so that you can push and pull without repeatedly entering your credentials.

![GitHub navigation bar](https://raw.githubusercontent.com/eth-vaw-glaciology/course-101-0250-00/78b7d0f9ea3577e81f8469ac22f7ccf445a2c931/lectures/part1_introduction/assets/l2_github-bar.png)

- Local: tell Git to cache credentials: `git config --global credential.helper cache`
  (this may not be needed on all operating systems, potentially a built-in password/credential
   manager will do this automatically)
- [github.com](https://github.com/):
  - "Settings" → "Developer settings" → "Personal access tokens" → "Generate new token"
    - Give the token a description/name and select the scope of the token
    - I selected "repo only" to facilitate pull, push, clone, and commit actions
  - → "Generate token" and copy it (keep that website open for now)

## Let's get our repo onto GitHub

- Create a repository on github.com: click the "+"
- Local: follow the setup instructions on the website
- Local: `git push`
  - Enter your username here + the **token** generated before

## Work with other people: pull request (PR)

When contributing to a shared repository, you typically make changes on a separate branch and submit a **pull request (PR)**. A pull request provides a web interface for reviewing changes, requesting revisions, and merging the code.

In a repository where you have write permission, use the following workflow:

- Make a branch and switch to it: `git switch -c some-branch-name`
- Make changes, add files, etc. and commit to the branch.  You can have several commits on the branch.
- Push the branch to GitHub
- On the GitHub web page, a bar with an "Open pull request" option should appear: click it
- If you have more changes, just commit and push them to that branch
- When the changes are ready and reviewed, merge the PR

You will use this workflow to submit homework for the course.

## Work with other people's code: fork

To contribute to a repository where you do not have write access:

- Fork a repository on github.com (top right)
- Make a branch on that fork and work on it
- Push the branch to your fork on GitHub and open a PR against the original repository
- (not needed in this lecture course)
"""

# ╔═╡ 3125ddfe-2a52-4c92-989c-6d26c21e3c93
Foldable("Got any questions?",
md"""
Write to us on Element. We will also work through more exercises and answer questions in class.
		 
![Git comic](https://raw.githubusercontent.com/eth-vaw-glaciology/course-101-0250-00/78b7d0f9ea3577e81f8469ac22f7ccf445a2c931/lectures/part1_introduction/assets/l2_git-me.png)
""")

# ╔═╡ c02bc7a1-2b6b-4453-bee7-9bb2735fc402
# helper function to animate the loop in Pluto live
macro animate(fig, nvis, loop)
	loop.head == :for || error("`@animate` can only be used with `for` loops")
	iter_expr = loop.args[1]
	iter_var = iter_expr.args[1]
	iter_range = iter_expr.args[2]
	body = loop.args[2]
	return quote
		iframe = first($(esc(iter_range)))
		CairoMakie.Makie.Record($(esc(fig)), $(esc(iter_range))[1:$(esc(nvis)):end]; format="mp4", framerate=30, compression=35, profile = "high444") do _
			for i in 1:$(esc(nvis))
				$(esc(iter_var)) = iframe
				$(esc(body))
				iframe += 1
			end
		end
	end
end;

# ╔═╡ 3e833c61-5f94-413e-ab57-5e1669da380e
# split: solution
function diffusion_1d()
	# physics
	lx   = 20.0
	dc   = 1.0
	# numerics
	nx   = 200
	nvis = 5
	# preprocessing
	dx   = lx / nx
	xc   = LinRange(dx/2,lx-dx/2,nx)
	dt   = dx^2 / dc / 2
	nt   = 500
	# array initialisation
	C    = @. exp(-(xc-lx/2)^2)
	qx   = zeros(nx-1) # deception is resolved in the solution
	# create plot
	fig = Figure(size=(600, 200))
	ax  = Axis(fig[1,1]; xlabel="x", ylabel="Concentration")
	lines!(xc, C; color=:blue)
	plt = lines!(xc, C; color=:red)
	# time loop
	@animate fig nvis for it = 1:nt
	    qx          .= .-dc.*diff(C )./dx
		C[2:end-1] .-=   dt.*diff(qx)./dx
		if it % nvis == 0
			plt[2] = C
		end
	end
end

# ╔═╡ b3843e23-b9cf-4192-ba9c-496ba1695711
# split: solution
diffusion_1d()

# ╔═╡ cff2c4c6-1008-4a2c-b13a-83618f00b6fd
# split: solution
function acoustic_1D()
    # physics
    lx   = 20.0
    ρ, β = 1.0, 1.0
    # numerics
    nx   = 200
    nvis = 2
    # preprocessing
    dx   = lx / nx
    xc   = LinRange(dx/2,lx-dx/2,nx)
    dt   = dx / sqrt(1/ρ/β)
    nt   = 2nx
    # array initialisation
    Pr   = @. exp(-(xc-lx/4)^2)
    Vx   = zeros(nx-1)
    # create plot
	fig = Figure(size=(600, 200))
	ax  = Axis(fig[1,1]; xlabel="x", ylabel="Pressure")
    ylims!(ax, -0.6, 1.1)
	lines!(xc, Pr; color=:blue)
	plt = lines!(xc, Pr; color=:red)
    # time loop
    @animate fig nvis for it = 1:nt
        Vx          .-= dt./ρ.*diff(Pr)./dx
        Pr[2:end-1] .-= dt./β.*diff(Vx)./dx
        if it % nvis == 0
            plt[2] = Pr
        end
    end
end

# ╔═╡ 6fb78164-19e2-48f8-957d-bb6681ebcb54
# split: solution
acoustic_1D()

# ╔═╡ 76c2a2f8-53ac-4820-97ed-1683209b9353
# split: solution
function advection_1D()
    # physics
    lx   = 20.0
    vx   = 1.0
    # numerics
    nx   = 200
    nvis = 2
    # derived numerics
    dx   = lx / nx
    xc   = LinRange(dx / 2, lx - dx / 2, nx)
    dt   = dx / abs(vx)
    nt   = nx
    # array initialisation
    C    = @. exp(-(xc - lx / 4)^2)
    # make visualisation
    fig = Figure(size=(600, 200))
    ax = Axis(fig[1, 1], xlabel="lx", ylabel="Concentration")
    lines!(ax, xc, C; color=:blue)
    plt = lines!(ax, xc, C; color=:red)
    # time loop
    @animate fig nvis for it = 1:nt
        C[2:end]   .-= dt .* max(vx, 0.0) .* diff(C) ./ dx
        C[1:end-1] .-= dt .* min(vx, 0.0) .* diff(C) ./ dx
        (it % (nt ÷ 2) == 0) && (vx = -vx)
        plt[2] = C
    end
end

# ╔═╡ a84ea677-fee3-42be-a194-24e50c4859e4
# split: solution
advection_1D()

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CairoMakie = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
PlutoTeachingTools = "661c6b06-c737-4d37-b85c-46df65de6f69"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
CairoMakie = "~0.15.14"
PlutoTeachingTools = "~0.4.7"
PlutoUI = "~0.7.83"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.12.7"
manifest_format = "2.0"
project_hash = "2f0e84c679cd198d8e9caacefe1556f69a34c941"

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
git-tree-sha1 = "3495bfc164949714579501b825b8e5e2cce7c56f"
uuid = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
version = "0.15.14"

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
git-tree-sha1 = "7a58e45171b63ed4782f2d36fdee8713a469e6e0"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "8.1.2+0"

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
git-tree-sha1 = "5bad39456d9f0166184fce2248783dd9862645c1"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "1.17.0"
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
git-tree-sha1 = "592cfb5ed8b02804f6a9c04091571c393081f73a"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.5.12"

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
git-tree-sha1 = "6570366d757b50fabae9f4315ad74d2e40c0560a"
uuid = "59f7168a-df46-5410-90c8-f2779963d0ec"
version = "5.2.3+0"

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
git-tree-sha1 = "88352712893ec50bee3680605891eaf0e9ed6368"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "1.8.0"

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
git-tree-sha1 = "37b10d17f74f54dc5fa7d3c6c20fd75613c71d80"
uuid = "ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a"
version = "0.24.14"

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
deps = ["ColorSchemes", "Colors", "Dates", "PrecompileTools", "Printf", "Random", "Reexport", "StableRNGs", "Statistics"]
git-tree-sha1 = "26ca162858917496748aad52bb5d3be4d26a228a"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.4.4"

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
git-tree-sha1 = "818554664a2e01fc3784becb2eb3a82326a604b6"
uuid = "65257c39-d410-5151-9873-9b3e5be5013e"
version = "0.5.0"

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

[[deps.StableRNGs]]
deps = ["Random"]
git-tree-sha1 = "4f96c596b8c8258cc7d3b19797854d368f243ddc"
uuid = "860ef19b-820b-49d6-a774-d7a799459cd3"
version = "1.0.4"

[[deps.StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "be1cf4eb0ac528d96f5115b4ed80c26a8d8ae621"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.2"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "PrecompileTools", "Random", "StaticArraysCore"]
git-tree-sha1 = "e206cf4850fd7ac4255ffd2b98922f563e18ac53"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.9.20"
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
git-tree-sha1 = "2d0fc55c61321ba245c47be599570d11bac50303"
uuid = "ec057cc2-7a8d-4b58-b3b3-92acb9f63b42"
version = "2.8.5"

    [deps.StructUtils.extensions]
    StructUtilsMeasurementsExt = ["Measurements"]
    StructUtilsStaticArraysCoreExt = ["StaticArraysCore"]
    StructUtilsTablesExt = ["Tables"]

    [deps.StructUtils.weakdeps]
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
git-tree-sha1 = "ef17c47d22224aaecc76e597ab21a072e025cf7b"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.14.1+0"

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
git-tree-sha1 = "4e4282c4d846e11dce56d74fa8040130b7a95cb3"
uuid = "c5f90fcd-3b7e-5836-afba-fc50a0988cb2"
version = "1.6.0+0"

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
# ╟─646b24fe-f47b-4554-86fd-a4f8bf2099ff
# ╟─ee6dedf2-b105-11f1-9ab4-b5e3b10de8fa
# ╟─0f85d4f3-8e27-478d-a7b3-c8a5f902adec
# ╟─24c0921c-ac89-4987-82d5-c209f7f131d1
# ╟─a1960792-dfe9-426b-8dc5-7746b3190da4
# ╟─41ad8ec5-0fb2-459c-93b4-121331a4c2f2
# ╟─12795455-66e2-436a-b993-46957783cc0f
# ╟─d2560b51-155e-411e-a414-093f9694273a
# ╟─85e2f8fa-f284-4e6e-ae8c-1cd203643f64
# ╟─3704f55f-96e1-415a-902d-159314818f12
# ╟─316505fa-14d6-4f22-876c-e6e1dabbe4d9
# ╟─fc1a07dc-8540-4b08-aec6-7fca73cf5b94
# ╟─6f66c134-6060-4f78-9c16-51bf3b1311d1
# ╟─4e464867-020a-4143-a027-2c968c30a960
# ╟─985a7cbd-185a-4129-9ef1-98463f991745
# ╠═0411bd65-d3db-4b1f-a58e-a88cbccfacd7
# ╟─129996e6-739c-4745-929e-583a15842fca
# ╟─3ed7e2de-7a0f-46bb-95d7-e6b6f4149585
# ╟─1230392d-eff2-4c96-9e5c-c95f790a5004
# ╠═9dd60033-2f5a-4e8b-a0e6-b2bb89b7bd1c
# ╠═3e833c61-5f94-413e-ab57-5e1669da380e
# ╠═241cf2b3-dd9c-41d0-b69e-aef71d3ee162
# ╠═b3843e23-b9cf-4192-ba9c-496ba1695711
# ╟─8534ddd3-6097-4a53-a403-429397b0df61
# ╟─e9c4fcc1-09f8-4a00-8368-2d5b67e11e5f
# ╟─563965f8-ef6c-4b12-91dd-1e3a25f65248
# ╟─d6d9d531-4a2f-4e44-a018-04e2e4046041
# ╠═6c85a0bf-9156-43ef-a1ad-3ae80ebdb966
# ╠═cff2c4c6-1008-4a2c-b13a-83618f00b6fd
# ╠═0ae59d37-ba0e-435a-b1e8-7ebd35eb98d3
# ╠═6fb78164-19e2-48f8-957d-bb6681ebcb54
# ╟─c48327ce-2829-441b-a2eb-ff5397d17d09
# ╟─37362ad9-3383-4171-bc37-bc85acf642fc
# ╟─c3fb9efa-0728-448c-a992-79926dea6f7c
# ╠═197f44d5-76e1-4aee-b576-811d6923310f
# ╟─4c843ddf-bc16-4a33-8683-41cfa88762de
# ╟─770c08ce-bce5-4542-8ca7-92179d43a45d
# ╟─f1a20d7e-4069-4a5d-a77b-56a07b6ea2fc
# ╟─31129331-fbd5-4d66-8108-d84e43b14747
# ╠═e4406be5-fae9-402d-abb2-0d01aa9d80f9
# ╠═76c2a2f8-53ac-4820-97ed-1683209b9353
# ╠═df956745-ec01-49b8-8e7b-0717ce60a159
# ╠═a84ea677-fee3-42be-a194-24e50c4859e4
# ╟─6bd96e91-83be-4f19-b2dd-267187521fdf
# ╟─9f3ecb1f-0a0c-4c6a-bed8-b6aff27fb625
# ╟─f6270619-d412-465b-a3af-e6c3c6f8e257
# ╟─5c9b9479-d89e-44d6-9081-ddae9a6291ba
# ╟─50cb4141-1cb1-428b-938b-fd81f8102a91
# ╟─3125ddfe-2a52-4c92-989c-6d26c21e3c93
# ╟─8c2afa19-cd8e-4f7c-a7d5-fe5a8313f684
# ╟─c02bc7a1-2b6b-4453-bee7-9bb2735fc402
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
