## Information about final projects

Final projects will provide 35% of the course grade. We recommend you work in teams of two, but being your own teammate is fine too.

**Project's due date is December 23, 2022 -- 23h59 CET (enforced by a "release tag v1.0.0").**

_Note that a single GitHub repository is sufficient per project._

\warn{The final project GitHub repository should **remain private** until submission on December 23, 2022 (unless you need it to be public for, e.g., deploying documentation.)}


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

## Getting started with the final projects

Head to [Logistics](/logistics/#final_project) in order to find infos on getting started and submission.
