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

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### Agenda
#### why we do it
- Predict the evolution of complex natural and engineered systems
- Physical processes that describe those systems are complex and often nonlinear
  - no or very limited analytical solution is available
  - a numerical approach is required to solve the mathematical model
- The numerical solution means solving a system of (coupled) differential equations
- Solving PDEs is computationally demanding
  - ODEs - scalar equations but
  - PDEs - involve vectors and tensors (local gradients - neighbours)
  - Computational costs increase with complexity (e.g. multi-physics, couplings)
  - Computational costs increase with dimensions (3D tensors...)
  - Computational costs increase upon refining spatial and temporal resolution
- High-resolution 3D models are challenging
  - Computational resources
  - Solution strategies
- Parallel computing
  - Memory wall
  - Single core to multi-core devices
  - Increase in Flop vs Bytes asymmetry
  - GPUS are massively multi-core devices
  - SIMD model
  - Requires to re-think the numerical implementation and solution strategies

#### why it is cool (in Julia)
- Price / Performance
- Availability
- Workstation turns into Supercomputers
- Two-language solution
  - Single code for prototyping and production
  - Single approach to learn basics and aggressive optimisations 
- Backend agnostic
  - Single code to run on single CPU or thousands of GPUs
  - Single code to run on various CPU and GPU architectures
- Interactive
  - No need for 3rd party visualisation software
  - Debugging in interactive mode
  - Efficient for development

#### examples from current research
- Show some cool stuff
  - ParallelStencil _miniapps_
  - 3D hydro-mechanics

"""
