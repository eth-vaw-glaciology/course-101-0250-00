+++
title = "Lecture 11"
hascode = true
literate_mds = true
showall = false
noeval = true
+++

# Lecture 11

> **Agenda**\
> :books: Multi-xPU thermal porous convection 3D\
> :computer: Automatic documentation and CI\
> :construction: Project:
> - Multi-xPU thermal porous convection 3D
> - Automatic documentation and CI

---

\label{content}
**Content**

\toc

[_👉 get started with exercises_](#exercises_-_lecture_11)

---

\literate{/_literate/l11_1-projects_web.jl}

[⤴ _**back to Content**_](#content)

# Exercises - lecture 11

\warn{**Exercise 1** is the final step of your project - scripts and results should be added to the `PorousConvection` subfolder in your private GitHub repo. The git commit hash (or SHA) of the final push needs to be uploaded on Moodle ([more](/homework)).\
From your `homework-8` branch, create a new git branch named `homework-11` in order to build upon work performed for homework 8.\
The exercises from Lecture 11 include the last steps towards the completion of the project. Hand-in information can be found in [Logistics](/logistics/#project).}

\literate{/_literate/lecture11_ex1_web.jl}

[⤴ _**back to Content**_](#content)

---

\literate{/_literate/lecture11_ex2_web.jl}

[⤴ _**back to Content**_](#content)

---

# Solving Partial Differential Equations in Parallel on GPUs II

Enjoyed the course and want more?
In the upcoming Spring Semester, we will offer Part II, in which your task will be to develop a new numerical code **from scratch**, using the knowledge acquired in this course. You will choose one project from three possible directions (A, B, or C):

## A. Solving One of the Proposed PDEs

### 1. Multi-GPU Navier–Stokes in 3D

Implement a simple Navier–Stokes solver using Chorin’s projection method and an advection scheme based on the method of characteristics. For the projection step, you will implement a Poisson solver for the pressure. You may reuse the pseudo-transient solver from class or implement your own (e.g., a multigrid solver or a Fourier-transform-based spectral solver).
The only requirement is that your solver must run on GPUs and scale well. Feel free to take inspiration from the [2D reference implementation](https://github.com/utkinis/NavierStokes.jl).

### 2. Free Convection Simulation

Use the [`ParallelStencil.jl` miniapp](https://github.com/omlins/ParallelStencil.jl#thermo-mechanical-convection-2-d-app) as a starting point to implement your own **3D multi-GPU mantle convection solver**.

### 3. Hydro-Mechanical Flow Localisation

Use the [`ParallelStencil.jl` miniapp](https://github.com/omlins/ParallelStencil.jl#hydro-mechanical-porosity-waves-2-d-app) as a starting point to implement your own **3D multi-GPU hydro-mechanical “two-phase flow” solver** capable of capturing the formation and propagation of solitary porosity waves.

### 4. Wave Physics

Elastic wave propagation is central to computational seismology, as it enables imaging of the subsurface, and it also has applications far beyond geosciences. Implement your 3D elastic wave solver, using the acoustic wave solver from the [`ParallelStencil.jl` miniapp](https://github.com/omlins/ParallelStencil.jl#acoustic-wave-3-d-app) as a starting point.
Alternatively, you may implement Maxwell’s equations to simulate the propagation of electromagnetic fields.

## B. Solving a PDE of Your Interest

Show your creativity by proposing your own PDE-based problem—perhaps related to another project or to a future research direction. We’ll do our best to help you implement it.
Relativistic MHD? Phase separation in alloys? Electromagnetic wave propagation? Spectral methods for PDEs? Name your topic! Ideally, bring relevant papers and equations.

## C. Advanced Optimisations

If you are interested in GPU code optimisation, you can work through the advanced optimisation material (Lecture 12) and, for example, add shared-memory support and manual register queuing to accelerate the 3D thermal porous convection solver from class.
Alternatively, pick one of the [`ParallelStencil.jl` miniapps](https://github.com/omlins/ParallelStencil.jl#acoustic-wave-3-d-app) and optimise it further.

[⤴ _**back to Content**_](#content)
