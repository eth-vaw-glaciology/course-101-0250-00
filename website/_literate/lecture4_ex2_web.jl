md"""
## Exercise 2 - **Damped Laplacian**
"""

#md # 👉 See [Logistics](/logistics/#submission) for submission details.

md"""
The goal of this exercise is to:
- Investigate second-order acceleration
- Derive scaling relation (number of iterations as function of number of grid points)
"""

md"""
In this exercise you will investigate the scalability of the first and second order iterative schemes discussed during lecture 4.

Start from the `Laplacian_damped.jl` script we realised in class, which should contain two "switches":
- `order` (1st or 2nd order scheme)
- `fact` (factor to multiply the number of grid points)

👉 Download the `Laplacian_damped.jl` script [here](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/) if needed (available after the course).

Add a copy of the `Laplacian_damped.jl` script we did in class to your exercise folder. Modify that script to perform systematics to assess the scalability of the damped versus the non-damped Laplacian 2D implementation.
"""

md"""
### Task 1
As first task, modify the iteration exit criteria such that the you can report the iteration count needed for `maximum(abs.(A))` to hit an absolute tolerance of `ε = 1e-9`.

### Task 2
Using this modified code, realise a scaling experiment where you report the total number of iterations needed to reach `ε` as function of the number of grid points `nx`, for `nx = 25 * 2 .^ (1:8)`. Repeat the experiment for both the damped and non-damped implementation (using e.g. the `order` flag).

### Task 3
Report your scaling results on a figure, plotting the number of iterations as function of the number of grid points. Save the figure as `png` and include it to the lecture 4 `README.md`. Comment the trends you observe.
"""

#nb # > 💡 hint: Use `![fig_name](./<relative-path>/my_fig.png)` to insert a figure in the `README.md`.
#md # \note{Use `![fig_name](./<relative-path>/my_fig.png)` to insert a figure in the `README.md`.}

md"""
### Task 4 *(optional)*
Investigate the effect of varying the damping parameter `dmp` on the iteration count, thus on the scaling. Add an additional figure to the `README.md` and comment about it.
"""
