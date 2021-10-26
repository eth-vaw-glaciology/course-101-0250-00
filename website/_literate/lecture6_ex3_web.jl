md"""
## Exercise 3 - **Unit and reference tests**
"""

#md # 👉 See [Logistics](/logistics/#submission) for submission details.

md"""
The goal of this exercise is to:
- revisit the last part of the lecture
- learn how testing works in Julia
"""

md"""
**Note**: I had some odd errors caused by `@views` which I couldn't get to the bottom of.  If you do too, just remove the `@views`.

**Note**: I packaged the Demo of the lecture within the repo [course-101-0250-00-L6Testing.jl](https://github.com/mauro3/course-101-0250-00-L6Testing.jl), which should be the
blueprint for this exercise.

Task:
- use the [`diffusion_nl_1D.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/diffusion_nl_1D.jl) script as a base.
- create a Julia project `L6TestingExercise` within the exercise submission folder `lecture6`.  Use the `generate` command of the REPL package-mode.
- add `diffusion_nl_1D.jl` to a `scripts/` folder
- You can remove the plotting.  This will make the tests run faster.  Also return the final `H` and `qx` from the function.
- make a few unit test for `av` function; wrap them in a `@testset`
- make a ReferenceTest.jl which tests the value at 20 random indices of `H` and `qx` against a truth.
- make sure that all tests run and pass when called via package-mode `test`

*Remember to check-in all the files into the repo; in particular the reference `*.bson`.
"""


