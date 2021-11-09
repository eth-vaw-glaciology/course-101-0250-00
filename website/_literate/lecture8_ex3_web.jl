md"""
## Exercise 3 - **Navier-Stokes flow**
"""

#md # 👉 See [Logistics](/logistics/#submission) for submission details.

md"""
The goal of this exercise is to:
- Implement a viscous Stokes flow
- Step from the Navier-Cauchy elastic wave solver to en explicit Navier-Stokes solver
- Get a glimpse into fluid dynamics
- Apply reference testing using `ReferenceTests.jl`

"""

md"""
### Getting started

In this exercise your task will be to modify the elastic wave code `elastic_2D.jl` from [Exercise 3, Lecture 7](/lecture7/#task_4_-_rearranging_the_code), turning it into a weakly compressible viscous Navier-Stokes flow solver with inertia terms.

The main task will be to modify the shear rheology, now viscous. Viscosity [Pa.s] defines as the ratio between  stress $τ$ and strain-rate $ε̇$.

In this lecture's Git repository, duplicate the `elastic_2D.jl` renaming it `viscous_NS_2D.jl`.

### Task 1

Modify the physics in order to implement the weakly compressible Navier-Stokes equations:

$$ \frac{∂P}{∂t} = -K ∇_k v_k ~,$$

$$ τ = μ\left(∇_i v_j + ∇_j v_i -\frac{1}{3} δ_{ij} ∇_k v_k \right) ~,$$

$$ ρ \frac{∂v_i}{∂t} = ∇_j \left( τ_{ij} - P δ_{ij} \right) ~,$$

where $P$ is the pressure, $v$ the velocity, $K$ the bulk modulus, $μ$ the viscosity, $τ$ the viscous deviatoric stress tensor, $ρ$ the density, and $\delta_{ij}$ the Kronecker delta.

Then, make sure the model runs using the following parameters:
```julia
# Physics
Lx, Ly = 10.0, 10.0
ρ      = 1.0
K      = 1.0
μ      = 1.0
ttot   = 5.0
# Numerics
nx, ny = 128, 128
```

Also, add the possibility of deactivating visualisation.

### Task 2

In a new section of the `README.md` add a figure from code featuring 4 subplots depicting pressure $P$, velocity x-component $v_x$, normal and shear stress components, $\tau_{xx}$ and $\tau_{xy}$, respectively, and a short description.

### Task 3

Add reference testing and set up Continuous Integration with GitHub Actions.

Perform the following tasks, applying reference testing to the `viscous_NS_2D.jl` script:
- Make sure your Lecture 8 GitHub repo is set up as a Julia project, i.e. it contains `.toml` files, and `src` and `test` folders (you could use the `generate` command of the REPL package-mode).
- add `viscous_NS_2D.jl` to a `scripts/` folder
- You can deactivate the plotting.  This will make the tests run faster.  Also return the final `P` and `xc` from the function.
- Make a `ReferenceTest.jl` which tests the value at 12 random indices of `P` against a truth, the truth being the `reftest-files/X.bson` file you should download and unzip from the [course-101-0250-00/scripts/](https://github.com/eth-vaw-glaciology/course-101-0250-00/tree/main/scripts/reftest-files.zip) folder (**make sure to place the `X.bson` in your `reftest-files` folder**). The reference test used to generate the `X.bson` file is following (feel free to recycle it for your tests):
    ```julia
    using Test, ReferenceTests, BSON

    include("./viscous_NS_2D.jl")

    ## Reference Tests with ReferenceTests.jl
    # We put both arrays xc and P into a BSON.jl and then compare them

    "Compare all dict entries"
    comp(d1, d2) = keys(d1) == keys(d2) && all([ v1≈v2 for (v1,v2) in zip(values(d1), values(d2))])

    X, P, = viscous_2D()

    inds = Int.(ceil.(LinRange(1, length(X), 12)))

    d = Dict(:X=> X[inds], :P=>P[inds])

    @testset "Ref-tests" begin
        @test_reference "reftest-files/X.bson" d by=comp
    end
    ```

\note{Remember to check-in all the files into the repo; in particular the reference `*.bson`.}

GitHub Actions and CI:
- Make sure that all tests run and pass when called via package-mode `test`
- Follow/revisit the Lecture 7 and in particular look at the example at [https://github.com/eth-vaw-glaciology/course-101-0250-00-L6Testing.jl](https://github.com/eth-vaw-glaciology/course-101-0250-00-L6Testing.jl) and [https://github.com/eth-vaw-glaciology/course-101-0250-00-L6Testing-subfolder.jl](https://github.com/eth-vaw-glaciology/course-101-0250-00-L6Testing-subfolder.jl) to setup CI
- Push to GitHub and make sure the CI runs and passes
- Add the CI-badge to the `README.md`
"""


