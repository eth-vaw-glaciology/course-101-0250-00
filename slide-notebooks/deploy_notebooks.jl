using Literate
## include Literate scripts starting with following 2 letters in the deploy
incl = "l4"
## Set `sol=true` to produce output with solutions contained and hints stripts. Otherwise the other way around.
sol = false
##

function replace_string(str)
        strn = str
        for st in ["./figures/" => "../assets/literate_figures/"]
            strn = replace(strn, st)
        end
    return strn
end

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
    regex = Regex(hashtag)
    for line in split(str, '\n')
        # line = if startswith(lstrip(line), hashtag)
        line = if occursin(regex, line)
            fn(striptag ? replace(line, hashtag=>"") : line)
        else
            line = line * "\n"
        end
        out = out * line
    end
    return out
end

"Use as `preproces` function to remove `#sol`-lines & just remote `#tag`-tag"
function rm_sol(str)
    str = process_hashtag(str, "#sol", line->"")
    str = process_hashtag(str, "#hint", line->line * "\n")
    return str
end
"Use as `preproces` function to remove `#hint`-lines & just remote `#sol`-tag"
function rm_hint(str)
    str = process_hashtag(str, "#sol", line->line * "\n")
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
        Literate.notebook(fl, "notebooks", credit=false, execute=false, mdstrings=true, preprocess=rm_hint)
    else
        Literate.notebook(fl, "notebooks", credit=false, execute=false, mdstrings=true, preprocess=rm_sol)
    end

    # duplicate .jl scripts and rename them for web deploy
    tmp = splitext(fl)[1] * "_web.jl"
    cp("$fl", tmp, force=true)

    str  = read(tmp, String)
    strn = replace_string(str)
    if sol
        strn2 = rm_hint(strn)
    else
        strn2 = rm_sol(strn)
    end
    write(tmp, strn2)

    mv("$tmp", "../website/_literate/$tmp", force=true)
end

# copy figures for ipynb
mkpath("notebooks/figures")
[cp("figures/$fl", "notebooks/figures/$fl", force=true) for fl in readdir("figures/")]

# copy literate figures
mkpath("../website/_assets/literate_figures")
[cp("figures/$fl", "../website/_assets/literate_figures/$fl", force=true) for fl in readdir("figures/")]
