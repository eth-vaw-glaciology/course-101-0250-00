<!--This file was generated, do not modify it.-->
## Exercise 3 - **CI and GitHub Actions**

👉 See [Logistics](/logistics/#submission) for submission details.

The goal of this exercise is to:
- setup Continuous Integration with GitHub Actions

### Tasks
1. Add CI setup to your `PorousConvection` project to run **one unit and one reference test** for both the 2D and 3D thermal porous convection scripts.
   - 👉 make sure that the reference test runs on a very small grid (without producing NaNs).  It should complete in less than, say, 10-20 seconds.
2. Follow/revisit the lecture and in particular look at the example at [https://github.com/eth-vaw-glaciology/course-101-0250-00-L6Testing-subfolder.jl](https://github.com/eth-vaw-glaciology/course-101-0250-00-L6Testing-subfolder.jl) to setup CI for a folder that is part of another Git repo (your `PorousConvection` folder is part of your `pde-on-gpu-<username>` git repo).
3. Push to GitHub and make sure the CI runs and passes
4. Add the CI-badge to the `README.md` file from your `PorousConvection` folder, right below the title (as it is commonly done).

You may realise that you can't initialise ParallelStencil for 2D and 3D configurations within the same test script. A good practice is to place one test2D.jl and another test3D.jl scripts within the `test` folder and call these scripts from the `runtests.jl` mains script, which could contain following:

````julia:ex1
push!(LOAD_PATH, "../src")

using PorousConvection

function runtests()
    exename = joinpath(Sys.BINDIR, Base.julia_exename())
    testdir = pwd()

    printstyled("Testing PorousConvection.jl\n"; bold=true, color=:white)

    run(`$exename -O3 --startup-file=no --check-bounds=no $(joinpath(testdir, "test2D.jl"))`)
    run(`$exename -O3 --startup-file=no --check-bounds=no $(joinpath(testdir, "test3D.jl"))`)

    return
end

exit(runtests())
````

Each sub-test file would then contain all what's needed to run the 2D or 3D tests. You can find an example of this approach in `ParallelStencil`'s own test suite [here](https://github.com/omlins/ParallelStencil.jl/tree/main/test), or in the [GitHub repository](https://github.com/PTsolvers/PseudoTransientDiffusion.jl/tree/main/test) related to the pseudo-transient solver publication discussed in [Lecture 3](/lecture3/#pseudo-transient_method).

\note{If your CI setup fails, check-out again the procedure at the top of the exercise section [here](#infos_about_projects). Secondly, make sure to run the CPU version of the scripts as there is **no GPU support** in GitHub Actions!}

