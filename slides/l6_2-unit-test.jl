#src # This is needed to make this run as normal Julia file
using Markdown #src

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
#nb # _Lecture 6_
md"""
# Unit testing in Julia
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### The Julia `Test` module

[Basic unit tests](https://docs.julialang.org/en/v1/stdlib/Test/#Basic-Unit-Tests) in Julia
- Provides simple _unit testing_ functionality
- A way to assess if code is correct by checking that results are as expected
- Helpful to ensure the code still works after changes
- Can be used when developing
- Should be used in package for continous integration (aka CI;
  when tests are run on GitHub automatically on a push)
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## Basic unit tests

Simple unit testing can be performed with the `@test` and `@test_throws` macros:
"""
using Test

@test 1==1

@test_throws MethodError 1+"a" ## the expected error must be provided too

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Or another example
"""
@test [1, 2] + [2, 1] == [3, 3]

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Testing an expression which is a call using infix syntax such as approximate comparisons (`\approx` + tab)
"""
@test π ≈ 3.14 atol=0.01

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
For example, suppose we want to check our new function `square(x)` works as expected:
"""
square(x) = x^2

md"""
If the condition is true, a `Pass` is returned:
"""
@test square(5) == 25

md"""
If the condition is false, then a `Fail` is returned and an exception is thrown:
"""
#nb @test square(5) == 20
#md # ```julia
#md # @test square(5) == 20
#md # ```
#md # ```julia
#md # Test Failed at none:1
#md #   Expression: square(5) == 20
#md #    Evaluated: 25 == 20
#md # Test.FallbackTestSetException("There was an error during testing")
#md # ```

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
## Working with a test sets

The `@testset` macro can be used to group [tests into sets](https://docs.julialang.org/en/v1/stdlib/Test/#Working-with-Test-Sets).

All the tests in a test set will be run, and at the end of the test set a summary will be printed.

If any of the tests failed, or could not be evaluated due to an error, the test set will then throw a `TestSetException`.
"""
@testset "trigonometric identities" begin
    θ = 2/3*π
    @test sin(-θ) ≈ -sin(θ)
    @test cos(-θ) ≈ cos(θ)
    @test sin(2θ) ≈ 2*sin(θ)*cos(θ)
    @test cos(2θ) ≈ cos(θ)^2 - sin(θ)^2
end;

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Let's try it with our `square()` function
"""
square(x) = x^2

@testset "Square Tests" begin
    @test square(5) == 25
    @test square("a") == "aa"
    @test square("bb") == "bbbb"
end;

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
If we now introduce a bug
"""
#nb square(x) = x^2
#nb @testset "Square Tests" begin
#nb     @test square(5) == 25
#nb     @test square("a") == "aa"
#nb     @test square("bb") == "bbbb"
#nb     @test square(5) == 20
#nb end;
#md # ```julia
#md # square(x) = x^2
#md #
#md # @testset "Square Tests" begin
#md #     @test square(5) == 25
#md #     @test square("a") == "aa"
#md #     @test square("bb") == "bbbb"
#md #     @test square(5) == 20
#md # end;
#md # ```
#md # ```julia
#md # Square Tests: Test Failed at none:6
#md #   Expression: square(5) == 20
#md #    Evaluated: 25 == 20
#md # Stacktrace:
#md #  [...]
#md # Test Summary: | Pass  Fail  Total
#md # Square Tests  |    3     1      4
#md # Some tests did not pass: 3 passed, 1 failed, 0 errored, 0 broken.
#md # ```

md"""
Then then the reporting tells us a test failed.
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### Where to put them, how to run them

The simplest is to just put the tests in your script, along the tested function.
Then the tests run every time the script is executed.

However, for bigger pieces of software, such as packages, this becomes unwieldly
and also undesired (as we don't want tests to run all the time).  Then tests are put
into `test/runtests.jl`.  If they are there they will be run when called from package
mode or from automated test (CI).
"""

#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
Example for the package `Literate.jl` (we use that to generate the website):
```julia
julia> using Pkg

julia> Pkg.test("Literate")
     Testing Literate
   ...
     Testing Running tests...
Test Summary:  | Pass  Total  Time
Literate.parse |  533    533  0.8s
Test Summary:   | Pass  Broken  Total  Time
Literate.script |   36       1     37  2.1s
Test Summary:     | Pass  Broken  Total  Time
Literate.markdown |   82       2     84  4.3s
Test Summary:     | Pass  Broken  Total  Time
Literate.notebook |   86       1     87  5.2s
Test Summary: | Pass  Total  Time
Configuration |    7      7  0.3s
     Testing Literate tests passed
```
"""



#src #########################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
### Wrapping-up

- The `Test` module provides simple _unit testing_ functionality.
- Tests can be grouped into sets using `@testset`.
- We'll later see how tests can be used in CI.
"""
