<!--This file was generated, do not modify it.-->
# Unit testing in Julia

### The Julia `Test` module

[Basic unit tests](https://docs.julialang.org/en/v1/stdlib/Test/#Basic-Unit-Tests) in Julia
- Provides simple _unit testing_ functionality
- A way to assess if code is correct by checking that results are as expected
- Helpful to ensure the code still works after changes
- Can be used when developing
- Should be used in package for continous integration (aka CI;
  when tests are run on GitHub automatically on a push)

## Basic unit tests

Simple unit testing can be performed with the `@test` and `@test_throws` macros:

````julia:ex1
using Test

@test 1==1

@test_throws MethodError 1+"a" ## the expected error must be provided too
````

Or another example

````julia:ex2
@test [1, 2] + [2, 1] == [3, 3]
````

Testing an expression which is a call using infix syntax such as approximate comparisons (`\approx` + tab)

````julia:ex3
@test π ≈ 3.14 atol=0.01
````

For example, suppose we want to check our new function `square(x)` works as expected:

````julia:ex4
square(x) = x^2
````

If the condition is true, a `Pass` is returned:

````julia:ex5
@test square(5) == 25
````

If the condition is false, then a `Fail` is returned and an exception is thrown:
```julia
@test square(5) == 20
```
```julia
Test Failed at none:1
  Expression: square(5) == 20
   Evaluated: 25 == 20
Test.FallbackTestSetException("There was an error during testing")
```

## Working with a test sets

The `@testset` macro can be used to group [tests into sets](https://docs.julialang.org/en/v1/stdlib/Test/#Working-with-Test-Sets).

All the tests in a test set will be run, and at the end of the test set a summary will be printed.

If any of the tests failed, or could not be evaluated due to an error, the test set will then throw a `TestSetException`.

````julia:ex6
@testset "trigonometric identities" begin
    θ = 2/3*π
    @test sin(-θ) ≈ -sin(θ)
    @test cos(-θ) ≈ cos(θ)
    @test sin(2θ) ≈ 2*sin(θ)*cos(θ)
    @test cos(2θ) ≈ cos(θ)^2 - sin(θ)^2
end;
````

Let's try it with our `square()` function

````julia:ex7
square(x) = x^2

@testset "Square Tests" begin
    @test square(5) == 25
    @test square("a") == "aa"
    @test square("bb") == "bbbb"
end;
````

If we now introduce a bug
```julia
square(x) = x^2

@testset "Square Tests" begin
    @test square(5) == 25
    @test square("a") == "aa"
    @test square("bb") == "bbbb"
    @test square(5) == 20
end;
```
```julia
Square Tests: Test Failed at none:6
  Expression: square(5) == 20
   Evaluated: 25 == 20
Stacktrace:
 [...]
Test Summary: | Pass  Fail  Total
Square Tests  |    3     1      4
Some tests did not pass: 3 passed, 1 failed, 0 errored, 0 broken.
```

Then then the reporting tells us a test failed.

### Where to put them, how to run them

The simplest is to just put the tests in your script, along the tested function.
Then the tests run every time the script is executed.

However, for bigger pieces of software, such as packages, this becomes unwieldly
and also undesired (as we don't want tests to run all the time).  Then tests are put
into `test/runtests.jl`.  If they are there they will be run when called from package
mode or from automated test (CI).

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

### Wrapping-up

- The `Test` module provides simple _unit testing_ functionality.
- Tests can be grouped into sets using `@testset`.
- We'll later see how tests can be used in CI.

