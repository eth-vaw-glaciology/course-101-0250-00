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
- why we do it
- why it is cool (in Julia)
- examples from current research
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### Propaganda
#### why we do it
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Predict the evolution of complex natural and engineered systems
- e.g. groundwater pollution, ice cap evolution, force distribution in a bridge, etc...

  _Add figure_
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

_**mathematical model -> discretisation -> solution**_

_Add figure_
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

$$ \frac{∂C}{∂t} = D~(\frac{∂^2C}{∂x^2} + \frac{∂^2C}{∂y^2}) $$

"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Computational costs increase
- with complexity (e.g. multi-physics, couplings)
- with dimensions (3D tensors...)
- upon refining spatial and temporal resolution

_Add figure tensor, resolution_
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Use **parallel computing** to address this:
- The "memory wall" in \~ 2004
- Single core to multi-core devices

![mem_wall](./figures/mem_wall.png)

"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
GPUS are massively multi-core devices
- SIMD model
- Further increases the Flop vs Bytes gap

![flops_bytes](./figures/flops_bytes.png)

"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
👉 We are memory bound: Requires to re-think the numerical implementation and solution strategies
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
- Nvidia Tesla A100 has **1TB/s** memory throughput

Availability (less fight for resources)
  - Still not many applications run on GPUs

Workstation turns into a personal Supercomputers
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
#### Julia is cool
Solution to the "Two-language problem"
- Single code for prototyping and production

![two_lang](./figures/two_lang.png)
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Backend agnostic
- Single code to run on single CPU or thousands of GPUs
- Single code to run on various CPU (x86, Power9, ARM) and GPU (Nvidia, AMD, Intel?) architectures

Interactive
  - No need for 3rd-party visualisation software
  - Debugging in interactive mode
  - Efficient for development
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
#### Examples from current research
ParallelStencil _miniapps_

3D hydro-mechanics

"""
