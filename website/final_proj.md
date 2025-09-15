# Information about final projects

Final projects will provide 35% of the course grade. We recommend you work in teams of two, but being your own teammate is fine too.

**Project's due date is December 20, 2024 -- 23h59 CET (enforced by a "release tag v1.0.0").**

_Note that a single GitHub repository is sufficient per project._

\warn{The final project GitHub repository should **remain private** until submission on December 20, 2024 (unless you need it to be public for, e.g., deploying documentation.)}

Final projects should to be handed-in on a single GitHub repository, including scripts, documentation (and code documentation), unit and reference testing, Continuous Integration (CI - using e.g. GitHub Actions), instructions to run the software and reproduce the results, references.

## Topics

Selecting a project of your choice among 3 possible directions (A/, B/ or C/):

### A. Solving one of the proposed PDE's

#### 1. Multi-GPU Navier-Stokes in 3D

Implement simple Navier-Stokes solver using Chorin's projection method and advection based on the method of characteristics. For the projection step, you'll implement a Poisson solver for the pressure. You could use the pseudo-transient solver from class or write your own. Examples would be the multigrid solvers or Fourier-transform-based spectral solvers. The only requirement is that your solver has to work on GPU and scale (reasonably) well. Feel free to take inspiration in the [2D reference implementation](https://github.com/utkinis/NavierStokes.jl) developed last year.

#### 2. Free convection simulation

Use the [`ParallelStencil.jl` miniapp](https://github.com/omlins/ParallelStencil.jl#thermo-mechanical-convection-2-d-app) as a starting point to implement your own 3D multi-GPU thermo-mechanical convection solver (lava-lamp).

#### 3. Water circulation in saline aquifers.

This project share many similarities with the the thermal porous convection. The main difference is that density variations are not due to temperature, but to variable concentration of salt dissolved in the water.

#### 4. Hydro-mechanical flow localisation

Use the [`ParallelStencil.jl` miniapp](https://github.com/omlins/ParallelStencil.jl#hydro-mechanical-porosity-waves-2-d-app) as a starting point to implement your own 3D multi-GPU hydro-mechanical "two-phase flow" solver to capture the formation and propagation of solitary waves of porosity.

#### 5. Wave physics

Elastic wave propagation is central in computational seismology as it allows to "image" the subsurface. It has also application far beyond geosciences. Implement your 3D elastic wave solver using, e.g., as starting point the acoustic wave solver from the [`ParallelStencil.jl` miniapp](https://github.com/omlins/ParallelStencil.jl#acoustic-wave-3-d-app) miniapp.

### B. Advanced optimisations

If you are interested in GPU code optimisation, you can go through the advanced optimisation [material (Lecture 10)](/lecture10) and, e.g., add shared memory support and manual register queuing to accelerate the 3D thermal porous convection solver from the class or select among the [`ParallelStencil.jl` miniapp](https://github.com/omlins/ParallelStencil.jl#acoustic-wave-3-d-app) miniapps.

### C. Solving PDEs you have some interest in

Show your creativity by coming up with your own problem that could be modelled using PDEs (e.g. related to another project or future study/research direction of yours). We’ll do our best to help you implementing it. Relativistic MHD? Phase separation in alloys? Electromagnetic waves propagation? Spectral methods for PDEs? Name your own! Ideally, come with papers and equations related to it.

## Getting started with the final project

The following steps will get you started with the final project:

1. Find a classmate to work with (being your own mate is fine too)
2. Select a topic of your choice
3. Initiate a private GitHub repository for your project (CamelCaps, including `.jl` at the end - e.g.: `MyProject.jl`)
4. Share the final project private repository on GitHub with the [teaching-bot (https://github.com/teaching-bot)](https://github.com/teaching-bot)
5. Send and email to Ivan (iutkin@ethz.ch) and Ludovic (luraess@ethz.ch) by **Tuesday December 3, 2024**, with subject _**Final projects**_ including
    - your project partner
    - a brief description of your choice
    - a link to your final project GitHub repository
    - _anything else missing in this list_
6. Work on your final project, asking for help
    - in the Element _Helpdesk_ channel for general question
    - as **GitHub "issue"** for project specific questions
    - during class hours serving as helpdesk

### Final project submission

Submission deadline for the project is **December 19, {{year}} -- 23h59 CET**.

Final submission timestamp is enforced upon tagging the v1.0.0 version release of your repository. See [GitHub docs](https://docs.github.com/en/repositories/releasing-projects-on-github/about-releases) for infos.

Also, add the last commit SHA to [Moodle - Final project submission](https://moodle-app2.let.ethz.ch/mod/assign/view.php?id=1103859) as for the exercises.

### Final project grading

Grading of the final project will contribute 35% of the final grade.

For a successful outcome, final projects are expected to be handed-in as single GitHub repository featuring the following items:

- documented and polished scripts (using e.g. docstrings, in-line comments)
- documentation including:
  - an enhanced `README.md` following to proposed structure with equations, cross-references, figures, figure captions
  - instructions to run the software and reproduce the results
  - references
- unit and reference testing
- Continuous Integration (CI - using e.g. GitHub Actions)
- additional features if needed
