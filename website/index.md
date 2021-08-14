@def title = "Solving PDEs in parallel on GPUs with Julia"
@def tags = ["syntax", "code"]

# Solving PDEs in parallel on GPUs with Julia

**This course aims to cover state-of-the-art methods in modern parallel Graphical Processing Unit (GPU) computing, supercomputing and code development with applications to natural sciences and engineering.**

\tableofcontents <!-- you can use \toc as well -->

## Objective
When quantitative assessment of physical processes governing natural and engineered systems relies on numerically solving differential equations, fast and accurate solutions require performant algorithms leveraging parallel hardware. The goal of this course is to offer a practical approach to solve systems of differential equations in parallel on GPUs using the Julia language. Julia combines high-level language conciseness to low-level language performance which enables efficient code development. 

The course will be taught in a hands-on fashion, putting emphasis on you writing code and completing exercises; lecturing will be kept at a minimum. In a final project you will solve a solid mechanics or fluid dynamics problem of your interest, such as the shallow water equation, the shallow ice equation, acoustic wave propagation, nonlinear diffusion, viscous flow, elastic deformation, viscous or elastic poromechanics, frictional heating, and more. Your Julia GPU application will be hosted on a git-platform and implement modern software development practices.

## Content
**Part 1** - Discovering a modern parallel computing ecosystem
- Learn the basics of the Julia language;
- Learn about the diffusion process and how to solve it;
- Understand the practical challenges of parallel and distributed computing: (multi-)GPUs, multi-core CPUs;
- Learn about software development tools: git, version control, continuous integration (CI), unit tests.

**Part 2** - Developing your own parallel algorithms
- Implement wave propagation (or more advanced physics);
- Apply spatial and temporal discretisation (finite-differences, various time-stepper);
- Implement efficient iterative algorithms;
- Implement shared (on CPU and GPU) and, if time allows, distributed memory parallelisation (multi-GPUs/CPUs);
- Learn about main simulation performance limiters.

**Part 3** - Personal final projects
- Apply your new skills in your personal project;
- Implement advanced physical processes (solid and fluid dynamic - elastic and viscous solutions).

## Assessment
Enrolled ETHZ students will have to hand in on Moodle:
1. 7 (out of 9) weekly assignments (40% of the final grade) during the course's Parts 1 and 2 _(Weekly coding exercises can be done alone or in groups of two)_.
2. A final project during Part 3 (60% of the final grade) _(Final projects submission includes codes in a git repository and extensive documentation)_.
