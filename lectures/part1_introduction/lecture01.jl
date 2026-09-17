### A Pluto.jl notebook ###
# v1.0.3

#> [frontmatter]
#> chapter = "1"
#> section = "1"
#> order = "1"
#> title = "Introduction to Julia"
#> date = "2026-09-15"
#> layout = "layout.jlhtml"
#> tags = ["module1"]
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

# ╔═╡ 5acc40dd-3463-4a28-b209-5c6dac4af0a7
# ╠═╡ show_logs = false
begin
using PlutoTeachingTools
using PlutoUI
PlutoUI.TableOfContents()
end

# ╔═╡ 3737ad5c-cc93-446f-884e-e196553d60cc
# ╠═╡ show_logs = false
using CairoMakie

# ╔═╡ c51edadb-418d-4d83-9aa5-ff4691250465
md"""
# Lecture 1

Welcome to ETH's course 101-0250-00L on solving partial differential equations (PDEs) in parallel on graphics processing units (GPUs) with the Julia language.

!!! info "Agenda"
	💡 Welcome     \
    📚 Why GPU computing \
    💻 Intro to Julia    \
    🚧 Exercises:
    - Solving ordinary differential equations (ODEs)
    - Visualisation
"""

# ╔═╡ dca5d64f-52cd-483b-ac36-e5206a6e5f55
md"""
## The team

| Name          | About me                                                                                    | Role in the course          |
| :----------- | :------------------------------------------------------------------------------------------ | :-------------------------- |
| Ivan Utkin   | Applied mathematician in the glaciology lab at ETH. Loves making things move on the screen. | Solving PDEs ...            |
| Ludovic Räss | Computational scientist at the University of Lausanne. Makes GPUs go brrr.                  | ... on GPUs ...             |
| Mauro Werder | Senior scientist in the glaciology lab at ETH. Knows how to `git push --force` safely.      | ... with best practices ... |
| Samuel Omlin | Computational scientist at CSCS. Wields the arcane arts of code optimisation.               | ... fast ...                |
| Ida Vetsch   | Teaching assistant. Knows how to solve the exercises better than the teachers do.           | ... and without worries.    |
"""

# ╔═╡ 59f175ad-f390-4e64-b319-7c4564a8a3e3
md"""
## Why solve PDEs on GPUs?

Problems in modern computational science are often **multiscale** both in time and space. A few examples:

- **Antarctic ice streams** carry a large share (as much as 90%) of the discharge from the ice sheet into the ocean, driving sea-level rise. Forecasting the evolution of ice sheets requires resolving scales from *~1 km* within the ice stream margin to *~5,000 km* at the continental scale.
- **Plate tectonics** drives the evolution of continents and oceans on Earth. Resolving subduction processes at convergent boundaries between plates requires **<1 km** resolution, while plate tectonics itself spans the entire Earth on scales of **~10,000 km**.
- **Earthquake cycle** happens in two phases: 1) slow stress buildup at the fault lines, taking **years**, and 2) rupture, happening when the stress reaches the critical strength of the rocks, on a timescale of **milliseconds**.
- **Atmospheric and ocean circulation** are critical for understanding climate change. Long-term climate-change forecasts suffer from large uncertainty, with the hope that achieving **<1 km** spatial resolution will enable much more accurate predictions. Current global circulation models (GCMs) achieve "only" 5--10 km resolution 😢
"""

# ╔═╡ 99c900e3-4548-4688-9311-3fee4a5c7d39
aside(md"""
!!! info "What are other ways?"
	Deep learning is highly successful in uncovering patterns in vast amounts of observational data. Data-driven and physics-based methods often complement each other. Examples are physics-informed neural networks (PINNs), neural operators, and adjoint-based inversions of physical parameters for PDEs.
""")

# ╔═╡ 6fcd42a3-68c2-4a82-95de-09003c7fd4ff
md"""
These problems can be approached from different angles. In this course, we will focus on modelling physical processes based on solving partial differential equations (PDEs) numerically by discretising them in time and space. This discretisation must resolve the smallest important scales to capture relevant physical processes. Resolving these multiscale processes, often governed by complex and nonlinear PDEs, can require computational resources that make **massively parallel computing** essential for practical simulations.

Growth in single-core performance started stagnating in the mid-2000s due to physical limitations. Moore's law is still relevant, but is now driven by the increase in the number of processing cores:

![50 years of microprocessor trend data](https://raw.githubusercontent.com/karlrupp/microprocessor-trend-data/refs/heads/master/50yrs/50-years-processor-trend.png)

Another important trend is the so-called **memory wall**, which refers to the growing gap between processor performance and memory-system performance, usually quantified as floating-point throughput (FLOP/s) and memory bandwidth (bytes/s), respectively. Both metrics grow exponentially over time, but the exponents are different:

![Evolution of CPU and GPU performance and memory bandwidth](https://raw.githubusercontent.com/eth-vaw-glaciology/course-101-0250-00/a4f02420601bae984a3e937fb72278b80d857b86/lectures/part1_introduction/assets/l1_cpu_gpu_evo.png)

This means that not the arithmetic complexity, but the amount and cost of memory accesses will ultimately determine the performance of more and more applications. Many scientific codes, especially PDE solvers, are memory bound.

GPUs offer memory bandwidth that is vastly superior to that of CPUs:

![GPU memory bandwidth comparison](https://raw.githubusercontent.com/eth-vaw-glaciology/course-101-0250-00/a4f02420601bae984a3e937fb72278b80d857b86/lectures/part1_introduction/assets/l1_perf_gpu.png)

However, developing codes for GPUs requires rethinking the implementation and which methods we choose for solving PDEs. In this course, you will learn how to use parallel computing, in particular GPU computing, to develop scalable PDE solvers with applications in natural sciences.
"""

# ╔═╡ bee9ddbf-13d4-4a56-9561-a5331d0e2787
md"""
## Why Julia?

Julia is a high-level and interactive language offering the performance of compiled languages such as C++ or Fortran. It provides the solution to the so-called **two-language problem**:

![The two-language problem](https://raw.githubusercontent.com/eth-vaw-glaciology/course-101-0250-00/a4f02420601bae984a3e937fb72278b80d857b86/lectures/part1_introduction/assets/l1_two_lang.png)

- One language to prototype - another language for production
- Example from Ludovic's past: prototype in MATLAB, production in CUDA-C
- One language for the users – one language for the implementation
    - NumPy (Python/C)
    - Machine learning: PyTorch, TensorFlow

Code stats for PyTorch/TensorFlow and Flux (Julia ML package):

![Code composition of Flux, PyTorch, and TensorFlow](https://raw.githubusercontent.com/eth-vaw-glaciology/course-101-0250-00/a4f02420601bae984a3e937fb72278b80d857b86/lectures/part1_introduction/assets/l1_flux-vs-tensorflow.png)

As you can see, Julia packages can be developed in 100% Julia.

Julia is interactive:

- No need for third-party visualisation software;
- Debugging and interactive REPL mode;
- Efficient for development.

Another "killer" feature of Julia is its rich [GPU ecosystem](https://juliagpu.org). You can run native Julia code on accelerators from many GPU vendors, including [NVIDIA](https://cuda.juliagpu.org/stable/), [AMD](https://amdgpu.juliagpu.org/stable/), [Apple](https://metal.juliagpu.org/stable/) and [Intel](https://juliagpu.github.io/oneAPI.jl/stable/). This enables **backend-agnostic** development, where the same program can execute on different architectures. You will learn how to write backend-agnostic programs in this course 😉

In recent years, more and more state-of-the-art numerical codes have been developed in Julia. A few examples:

- [JustRelax.jl](https://github.com/PTsolvers/JustRelax.jl) - geodynamics solvers for mantle convection and subduction;
- [Oceananigans.jl](https://github.com/CliMA/Oceananigans.jl) - ocean circulation model;
- [SpeedyWeather.jl](https://github.com/SpeedyWeather/SpeedyWeather.jl) - atmospheric circulation model;
- [Trixi.jl](https://github.com/trixi-framework/Trixi.jl) - framework for solving conservation laws;
- [ODINN.jl](https://github.com/ODINN-SciML/ODINN.jl) - global glacier evolution model;
- [Ferrite.jl](https://github.com/Ferrite-FEM/Ferrite.jl) - finite element toolbox.

Other nice things in the Julia ecosystem that we won't discuss further but are worth mentioning:

1. State-of-the-art ODE solvers - [DifferentialEquations.jl](https://docs.sciml.ai/DiffEqDocs/stable/);
2. Differentiability through automatic differentiation - [Enzyme.jl](https://enzyme.mit.edu/julia/stable/), [ForwardDiff.jl](https://juliadiff.org/ForwardDiff.jl/stable/);


!!! warning "Are there downsides?"
	Sure, as with any technology, there are a few:
	- Time to first execution (TTFX) can be quite long;
	- The language and package ecosystem evolve quickly and can be unstable.
"""

# ╔═╡ bd908b00-0c24-4145-8acb-3e3ab125e52f
md"""
### Time for some interactivity

!!! info "What is your previous programming experience?"
	1. Julia
	2. MATLAB, Python, Octave, R, ...
	3. C, Fortran, ...
	4. Pascal, Java, C++, ...
	5. Lisp, Haskell, ...
	6. Assembler
	7. Coq, Brainfuck, ...

Here's a survey for you to fill in now: [https://forms.gle/fZekjf9B5HwFEtvRA](https://forms.gle/fZekjf9B5HwFEtvRA). It shouldn't take more than 3 min to complete.
"""

# ╔═╡ 35e22cb6-9d3d-11f1-b980-a15009e82513
md"""
# Introduction to Julia

[Julia](https://julialang.org) is a modern, interactive, and high-performance programming language. It's a general-purpose language with a focus on technical computing.

- Julia was first released in 2012
- Reached version 1.0 in 2018
- Current version 1.13
- Thriving community, for instance there are currently around [14000 packages registered](https://juliahub.com/ui/Packages)

Let's see what Julia looks like. Here's an example solving the Lorenz system of ODEs:
"""

# ╔═╡ 799c495f-25b7-4533-b2ae-a5ac5ba629a8
let 
function lorenz(x)
    σ = 10
    β = 8/3
    ρ = 28
    [σ*(x[2]-x[1]),
     x[1]*(ρ-x[3]) - x[2],
     x[1]*x[2] - β*x[3]]
end
    
# integrate dx/dt = lorenz(t,x) numerically for 5000 steps
dt = 0.01
x₀ = [1.0, 0.0, 0.0]
out = zeros(3, 5000)
out[:,1] = x₀
for i=2:size(out,2)
    out[:,i] = out[:,i-1] + lorenz(out[:,i-1]) * dt
end

fig = Figure(size=(550, 500))
ax  = Axis3(fig[1, 1], title="Lorenz attractor", aspect=:equal, azimuth=2π/3)
lines!(ax, out[1,:], out[2,:], out[3,:])
fig
end

# ╔═╡ dfd2ac20-04b9-40a5-9ba2-266791449ebb
md"""
Yes, this takes a bit of time... Julia is Just-Ahead-of-Time compiled. I.e. Julia is compiling.
"""

# ╔═╡ 8fe811e0-f6cc-48a8-9d49-8e7213a922dc
md"""
## Let's get our hands dirty!

We will now look at

- Variables and types
- Control flow
- Functions
- Modules and packages

!!! tip
    Make sure you have working installation of Julia and Pluto. Follow the [software installation](https://pde-on-gpu.vaw.ethz.ch/previews/PR57/installation/) instructions.

The Julia documentation is good and can be found at [https://docs.julialang.org](https://docs.julialang.org); although for learning it might be a bit terse...

For tutorials, see [https://julialang.org/learning/](https://julialang.org/learning/).

Furthermore, documentation can be accessed with `?xyz`

```julia-repl
> ?cos
```

!!! tip
	To get started, click "**Edit** or **run** this notebook" in the top-right corner of this web page, then find the "**Copy the notebook URL**" section, copy the link to the notebook, and paste it into the "Open the notebook" field on your local Pluto main page.

## Variables, assignments, and types

Refer to the [documentation](https://docs.julialang.org/en/v1/manual/variables/) for details.

Create a variable by assigning a value to it:
"""

# ╔═╡ 1b0e888a-b2c7-40db-9f3b-25e2da7159e5
hello = "Hello"

# ╔═╡ 2573876f-b9e8-49df-a4fb-b48d7b78ea96
md"""
Julia supports string concatenation using the multiplication symbol '`*`':
"""

# ╔═╡ 162a5f3c-5137-4161-a1aa-5b011cd964bd
hello_world = hello * ", world!"

# ╔═╡ 3f376974-a7a0-44e5-bb26-d195f8dec9b8
md"""
!!! info "Pluto reactivity"
    Unlike Jupyter notebooks, Pluto.jl is **reactive**. Try changing the value of the variable `hello` and see what happens to `hello_world`.
"""

# ╔═╡ 494c2217-f969-42b3-a7c4-0fcfbfe8df1f
md"""
### Naming conventions

- variables are (usually) lowercase; words can be separated by `_`
- function names are lowercase
- modules, packages and types are in CamelCase

### Unicode

In Julia, Unicode names are allowed. See [the documentation](https://docs.julialang.org/en/v1/manual/variables/) for details.
"""

# ╔═╡ 381b4692-4571-448c-a9fc-97590837f958
δ = 0.00001 # very small number

# ╔═╡ 89ec7590-249a-4845-abd8-b4e600e1e2d6
안녕하세요 = "Hello"

# ╔═╡ f3633fb8-fa4b-4cf1-9832-bd959f3e6530
md"""
In the Julia REPL (also in Pluto and VS Code), you can type many Unicode math symbols by typing the backslashed LaTeX symbol name followed by Tab. For example, the variable name `δ` can be entered by typing `\delta + tab`, or even `α̂⁽²⁾` by `\alpha + tab + \hat + tab + \^(2) + tab`.

If you find a symbol that you don't know how to type, just type `?` in a Pluto cell or the REPL and then paste the symbol:
"""

# ╔═╡ ccc03075-f0d8-499f-8fe6-8a404c5fd5f1
# try typing ? and paste δ

# ╔═╡ c531c2b1-e127-4f36-9801-f01d17400519
md"""
### Basic data types

Built-in data types in Julia include, but are not limited to:

- numbers
- strings
- rationals
- tuples
- arrays
- dictionaries
"""

# ╔═╡ 350ac9e0-197e-4a79-b64c-540a27f3478c
i = 1 # try to type Int32(1) instead

# ╔═╡ d8ed3500-2f9c-42d9-9c32-d3b5ea703c2c
md"""
Variable `i` is a $(sizeof(i)*8)-bit integer.

Every value in Julia has a type:
"""

# ╔═╡ 4b8eb13e-e908-401c-a706-97eedc3d3d24
typeof(1.5), typeof(1//2)

# ╔═╡ b4a736a7-494e-499c-93d5-0f9f1ac6daf5
md"""
Declare a tuple in Julia using parentheses. Tuples are **immutable** and can store any data types:
"""

# ╔═╡ c606fe99-cc0e-4f5d-a59f-60dc817d3708
(1, 3.5)

# ╔═╡ 72a0c389-124d-439d-856c-0aa2cbb8e720
md"""
Arrays are declared with square brackets, and can only store values of the same type:
"""

# ╔═╡ 6c3af128-d4ac-48b1-945e-a87719747776
[1, 2, 3] # array of eltype Int

# ╔═╡ 767a51ef-e9ea-4a70-ba34-3c78be24c7d6
md"""
Try to create an array with two elements of different types. Explain why it works despite what was said above.
"""

# ╔═╡ ace7d4ca-c087-48ec-90b2-4e4e9fe7f2a4
# ╠═╡ disabled = true
#=╠═╡
# split: statement
# enter your code here
  ╠═╡ =#

# ╔═╡ f1ce7632-6217-492e-bd45-7cd5beddbbf6
# split: solution
[1, "hi"]

# ╔═╡ 6eefde0c-4b53-40bc-acdf-f8b6d5b53eac
md"""
!!! hint
	Use `eltype` to determine the element type.
"""

# ╔═╡ 348a9646-8721-492e-916d-4cff6caa147c
md"""
Dictionaries are collections that allow fast lookup of a value by key:
"""

# ╔═╡ a22d8be6-5102-425d-9bcb-ffa7ef96a71f
Dict("a" => 1, "b" => cos)

# ╔═╡ 369c7afa-b332-4e78-8db3-490d00ff705e
md"""
## Array exercises

We will use arrays extensively in this course.

All array types in Julia are subtypes of `AbstractArray`. There are many built-in `AbstractArray` types in Julia, including regular arrays and ranges, and even more array types available through external packages: GPU arrays, static arrays, etc.

Assign two integer vectors to variables `a` and `b`, and then concatenate them using '`;`':
"""

# ╔═╡ f2c73519-bcd4-466c-ab51-756d10b2ce6f
# ╠═╡ disabled = true
#=╠═╡
# split: statement
begin
	# enter your code here
end
  ╠═╡ =#

# ╔═╡ c8684934-f6be-450f-ba76-c57e639ccc5d
# split: solution
begin
	a = [1, 2]
	b = [3, 4]
	[a; b]
end

# ╔═╡ fb3634f7-9721-467d-8823-15bf9aad3f4c
md"""
!!! info "Code blocks in Pluto"
	By default, each code cell must contain only one expression. This limitation comes from reactivity. To use several expressions in a single cell, wrap them in a `begin ... end` code block.

Add a few new elements, e.g., `[6, 7]`, to the end of `b`:
"""

# ╔═╡ 0a494b8c-1454-49ac-b68f-1630014b80d7
# ╠═╡ disabled = true
#=╠═╡
# split: statement
# enter your code here
  ╠═╡ =#

# ╔═╡ 6b379e97-a85a-46b1-90aa-ed4f1e96c603
# split: solution
push!(b, 6, 7)

# ╔═╡ ad146aa3-38cf-4a82-aa60-3e9cf6f60d59
md"""
!!! hint
	Look up the documentation for `push!`
"""

# ╔═╡ 81007648-c981-4ba7-a2e4-dcd5b9cde67e
md"""
Ranges in Julia are declared using the colon symbol '`:`'. Concatenate a range `1:10` with a vector `[11, 12]`:
"""

# ╔═╡ a0dbd78a-6c3f-4736-8cf2-f392daba80a3
# ╠═╡ disabled = true
#=╠═╡
# split: statement
range_and_vec = missing
  ╠═╡ =#

# ╔═╡ c6c905c5-3a2b-4614-b198-381a74c9373e
# split: solution
range_and_vec = [1:10; [11, 12]]

# ╔═╡ 7acdf6c0-c8e6-4ac0-9f25-1d7683b08c8e
if ismissing(range_and_vec)
	still_missing()
elseif range_and_vec == [1:10, [11, 12]]
	almost(md"Whoops, you've put the range and a vector together instead of concantenating.")
elseif range_and_vec == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
	correct()
else
	keep_working()
end

# ╔═╡ 62edf55a-aba7-42ed-8aa8-8fc9a7b084db
md"""
Make a random array `c` of size `(3, 3)`. Look up `?rand`:
"""

# ╔═╡ ecb7b160-b745-4ca6-8705-c4246b66bbc5
# ╠═╡ disabled = true
#=╠═╡
# split: statement
# enter your code here
  ╠═╡ =#

# ╔═╡ 7965f354-3d48-43ec-a7eb-3d555448c6b2
# split: solution
c = rand(3, 3)

# ╔═╡ fbba14e8-6f53-4395-b9be-fc4070e24f01
md"""
Access elements `[1, 2]` and `[2, 1]` of matrix `c`:
"""

# ╔═╡ 003af53e-e17f-4f32-a62e-636d007486f5
# ╠═╡ disabled = true
#=╠═╡
# split: statement
# enter your code here
  ╠═╡ =#

# ╔═╡ 7b6c77a0-5d24-467b-93b8-2aa9d5fb2a40
# split: solution
c[1, 2], c[2, 1]

# ╔═╡ f47e0a2b-d01f-4c72-8108-6db62120a8e3
md"""
### Linear vs Cartesian indexing

Access the first element of `c` using a single linear index:
"""

# ╔═╡ 4ac5a5ff-8cc0-4b4c-933a-ab47a6145e29
# ╠═╡ disabled = true
#=╠═╡
# split: statement
# linear index
  ╠═╡ =#

# ╔═╡ 7743f6ed-7244-4013-97bd-535a9794cb54
# split: solution
c[1]

# ╔═╡ 6c532a20-d672-4b83-a946-0dc0e1f9c2b3
md"""
And a Cartesian index:
"""

# ╔═╡ e4b2f145-d695-4dc9-b601-b0d2bc39aa0b
# ╠═╡ disabled = true
#=╠═╡
# split: statement
# Cartesian index
  ╠═╡ =#

# ╔═╡ aa37849b-31aa-4a9f-aab7-e03784b93ce0
# split: solution
c[1, 1]

# ╔═╡ 72716ed9-50b1-48c7-b0fd-d687d063f7c5
md"""
By looking at linear indices of `c`, answer the question:

!!! question
	Are arrays in Julia row-major or column-major?
"""

# ╔═╡ 98cd2072-73cf-46ca-9cfe-63fc5f9a27bf
md"""
Access the last element of `c` (look up `?end`) using either linear or Cartesian indices:
"""

# ╔═╡ b8a6b23d-2ed7-4fad-810a-ab49be68e37d
# ╠═╡ disabled = true
#=╠═╡
# split: statement
# enter your code here
  ╠═╡ =#

# ╔═╡ 43cdee13-5894-4ce6-aa6b-2d844fda5996
# split: solution
c[end, end]

# ╔═╡ 023e5441-79ce-401f-b3de-435582ca2cb2
md"""
### Indexing by ranges

Access the last **row** of `c`:
"""

# ╔═╡ 9622c8ce-e36b-4685-9345-cb06133e450c
# ╠═╡ disabled = true
#=╠═╡
# split: statement
# enter your code here
  ╠═╡ =#

# ╔═╡ 06ec9f2f-cade-4020-a583-baff6086e886
# split: solution
c[end, 1:end]

# ╔═╡ 46b99f8f-a08b-4c15-98b8-3c807a389a53
md"""
!!! hint
	Use `1:end`
"""

# ╔═╡ 94cc402e-aab7-4806-a1a5-c665daa2cd50
md"""
Access a 2 × 2 submatrix:
"""

# ╔═╡ 916b8269-b407-4c5f-97d1-017bb471829e
# ╠═╡ disabled = true
#=╠═╡
# split: statement
# enter your code here
  ╠═╡ =#

# ╔═╡ 11943ba0-1328-4f4c-b409-24c391d6ae83
# split: solution
c[1:2, 1:2]

# ╔═╡ db4227eb-0395-4ed0-84ed-7641ce72d776
md"""
### Variable bindings and views

Look at the following code snippet:
"""

# ╔═╡ 61eb9beb-baa9-4673-a3f5-f6b865851d73
begin
	d = [1 4; 3 4] # this is another way to define a matrix
	e = d
	d[1, 2] = 99
	@assert e[1, 2] == d[1, 2]
end

# ╔═╡ 62ba4b85-77ee-4fe6-b33a-9fd010755456
md"""
What do you make of it? Type your answer here:
"""

# ╔═╡ 33852296-6a22-412a-ad5d-fd0d37934766
# ╠═╡ disabled = true
#=╠═╡
# split: statement
md"""

"""
  ╠═╡ =#

# ╔═╡ c566aa5b-d3a6-4804-a67c-a875974f16a0
# split: solution
md"""
Both variables `d` and `e` refer to the same memory address. Thus, updates to the array via one variable will show up in the other.
"""

# ╔═╡ abc9a86c-9b4c-4764-9968-2a815e570e6a
md"""
An assignment **binds** the same array to both variables:
"""

# ╔═╡ 6cdaddba-081e-4a21-b506-373edd3e2f58
begin
	p = d
	p[1] = 8
	@assert d[1] == 8 # f and d are the same thing!
	@assert p === d  # note the triple `=`
end

# ╔═╡ a612e8af-e946-4766-b199-5902ba428d42
md"""
In Julia, indexing with ranges will create a new array with copies of the original's entries. Consider this:
"""

# ╔═╡ f5fd39be-e532-4d2c-8b05-19cad9196eed
begin
	q = c[1:2, 1:2]
	q[1] = 99
	@assert q[1] != c[1]
end

# ╔═╡ 6a3689f7-bf39-4030-a11e-53fc46670cce
md"""
But the memory footprint will be large if we work with large arrays and take subarrays of them.

Views to the rescue:
"""

# ╔═╡ 361cdc34-6ae0-4aea-b80b-abeda7b06a47
begin
	v = @view c[1:3, 1:2]
	v[1] = 99
end

# ╔═╡ 6baeee64-29e3-45df-ae1d-acc29fba1c73
md"""
Check whether the change through `v` is reflected in `c`:
"""

# ╔═╡ 5a4f7187-69ab-4f50-bc3d-9758ecbf81c4
@assert c[1] == 99

# ╔═╡ 571e03ee-be64-4401-89f6-91a2ad7cedfc
md"""
## More about types

All values have types, as we saw above. An array’s type includes its element type.

!!! tip
	Arrays which have concrete element types are more performant!

The type can be specified at creation:
"""

# ╔═╡ 0c3f7078-d31a-425e-999a-47ff809a1eba
String["one", "two"]

# ╔═╡ 7ab513d2-6039-4544-9e28-e4032fd45d61
md"""
Create an empty array of `Int`, then push `1`, `1.0` and `1.5` to it. What happens?
"""

# ╔═╡ 7d38590b-90b5-4cf4-a003-0995b8e66477
# ╠═╡ disabled = true
#=╠═╡
# split: statement
let a = Int[]
	# enter your code here
end
  ╠═╡ =#

# ╔═╡ 289bfa51-d0fa-4029-b5ff-9e4288182a74
# split: solution
let a = Int[]
	push!(a, 1)   # works
	push!(a, 1.0) # works
	push!(a, 1.5) # errors as 1.5 cannot be converted to an Int
end

# ╔═╡ 41c7d2f1-5b65-4a8f-9aa4-81f15c378b92
md"""
!!! info "Let block"
    A `let ... end` block introduces a local scope, allowing you to reuse variable names, which Pluto normally won't allow.

Try to assign `1.5` to the first element of an array of type `Array{Int,1}`:
"""

# ╔═╡ 21de8544-f929-4b97-b8aa-2beba0632572
# ╠═╡ disabled = true
#=╠═╡
# split: statement
# enter your code here
  ╠═╡ =#

# ╔═╡ 53d6ef00-3b01-4679-94ec-46b8a417418d
# split: solution
let a = [1]
	a[1] = 1.5
end

# ╔═╡ 68667330-254c-4f7a-9991-122e68cdf659
md"""
### Array initialisation

Create an uninitialised matrix of size `(3, 3)` and assign it to `k`. Specify a `let` block if needed to avoid another global definition. First look up the docs for `Array` with `?Array`. Test that its size is correct (see `size`):
"""

# ╔═╡ f620497e-9a57-4d91-bab8-0f0b17b0dfbf
# ╠═╡ disabled = true
#=╠═╡
# split: statement
# enter your code here
  ╠═╡ =#

# ╔═╡ aa59c4be-6a6b-41f3-b026-50322c0c4d20
# split: solution
let k = Array{Any}(undef, 3, 3)
	@assert size(k) == (3, 3)
end

# ╔═╡ f9753402-6d39-4139-837f-c7090c0bebe7
md"""
Well done! You will learn the rest about Julia arrays by doing 😉
"""

# ╔═╡ a568d1da-de09-42ab-bbc2-9fcf78ba4cca
md"""
## Control flow

Julia provides a variety of control flow constructs. We will look at:

- conditional evaluation: `if ... elseif ... else` and `... ? ... : ...` (ternary operator)
- short-circuit evaluation: logical operators `&&` ("and") and `||` ("or"), and also chained comparisons
- repeated evaluation: `while` and `for` loops

### Conditional evaluation

Read the first paragraph of [the documentation](https://docs.julialang.org/en/v1/manual/control-flow/#man-conditional-evaluation) up to "... and no further condition expressions or blocks are evaluated."

Write a conditional check which looks at the start of the string in variable `l` (look up `?startswith`) and returns accordingly.

If the start is:

- "Wh" then return "Likely a question"
- "The " then return "A noun"
- otherwise return "no idea"
"""

# ╔═╡ 23524c52-2388-425a-8d34-5fc6daee0622
l = "Where are the flowers"

# ╔═╡ 37b07142-aa3d-4b39-815e-266d45cccfad
# ╠═╡ disabled = true
#=╠═╡
# split: statement
# enter your code here
  ╠═╡ =#

# ╔═╡ d31431f5-db94-4a7c-a52c-823206501cee
# split: solution
if startswith(l, "Wh")
  "Likely a question"
elseif startswith(l, "The  ")
  "Likely a noun"
else
  "no idea"
end

# ╔═╡ 4a95170d-4ed6-4295-a850-7d8eac624440
md"""
### The ternary operator

Let's learn more compact ways of expressing the control flow.
"""

# ╔═╡ 2b104943-fb24-471e-bb9c-276832ba18ac
x = 5

# ╔═╡ 8aed2345-9eab-4c27-9863-9f16e6b54303
md"""
Look up the docs for the ternary operator `?` (use `??`).

Rewrite the following code using the ternary operator:
"""

# ╔═╡ 2fa15b9f-adc7-4aba-851d-e44550320459
if x > 5
    "really big"
else
    "not so big"
end

# ╔═╡ b9888186-227b-4b9d-b7d9-e37c3e305958
# ╠═╡ disabled = true
#=╠═╡
# split: statement
# enter your code here
  ╠═╡ =#

# ╔═╡ 02dbd894-e3df-47a6-b3ed-430e0f219d35
# split: solution
x > 5 ? "really big" : "not so big"

# ╔═╡ 7c8caad6-346c-4f18-ac24-e95424cd43a5
md"""
### Short-circuit operators `&&` and `||`

Read [the documentation](https://docs.julialang.org/en/v1/manual/control-flow/#Short-Circuit-Evaluation) about short-circuit evaluation.

Explain what this does:
"""

# ╔═╡ 10016223-51eb-4287-835c-3b352ea705b5
x < 0 && error("Not valid input for `x`")

# ╔═╡ 8c985a11-f45f-41d2-96d6-55c41e01b3d4
md"""
Type your answer here:
"""

# ╔═╡ e8ee8ac4-677e-488d-8659-9221c343e76f
# split: statement
md"""

"""

# ╔═╡ c238c957-a269-4b85-b71c-8deb547a15e9
# split: solution
md"""
If `x < 0` evaluates to `true`, then the part after the `&&` is evaluated too, i.e. an error is thrown. Otherwise, only `x < 0` is evaluated and no error is thrown.
"""

# ╔═╡ 9778d460-1ac6-4a16-a4a2-b81162eab8b9
md"""
### Loops: `for` and `while`

Read [the documentation](https://docs.julialang.org/en/v1/manual/control-flow/#man-loops) about loops.


Here's a summary of the loop syntax in Julia:
"""

# ╔═╡ 92e70453-d542-43c1-8b8c-670a99ce8969
begin
for i = 1:3
    println(i)
end

for i in ["dog", "cat"] # 'in`, '=', and even '∈' are equivalent for writing loops
    println(i)
end
end

# ╔═╡ a31b661b-2d1d-47ea-b24f-f9b34eb13bfb
let i = 1
    while i<4
        println(i)
        i += 1
    end
end

# ╔═╡ ba3cc1c1-f744-460d-9c88-05689c031759
md"""
## Functions

Functions can be defined in Julia in a number of ways. In particular, there is one variant more suited to longer definitions:
"""

# ╔═╡ 555e9a9c-7dbe-46b0-bec0-2922c06f6de8
function f(a, b)
   return a * b
end

# ╔═╡ 50ebcc54-0b9b-456e-965e-285542d9a302
md"""
And one for one-liners:
"""

# ╔═╡ 374dab69-402c-4c04-bf12-6863583e4ba2
g(a, b) = a * b

# ╔═╡ 52297b32-af55-484a-b000-207ee785fda4
md"""
Defining many short functions is typical in good Julia code.

Read [the documentation](https://docs.julialang.org/en/v1/manual/functions/) about functions up to and including "The `return` Keyword".

Define a function in long form which takes two arguments. Use some `if ... else` statements and the `return` keyword:
"""

# ╔═╡ a23899dd-80e6-4b17-8d20-812e64e76edc
# split: statement
# enter your code here

# ╔═╡ 3208d485-7de8-4f12-83db-a31841816567
# split: solution
function fn(a, b)
    if a > b
        return a
    else
        return b
    end
end

# ╔═╡ e52e1d07-6894-4935-a76e-f30693b37aca
md"""
Implement a simplified version of `map` called `mymap`. First look up what `map` does, then create a `mymap` function which does the same. Map `sin` over the range `1:10`.

!!! note "Higher-order functions"
	Note that `map` and `mymap` are **higher-order functions**: functions which take another function as an argument.
"""

# ╔═╡ 5c8faade-11f2-429b-a4eb-0a584ba4e7f7
# ╠═╡ disabled = true
#=╠═╡
# split: statement
mymap(fn, a) = missing
  ╠═╡ =#

# ╔═╡ f0222d1f-e455-49eb-89b7-b92e63a7ff74
# split: solution
mymap(fn, a) = [fn(x) for x in a]

# ╔═╡ a34aaa25-6c4a-4bb1-bad1-5817c11befc7
mymap(sin, 1:10)

# ╔═╡ 0f4757ec-8659-4de9-8aa1-40e50751dbee
let
	answer = mymap(sin, 1:10)
	if ismissing(answer)
		still_missing()
	elseif answer == map(sin, 1:10)
		correct()
	else
		keep_working()
	end
end

# ╔═╡ 19a42d47-a4be-416f-aaac-54e278840e7f
md"""
## Broadcasting and the dot syntax

Broadcasting applies a function elementwise and can combine inputs with compatible shapes. This is really similar to the `map` function, a shorthand to map/broadcast a function over values. Append `.` to the function name to apply the function to a collection element-wise.

Broadcast the `sin` function over a `1:10` range using the dot syntax:
"""

# ╔═╡ dde4f08a-ecd0-46ac-a0cf-60354c24f16f
# ╠═╡ disabled = true
#=╠═╡
# split: statement
# enter your code here
  ╠═╡ =#

# ╔═╡ 9c204f78-7013-48fe-ba7d-7d6754b85f43
# split: solution
sin.(1:10)

# ╔═╡ b5ecfca6-f288-43da-92b5-3da7a08752f5
md"""
Broadcasting will extend row and column vectors into a matrix. Try `(1:10) .+ (1:10)'`:
"""

# ╔═╡ 1f51a87e-ed58-4c79-889d-5162a81a3fbf
# ╠═╡ disabled = true
#=╠═╡
# split: statement
# enter your code here
  ╠═╡ =#

# ╔═╡ dd26955e-ee24-4c66-8a97-3f388599bc7b
# split: solution
(1:10) .+ (1:10)'

# ╔═╡ 11f95adb-9b39-469e-b85f-4f90ab2d719d
md"""
!!! note "The transpose operator"
	The symbol `'` is a transpose operator that in this case turns a column vector into a row vector.
"""

# ╔═╡ 203223f6-1cc7-4049-b8b5-d728d2094f44
md"""
Broadcast the function `sin(x) + cos(y)` over `x ∈ [0, π]` and `y ∈ [-π, π]` with a step of 0.1 in both `x` and `y`:
"""

# ╔═╡ 237f42b7-645e-4776-8af0-186f595c38cb
# ╠═╡ disabled = true
#=╠═╡
# split: statement
# enter your code here
  ╠═╡ =#

# ╔═╡ a8c4fbbe-0eb6-440e-8562-fd34145c9404
# split: solution
let
	x, y = 0:0.1:π, -π:0.1:π
	sin.(x) .+ cos.(y')
end

# ╔═╡ b26dab4e-0bb3-4eee-8804-797dd05083d4
md"""
!!! hint
	Use ranges for `x` and `y`, and a `let` block to avoid variable name clashes. Both `π` and `pi` are built-in constants defined in Julia. Don't forget to use `'`!
"""

# ╔═╡ a0c502b0-7585-450a-91ef-5899671d06ca
md"""
### Anonymous functions

So far, our functions have had names. They can also be defined without a name.

Read [the documentation](https://docs.julialang.org/en/v1/manual/functions/#man-anonymous-functions) about anonymous functions.

Map the function `sin(x) + cos(x)` over `1:10` but define it as an anonymous function:
"""

# ╔═╡ 2cab5fc1-f97c-4d2e-b4d7-8b80a553b542
# ╠═╡ disabled = true
#=╠═╡
# split: statement
# enter your code here
  ╠═╡ =#

# ╔═╡ 854f5b33-62a3-4902-95c8-11ac89b24ab0
# split: solution
map(x -> sin(x) + cos(x), 1:10)

# ╔═╡ a2c37ad9-16e1-406f-ae3f-e11a3cfb26c5
md"""
## Killer feature: multiple dispatch

Julia is **not an object-oriented language**, and this is a good thing!

In an object-oriented language, methods belong to objects, and a particular method is selected based on the dynamic type of an object (which is sometimes passed as a first argument, e.g. `self` in Python).

Julia is a language with ✨**multiple dispatch**✨. This means that methods are separate from objects, and are selected at runtime based on the dynamic types of **all arguments**. This is similar to overloading but method selection occurs at runtime and not compile-time.

This turns out to be very natural for mathematical programming.

Check this JuliaCon 2019 presentation on the subject by Stefan Karpinski (co-creator of Julia):
"""

# ╔═╡ 86dea386-5d8c-4dff-8e20-b8ea5e68ae24
html"""
<iframe width="560" height="315" src="https://www.youtube.com/embed/kc9HwsxE1OY?si=Rmozw0mxfS_c3qqs" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>
"""

# ╔═╡ ce299789-51d9-4961-8f5a-eed6458af549
md"""
### Multiple dispatch demo

This cool example is based on a [blog post](https://giordano.github.io/blog/2017-11-03-rock-paper-scissors/) by Mose Giordano:
"""

# ╔═╡ 4951bdee-b47c-42df-bf14-8468edf5a9b3
begin
struct Rock end
struct Paper end
struct Scissors end
	
## of course structs could have fields as well
# struct Rock
#     color
#     name::String
#     density::Float64
# end

# define multi-method
play(::Rock, ::Paper) = "Paper wins"
play(::Rock, ::Scissors) = "Rock wins"
play(::Scissors, ::Paper) = "Scissors wins"
play(a, b) = play(b, a) # commutative
end

# ╔═╡ 4152492c-e1bf-46e0-921a-8ea70d372486
md"""
This can easily be extended later

with a new type:
"""

# ╔═╡ 0a91c58a-b8f2-41c8-99de-7bd0a077e6ff
begin
struct Pond end
play(::Rock, ::Pond) = "Pond wins"
play(::Paper, ::Pond) = "Paper wins"
play(::Scissors, ::Pond) = "Pond wins"
end

# ╔═╡ a4389ae9-5cc5-4270-bcff-f1a28c768429
play(Scissors(), Rock())

# ╔═╡ 5318bd35-b184-4e6c-8df7-932f82f2dbc0
play(Scissors(), Pond())

# ╔═╡ 8844984d-f677-4a15-8b00-eaed1c5d3042
md"""
or with a new function:
"""

# ╔═╡ 78c8b8b2-7046-41ac-92f1-f4356a8e4dd0
begin
combine(::Rock, ::Paper) = "Paperweight"
combine(::Paper, ::Scissors) = "Two pieces of papers"
# ...
end

# ╔═╡ a41245ac-12ab-4fb6-a148-3a5e8052dc39
combine(Rock(), Paper())

# ╔═╡ 2a098678-bfda-47fa-a066-ad0925629634
md"""
*Multiple dispatch makes Julia packages very composable!*

This is a key characteristic of the Julia package ecosystem.
"""

# ╔═╡ 54f1fc94-054b-4239-b905-332b24c4ed8c
md"""
## Modules and packages

Modules can be used to structure code into larger entities, and to divide it into different namespaces. We will not make much use of them, but if you are interested, see [the documentation](https://docs.julialang.org/en/v1/manual/modules/).

Packages are the way people distribute code and we'll make use of them extensively. In the first example, the Lorenz ODE, you saw
"""

# ╔═╡ f971ad6b-808f-4c00-8cc8-20a5a3187a5b
md"""
At the start of this notebook, `using CairoMakie` loads CairoMakie and brings its exported names into scope. You can use it like so:
"""

# ╔═╡ a243b363-cc8e-434d-aec2-001c24bd1ab7
lines((1:10).^2)

# ╔═╡ fe8afed4-e7fd-4db4-b558-016b7d27b5fd
md"""
!!! info "Installing packages"
	Pluto.jl features its own [package manager](https://plutojl.org/en/docs/packages/), which installs packages automatically when they are used. Installing and updating packages when working with Julia outside of Pluto is a future topic.

**This concludes the rapid Julia tour!**

Julia has many more features, but this should get you started and ready for the exercises. (Let us know if you feel we left something out which would have been helpful for the exercises.)

Remember, you can get help by:

- using `?` in the notebook. Similarly, there is an `apropos` function.
- reading [the docs](https://docs.julialang.org/en/v1/)
- asking for help in our chat channel: see Moodle
"""

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
manifest_format = "2.1"
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
git-tree-sha1 = "6c3913f4e9bdf6ba3c08041a446fb1332716cbc2"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.4.0"

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
git-tree-sha1 = "daa72978cd7a624246e894a4f4f067706d4e17e2"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "4.7.0"
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
git-tree-sha1 = "8b770b60760d4451834fe79dd483e318eee709c4"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.5.2"

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
git-tree-sha1 = "ae3bb1eb3bba077cd276bc5cfc337cc65c3075c0"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.1"
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

[registries.General]
url = "https://github.com/JuliaRegistries/General.git"
uuid = "23338594-aafe-5451-b93e-139f81909106"
"""

# ╔═╡ Cell order:
# ╟─5acc40dd-3463-4a28-b209-5c6dac4af0a7
# ╟─c51edadb-418d-4d83-9aa5-ff4691250465
# ╟─dca5d64f-52cd-483b-ac36-e5206a6e5f55
# ╟─59f175ad-f390-4e64-b319-7c4564a8a3e3
# ╟─99c900e3-4548-4688-9311-3fee4a5c7d39
# ╟─6fcd42a3-68c2-4a82-95de-09003c7fd4ff
# ╟─bee9ddbf-13d4-4a56-9561-a5331d0e2787
# ╟─bd908b00-0c24-4145-8acb-3e3ab125e52f
# ╟─35e22cb6-9d3d-11f1-b980-a15009e82513
# ╠═799c495f-25b7-4533-b2ae-a5ac5ba629a8
# ╟─dfd2ac20-04b9-40a5-9ba2-266791449ebb
# ╟─8fe811e0-f6cc-48a8-9d49-8e7213a922dc
# ╠═1b0e888a-b2c7-40db-9f3b-25e2da7159e5
# ╟─2573876f-b9e8-49df-a4fb-b48d7b78ea96
# ╠═162a5f3c-5137-4161-a1aa-5b011cd964bd
# ╟─3f376974-a7a0-44e5-bb26-d195f8dec9b8
# ╟─494c2217-f969-42b3-a7c4-0fcfbfe8df1f
# ╠═381b4692-4571-448c-a9fc-97590837f958
# ╠═89ec7590-249a-4845-abd8-b4e600e1e2d6
# ╟─f3633fb8-fa4b-4cf1-9832-bd959f3e6530
# ╠═ccc03075-f0d8-499f-8fe6-8a404c5fd5f1
# ╟─c531c2b1-e127-4f36-9801-f01d17400519
# ╠═350ac9e0-197e-4a79-b64c-540a27f3478c
# ╟─d8ed3500-2f9c-42d9-9c32-d3b5ea703c2c
# ╠═4b8eb13e-e908-401c-a706-97eedc3d3d24
# ╟─b4a736a7-494e-499c-93d5-0f9f1ac6daf5
# ╠═c606fe99-cc0e-4f5d-a59f-60dc817d3708
# ╟─72a0c389-124d-439d-856c-0aa2cbb8e720
# ╠═6c3af128-d4ac-48b1-945e-a87719747776
# ╟─767a51ef-e9ea-4a70-ba34-3c78be24c7d6
# ╠═ace7d4ca-c087-48ec-90b2-4e4e9fe7f2a4
# ╠═f1ce7632-6217-492e-bd45-7cd5beddbbf6
# ╟─6eefde0c-4b53-40bc-acdf-f8b6d5b53eac
# ╟─348a9646-8721-492e-916d-4cff6caa147c
# ╠═a22d8be6-5102-425d-9bcb-ffa7ef96a71f
# ╟─369c7afa-b332-4e78-8db3-490d00ff705e
# ╠═f2c73519-bcd4-466c-ab51-756d10b2ce6f
# ╠═c8684934-f6be-450f-ba76-c57e639ccc5d
# ╟─fb3634f7-9721-467d-8823-15bf9aad3f4c
# ╠═0a494b8c-1454-49ac-b68f-1630014b80d7
# ╠═6b379e97-a85a-46b1-90aa-ed4f1e96c603
# ╟─ad146aa3-38cf-4a82-aa60-3e9cf6f60d59
# ╟─81007648-c981-4ba7-a2e4-dcd5b9cde67e
# ╠═a0dbd78a-6c3f-4736-8cf2-f392daba80a3
# ╠═c6c905c5-3a2b-4614-b198-381a74c9373e
# ╟─7acdf6c0-c8e6-4ac0-9f25-1d7683b08c8e
# ╟─62edf55a-aba7-42ed-8aa8-8fc9a7b084db
# ╠═ecb7b160-b745-4ca6-8705-c4246b66bbc5
# ╠═7965f354-3d48-43ec-a7eb-3d555448c6b2
# ╟─fbba14e8-6f53-4395-b9be-fc4070e24f01
# ╠═003af53e-e17f-4f32-a62e-636d007486f5
# ╠═7b6c77a0-5d24-467b-93b8-2aa9d5fb2a40
# ╟─f47e0a2b-d01f-4c72-8108-6db62120a8e3
# ╠═4ac5a5ff-8cc0-4b4c-933a-ab47a6145e29
# ╠═7743f6ed-7244-4013-97bd-535a9794cb54
# ╟─6c532a20-d672-4b83-a946-0dc0e1f9c2b3
# ╠═e4b2f145-d695-4dc9-b601-b0d2bc39aa0b
# ╠═aa37849b-31aa-4a9f-aab7-e03784b93ce0
# ╟─72716ed9-50b1-48c7-b0fd-d687d063f7c5
# ╟─98cd2072-73cf-46ca-9cfe-63fc5f9a27bf
# ╠═b8a6b23d-2ed7-4fad-810a-ab49be68e37d
# ╠═43cdee13-5894-4ce6-aa6b-2d844fda5996
# ╟─023e5441-79ce-401f-b3de-435582ca2cb2
# ╠═9622c8ce-e36b-4685-9345-cb06133e450c
# ╠═06ec9f2f-cade-4020-a583-baff6086e886
# ╟─46b99f8f-a08b-4c15-98b8-3c807a389a53
# ╟─94cc402e-aab7-4806-a1a5-c665daa2cd50
# ╠═916b8269-b407-4c5f-97d1-017bb471829e
# ╠═11943ba0-1328-4f4c-b409-24c391d6ae83
# ╟─db4227eb-0395-4ed0-84ed-7641ce72d776
# ╠═61eb9beb-baa9-4673-a3f5-f6b865851d73
# ╟─62ba4b85-77ee-4fe6-b33a-9fd010755456
# ╠═33852296-6a22-412a-ad5d-fd0d37934766
# ╠═c566aa5b-d3a6-4804-a67c-a875974f16a0
# ╟─abc9a86c-9b4c-4764-9968-2a815e570e6a
# ╠═6cdaddba-081e-4a21-b506-373edd3e2f58
# ╟─a612e8af-e946-4766-b199-5902ba428d42
# ╠═f5fd39be-e532-4d2c-8b05-19cad9196eed
# ╟─6a3689f7-bf39-4030-a11e-53fc46670cce
# ╠═361cdc34-6ae0-4aea-b80b-abeda7b06a47
# ╟─6baeee64-29e3-45df-ae1d-acc29fba1c73
# ╠═5a4f7187-69ab-4f50-bc3d-9758ecbf81c4
# ╟─571e03ee-be64-4401-89f6-91a2ad7cedfc
# ╠═0c3f7078-d31a-425e-999a-47ff809a1eba
# ╟─7ab513d2-6039-4544-9e28-e4032fd45d61
# ╠═7d38590b-90b5-4cf4-a003-0995b8e66477
# ╠═289bfa51-d0fa-4029-b5ff-9e4288182a74
# ╟─41c7d2f1-5b65-4a8f-9aa4-81f15c378b92
# ╠═21de8544-f929-4b97-b8aa-2beba0632572
# ╠═53d6ef00-3b01-4679-94ec-46b8a417418d
# ╟─68667330-254c-4f7a-9991-122e68cdf659
# ╠═f620497e-9a57-4d91-bab8-0f0b17b0dfbf
# ╠═aa59c4be-6a6b-41f3-b026-50322c0c4d20
# ╟─f9753402-6d39-4139-837f-c7090c0bebe7
# ╟─a568d1da-de09-42ab-bbc2-9fcf78ba4cca
# ╠═23524c52-2388-425a-8d34-5fc6daee0622
# ╠═37b07142-aa3d-4b39-815e-266d45cccfad
# ╠═d31431f5-db94-4a7c-a52c-823206501cee
# ╟─4a95170d-4ed6-4295-a850-7d8eac624440
# ╠═2b104943-fb24-471e-bb9c-276832ba18ac
# ╟─8aed2345-9eab-4c27-9863-9f16e6b54303
# ╠═2fa15b9f-adc7-4aba-851d-e44550320459
# ╠═b9888186-227b-4b9d-b7d9-e37c3e305958
# ╠═02dbd894-e3df-47a6-b3ed-430e0f219d35
# ╟─7c8caad6-346c-4f18-ac24-e95424cd43a5
# ╠═10016223-51eb-4287-835c-3b352ea705b5
# ╟─8c985a11-f45f-41d2-96d6-55c41e01b3d4
# ╠═e8ee8ac4-677e-488d-8659-9221c343e76f
# ╠═c238c957-a269-4b85-b71c-8deb547a15e9
# ╟─9778d460-1ac6-4a16-a4a2-b81162eab8b9
# ╠═92e70453-d542-43c1-8b8c-670a99ce8969
# ╠═a31b661b-2d1d-47ea-b24f-f9b34eb13bfb
# ╟─ba3cc1c1-f744-460d-9c88-05689c031759
# ╠═555e9a9c-7dbe-46b0-bec0-2922c06f6de8
# ╟─50ebcc54-0b9b-456e-965e-285542d9a302
# ╠═374dab69-402c-4c04-bf12-6863583e4ba2
# ╟─52297b32-af55-484a-b000-207ee785fda4
# ╠═a23899dd-80e6-4b17-8d20-812e64e76edc
# ╠═3208d485-7de8-4f12-83db-a31841816567
# ╟─e52e1d07-6894-4935-a76e-f30693b37aca
# ╠═5c8faade-11f2-429b-a4eb-0a584ba4e7f7
# ╠═f0222d1f-e455-49eb-89b7-b92e63a7ff74
# ╠═a34aaa25-6c4a-4bb1-bad1-5817c11befc7
# ╟─0f4757ec-8659-4de9-8aa1-40e50751dbee
# ╟─19a42d47-a4be-416f-aaac-54e278840e7f
# ╠═dde4f08a-ecd0-46ac-a0cf-60354c24f16f
# ╠═9c204f78-7013-48fe-ba7d-7d6754b85f43
# ╟─b5ecfca6-f288-43da-92b5-3da7a08752f5
# ╠═1f51a87e-ed58-4c79-889d-5162a81a3fbf
# ╠═dd26955e-ee24-4c66-8a97-3f388599bc7b
# ╟─11f95adb-9b39-469e-b85f-4f90ab2d719d
# ╟─203223f6-1cc7-4049-b8b5-d728d2094f44
# ╠═237f42b7-645e-4776-8af0-186f595c38cb
# ╠═a8c4fbbe-0eb6-440e-8562-fd34145c9404
# ╟─b26dab4e-0bb3-4eee-8804-797dd05083d4
# ╟─a0c502b0-7585-450a-91ef-5899671d06ca
# ╠═2cab5fc1-f97c-4d2e-b4d7-8b80a553b542
# ╠═854f5b33-62a3-4902-95c8-11ac89b24ab0
# ╟─a2c37ad9-16e1-406f-ae3f-e11a3cfb26c5
# ╟─86dea386-5d8c-4dff-8e20-b8ea5e68ae24
# ╟─ce299789-51d9-4961-8f5a-eed6458af549
# ╠═4951bdee-b47c-42df-bf14-8468edf5a9b3
# ╠═a4389ae9-5cc5-4270-bcff-f1a28c768429
# ╟─4152492c-e1bf-46e0-921a-8ea70d372486
# ╠═0a91c58a-b8f2-41c8-99de-7bd0a077e6ff
# ╠═5318bd35-b184-4e6c-8df7-932f82f2dbc0
# ╟─8844984d-f677-4a15-8b00-eaed1c5d3042
# ╠═78c8b8b2-7046-41ac-92f1-f4356a8e4dd0
# ╠═a41245ac-12ab-4fb6-a148-3a5e8052dc39
# ╟─2a098678-bfda-47fa-a066-ad0925629634
# ╟─54f1fc94-054b-4239-b905-332b24c4ed8c
# ╠═3737ad5c-cc93-446f-884e-e196553d60cc
# ╟─f971ad6b-808f-4c00-8cc8-20a5a3187a5b
# ╠═a243b363-cc8e-434d-aec2-001c24bd1ab7
# ╟─fe8afed4-e7fd-4db4-b558-016b7d27b5fd
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
