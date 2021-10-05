#src # This is needed to make this run as normal Julia file
using Markdown #src

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
#nb # _Lecture 1_
md"""
# Why solve PDEs on GPUs? & The tool for the job
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## Why solve PDEs on GPUs?

![gpu](../assets/literate_figures/gpu.png)

"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
### An brief intro about GPU computing:
- Why we do it
- Why it is cool (in Julia)
- Examples from current research
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### Propaganda
#### Why we do it
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Predict the evolution of natural and engineered systems
- e.g. ice cap evolution, stress distribution, etc...

![ice2](../assets/literate_figures/ice2.png)
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Physical processes that describe those systems are **complex** and often **nonlinear**
- no or very limited analytical solution is available

👉 a numerical approach is required to solve the mathematical model
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
A numerical solution means solving a system of (coupled) differential equations

$$
\mathbf{mathematical ~ model ~ → ~ discretisation ~ → ~ solution}\\
\frac{∂C}{∂t} = ... ~ → ~ \frac{\texttt{C}^{i+1} - \texttt{C}^{i}}{\texttt{∆t}} = ... ~ → ~ \texttt{C} = \texttt{C} + \texttt{∆t} \cdot ...
$$

"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Solving PDEs is computationally demanding
- ODEs - scalar equations

$$ \frac{∂C}{∂t} = -\frac{(C-C_{eq})}{ξ} $$

but...
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
- PDEs - involve vectors (and tensors)  👉 local gradients & neighbours

$$ \frac{∂C}{∂t} = D~ \left(\frac{∂^2C}{∂x^2} + \frac{∂^2C}{∂y^2} \right) $$

"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Computational costs increase
- with complexity (e.g. multi-physics, couplings)
- with dimensions (3D tensors...)
- upon refining spatial and temporal resolution

"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
![Stokes2D_vep](../assets/literate_figures/Stokes2D_vep.gif)

"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Use **parallel computing** to address this:
- The "memory wall" in ~ 2004
- Single-core to multi-core devices

![mem_wall](../assets/literate_figures/mem_wall.png)

"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
GPUs are massively parallel devices
- SIMD machine (programmed using threads - SPMD) ([more](https://safari.ethz.ch/architecture/fall2020/lib/exe/fetch.php?media=onur-comparch-fall2020-lecture24-simdandgpu-afterlecture.pdf))
- Further increases the Flop vs Bytes gap

![cpu_gpu_evo](../assets/literate_figures/cpu_gpu_evo.png)

"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
👉 We are memory bound: requires to re-think the numerical implementation and solution strategies
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
#### Why it is cool
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
![julia-gpu](../assets/literate_figures/julia-gpu.png)

"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
#### GPU are cool
Price vs Performance
- Close to **1TB/s** memory throughput (here on nonlinear diffusion SIA)

![perf_gpu](../assets/literate_figures/perf_gpu.png)

! And one can get there !
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Availability (less fight for resources)
- Still not many applications run on GPUs

Workstation turns into a personal Supercomputers
- GPU vs CPUs peak memory bandwidth: theoretical 10x (practically maybe more)

![titan_node](../assets/literate_figures/titan_node.jpg)

"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
#### Julia is cool
Solution to the "two-language problem"
- Single code for prototyping and production

![two_lang](../assets/literate_figures/two_lang.png)
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Backend agnostic:
- Single code to run on single CPU or thousands of GPUs
- Single code to run on various CPUs (x86, Power9, ARM) \
  and GPUs (Nvidia, AMD, Intel?)

Interactive:
- No need for 3rd-party visualisation software
- Debugging and interactive REPL mode
- Efficient for development
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
#### Examples from current research

- [ParallelStencil _miniapps_](https://github.com/omlins/ParallelStencil.jl#miniapp-content)
- [Ice-flow modelling](https://github.com/luraess/julia-parallel-course-EGU21#greenlands-ice-cap-evolution)
- [3D hydro-mechanical inversions](https://github.com/PTsolvers/PseudoTransientAdjoint.jl#3d-hydro-mechanically-constrained-inversion)
- [3D Random fields](https://github.com/luraess/ParallelRandomFields.jl#parallelrandomfieldsjl)
- more ...

"""


