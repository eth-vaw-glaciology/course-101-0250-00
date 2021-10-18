# This file was generated, do not modify it. # hide
square!(x) = x^2

@testset "Square Tests" begin
    @test square!(5) == 25
    @test square!("a") == "aa"
    @test square!("bb") == "bbbb"
end;