### A Pluto.jl notebook ###
# v1.0.3

using Markdown
using InteractiveUtils

# ╔═╡ 2ddec1a4-f9ae-4518-bd2e-7ffc0eee8490
begin
using PlutoUI
using PlutoTeachingTools
TableOfContents()
end

# ╔═╡ e3f5c992-b76f-11f1-b33c-3b9472606fe3
md"""
# Solving elliptic PDEs

The goal of this lecture is to become familiar with:

- The damped wave equation.
- Accelerated pseudo-transient method for solving elliptic PDEs.

In the previous lecture, we established that the solution to the elliptic PDE could be obtained through integrating in time a corresponding parabolic PDE:

```math
c_t = \lambda c_{xx}
```

and discussed the limitations of this approach for numerical modelling, i.e., the quadratic dependence of the number of time steps on the number of grid points in spatial discretisation.

## Accelerating elliptic solver convergence: intuition

In this lecture, we'll improve the convergence rate of the elliptic solver, and consider the generalisation to higher dimensions.

Let's recall the stability conditions for diffusion and acoustic wave propagation:

```julia
dt = dx^2/dc/2      # diffusion
dt = dx/sqrt(1/β/ρ) # acoustic wave propagation
```

We can see that the acceptable time step for an acoustic problem is proportional to the grid spacing `dx`, and not `dx^2` as for the diffusion.

The number of time steps required for the wave to propagate through the domain is only proportional to the number of grid points `nx`.

Can we use that information to reduce the time required for the elliptic solver to converge?

In the solution to the wave equation, the waves do not attenuate with time: **there is no steady state**!

## Damped wave equation

Let's add diffusive properties to the wave equation by simply combining the physics:

```math
\begin{align}
\rho\frac{\partial V_x}{\partial t}                 &= -\frac{\partial P}{\partial x} \\[10pt]
\beta\frac{\partial P}{\partial t} + \frac{P}{\eta} &= -\frac{\partial V_x}{\partial x}
\end{align}
```

Note the addition of the new term ``\frac{P}{\eta}`` to the left-hand side of the mass balance equation, which could be interpreted physically as accounting for the bulk viscosity of the gas.

Equvalently, we could add the time derivative to the diffusion equation

```math
\begin{align}
\rho\frac{\partial q}{\partial t} + \frac{q}{D} &= -\frac{\partial C}{\partial x} \\[10pt]
\frac{\partial C}{\partial t}                   &= -\frac{\partial q}{\partial x}
\end{align}
```

In that case, the new term would be $\rho\frac{\partial q}{\partial t}$, which could be interpreted physically as adding the inertia to the momentum equation for diffusive flux.

Let's eliminate ``V_x`` and ``q`` in both systems to get one governing equation for ``P`` and ``C``, respectively:

```math
\begin{align}
\beta\frac{\partial^2 P}{\partial t^2} + \frac{1}{\eta}\frac{\partial P}{\partial t} &= \frac{1}{\rho}\frac{\partial^2 P}{\partial x^2} \\[10pt]
\rho\frac{\partial^2 C}{\partial t^2} + \frac{1}{D}\frac{\partial C}{\partial t}     &= \frac{\partial^2 C}{\partial x^2}
\end{align}
```

We refer to such equations as the **damped wave equations**. They combine wave propagation with diffusion, which manifests as wave attenuation, or decay. The damped wave equation is a hyperbolic PDE.

## Implementing the damped wave equation

In the following, we'll use the damped wave equation for concentration ``C`` obtained by augmenting the diffusion equation with density ``\rho``.

Starting from the existing code implementing time-dependent diffusion, let's add the intertial term ``\rho\frac{\partial q}{\partial t}``.

First step is to add the new physical parameter ``\rho`` to the `# physics` section:

```julia
# physics
...
ρ   = 20.0
```

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

Then we modify the time loop to incorporate the new physics:

```julia
for it = 1:nt
    #hint=#qx         .-= ...
    #sol=qx         .-= dt./(ρ*dc + dt).*(qx + dc.*diff(C)./dx)
    C[2:end-1] .-= dt.*diff(qx)./dx
    ...
end
```

👉 Your turn. Try to add the inertial term.

!!! hint
	There are two ways of adding the inertial term into the update rule.
	We could either take the known flux `q` in `q/dc` from the previous time step (explicit time integration), or the unknown flux from the next time step (implicit time integration).
	Could we treat the flux implicitly without having to solve the linear system?
	What are the benefits of the implicit time integration compared to the explicit one?

If the implementation is correct, we should see something like this:
"""

# ╔═╡ 0453afca-55f7-49ce-bd35-2ff47bf32c46
TODO("Damped wave equation")

# ╔═╡ f5c7c226-822e-48ae-a260-59ed19b6fe83
md"""


The waves decay, now there is a steady state! 🎉 The time it takes to converge, however, doesn't seem to improve...

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

Re-run the simulation and see the results:
"""

# ╔═╡ 0067339a-0167-4dd3-bdfb-c53113a885c4
TODO("Faster damped wave equation")

# ╔═╡ 4e08d1a4-f2ca-4931-a7c3-a16d4ba333ec
md"""
Now, this is much better! We observe that in less time steps, we get a much faster convergence. However, we introduced the new parameter, ``\rho``. Does the solution depend on the value of ``\rho``?

!!! note
	As we now consider pseudo-time to reach a steady state instead of physical time, we should replce `t` by `τ`.

## Problem of finding the iteration parameters

👉 Try changing the new parameter `ρ`, increasing and decreasing it. What happens to the solution?

We notice that depending on the value of the parameter `ρ`, the convergence to steady-state can be faster or slower. If `ρ` is too small, the process becomes diffusion-dominated, and we're back to the non-accelerated version. If `ρ` is too large, waves decay slowly.

If the parameter `ρ` has optimal value, the convergence to steady-state could be achieved in the number of time steps proportional to the number of grid points `nx` and not `nx^2` as for the parabolic PDE.

For linear PDEs it is possible to determine the optimal value for `ρ` analytically:

```julia
ρ    = (lx/(dc*2π))^2
```

How does one derive the optimal values for other problems and boundary conditions?
Unfortunately, we don't have time to dive into details in this course...

The idea of accelerating the convergence by increasing the order of PDE dates back to the work by [Frankel (1950)](https://doi.org/10.2307/2002770) where he studied the convergence rates of different iterative methods. Frankel noted the analogy between the iteration process and transient physics. In his work, the accelerated method was called the **second-order Richardson method**.

👀 If interested, [Räss et al. (2022)](https://gmd.copernicus.org/articles/15/5757/2022/) paper is a good starting point.

## Pseudo-transient method

In this course, we call any method that builds upon the analogy to the transient physics the **pseudo-transient (PT)** method.

Using this analogy proves useful when studying multi-physics and nonlinear processes. The PT method isn't restricted to solving the Poisson problems, but can be applied to a wide range of problems that are modelled with PDEs.

In a pseudo-transient method, we are interested only in a steady-state distributions of the unknown field variables such as concentration, temperature, etc.

We consider time steps as iterations in a numerical method. Therefore, we replace the time ``t`` in the equations with **pseudo-time** ``\tau``, and a time step `it` with iteration counter `iter`. When a pseudo-transient method converges, all the pseudo-time derivatives ``\partial/\partial\tau``, ``\partial^2/\partial\tau^2`` etc., vanish.

!!! warning
	We should be careful when introducing the new pseudo-physical terms into the governing equations. We need to make sure that when iterations converge, i.e., if the pseudo-time derivatives are set to 0, the system of equations is identical to the original steady-state formulation.

For example, consider the damped acoustic problem that we introduced in the beginning:

```math
\begin{align}
\rho\frac{\partial V_x}{\partial\tau}                 &= -\frac{\partial P}{\partial x} \\[10pt]
\beta\frac{\partial P}{\partial\tau} + \frac{P}{\eta} &= -\frac{\partial V_x}{\partial x}
\end{align}
```

At the steady-state, the second equation reads:

```math
\frac{P}{\eta} = -\frac{\partial V_x}{\partial x}
```

The velocity divergence is proportional to the pressure. If we wanted to solve the incompressible problem (i.e. the velocity divergence = 0), and were interested in the velocity distribution, this approach would lead to incorrect results. If we only want to solve the Laplace problem ``\partial^2 P/\partial x^2 = 0``, we could consider ``V_x`` purely as a numerical variable.

In other words: only add those new terms to the governing equations that vanish when the iterations converge!

## Measuring convergence

Let's modify the code structure of the new elliptic solver. We need to monitor convergence and stop iterations when the error has reached predefined tolerance.

To define the measure of error, we introduce the residual:

```math
r_C = D\frac{\partial^2 \widehat{C}}{\partial x^2}
```

where ``\widehat{C}`` is the pseudo-transient solution.

There are many ways to define the error as the norm of the residual, the most popular ones are the ``L_2`` norm and ``L_\infty`` norm. We will use the ``L_\infty`` norm here:

```math
\|\boldsymbol{r}\|_\infty = \max_i(|r_i|)
```

Add new parameters to the `# numerics` section of the code:

```julia
# numerics
nx      = 200
ϵtol    = 1e-8
maxiter = 20nx
ncheck  = ceil(Int,0.25nx)
```

Here `ϵtol` is the tolerance for the pseudo-transient iterations, `maxiter` is the maximal number of iterations, that we use now instead of number of time steps `nt`, and `ncheck` is the frequency of evaluating the residual and the norm of the residual, which is a costly operation.

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

Note that we save the number of iteration per grid cell `iter/nx`.

If the value of pseudo-transient parameter `ρ` is optimal, the number of iterations required for convergence should be proportional to `nx`, thus the `iter/nx` should be approximately constant.

👉 Try to check that by changing the resolution `nx`.

## Multi-physics: steady diffusion-reaction

Let's implement our first pseudo-transient multi-physics solver by adding chemical reaction:

```math
D\frac{\partial^2 C}{\partial x^2} = \frac{C - C_{eq}}{\xi}
```

As you might remember from the exercises, characteristic time scales of diffusion and reaction can be related through the non-dimensional Damköhler number ``\mathrm{Da}=l_x^2/D/\xi``.


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
    #hint=# C[2:end-1] .-= ...
    #sol=C[2:end-1] .-= dτ./(1 + dτ/ξ) .*((C[2:end-1] .- C_eq)./ξ .+ diff(qx)./dx)
    ...
end
```

!!! hint
	Don't forget to modify the residual!

Run the simulation and see the results:
"""

# ╔═╡ 453dd5fe-d9d4-41de-84af-d4ad5f291f33
TODO("diffusion-reaction")

# ╔═╡ f574be7f-945d-45d6-a16e-00bd9d85581b
md"""
As a final touch, let's refactor the code and extract the magical constant `2π` from the definition of numerical density `ρ`:

```julia
re      = 2π
ρ       = (lx/(dc*re))^2
```

We call this new parameter `re` due to it's association to the non-dimensional [Reynolds number](https://en.wikipedia.org/wiki/Reynolds_number) relating intertial and dissipative forces into the momentum balance.

Interestingly, the convergence rate of the diffusion-reaction systems could be improved significantly by modifying `re` to depend on the previously defined Damköhler number `da`:

```julia
re      = π + sqrt(π^2 + da)
```
👉 Verify that the number of iterations is indeed lower for the higher values of the Damköhler number.

## Wrapping-up

- Switching from parabolic to hyperbolic PDE allows to approach the steady-state in number of iterations, proportional to the number of grid points
- Pseudo-transient (PT) method is the matrix-free iterative method to solve elliptic (and other) PDEs by utilising the analogy to transient physics
- Using the optimal iteration parameters is essential to ensure the fast convergence of the PT method
"""

# ╔═╡ 413647f6-7a93-49e3-a517-b8ef158f670f
md"""
# Julia's REPL, the Package manager (Pkg.jl), and essential packages

## Julia REPL (interactive terminal)

[https://docs.julialang.org/en/v1/stdlib/REPL/](https://docs.julialang.org/en/v1/stdlib/REPL/)

`julia` starts the REPL, run `julia --help` to see options.  Useful options:
- `--project` sets the project directory to the current directory
- `-t 8` launches Julia with 8 threads (or any other number you specify)

Pretty powerful REPL:
- completion
- history:
  - start typing + up-arrow
  - Ctrl-r
- unicode completion
- several sub-modes: shell, Pkg, help
  - they are displayed with a different prompt
  - shell mode in Windows, try: `shell> powershell`

**Demo**

## Julia package manager

Docs:
- [short](https://docs.julialang.org/en/v1/stdlib/Pkg/)
- [detailed](https://pkgdocs.julialang.org/v1/)

Powerful package manager:
- installing, updating and removing packages
  - this also includes dependencies such as C/Fortan libs, Python/Conda environments, etc.
- separate environments for separate projects

## Demo of Julia package manager

**Demo** of:
- `Pkg` vs REPL mode `]`
- installing, removing, updating packages into global environment ([docs](https://pkgdocs.julialang.org/v1/managing-packages/))
  - the registry https://github.com/JuliaRegistries/General and https://juliahub.com/ui/Packages
- making a "Project" ([docs](https://pkgdocs.julialang.org/v1/environments/))
  - installing packages into that project's environment
  - testing packages
  - installing non-registered packages
  - `Project.toml` and `Manifest.toml`
- version conflicts and version bounds ([docs](https://pkgdocs.julialang.org/v1/managing-packages/#conflicts))
- developing a "Package"

## Essential packages for your global environment

Packages installed in your global environment are always available, thus useful for utility packages.

I have installed in my global environment:
- [Revise.jl](https://github.com/timholy/Revise.jl) --
  To load it at startup: `mkdir -p ~/.julia/config/ && echo "using Revise" >> ~/.julia/config/startup.jl`
- [BenchmarkTools.jl](https://github.com/timholy/Revise.jl) --
  Accurate timers for benchmarking, even quick fast running functions
- [IJulia.jl](https://github.com/JuliaLang/IJulia.jl) --
  The Julia Jupyter kernel.  Needs to be installed globally.
- [Plots.jl](https://github.com/JuliaPlots/Plots.jl)
- [Infiltrator.jl](https://github.com/JuliaDebug/Infiltrator.jl) --
  A debugger.  Pretty basic but works well without slowing down program execution (unlike Debugger.jl which has more features).
- [StatProfilerHTML.jl](https://github.com/tkluck/StatProfilerHTML.jl) or [ProfileView.jl](https://github.com/timholy/ProfileView.jl/) --
  To be used with the built in `Profile` module.  Displays nice flame graphs (probably does not work on the GPU)

## Julia Project environments: usage in this course

You will make use of Julia environments to submit your homework:

- In your project folder, which is push to GitHub, make sure to create a new folder for each week's exercises.
- Each week's folder should be a Julia project, i.e. it should contain a `Project.toml` file.

## Demo on how to do this

This can be achieved by typing entering the Pkg mode from the Julia REPL in the target folder

```julia-repl
julia> ]

(@v1.11) pkg> activate .

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

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
PlutoTeachingTools = "661c6b06-c737-4d37-b85c-46df65de6f69"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
PlutoTeachingTools = "~0.4.7"
PlutoUI = "~0.7.83"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.12.7"
manifest_format = "2.0"
project_hash = "b2ecc7c6ca1a91c35cb268bae47c4736cead32b9"

[[deps.AbstractPlutoDingetjes]]
git-tree-sha1 = "e71ee7b4aa06b045259a7d6101e1cb45ad140bce"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.4.1"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "67e11ee83a43eb71ddc950302c53bf33f0690dfe"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.12.1"
weakdeps = ["StyledStrings"]

    [deps.ColorTypes.extensions]
    StyledStringsExt = "StyledStrings"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.3.1+2"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.7.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FixedPointNumbers]]
deps = ["Random", "Statistics"]
git-tree-sha1 = "59af96b98217c6ef4ae0dfe065ac7c20831d1a84"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.6"

[[deps.Format]]
git-tree-sha1 = "9c68794ef81b08086aeb32eeaf33531668d5f5fc"
uuid = "1fa38f19-a742-5d3f-a2b9-30dd87b9d5f8"
version = "1.3.7"

[[deps.Ghostscript_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Zlib_jll"]
git-tree-sha1 = "38044a04637976140074d0b0621c1edf0eb531fd"
uuid = "61579ee1-b43e-5ca0-a5da-69d92c66a64b"
version = "9.55.1+0"

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

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "7204148362dafe5fe6a273f855b8ccbe4df8173e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.8.0"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "037babc10853eeb8e585418922246cb97b8e5b74"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "3.2.0+1"

[[deps.JuliaSyntaxHighlighting]]
deps = ["StyledStrings"]
uuid = "ac6e5ff7-fb65-4e79-a425-ec3bc9c03011"
version = "1.12.0"

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

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "OpenSSL_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.15.0+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "OpenSSL_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.3+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.12.0"

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

[[deps.Markdown]]
deps = ["Base64", "JuliaSyntaxHighlighting", "StyledStrings"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2025.11.4"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.3.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.29+0"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.5.6+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "05f45c2e0de6259db764adbfd2f1dc6d3f8de13c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "2.0.1"

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

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "5005266de4bfe50e53ff44a5cb5c540b6e47a254"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.6.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "62389eeff14780bfe55195b7204c0d8738436d64"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.1"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "e2b53ce13a53367e96601081e33d34746b571bad"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.5"

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

    [deps.Statistics.weakdeps]
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.StyledStrings]]
uuid = "f489334b-da3d-4c2e-b8f0-e476e12c162b"
version = "1.11.0"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

[[deps.Tricks]]
git-tree-sha1 = "311349fd1c93a31f783f977a71e8b062a57d4101"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.13"

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

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.3.1+2"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.15.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.64.0+1"
"""

# ╔═╡ Cell order:
# ╟─e3f5c992-b76f-11f1-b33c-3b9472606fe3
# ╟─0453afca-55f7-49ce-bd35-2ff47bf32c46
# ╟─f5c7c226-822e-48ae-a260-59ed19b6fe83
# ╟─0067339a-0167-4dd3-bdfb-c53113a885c4
# ╟─4e08d1a4-f2ca-4931-a7c3-a16d4ba333ec
# ╟─453dd5fe-d9d4-41de-84af-d4ad5f291f33
# ╟─f574be7f-945d-45d6-a16e-00bd9d85581b
# ╟─413647f6-7a93-49e3-a517-b8ef158f670f
# ╟─2ddec1a4-f9ae-4518-bd2e-7ffc0eee8490
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
