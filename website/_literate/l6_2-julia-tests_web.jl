#src # This is needed to make this run as normal Julia file
using Markdown #src

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
#nb # _Lecture 6_
md"""
# Unit testing and reference tests in Julia

(Unit) testing is pervasive in the Julia ecosystem thanks to efficient built-in tools and
a culture encouraging testing.

This [JuliaCon 2021 talk](https://live.juliacon.org/talk/HVSAW9) gives a nice overview: more than 90% of all registered
packages have at least some tests, with the median package having about 25% of the code being tests.
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Terms:
- "unit test": small tests, usually on a per-function basis
- "integration test": test large part of the code base
- "reference test": test against a previous output (not necessarily known whether "good" or "bad")
- "Continuous Integration" (CI): running of the tests automatically on push to github/gitlab/etc
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### The goals of this lecture are
- how to assess CI-run tests for packages of the Julia ecosystem (registered packages)
- how to run tests for registered packages on your computer
- how to use tests of packages as "documentation"
- create a test-suite for a small project of your
- learn to use [ReferenceTests.jl](https://github.com/JuliaTesting/ReferenceTests.jl)

(How to setup CI as part of a project of yours will be taught later)
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## Registered Packages: CI tests & using as documentation

Let's look at a simple package: [UnPack.jl](https://github.com/mauro3/UnPack.jl)

![UnPack.jl](../assets/literate_figures/l6_UnPack.png)

- the CI-results are often displayed in form of _badges_
- there are different CI-services, most used is GitHub-Actions
- often the tests are a fairly good source of documentation by example

-> "demo"
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## Registered Packages: test locally

Using: [UnPack.jl](https://github.com/mauro3/UnPack.jl)

`dev` the package:
```julia
pkg> dev UnPack
```
This will checkout the package to `~/.julia/dev/UnPack`.

Re-Start Julia with this package activated:
```
$ cd ~/.julia/dev/UnPack
$ julia --project
```
In package mode run the tests:
```
(UnPack) pkg> test
    Testing UnPack
      Status `/tmp/jl_LgpabA/Project.toml`
  [3a884ed6] UnPack v1.0.2 `~/julia/dot-julia-dev/UnPack`
...
```
If you edit the source, e.g. to fix a bug, re-run the tests before submitting a PR.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## Write your own tests

Start easy:
- add test just to a script

Step up:
- move tests to `test/runtests.jl`, the standard location
- include scripts to just run-through
- use ReferenceTests.jl as integration tests

Another day:
- setup CI on Github

**NOTE**: floating-point comparisons should only be done approximately:
```
julia> ℯ + π - ℯ == π
false
```
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## Write your own tests: demo with "car_travel.jl" from Lecture 1
"""
using Plots
pyplot()

@views function car_travel_1D()
    ## Physical parameters
    V     = 113.0          # speed, km/h
    L     = 200.0          # length of segment, km
    dir   = 1              # switch 1 = go right, -1 = go left
    ttot  = 16.0           # total time, h
    ## Numerical parameters
    dt    = 0.1            # time step, h
    nt    = Int(cld(ttot, dt))  # number of time steps
    ## Array initialisation
    T     = zeros(nt)
    X     = zeros(nt)
    ## Time loop
    for it = 2:nt
        T[it] = T[it-1] + dt
        X[it] = X[it-1] + dir*V*dt  # move the car
        if X[it] > L
            dir = -1      # if beyond L, go back (left)
        elseif X[it] < 0
            dir = 1       # if beyond 0, go back (right)
        end
    end
    ## Visualisation
    ## display(scatter(T, X, markersize=5, xlabel="time, hrs", ylabel="distance, km", framestyle=:box, legend=:none))
    return T, X
end

T, X = car_travel_1D()

md"""
## Write your own tests: demo with "car_travel.jl" from Lecture 1

Steps:
- make it a project
- add some unit tests in-line
- move tests to `test/`
- use ReferenceTests.jl
"""


