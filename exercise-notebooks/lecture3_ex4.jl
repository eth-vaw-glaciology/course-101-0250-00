md"""
## Exercise 4 - **Optimal iteration parameters for pseudo-transient method**
"""

#md # 👉 See [Logistics](/logistics/#submission) for submission details.

md"""
The goal of this exercise is to confirm numerically the optimality of the pseudo-transient parameters.

You will make the systematic study of the convergence rate of the pseudo-transient method, varying the numerical parameter `re` on a regular grid of values.

👉 Download the `steady_diffusion_1D.jl` script [here](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/) if needed (available after the course).
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
    ...
end
```

After every elliptic solve, store the `iter/nx` value in the `conv[ifact]`. Report the results as a figure, plotting the `conv` vs `fact`.

"""