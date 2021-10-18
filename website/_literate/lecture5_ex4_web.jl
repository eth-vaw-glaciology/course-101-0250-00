md"""
## Exercise 4 - **Unit tests**
"""

#md # 👉 See [Logistics](/logistics/#submission) for submission details.

md"""
The goal of this exercise is to:
- Implement basic unit tests for the diffusion and acoustic 2D scripts
- Group the tests in a test-set
"""

md"""
For this exercise, you will implement a test set of basic unit tests to verify the implementation of the diffusion and acoustic 2D solvers.
"""

md"""
### Task 1

In the `diffusion2D` folder, duplicate the `diffusion_2D_perf_loop_fun.jl` script and rename it `diffusion_2D_test.jl`.

Implement a test set in order to test `C[xtest,ytest]` and assess that the values returned are approximatively equal to the following ones for the given values of `nx = ny`.

```julia
xtest = [5, Int(cld(0.6*Lx/dx)), nx-10]
ytest = Int(cld(0.5*Ly/dy))
```
for
```julia
nx = ny = 16 * 2 .^ (2:5)
```
should match

| `nx, ny` | `C[xtest,ytest]` |
|:--------:|:----------------:|
|  `64`    | `[1.28961441675812e-6  0.3403434055248243  0.000226725154067358]` |
| `128`    | `[1.42876853096198e-7  0.3606848631942946  2.784022638919167e-6]` |
| `256`    | `[3.82994869422046e-8  0.3515100977539851  2.070629144549965e-7]` |
| `512`    | `[1.56975129887789e-8  0.3467239448747831  4.938759153492403e-8]` |

Report the output of the test set as code block in a new section of the `README.md` in the `diffusion2D` folder.
"""

#nb # > 💡 hint: Use triple backticks to generate code blocks in the `README.md` ([more](https://www.markdownguide.org/extended-syntax/#fenced-code-blocks)).
#md # \note{Use triple backticks to generate code blocks in the `README.md` ([more](https://www.markdownguide.org/extended-syntax/#fenced-code-blocks)).}
