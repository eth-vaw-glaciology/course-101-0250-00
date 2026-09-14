SOLUTION_CUTOFF = 0
LECTURES_PATH   = joinpath(@__DIR__, "lectures")

cd(@__DIR__)

import Pkg
Pkg.activate("./pluto-deployment-environment")
Pkg.instantiate()

import PlutoSplitter

# split the notebook into solution and 
for path in readdir(LECTURES_PATH)
    for file in readdir(joinpath(LECTURES_PATH, path))
        filepath = joinpath(LECTURES_PATH, path, file)
        lecture_id = parse(Int, filter(isnumeric, splitext(file)[1]))
        
        output_filename = joinpath(@__DIR__, "src", path, file)
        type = lecture_id <= SOLUTION_CUTOFF ? "solution" : "statement"

        @info "splitting notebook" file type

        PlutoSplitter.split_notebook(filepath, type; output_filename)

        # PlutoSplitter changes directory
        cd(@__DIR__)
    end
end

import PlutoPages

PlutoPages.develop(@__DIR__)
