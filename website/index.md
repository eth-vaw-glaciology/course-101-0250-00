+++
title = "Solving PDEs in parallel on GPUs with Julia"
+++

# Solving PDEs in parallel on GPUs with Julia

:tada: Welcome to ETH's [**course 101-0250-00L**](https://www.vorlesungen.ethz.ch/Vorlesungsverzeichnis/lerneinheit.view?semkez=2025W&ansicht=KATALOGDATEN&lerneinheitId=193496&lang=en) on solving partial differential equations (PDEs) in parallel on graphical processing units (GPUs) with the [Julia programming language](http://www.julialang.org/). This course is the first part of a two-part series, focusing on the fundamentals of GPU programming and parallel numerical methods. The second part, offered in the spring semester next year, is project-based: participants will design and implement their own GPU-accelerated applications.

\note{2025 edition starts Tuesday Sept. 16, 12h45}

## Course information

This course introduces state-of-the-art methods in modern parallel GPU computing, supercomputing, and scientific software development, with applications in the natural sciences and engineering. All course materials are open source and available on [GitHub](https://github.com/eth-vaw-glaciology/course-101-0250-00). As part of the course, you will learn how to model physical processes such as thermal convection in porous media, as illustrated below with an example simulation:

~~~
<center>
  <video width="80%" autoplay loop controls src="/assets/porous_convection_2D.mp4"/>
</center>
~~~

### Objective

The goal of this course is to offer a practical approach to solve systems of partial differential equations in parallel on GPUs using the [Julia programming language](http://www.julialang.org/). Julia combines high-level language expressiveness and low-level language performance which enables efficient code development. The Julia GPU applications will be hosted on GitHub and implement modern software development practices.

### Outline

- **Part 1**  _Introducing Julia & PDEs_
  - The Julia language: hands-on
  - Modelling physical processes: advection, reaction, diffusion & wave propagation
  - Spatial and temporal discretisation: finite differences and explicit time integration
  - Software development tools: Git, continuous integration

- **Part 2**  _Solving PDEs on GPUs_
  - Steady-state, implicit & nonlinear solutions
  - Efficient iterative algorithms
  - Parallel and GPU computing
  - Simulation performance limiters

- **Part 3** _Final Project_
  - xPU computing with backend-agnostic kernel programming
  - Distributed computing with MPI
  - Advanced optimisations: using shared memory and registers
  - Simulation of thermal porous convection in 3D

## Teaching staff

- [Ivan Utkin](https://github.com/utkinis) — ETHZ / WSL
- [Ludovic Räss](https://github.com/luraess) — Unil / ETHZ
- [Mauro Werder](https://vaw.ethz.ch/en/personen/person-detail.html?persid=124402) — WSL / ETHZ
- [Samuel Omlin](https://www.cscs.ch/about/staff/) — CSCS / ETHZ
- Teaching Assistant: [Badie Taye](https://github.com/BadeaTayea) — ETHZ
