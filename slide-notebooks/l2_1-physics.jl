#src # This is needed to make this run as normal Julia file
using Markdown #src

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
#nb # _Lecture 2_
md"""
# ODEs & PDEs: advection - diffusion - reaction
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Reaction - Diffusion - Advection gifs
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### The goal of this lecture 2 is to familiarise (or refresh) with
- Ordinary differential equations - ODEs (e.g. reaction equation)
- Partial differential equations - PDEs (e.g. diffusion and advection equations)
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
- Finite-difference discretisation
- Explicit solutions
- Multi-process (physics) coupling
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
> A partial differential equation (PDE) is an equation which imposes relations between the various partial derivatives of a multivariable function.

> Ordinary differential equations form a subclass of partial differential equations, corresponding to functions of a single variable".

[_Wikipedia_](https://en.wikipedia.org/wiki/Partial_differential_equation)
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## ODEs
Simple reaction equations, finite-difference method and explicit solution
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Let's take-off 🚀
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Our first task is to design a numerical solution approach for the following reaction process (e.g. [reaction kinetics](https://en.wikipedia.org/wiki/Chemical_kinetics))

$$
\frac{∂C}{∂t} = -\frac{C-C_{eq}}{ξ}~,
$$

"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
where $C$ is the concentration of ,e.g. a specific chemical quantity, $t$ is time, $C_{eq}$ is the equilibrium concentration of $C$ and $ξ$ is the reaction rate.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Suppose the reaction kinetics process occurs in a spatial domain (x-direction) of $Lx=10.0$, consider a reaction rate $ξ=10.0$ and an equilibrium concentration $C_{eq}=0.5$.

The goal is now to predict the evolution of a system with initial random distribution of concentration $C$ in the range $[0, 1]$ for non-dimensional total time of $20.0$.
"""

## Physics
Lx   = 10.0
ξ    = 10.0
Ceq  = 0.5
ttot = 20.0

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
As next step, one needs to discretise the continuum problem in both space and time. We will use a [finite-difference](https://en.wikipedia.org/wiki/Finite_difference) spatial discretisation and an explicit ([forward Euler](https://en.wikipedia.org/wiki/Euler_method)) time integration scheme.
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
In a new `# Numerics` section we define the number of grid points we will use to discretise our physical domain $Lx$.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Then, in a `# Derived numerics` section, we compute the grid size `dx`, the time-step `dt`, the number of time-steps `nt` and the vector containing the coordinate of all cell centres `xc`.
"""

## Numerics
nx   = 128
## Derived numerics
dx   = Lx/nx
dt   = ξ/2.0
nt   = cld(ttot, dt)
xc   = LinRange(dx/2, Lx-dx/2, nx)

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
#nb # > 💡 hint:
#nb # > type `?` in the Julia REPL followed by the function you want to know more about to display infos
#md # \note{type `?` in the Julia REPL followed by the function you want to know more about to display infos}

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
We now need to initialise 3 1D arrays to hold information about concentration `C`, initial concentration distribution `Ci`, and rate of change of concentration `dCdt`.
"""

## Array initialisation
C    =  rand(Float64, nx)
Ci   =  copy(C)
dCdt = zeros(Float64, nx)

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
#nb # > 💡 hint: note we here work with double precision arithmetic `Float64`
#md # \note{note we here work with double precision arithmetic `Float64`}

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Remains the most important part, the `# Time loop` where _predictive_ action should take place. We will loop from `it=1` to `nt` computing the rate of change of `C`, `dCdt`, and then updating `C`. We also want to visualise the evolution of the concentration distribution.
"""
using Plots

## Time loop
for it = 1:nt
  #dCdt = ...
  #C    = ...
  display(plot(xc, C, lw=2, xlims=(xc[1], xc[end]), ylims=(0.0, 1.0),
                xlabel="Lx", ylabel="Concentration", title="time = $(it*dt)",
                framestyle=:box, label="Concentration"))
end

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
- Make sure to update the arrays `dCdt` and `C` using the [dot syntax](https://docs.julialang.org/en/v1/manual/functions/#man-vectorized) for vectorised functions.
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
- The `display()` function will force to update the figure within the loop. Note that in Jupyter notebooks, you can use following syntax to avoid the creation of a new figure at each step.
"""

using IJulia
IJulia.clear_output(true)
display(plot(...))

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
After the time loop, we can also display the initial concentration we stored `Ci` and the equilibrium concentration `Ceq`:
"""

plot!(xc, Ci, lw=2, label="C initial")
display(plot!(xc, Ceq*ones(nx), lw=2, label="Ceq"))


#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
We may want to write a single "monolithic" code to perform these steps that looks as following
"""

using Plots

@views function reaction_1D()
    ## Physics
    Lx   = 10.0
    ξ    = 10.0
    Ceq  = 0.5
    ttot = 20.0
    ## Numerics
    nx   = 128
    ## Derived numerics
    dx   = Lx/nx
    dt   = ξ/2.0
    nt   = cld(ttot, dt)
    xc   = LinRange(dx/2, Lx-dx/2, nx)
    ## Array initialisation
    C    =  rand(Float64, nx)
    Ci   =  copy(C)
    dCdt = zeros(Float64, nx)
    ## Time loop
    for it = 1:nt
        #dCdt
        #C   
        display(plot(xc, C, lw=2, xlims=(xc[1], xc[end]), ylims=(0.0, 1.0),
                xlabel="Lx", ylabel="Concentration", title="time = $(it*dt)",
                framestyle=:box, label="Concentration"))
    end
    plot!(xc, Ci, lw=2, label="C initial")
    display(plot!(xc, Ceq*ones(nx), lw=2, label="Ceq"))
    return
end

reaction_1D()

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
So, excellent, we have our first 1D ODE solver up and running in Julia :-)
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## PDEs

From reactions to diffusion and advection - involving neighbouring cells.
"""
