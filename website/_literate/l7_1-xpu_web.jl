#src # This is needed to make this run as normal Julia file
using Markdown #src

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
#nb # _Lecture 7_
md"""
# Solving the "two-language problem": XPU-implementation
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### The goal of this lecture 7:

- Address the "two-language" problem
- Combine CPU and GPU computing - XPU
- Towards Stokes I: acoustic to elastic
- Reference testing, GitHub CI and workflows
"""

#src ######################################################################### 
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## The "two-language" problem
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Combining CPU and GPU implementation within a single code.
"""


