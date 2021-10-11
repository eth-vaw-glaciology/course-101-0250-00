<!--This file was generated, do not modify it.-->
## Exercise 2 - **Damped Laplacian**

👉 See [Logistics](/logistics/#submission) for submission details.

The goal of this exercise is to:
- Investigate second-order acceleration
- Derive scaling relation (iterations as function of grid points)

In this exercise you will investigate the scalability of the first and second order iterative schemes discussed during lecture 4.

Start from the `Laplacian_damped.jl` script we realised in class, which should contain two "switches":
- `order` (1st or second order scheme)
- `fact` (factor to multiply the number of grid points)

👉 Download the `Laplacian_damped.jl` script [here](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/) if needed (only after the course).

Add a copy of the `Laplacian_damped.jl` script we did in class to your exercise folder. Modify that script to perform some systematics to assess the scalability of the damped versus the non-damped Laplacian 2D implementation.

### Task 1
As first task, modify the iteration exit criteria such that the you can report the iteration count needed for `maximum(abs.(A))` to hit an absolute tolerance of `ε = 1e-9`.

### Task 2
Using this modified code, realise a scaling experiment where you report the total number of iterations needed to reach `ε` as function of number of grid points `nx`, for `nx = 25 * 2 .^ (1:8)`. Repeat the experiment for both the damped and non-damped implementation (using e.g. the `order` flag).

### Task 3
Report your scaling results on a plot and comment the trends you observe (the comment could be e.g. displayed in the REPL upon execution or as text under the figure).

### Task 4 *(optionnal)*
Investigate the effect of varying the damping parameter `dmp` on the iteration count, thus on the scaling.

