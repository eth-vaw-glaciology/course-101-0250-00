md"""
## Exercise 3 - **Unit and reference tests**
"""

#md # 👉 See [Logistics](/logistics/#submission) for submission details.

md"""
The goal of this exercise is to:
- revisit the last part of the lecture
- learn how testing works in Julia
"""

#nb # > 💡 note: I had some odd errors caused by `@views` which I couldn't get to the bottom of.  If you do too, just remove the `@views`.
#md # \note{I had some odd errors caused by `@views` which I couldn't get to the bottom of.  If you do too, just remove the `@views`.}

#nb # > 💡 note: I packaged the Demo of the lecture within the repo [course-101-0250-00-L6Testing.jl](https://github.com/eth-vaw-glaciology/course-101-0250-00-L6Testing.jl), which should be the blueprint for this exercise.
#md # \note{I packaged the Demo of the lecture within the repo [course-101-0250-00-L6Testing.jl](https://github.com/eth-vaw-glaciology/course-101-0250-00-L6Testing.jl), which should be the blueprint for this exercise.}

md"""
Task:
- Use the [`l2_diffusion_1D.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/l2_diffusion_1D.jl) script as a base and rename it `diffusion_1D_test.jl`.
- Define your own `diff()` function as `@views Diff(A) = A[2:end].-A[1:end-1]`
- Create a Julia project `L6TestingExercise` within the exercise submission folder `lecture6`.  Use the `generate` command of the REPL package-mode.
- Add `l2_diffusion_1D.jl` to a `scripts/` folder
- You should remove/disable the plotting. This will make the tests run faster. Remove the `@views` for the main function. Also return the final `C` and `qx` from the function.
- Make two unit tests for `Diff(A)` function; wrap them in a `@testset`
- Make a reference-test which tests the value at 20 random indices of `C` and `qx` against a truth.
- Make sure that all tests run and pass when called via package-mode `test`
"""


