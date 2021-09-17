#src # This is needed to make this run as normal Julia file
using Markdown #src

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
# _Lecture 1_
# Why solve PDEs on GPUs? & The tools to do it
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## Why solve PDEs on GPUs?

![gpu](./figures/gpu.png)

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

![ice2](./figures/ice2.png)
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

_**mathematical model $~ → ~$ discretisation $~ → ~$ solution**_

$\frac{∂C}{∂t} = ... ~ → ~ \frac{\texttt{C}^{i+1} - \texttt{C}^{i}}{\texttt{∆t}} = ... ~ → ~ \texttt{C} = \texttt{C} + \texttt{∆t} \cdot ...$
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

![Stokes2D_vep](./figures/Stokes2D_vep.gif)

"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Use **parallel computing** to address this:
- The "memory wall" in \~ 2004
- Single-core to multi-core devices

![mem_wall](./figures/mem_wall.png)

"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
GPUS are massively multi-core devices
- SIMD model
- Further increases the Flop vs Bytes gap

![cpu_gpu_evo](./figures/cpu_gpu_evo.png)

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
![julia-gpu](./figures/julia-gpu.png)

"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
#### GPU are cool
Price vs Performance
- Close to **1TB/s** memory throughput (here on nonlinear diffusion SIA)

![perf_gpu](./figures/perf_gpu.png)

! And one can get there !
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Availability (less fight for resources)
- Still not many applications run on GPUs

Workstation turns into a personal Supercomputers
- GPU vs CPUs peak memory bandwidth: theoretical 10x, practical 20-100x

![titan_node](./figures/titan_node.jpg)

"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
#### Julia is cool
Solution to the "two-language problem"
- Single code for prototyping and production

![two_lang](./figures/two_lang.png)
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
ParallelStencil _miniapps_

3D hydro-mechanics

"""
