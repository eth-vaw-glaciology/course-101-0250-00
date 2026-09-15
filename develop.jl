cd(@__DIR__)

import Pkg
Pkg.activate("./pluto-deployment-environment")
Pkg.instantiate()

include("split.jl")

import PlutoPages

PlutoPages.develop(@__DIR__)
