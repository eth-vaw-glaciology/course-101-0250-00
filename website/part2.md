+++
title = "Solving PDEs in parallel on GPUs with Julia II"
+++

# Solving PDEs in parallel on GPUs with Julia II

[![Element chat](/assets/element_chat.svg#badge)](https://chat.ethz.ch)
[![ETHZ Moodle](/assets/moodle.png#badge)]({{moodle_url}})

:tada: Welcome to **Part II** of *Solving PDEs in Parallel on GPUs*.
In this course, you will work in teams of two to design, implement, optimise, and run a complete high-performance numerical application on modern heterogeneous supercomputers.

The focus of the course is on developing a **scientific computing application from start to finish**, including mathematical model formulation, discretisation and algorithm design, GPU implementation in Julia, performance optimisation, execution on a supercomputer, validation and performance analysis.

By the end of the semester, you will be able to independently develop and assess a non-trivial GPU-accelerated solver and understand its numerical and computational behaviour at scale.

\label{content}
**Content**

\toc

---

## Course content

During the semester you will:

1. **Form a team of two** (contact the instructors if you need help finding a teammate).
2. **Select a project topic** (from the list below or propose your own).
3. **Send a short project proposal by email**, including a brief description of the problem, a preliminary work plan, and up to three key literature references.
4. **Present your project proposal**, 10 minutes total: 7 minutes talk + 3 minutes discussion.
5. **Develop a working prototype**.
6. **Present a progress report**, including demonstration of the prototype, preliminary numerical results, issues encountered, potential changes to the plan.
7. **Continue development and optimisation**.
8. **Present the final project**, including validated numerical results, performance benchmarks, scalability discussion reflection on challenges and lessons learned, possible future extensions.
9. **Finalise and polish the repository**.
10. **Submit the project** by providing the SHA of the final commit on Moodle.
11. *(Optional)* Submit an entry for the course gallery with a short description and a figure or animation.

[⤴ _**back to Content**_](#content)

---

## Logistics

* Presentations must be uploaded to Moodle before the presentation day.
* Instructors will be available in person either biweekly in the office or upon request.
* All communication takes place on **Element**.
* Code must be hosted on GitHub.
* Access to the computing infrastructure will be provided later shortly after the first presentation.

De-registration from the course is only possible **before the project deadline selection deadline** (see below). Students who won't deregister will be graded by the end of the semester.

[⤴ _**back to Content**_](#content)

---

## Important Dates

* **24.02.2026** — Project topic selection deadline
* **03.03.2026** — Proposal presentation
* **31.03.2026** — Progress presentation
* **12.05.2026** — Final presentation
* **29.05.2026** — Project submission deadline

[⤴ _**back to Content**_](#content)

---

## List of Possible Topics

Each topic is structured in **tiers of increasing complexity**.
Higher tiers correspond to more challenging features and typically contribute toward higher grades. The list in non-exhaustive, and you are encouraged to come up with your own topic based on your research interests.

* **1. Turbulence – Navier–Stokes Solver**
  * 2D incompressible solver
  * 3D solver
  * Internal boundaries or obstacles
  * Smoke / passive scalar simulation
  * Efficient Poisson solver (Krylov / Multigrid / FFT)
* **2. Ice Sheet Modelling – Depth-Averaged Ice Flow**
  * SIA (Shallow Ice Approximation)
  * SSA (Shallow Shelf Approximation)
  * DIVA or hybrid models
* **3. Ocean and Atmosphere Modelling – Shallow Water Equations**
  * Cartesian coordinates
  * Barotropic instabilities
  * Internal boundaries
  * Spherical coordinates
* **4. Electromagnetic Wave Propagation – Maxwell Solver**
  * 2D formulation
  * 3D formulation
  * Perfectly Matched Layers (PML)
* **5. Mantle Convection – Thermomechanically Coupled Stokes Solver**
  * 2D formulation
  * 3D formulation
  * Spherical geometry
* **6. CO₂ Storage and Porosity Waves – Coupled Porous Flow**
  * 2D model
  * 3D model
  * Coupling with Stokes flow
* **7. Phase Separation – Cahn–Hilliard Solver**
  * 2D implementation
  * 3D implementation
  * Implicit/dual-time time stepping

[⤴ _**back to Content**_](#content)

---

## Grading

* **Passing (4.0–5.0)**
  * All presentations delivered
  * Project repository submitted
  * Working code
  * Numerical results and figures
  * Basic README
* **Good (5.0–5.5)**
  * Clear code documentation
  * Unit tests
  * Continuous integration (CI)
  * GPU implementation
  * Performance benchmarks
  * Meaningful results
  * Animations
* **Excellent (5.5–6.0)**
  * Multi-GPU implementation
  * Scalability study
  * Numerical validation against references
  * Advanced or difficult extensions
  * Clear scientific and performance analysis

[⤴ _**back to Content**_](#content)

---

## Using AI

There are **no restrictions** on using AI tools (e.g., for code generation, debugging, documentation, or literature search).

However:

* You are fully responsible for your code and results.
* "Vibe-coding" without understanding the implementation is strongly discouraged.
* Your repository must include a section in the `README` specifying which AI tools were used, for which tasks, and how they contributed to the project.

[⤴ _**back to Content**_](#content)

---
