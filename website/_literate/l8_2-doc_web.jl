#src # This is needed to make this run as normal Julia file
using Markdown #src

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
#nb # _Lecture 8_
md"""
# Documenting your code

This lecture we will learn:
- documentation vs code-comments
- why to write documentation
- GitHub tools:
  - rendering of markdown files
  - gh-pages
- some Julia tools:
  - docstrings
  - [https://github.com/fredrikekre/Literate.jl](https://github.com/fredrikekre/Literate.jl)
  - [https://github.com/JuliaDocs/Documenter.jl](https://github.com/JuliaDocs/Documenter.jl)
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
#nb # _Lecture 8_
md"""
![comic](https://pcweenies.com/wp-content/uploads/2012/01/2012-01-12_pcw.jpg)
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### Why should I document my code?

Why should I write code comments?
- ["Code Tells You How, Comments Tell You Why"](https://blog.codinghorror.com/code-tells-you-how-comments-tell-you-why/)
  - code should be made understandable by itself, as much as possible
  - comments then should be to tell the "why" you're doing something
- *but* I do a lot of structuring comments as well
- math-y variables tend to be short and need a comment as well
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Why should I write documentation?
- documentation should give a bigger overview of what your code does
  - at the function-level (doc-strings)
  - at the package-level (README, full-fledged documentation)
- to let other people and your future self (probably most importantly) understand what
  your code is about
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### Documentation easily rots...

Worse than no documentation/code comments is documentation which is
outdated.

I find the best way to keep documentation up to date is:
- have documentation visible to you, e.g. GitHub README
- document what you need yourself
- use examples and run them as part of CI (doc-tests, example-scripts)
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### Documentation tools: doc-strings

A Julia doc-string ([Julia manual](https://docs.julialang.org/en/v1/manual/documentation/)):
- is just a string before the object (no blank-line inbetween); interpreted as markdown-string
- can be attached to most things (functions, variables, modules, macros, types)
- can be queried with `?`
"""

"Typical size of a beer crate"
const BEERBOX = 12

#-
?BEERBOX

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### Documentation tools: doc-strings with examples

One can add examples to doc-strings (they can even be part of testing: [doc-tests](https://juliadocs.github.io/Documenter.jl/stable/man/doctests/)).

(Run it in the REPL and copy paste to the docstring.)
"""


"""
    transform(r, θ)

Transform polar `(r,θ)` to cartesian coordinates `(x,y)`.

## Example
```jldoctest
julia> transform(4.5, pi/5)
(3.6405764746872635, 2.6450336353161292)
```
"""
transform(r, θ) = (r*cos(θ), r*sin(θ))

#-
?transform

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### Documentation tools: Github markdown rendering

The easiest way to write long-form documentation is to just use GitHub's markdown rendering.

A nice example is [this short course](https://github.com/luraess/parallel-gpu-workshop-JuliaCon21)
by Ludovic (incidentally about solving PDEs on GPUs 🙂).

- images are rendered
- in-page links are easy, e.g. `[_back to workshop material_](#workshop-material)`
- top-left has a burger-menu for page navigation
- can be edited within the web-page (pencil-icon)

👉 this is a good and low-overhead way to produce pretty nice documentation
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### Documentation tools: Literate.jl

There are several tools which render .jl files (with special formatting) into
markdown files.  These files can then be added to Github and will be rendered there.

- we're using [Literate.jl](https://github.com/fredrikekre/Literate.jl)
- format is described [here](https://fredrikekre.github.io/Literate.jl/v2/fileformat/)
- files stay valid Julia scripts, i.e. they can be executed without Literate.jl


Example
- input julia-code in: [course-101-0250-00-L8Documentation.jl: scripts/car_travels.jl](https://github.com/eth-vaw-glaciology/course-101-0250-00-L8Documentation.jl/blob/4bbeb3ddda046490847f050b02d3fc5d9308695b/scripts/car_travels.jl)
- output markdown in: [course-101-0250-00-L8Documentation.jl: scripts/car_travels.md](https://github.com/eth-vaw-glaciology/course-101-0250-00-L8Documentation.jl/blob/4bbeb3ddda046490847f050b02d3fc5d9308695b/scripts/car_travels.md) created with:
```
Literate.markdown("car_travels.jl", directory_of_this_file, execute=true, documenter=false, credit=false)
```
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragement"}}
md"""
But this is not automatic!  Manual steps: run Literate, add files, commit and push...

or use Github Actions...
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### Documentation tools: Automating Literate.jl

Demonstrated in the repo [course-101-0250-00-L8Documentation.jl](https://github.com/eth-vaw-glaciology/course-101-0250-00-L8Documentation.jl)
```yml
name: Run Literate.jl
# adapted from https://lannonbr.com/blog/2019-12-09-git-commit-in-actions
on: push
jobs:
  lit:
    runs-on: ubuntu-latest
    steps:
      # Checkout the branch
      - uses: actions/checkout@v2
      - uses: julia-actions/setup-julia@v1
        with:
          version: '1.9'
          arch: x64
      - uses: julia-actions/cache@v1
      - uses: julia-actions/julia-buildpkg@latest
      - name: run Literate
        run: QT_QPA_PLATFORM=offscreen julia --color=yes --project -e 'cd("scripts"); include("literate-script.jl")'
      - name: setup git config
        run: |
          # setup the username and email. I tend to use 'GitHub Actions Bot' with no email by default
          git config user.name "GitHub Actions Bot"
          git config user.email "<>"
      - name: commit
        run: |
          # Stage the file, commit and push
          git add scripts/md/*
          git commit -m "Commit markdown files fom Literate"
          git push origin master
```
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### Documentation tools: Documenter.jl

If you want to have full-blown documentation, including, e.g., automatic API documentation generation, versioning,
then use [Documenter.jl](https://github.com/JuliaDocs/Documenter.jl).

Examples:
- [https://docs.julialang.org/en/v1/](https://docs.julialang.org/en/v1/)
- [https://mauro3.github.io/Parameters.jl/stable/](https://mauro3.github.io/Parameters.jl/stable/)

_**Notes:**_
- it's geared towards Julia-packages, less for a bunch-of-scripts as in our lecture
- Documenter.jl also integrates with Literate.jl.
- for more free-form websites, use [https://github.com/tlienart/Franklin.jl](https://github.com/tlienart/Franklin.jl) (as the course website does)
- if you want to use it, it's easiest to generate your package with [PkgTemplates.jl](https://github.com/invenia/PkgTemplates.jl)
  which will generate the Documenter-setup for you.
- **we don't use it in this course**
"""


