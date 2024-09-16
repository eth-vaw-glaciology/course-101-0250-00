+++
title = "Solving PDEs in parallel on GPUs with Julia"
+++

# Solving PDEs in parallel on GPUs with Julia

:tada: Welcome to ETH's [**course 101-0250-00L**](https://www.vorlesungen.ethz.ch/Vorlesungsverzeichnis/lerneinheit.view?semkez=2024W&ansicht=KATALOGDATEN&lerneinheitId=182481&lang=en) on solving partial differential equations (PDEs) in parallel on graphical processing units (GPUs) with the [Julia programming language](http://www.julialang.org/).

\note{2024 edition starts Tuesday Sept. 17, 12h45. Welcome!}

## Course information
This course aims to cover state-of-the-art methods in modern parallel GPU computing, supercomputing and scientific software development with applications to natural sciences and engineering. The course is open source and is available on [Github](https://github.com/eth-vaw-glaciology/course-101-0250-00)

~~~
<center>
  <video width="80%" autoplay loop controls src="/assets/porous_convection_2D.mp4"/>
</center>
~~~

### Objective
The goal of this course is to offer a practical approach to solve systems of partial differential equations in parallel on GPUs using the [Julia programming language](http://www.julialang.org/). Julia combines high-level language expressiveness and low-level language performance which enables efficient code development. The Julia GPU applications will be hosted on Github and implement modern software development practices.

### Outline
- **Part 1**  _Introducing Julia & PDEs_
  - The Julia language: hands-on
  - Solving physical processes: advection, reaction, diffusion & wave propagation
  - Spatial and temporal discretisation: finite differences and explicit time-stepping
  - Software development tools: Git, Continuous Integration

- **Part 2**  _Solving PDEs on GPUs_
  - Steady-state, implicit & nonlinear solutions
  - Efficient iterative algorithms
  - Parallel and GPU computing
  - Simulation performance limiters

- **Part 3** _Projects_

  Multi-GPU computing and optimisations
  - xPU computing
  - Distributed computing
  - Advanced optimisations

- **Final projects**

  Solve a solid mechanics or fluid dynamics problem of your interest, such as:
  - dynamic elasticity — seismic wave propagation
  - Maxwell's equations — electromagnetic fields propagation
  - shallow-water equations — rivers, lakes, or oceans
  - shallow ice approximation — ice sheet evolution
  - Navier–Stokes equations — fluid or smoke
  - thermo-mechanically coupled Stokes flow — mantle convection
  - hydro-mechanically coupled Stokes flow — subsurface CO2 flow
  - your own idea

## Teaching staff
- [Ivan Utkin](https://github.com/utkinis) — ETHZ / WSL
- [Ludovic Räss](https://github.com/luraess) — Unil / ETHZ
- [Mauro Werder](https://vaw.ethz.ch/en/personen/person-detail.html?persid=124402) — WSL / ETHZ
- [Samuel Omlin](https://www.cscs.ch/about/staff/) — CSCS / ETHZ
- Teaching Assistant: [You Wu](https://github.com/youwuyou) — ETHZ
