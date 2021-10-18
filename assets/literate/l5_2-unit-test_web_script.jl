# This file was generated, do not modify it.

using Test

@test true

@test [1, 2] + [2, 1] == [3, 3]

@test π ≈ 3.14 atol=0.01

square!(x) = x^2

@test square!(5) == 25

@testset "trigonometric identities" begin
    θ = 2/3*π
    @test sin(-θ) ≈ -sin(θ)
    @test cos(-θ) ≈ cos(θ)
    @test sin(2θ) ≈ 2*sin(θ)*cos(θ)
    @test cos(2θ) ≈ cos(θ)^2 - sin(θ)^2
end;

square!(x) = x^2

@testset "Square Tests" begin
    @test square!(5) == 25
    @test square!("a") == "aa"
    @test square!("bb") == "bbbb"
end;

