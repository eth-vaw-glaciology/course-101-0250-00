import Pkg
Pkg.activate("./pluto-deployment-environment")
Pkg.instantiate()

include("split.jl")

import PlutoPages

PlutoPages.generate("."; html_report_path="generation_report.html")
