using Literate

## include Literate scripts starting with following 2 letters in the deploy
incl = "l2_3"
## Set `sol=true` to produce output with solutions contained and hints stripts.  Otherwise
#  the other way around.
sol = false
##

"""
    process_hashtag(str, hashtag, fn; striptag=true)

Process all lines in str which start with a hashtag by the
function `fn` (`line->newline`).

```
# drop lines starting with "#sol"
drop_sol = str -> process_hashtag(str, "#sol", line -> "")
Literate.notebook(fl, "notebooks", preproces=drop_sol)
```
"""
function process_hashtag(str, hashtag, fn; striptag=true)
    hashtag = strip(hashtag) * " "
    occursin("\r\n", str) && error("""DOS line endings "\r"n" not supported""")
    out = ""
    for line in split(str, '\n')
        line = if startswith(line, hashtag)
            fn(striptag ?
                replace(line, hashtag=>"") :
                line)
        else
            line
        end
        out = out * line * "\n"
    end
    return out
end

"Use as `preproces` function to remove `#sol`-lines & just remote `#tag`-tag"
function rm_sol(str)
    str = process_hashtag(str, "#sol", line->"")
    str = process_hashtag(str, "#hint", line->line)
    return str
end
"Use as `preproces` function to remove `#hint`-lines & just remote `#sol`-tag"
function rm_hint(str)
    str = process_hashtag(str, "#sol", line->line)
    str = process_hashtag(str, "#hint", line->"")
    return str
end


for fl in readdir()
    if splitext(fl)[end]!=".jl" || splitpath(@__FILE__)[end]==fl || !occursin(incl, fl)
        continue
    end

    println("File: $fl")

    # create ipynb
    if sol
        Literate.notebook(fl, "notebooks", credit=false, execute=false, mdstrings=true, preproces=rm_hint)
    else
        Literate.notebook(fl, "notebooks", credit=false, execute=false, mdstrings=true, preproces=rm_hint)
    end

    # duplicate .jl scripts and rename them for web deploy
    tmp = splitext(fl)[1] * "_web.jl"
    cp("$fl", tmp, force=true)

    str  = read(tmp, String)
    strn = replace.(Ref(str), ["./figures/" => "../assets/literate_figures/"])
    write(tmp, strn)

    mv("$tmp", "../website/_literate/$tmp", force=true)
end

# copy figures for ipynb
mkpath("notebooks/figures")
[cp("figures/$fl", "notebooks/figures/$fl", force=true) for fl in readdir("figures/")]

# copy literate figures
mkpath("../website/_assets/literate_figures")
[cp("figures/$fl", "../website/_assets/literate_figures/$fl", force=true) for fl in readdir("figures/")]
