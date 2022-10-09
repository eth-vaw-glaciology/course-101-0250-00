md"""
## Exercise 4 - **Optimal iteration parameters for pseudo-transient method**
"""

#md # 👉 See [Logistics](/logistics/#submission) for submission details.

md"""
The goal of this exercise is to confirm numerically the optimality of the pseudo-transient parameters for a 1D elliptic solver (e.g., solving steady-state diffusion).

You will make the systematic study of the convergence rate of the pseudo-transient method, varying the numerical parameter `re` on a regular grid of values.

### Getting started

1. 👉 Download the `l3_steady_diffusion_1D.jl` script [here](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/) if needed (available after the course).
2. Create a new code `steady_diffusion_parametric_1D.jl` for this exercise and add it to the `lecture3` folder in your private GitHub repo.
3. Report the results of this exercise within a new section in the `README.md`.
"""

md"""
### Task 1

Start from the 1D elliptic solver.
Add the new variable storing the range of factors to multiply the `re` parameter with to the `# numerics` section. Add new array to store the number of iterations per grid block for each value of this factor:

```julia
# numerics
fact = 0.5:0.1:1.5
conv = zeros(size(fact))
```

Wrap the `# array initialisation` and `# iteration loop` sections of the code in a `for`-loop over indices of `fact`:

```julia
for ifact in eachindex(fact)
    # array initialisation
    ...
    # iteration loop
    while ...
    end
end
```

Move the definition of `ρ` to the beginning of the new loop. Extract the value `2π` and store in the variable `re`, multiplying by the corresponding value from `fact`:

```julia
for ifact in eachindex(fact)
    re = 2π*fact[ifact]
    ρ  = (lx/(dc*re))^2
    dτ = ...
    ...
end
```

After every elliptic solve, store the `iter/nx` value in the `conv[ifact]`. Report the results as a figure, plotting the `conv` vs `fact`. You should get a picture like this:

![checkmark](../assets/literate_figures/l3_checkmark.png)
"""

