using Literate

function replace_string(str)
        strn = str
        for st in ["./figures/" => "../assets/literate_figures/"]
            strn = replace(strn, st)
        end
    return strn
end

for fl in readdir()
    if splitext(fl)[end]!=".jl" || splitpath(@__FILE__)[end]==fl || "make_notebooks.jl"==fl
        continue
    end
    
    # create ipynb
    Literate.notebook(fl, "notebooks", credit=false, execute=false, mdstrings=true) #, preprocess=include2nbinclude)

    # duplicate .jl scripts and rename them for web deploy
    tmp = splitext(fl)[1] * "_web.jl"
    cp("$fl", tmp, force=true)

    # str  = read(tmp, String)
    # strn = replace_string(str)
    # write(tmp, strn)

    mv("$tmp", "../website/_literate/$tmp")
end

# # copy figures for ipynb
# mkpath("notebooks/figures")
# [cp("figures/$fl", "notebooks/figures/$fl", force=true) for fl in readdir("figures/")]

# # copy literate figures
# mkpath("../website/_assets/literate_figures")
# [cp("figures/$fl", "../website/_assets/literate_figures/$fl", force=true) for fl in readdir("figures/")]
