SOLUTION_CUTOFF = 1
LECTURES_PATH = joinpath(@__DIR__, "lectures")

import SHA

SPLIT_CACHE_PATH = mkpath(joinpath(@__DIR__, "_cache", "split-v1"))
SPLIT_ENVIRONMENT = map(("Project.toml", "Manifest.toml")) do file
    path = joinpath(@__DIR__, "pluto-deployment-environment", file)
    isfile(path) ? read(path, String) : nothing
end

# Keep execution enabled so generated notebooks also work as ordinary Julia scripts.
# Hash contents, not timestamps: rebuilding src must preserve cache hits.
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
                key = bytes2hex(SHA.sha256(repr((
                    relpath(filepath, LECTURES_PATH), read(filepath, String), type,
                    string(VERSION), SPLIT_ENVIRONMENT,
                ))))
                cachepath = joinpath(SPLIT_CACHE_PATH, key * ".jl")
                if isfile(cachepath)
                    @info "split cache hit" file type
                    cp(cachepath, outpath)
                else
                    @info "split cache miss" file type
                    @eval import PlutoSplitter
                    try
                        PlutoSplitter.split_notebook(filepath, type; output_filename=outpath)
                    finally
                        # PlutoSplitter changes directory, including when execution fails.
                        cd(@__DIR__)
                    end
                    # Publish only a complete output; interrupted runs cannot leave a hit.
                    mktemp(SPLIT_CACHE_PATH) do path, io
                        write(io, read(outpath))
                        close(io)
                        mv(path, cachepath; force=true)
                    end
                end
            elseif ext == ".md"
                @info "copying '$filepath' to '$outpath'"
                cp(filepath, outpath)
            else
                error("only .jl or .md lecture files are supported, got '$file'")
            end
        end
    end
end
