<!--This file was generated, do not modify it.-->
## Exercise 3 - **Unit tests**

👉 See [Logistics](/logistics/#submission) for submission details.

The goal of this exercise is to:
- Implement basic unit tests for the diffusion and acoustic 2D scripts
- Group the tests in a test-set

For this exercise, you will implement a test set of basic unit tests to verify the implementation of the diffusion and acoustic 2D solvers.

### Task 1

In the `Pf_diffusion_2D` folder, duplicate the `Pf_diffusion_2D_perf_loop_fun.jl` script and rename it `Pf_diffusion_2D_test.jl`.

Implement a test set in order to test `Pf[xtest, ytest]` and assess that the values returned are approximatively equal to the following ones for the given values of `nx = ny`. Make sure to set `do_check = false` i.e. to ensure the code to run 500 iterations.

````julia:ex1
xtest = [5, Int(cld(0.6*lx, dx)), nx-10]
ytest = Int(cld(0.5*ly, dy))
````

for

````julia:ex2
nx = ny = 16 * 2 .^ (2:5) .- 1
maxiter = 500
````

should match

| `nx, ny` | `Pf[xtest, ytest]`                                                |
|:--------:|:-----------------------------------------------------------------:|
|  `64`    | `[0.00785398056115133 0.007853980637555755 0.007853978592411982]` |
| `128`    | `[0.00787296974549236 0.007849556884184108 0.007847181374079883]` |
| `256`    | `[0.00740912103848251 0.009143711648167267 0.007419533048751209]` |
| `512`    | `[0.00566813765849919 0.004348785338575644 0.005618691590498087]` |

Report the output of the test set as code block in a new section of the `README.md` in the `Pf_diffusion_2D` folder.

\note{Use triple backticks to generate code blocks in the `README.md` ([more](https://www.markdownguide.org/extended-syntax/#fenced-code-blocks)).}

