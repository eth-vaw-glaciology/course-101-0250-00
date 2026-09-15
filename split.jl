SOLUTION_CUTOFF = 0
LECTURES_PATH = joinpath(@__DIR__, "lectures")

import PlutoSplitter

# split the notebook into solution and 
for part in readdir(LECTURES_PATH)
    part_path = joinpath(@__DIR__, "src", part)
    rm(part_path; force=true, recursive=true)
    mkpath(part_path)
    for file in readdir(joinpath(LECTURES_PATH, part))
        filepath = joinpath(LECTURES_PATH, part, file)
        outpath = joinpath(@__DIR__, "src", part, file)
        if isdir(filepath)
            @info "copying '$filepath' to '$outpath'"
            cp(filepath, outpath)
        else
            base, ext = splitext(file)
            if ext == ".jl"
                lecture_id = parse(Int, filter(isnumeric, base))
                type = lecture_id <= SOLUTION_CUTOFF ? "solution" : "statement"
                @info "splitting notebook" file type
                PlutoSplitter.split_notebook(filepath, type; output_filename=outpath)
                # PlutoSplitter changes directory
                cd(@__DIR__)
            elseif ext == ".md"
                @info "copying '$filepath' to '$outpath'"
                cp(filepath, outpath)
            else
                error("only .jl or .md lecture files are supported")
            end
        end
    end
end
