+++
title = "Lecture 10"
hascode = true
literate_mds = true
showall = false
noeval = true
+++

# Final projects

> **Agenda**\
> :books: Final projects\
> :computer: Q&A\
> :construction: Exercises: Q&A

---

**Content**

\toc

---

## Information about final projects

Final projects will provide 60% of the course grade. We recommend you work in teams of two, but being your own teammate is fine too.

_Note that a single GitHub repository is sufficient per project._

**Project's due date is XXX (enforced by a "release tag v1.0.0").**

[**Project template** available here](https://github.com/eth-vaw-glaciology/FinalProjectRepo.jl) - copy or clone to get started.

---

Final projects compose of 2 distinct parts (50% of the project mark each) to be handed-in on a single GitHub repository, including scripts, documentation (and code documentation), unit and reference testing, Continuous Integration (CI - using e.g. GitHub Actions), instructions to run the software and reproduce the results, references.

### Part 1: 3D multi-XPUs diffusion solver
Steady state solution of a diffusive process for given physical time steps using the pseudo-transient acceleration (using the so-called "[dual-time]((/lecture4/#implicit_solutions))" method).

Your task in **_part 1_** is to solve the linear diffusion equation in 3D

$$ \frac{∂H}{∂t} = ∇ ⋅ D\;∇H ~ ,$$

where $D=1$, using an implicit iterative approach leveraging pseudo-transient acceleration (see [Lecture 4](/lecture4/#steady-state_and_implicit_iterative_solutions)). Use following physical parameters
```julia
lx, ly, lz = 10.0, 10.0, 10.0 # domain size
D          = 1.0              # diffusion coefficient
ttot       = 1.0              # total simulation time
dt         = 0.2              # physical time step
```
and converge your reference solution to $\mathrm{tol_{nl}} = 10^{-8}$ using the L2-norm on the equation's residual $R_H$ (`norm(R_H)/sqrt(length(R_H))`).

As initial condition, define a Gaussian distribution of $H$ centred in the domain's centre with amplitude of 2 and standard deviation of 1. Enforce Dirichlet boundary condition $H=0$ an all 6 faces.

\note{Use [ParallelStencil.jl]() and [ImplicitGlobalGrid.jl]() for the (multi-)XPU implementation. You are free to use either `@parallel` or `@parallel_indices` type of kernel definition.}

Implement the 3D diffusion equation (1) using a [dual-time stepping](/lecture4/#implicit_solutions) approach, including the physical time-derivative as physical term in the residual definition and using pseudo-time to iterate the solution as suggested [here (Eqs 11 & 12)](/lecture4/#implicit_solutions).

For the multi-XPU implementation, you can build on the [2D multi-XPU diffusion](/lecture8/#using_implicitglobalgridjl) provided in Lecture 8, extending it to 3D.

\note{GitHub Actions only provides CPU-based runners. For unit and reference testing purpose, select small problem sizes (e.g. `nx = ny = nz = 32`), run on a single process (launching the code without `mpirun` or `mpiexecjl`) and use ParallelStencil's CPU backend (setting `USE_GPU = false`).}

### Part 2: [your personal project]
Selecting a project of your choice among 3 possible directions:
1. Solving PDEs you have some interest in (e.g. related to another project or future study/research direction of yours)
2. Applying [advanced optimisations](/lecture9/) and benchmarking to existing PDEs; the ones seen in class or, e.g., to examples from [ParallelStencil's miniapps](https://github.com/omlins/ParallelStencil.jl#concise-singlemulti-xpu-miniapps).
3. Solving one of the proposed PDE's
    - [2D Shallow water equations](https://en.wikipedia.org/wiki/Shallow_water_equations)
    - [3D Thermo-mechanically coupled viscous flow](https://doi.org/10.1093/gji/ggy434)
    - [3D elastic wave propagation](https://en.wikipedia.org/wiki/Linear_elasticity#Elastodynamics_in_terms_of_displacements)
    - [3D viscous Stokes flow]
    - more ...

## Getting started with the final projects

The following steps will get you started with the final projects:
1. Find a classmate to work with (being your own mate is fine too)
2. Select a topic of your choice for **_part 2_** (see [here]())
3. Copy or clone the [**template**](https://github.com/eth-vaw-glaciology/FinalProjectRepo.jl) for the final project.
4. Invite the teaching staff to the repo
5. Send and email to Ludovic (luraess@ethz.ch) and Mauro (werder@vaw.baug.ethz.ch) by **Tuesday November 30, 2021**, including
    - your project mate
    - a brief description of your choice for **_part 2_**
    - a link to your final project GitHub repository
    - what is missing in this list
6. Work on you final project, asking for help
    - in the Element _Helpdesk_ channel for general question
    - as **GitHub "issue"** for project specific questions

## Project submission

Submission deadline for the project is XXX. Final submission timestamp is enforced upon tagging the v1.0.0 version release of your repository. See [GitHub's doc](https://docs.github.com/en/repositories/releasing-projects-on-github/about-releases) for infos.

## Project grading

Grading of the project will be 50% for **_part 1_** and 50% for **_part 2_**.

For a successful outcome, both parts are expected to be handed-in as single GitHub repository featuring the following items:
- documented and polished scripts (using e.g. docstrings, in-line comments)
- documentation including:
  - a succinct `README.md` directing to both project parts enhanced documentation  
  - an enhanced `README.md` for each parts following to proposed structure with equations, cross-references, figures, figure captions
  - instructions to run the software and reproduce the results
  - references
- unit and reference testing
- Continuous Integration (CI - using e.g. GitHub Actions)
- additional features if needed

---

_Note that in case of un-expected results, the grading will reward the development, implementation and extensive documentation, even if, e.g, stiff PDEs would not deliver expected results._
