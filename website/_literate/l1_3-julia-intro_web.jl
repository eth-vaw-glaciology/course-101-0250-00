#src # This is needed to make this run as normal Julia file:
using Markdown #src

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
# Tool for the job: introduction to Julia

![julia-logo](../assets/literate_figures/l1_julia-logo.png)
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## Aside 1: Jupyter Notebooks

These slides are a [Jupyter notebook](https://jupyter.org/); a browser-based computational notebook.
"""

#nb # > 💡 note: You can follow the lecture along live from the Moodle-based [JupyterHub](https://moodle-app2.let.ethz.ch/course/view.php?id=18084) server.
#md # \note{You can follow the lecture along live from the Moodle-based [JupyterHub](https://moodle-app2.let.ethz.ch/course/view.php?id=18084) server.}

md"""
Code cells are executed by putting the cursor into the cell and hitting `shift + enter`.  For more
info see the [documentation](https://jupyter-notebook.readthedocs.io/en/stable/).
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## Aside 2: What is your previous programming experience?

1. Julia
2. Matlab, Python, Octave, R, ...
3. C, Fortran, ...
4. Pascal, Java, C++, ...
5. Lisp, Haskell, ...
6. Assembler
7. Coq, Brainfuck, ...

https://docs.google.com/forms/d/13BF2S2HaKHN9m1aK3CyR6CHoUJskQHJpIK7L2DrmN3M/edit#responses
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## The Julia programming language

[Julia](https://julialang.org/) is a modern, interactive, and high performance programming language.  It's a general purpose
language with a bend on technical computing.

![julia-logo](../assets/literate_figures/l1_julia-logo-repl.png)

- first released in 2012
- reached version 1.0 in 2018
- current version 1.8.1 (09.2022)
- thriving community, for instance there are currently around 8300 [packages registered](https://juliahub.com/ui/Packages)
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### What does Julia look like

An example solving the Lorenz system of ODEs:
"""

using OrdinaryDiffEq, Plots

function lorenz(x, p, t)
    σ = 10
    β = 8/3
    ρ = 28
    [σ*(x[2]-x[1]),
     x[1]*(ρ-x[3]) - x[2],
     x[1]*x[2] - β*x[3]]
end

## integrate dx/dt = lorenz(t,x) numerically from t=0 to t=50 and starting point x₀
tspan = (0.0, 50.0)
x₀ = [2.0, 0.0, 0.0]
sol = solve(ODEProblem(lorenz, x₀, tspan), Tsit5())

# Yes, this takes some time... Julia is Just-Ahead-of-Time compiled.  I.e. Julia is compiling.

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
And its solution plotted
"""
plot(sol, idxs=(1,2,3)) # plot Lorenz attractor

#md # ![lorenz](../assets/literate_figures/l1_lorenz.png)

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### Julia in brief
Julia 1.0 released 2018, now at version 1.8.1

Features:
- general purpose language with a focus on technical computing
- dynamic language
  - interactive development
  - garbage collection
- good performance on par with C & Fortran
  - just-ahead-of-time compiled via LLVM
  - No need to vectorise: for loops are fast
- multiple dispatch
- user-defined types are as fast and compact as built-ins
- Lisp-like macros and other metaprogramming facilities
- designed for parallelism and distributed computation
- good inter-op with other languages
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### The two language problem

**One language to prototype   --  one language for production**
- example from Ludovic's past: prototype in Matlab, production in CUDA-C

**One language for the users  --  one language for under-the-hood**
- Numpy (python -- C)
- machine-learning: pytorch, tensorflow
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
![](../assets/literate_figures/l1_ml.png)
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### The two language problem

Prototype/interface language:
- easy to learn and use
- interactive
- productive
- --> *but slow*
- Examples: Python, Matlab, R, IDL...

Production/fast language:
- fast
- --> *but* complicated/verbose/not-interactive/etc
- Examples: C, C++, Fortran, Java...
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
###  Julia solves the two-language problem

Julia is:
- easy to learn and use
- interactive
- productive

and also:
- fast
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
![](../assets/literate_figures/l1_flux-vs-tensorflow.png)
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
###  Let's get our hands dirty!

Head to the course's moodle page https://moodle-app2.let.ethz.ch/course/view.php?id=18084
and fire up your JupyterHub.

[Brief explanation on JupyterHub]
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
This notebook and other should be on you JupyterHub in the folder

    course-101-0250-00-JupyterLab.git/

if not, to get this notebook (and other stuff), open a terminal on JupyterHub and run:

    git clone https://tinyurl.com/pdeongpu
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
###  Let's get our hands dirty!

We will now look at
- variables and types
- control flow
- functions
- modules and packages

The documentation of Julia is good and can be found at [https://docs.julialang.org](https://docs.julialang.org); although for learning it might be a bit terse...

There are also tutorials, see [https://julialang.org/learning/](https://julialang.org/learning/).

Furthermore, documentation can be gotten with `?xyz`
"""

## ?cos

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## Variables, assignments, and types
[https://docs.julialang.org/en/v1/manual/variables/](https://docs.julialang.org/en/v1/manual/variables/)
"""

a = 4
b = "a string"
c = b # now b and c bind to the same value

md"""
Conventions:
- variables are (usually) lowercase, words can be separated by `_`
- function names are lowercase
- modules, packages and types are in CamelCase
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### Variables: Unicode
From [https://docs.julialang.org/en/v1/manual/variables/](https://docs.julialang.org/en/v1/manual/variables/):

Unicode names (in UTF-8 encoding) are allowed:

```julia
julia> δ = 0.00001
1.0e-5

julia> 안녕하세요 = "Hello"
"Hello"
```

In the Julia REPL and several other Julia editing environments, you can type many Unicode math
symbols by typing the backslashed LaTeX symbol name followed by tab. For example, the variable
name `δ` can be entered by typing `\delta`-*tab*, or even `α̂⁽²⁾` by `\alpha`-*tab*-`\hat`-
*tab*-`\^(2)`-*tab*. (If you find a symbol somewhere, e.g. in someone else's code,
that you don't know how to type, the REPL help will tell you: just type `?` and
then paste the symbol.)
"""

##


#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### Basic datatypes
- numbers (Ints, Floats, Complex, etc.)
- strings
- tuples
- arrays
- dictionaries
"""

1     # 64 bit integer (or 32 bit if on a 32-bit OS)
1.5   # Float64
1//2  # Rational
#-
typeof(1.5)
#-
"a string", (1, 3.5) # and tuple
#-
[1, 2, 3,] # array of eltype Int
#-
Dict("a"=>1, "b"=>cos)


#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### Array exercises

We will use arrays extensively in this course.

Datatypes belonging to AbstactArrays:
- `Array` (with aliases `Vector`, `Matrix`)
- `Range`
- GPU arrays, static arrays, etc
"""

# Task: assign two vectors to `a`, and `b` and the concatenate them using `;`:

a = [2, 3]
b = [4, 5]
[a ; b]

# Add new elements to the end of Vector `b` (hint look up the documentation for `push!`)

push!(b, 1)
push!(b, 3, 4)

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "subslide"}}
md"""
### Array exercises

Concatenate a Range, say `1:10`, with a Vector, say [4,5]:
"""

[1:10; [4,5]]


md"""
Make a random array of size (3,3).  Look up `?rand`.  Assign it to `a`
"""

a = rand(3,3)

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "subslide"}}
md"""
### Array exercise: indexing

Access element `[1,2]` and `[2,1]` of Matrix `a` (hint use []):
"""

a[1,2], a[2,1]

# Put those two values into a vector

[ a[1,2], a[2,1] ]

# Linear vs Cartesian indexing,
# access the first element:

a[1]
a[1,1]

# Access the last element (look up `?end`) both with linear and Cartesian indices


a[end]
a[end, end]

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "subslide"}}
md"""
### Array exercise: indexing by ranges

Access the last row of `a` (hint use `1:end`)
"""

a[end, 1:end]

# Access a 2x2 sub-matrix

a[1:2, 1:2]

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "subslide"}}
md"""
### Array exercises: variable bindings and views

What do you make of
"""

a = [1 4; 3 4] # note, this is another way to define a Matrix
c = a
a[1, 2] = 99
@assert c[1,2] == a[1,2]

# Type your answer here (to start editing, double click into this cell.  When done shift+enter):

#
#md Both variables `a` and `c` refer to the same "thing".  Thus updating the array via one will show in the other.

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "subslide"}}
md"""
### Array exercises: variable bindings and views

An assignment _binds_ the same array to both variables
"""
c = a
c[1] = 8
@assert a[1]==8 # as c and a are the same thing
@assert a===c  # note the triple `=`

md"""
Views vs copies:

In Julia indexing with ranges will create a new array with copies of
the original's entries. Consider
"""
a = rand(3,4)
b = a[1:3, 1:2]
b[1] = 99
@assert a[1] != b[1]

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "subslide"}}
md"""
### Array exercises: variable bindings and views

But the memory footprint will be large if we work with large arrays and take sub-arrays of them.

Views to the rescue
"""
a = rand(3,4)
b = @view a[1:3, 1:2]
b[1] = 99

# check whether the change in `b` is reflected in `a`:

@assert a[1] == 99

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "subslide"}}
md"""
### A small detour: types

All values have types as we saw above.  Arrays store in their type what type the elements can be.

> Arrays which have concrete element-types are more performant!
"""
typeof([1, 2]), typeof([1.0, 2.0])

# Aside, they also store their dimension in the second parameter.
#
# The type can be specified at creation
String["one", "two"]

# Create an array taking `Int` with no elements.  Push `1`, `1.0` and `1.5` to it.  What happens?

a = Int[]
push!(a, 1) ## works
push!(a, 1.0) ## works
push!(a, 1.5) ## errors as 1.5 cannot be converted to an Int

#-
# Make an array of type `Any` (which can store any value).  Push a value of type
# Int and one of type String to it.

a = []
push!(a, 5)
push!(a, "a")

#-
# Try to assgin 1.5 to the first element of an array of type Array{Int,1}

[1][1] = 1.5 ## errors


#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "subslide"}}
md"""
### Array exercises

Create a uninitialised Matrix of size (3,3) and assign it to `a`.
First look up the docs of Array with `?Array`
"""

a = Array{Any}(undef, 3, 3)

#-
# Test that its size is correct, see `size`

size(a)

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "subslide"}}
md"""
### Array exercises: ALL DONE

The rest about Arrays you will learn-by-doing.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## Control flow

Julia provides a variety of [control flow constructs](https://docs.julialang.org/en/v1/manual/control-flow/), of which we look at:

  * [Conditional Evaluation](https://docs.julialang.org/en/v1/manual/control-flow/#man-conditional-evaluation): `if`-`elseif`-`else` and `?:` (ternary operator).
  * [Short-Circuit Evaluation](https://docs.julialang.org/en/v1/manual/control-flow/#Short-Circuit-Evaluation): logical operators `&&` (“and”) and `||` (“or”), and also chained comparisons.
  * [Repeated Evaluation: Loops](https://docs.julialang.org/en/v1/manual/control-flow/#man-loops): `while` and `for`.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### Conditional evaluation

Read the first paragraph of
[https://docs.julialang.org/en/v1/manual/control-flow/#man-conditional-evaluation](https://docs.julialang.org/en/v1/manual/control-flow/#man-conditional-evaluation)
(up to "... and no further condition expressions or blocks are evaluated.")
"""

#-
md"""
Write a test which looks at the start of the string in variable `a`
(?startswith) and sets `b` accordingly.  If the start is
- "Wh" then set `b = "Likely a question"`
- "The " then set `b = "A noun"`
- otherwise set `b = "no idea"`
"""

a = "Where are the flowers"
if startswith(a, "Wh")
  b = "Likely a question"
elseif startswith(a, "The")
  b = "Likely a noun"
else
  b = "no idea"
end

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "subslide"}}
md"""
### Conditional evaluation: the "ternary operator" `?`

Look up the docs for `?` (i.e. evaluate `??`)

Re-write using `?`
```
if a > 5
    "really big"
else
    "not so big"
end
```
"""

a > 5 ? "really big" : "not so big"

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### Short circuit operators `&&` and `||`

Read [https://docs.julialang.org/en/v1/manual/control-flow/#Short-Circuit-Evaluation](https://docs.julialang.org/en/v1/manual/control-flow/#Short-Circuit-Evaluation)

Explain what this does

```
a < 0 && error("Not valid input for `a`")
```
"""

# Type your answer here (to start editing, double click into this cell.  When done shift+enter):

# If `a < 0` evaluates to `true` then the bit after the `&&` is evaluated too,
# i.e. an error is thrown.  Otherwise, only `a < 0` is evaluated and no error is thrown.

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### Loops: `for` and `while`

[https://docs.julialang.org/en/v1/manual/control-flow/#man-loops](https://docs.julialang.org/en/v1/manual/control-flow/#man-loops)
"""

for i = 1:3
    println(i)
end

for i in ["dog", "cat"] ## `in` and `=` are equivalent for writing loops
    println(i)
end

i = 1
while i<4
    println(i)
    i += 1
end


#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## Functions

Functions can be defined in Julia in a number of ways.  In particular there is one variant
more suited to longer definitions, and one for one-liners:

```
function f(a, b)
   a * b
end
f(a, b) = a * b
```

Defining many, short functions is typical in good Julia code.

Read [https://docs.julialang.org/en/v1/manual/functions/](https://docs.julialang.org/en/v1/manual/functions/) up to an including "The return Keyword"
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "subslide"}}
md"""
### Functions: exercises

Define a function in long-form which takes two arguments.
Use some if-else statements and the return keyword.
"""

function fn(a, b)
  if a> b
    return a
  else
    return b
  end
end


#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "subslide"}}
md"""
### Functions: exercises

Re-define the `map` function.  First look up what it does `?map`, then create a `mymap` which
does the same.  Map `sin` over the vector `1:10`.

(Note, this is a higher-order function: a function which take a function as a argument)
"""

mymap(fn, a) = [fn(aa) for aa in a]
mymap(sin, 1:10)

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "subslide"}}
md"""
### Functions: dot-syntax

This is really similar to the `map` function, a short-hand to map/broadcast a
function over values.

Exercise: apply the `sin` function to a vector `1:10`:
"""

sin.(1:10)

# Broadcasting will extend row and column vectors into a matrix.
# Try `(1:10) .+ (1:10)'`  (Note the `'`, this is the transpose operator)

(1:10) .+ (1:10)'

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "subslide"}}
md"""
### Functions: dot-syntax exercise

Evaluate the function `sin(x) + cos(y)` for
`x = 0:0.1:pi` and `y = -pi:0.1:pi`.  Remember to use `'`.
"""

x,y = 0:0.1:pi, -pi:0.1:pi
sin.(x) .+ cos.(y')

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "subslide"}}
md"""
### Functions: anonymous functions

So far our function got a name with the definition. They can also be defined without name.

Read [https://docs.julialang.org/en/v1/manual/functions/#man-anonymous-functions](https://docs.julialang.org/en/v1/manual/functions/#man-anonymous-functions)

Map the function `f(x,y) = sin(x) + cos(x)` over `1:10` but define it as an anonymous
function.
"""

map(x -> sin(x) + cos(x), 1:10)


#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "subslide"}}
md"""
### Key feature: multiple dispatch functions

- Julia is not an object oriented language

OO:
- methods belong to objects
- method is selected based on first argument (e.g. `self` in Python)

Multiple dispatch:
- methods are separate from objects
- are selected based on all arguments
- similar to overloading but method selection occurs at runtime and not compile-time (see also video below)
> very natural for mathematical programming

JuliaCon 2019 presentation on the subject by Stefan Karpinski
(co-creator of Julia):

["The Unreasonable Effectiveness of Multiple Dispatch"](https://www.youtube.com/watch?v=kc9HwsxE1OY)
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "subslide"}}
md"""
## Functions: Multiple dispatch demo
"""

struct Rock end
struct Paper end
struct Scissors end
### of course structs could have fields as well
## struct Rock
##     color
##     name::String
##     density::Float64
## end

## define multi-method
play(::Rock, ::Paper) = "Paper wins"
play(::Rock, ::Scissors) = "Rock wins"
play(::Scissors, ::Paper) = "Scissors wins"
play(a, b) = play(b, a) # commutative

play(Scissors(), Rock())

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "subslide"}}
md"""
### Multiple dispatch demo
Can easily be extended later

with new type:
"""
struct Pond end
play(::Rock, ::Pond) = "Pond wins"
play(::Paper, ::Pond) = "Paper wins"
play(::Scissors, ::Pond) = "Pond wins"

play(Scissors(), Pond())
#-

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
with new function:
"""
combine(::Rock, ::Paper) = "Paperweight"
combine(::Paper, ::Scissors) = "Two pieces of papers"
## ...

combine(Rock(), Paper())

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
*Multiple dispatch makes Julia packages very composable!*

This is a key characteristic of the Julia package ecosystem.
"""


#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## Modules and packages

Modules can be used to structure code into larger entities, and be used to divide it into
different name spaces.  We will not make much use of those, but if interested see
[https://docs.julialang.org/en/v1/manual/modules/](https://docs.julialang.org/en/v1/manual/modules/)

**Packages** are the way people distribute code and we'll make use of them extensively.
In the first example, the Lorenz ODE, you saw
```
using OrdinaryDiffEq, Plots
```
This statement loads the two packages `OrdinaryDiffEq` and `Plots` and makes their functions
and types available in the current session.
"""

using Plots
plot( (1:10).^2 )

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "subslide"}}
md"""
### Packages

**Note** package installation does not work on the moodle-Jupyterhub.  But it will work on your local installation.

All public Julia packages are listed on [https://juliahub.com/ui/Packages](https://juliahub.com/ui/Packages).

You can install a package, say `UnPack.jl` by
```
using Pkg
Pkg.add("UnPack.jl")
using UnPack
```

In the REPL, there is also a package-mode (hit `]`) which is for interactive use.
"""

## Install a package (maybe not a too big one, UnPack.jl is good that way),
## use it, query help on the package itself:

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "subslide"}}
md"""
## This concludes the rapid Julia tour

There are many more features of Julia for sure but this should get you started, and setup for
the exercises.  (Let us know if you feel we left something out which would have been helpful for the exercises).

Remember you can self-help with:
- using `?` at the notebook.  Similarly there is an `apropos` function.
- the docs are your friend [https://docs.julialang.org/en/v1/](https://docs.julialang.org/en/v1/)
- ask for help in our chat channel: see Moodle
"""


