# This file was generated, do not modify it.

using Test
using PorousConvection

function runtests()
    exename = joinpath(Sys.BINDIR, Base.julia_exename())
    testdir = pwd()

    printstyled("Testing PorousConvection.jl\n"; bold=true, color=:white)

    run(`$exename -O3 --startup-file=no $(joinpath(testdir, "test2D.jl"))`)
    run(`$exename -O3 --startup-file=no $(joinpath(testdir, "test3D.jl"))`)

    return
end

exit(runtests())
