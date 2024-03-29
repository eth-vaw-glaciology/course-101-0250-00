#src # This is needed to make this run as normal Julia file
using Markdown #src

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
#nb # _Lecture 3_
md"""
# Julia's REPL, the Package manager (Pkg.jl), and essential packages
"""

#src INFO - use only level 2 ## and 3 ### titles

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
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

"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
**Demo**
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## Julia package manager

Docs:
- [short](https://docs.julialang.org/en/v1/stdlib/Pkg/)
- [detailed](https://pkgdocs.julialang.org/v1/)

Powerful package manager:
- installing, updating and removing packages
  - this also includes dependencies such as C/Fortan libs, Python/Conda environments, etc.
- separate environments for separate projects

"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
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
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
**Take-home**: make a separate Project for each of your projects/assignments!
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## Essential packages for your global environment

Packages installed in your global environment are always available, thus useful for utility packages.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
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
"""
