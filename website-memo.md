# website-memo
This document lists the basics on how to edit the course website accessible at https://eth-vaw-glaciology.github.io/course-101-0250-00/.

🚧 More to come soon.

## Franklin static website

To test the website locally (or after making the a pull from Git):
```julia-repl
julia> using Franklin

julia> using NodeJS

julia> serve(clear=true)
```
> Note the first time you are using `NodeJS`, you need to execute:
```julia-repl
julia> run(`sudo $(npm_cmd()) install highlight.js`)
```

## How-to

### Add YouTube video
To embed YouTube videos, go to YouTube, click on the `Share` link and then `<Embed>`, and copy-paste the script into an html block:
```md
~~~
<iframe width="560" height="315" src="https://www.youtube.com/embed/DvlM0w6lYEY" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
~~~
```

### Notebook, code, and markdown with Franklin

Using `Literate.jl` permit to write a single `.jl` source file that can contain Julia code and markdown comments and can be transformed into a markdown page, a notebook and notebook-based slides. The website build with `Franklin.jl` has native support to integrate `.jl` scripts ready to me processed by `Literate.jl` in markdown.

#### Display Julia script as Markdown page on the website

1. Create a Literate-ready `my_script.jl` script

2. Place it in the `_literate` folder

3. Add `\literate{/_literate/my_script.jl}` in the website page you want to include `my_script.jl` markdown rendering

4. Done

Note that there are 2 pre-defined box environments to highlight **note** and **warning**. Use them as following:
```md
#md # \note{...}
#md # \warn{...}
```

#### Launch a notebook from the script

1. In Julia, load Literate and export `my_script.jl` as a notebook:
```julia
julia> using Literate

julia> Literate.notebook("my_scritp.jl", outputdir=pwd())

```

2. Then load IJulia and launch the notebook for the given path
```julia
julia> using IJulia

julia> notebook(dir="/some/path")
```

#### Transform the notebook into a presentation

1. To allow for slide rendering as _slide, subslide or fragment_, populate `my_script.jl` "source" code with
```julia
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide/subslide/fragment"}}
```

2. To view the notebook as a slideshow, install the [RISE plugin](https://rise.readthedocs.io/en/stable/installation.html).

3. Open the notebook as in [here](#launch-a-notebook-from-the-script)

4. Press `alt-r` to start. Use spacebar to advance.


## Misc

### HTML color-picker

https://www.w3schools.com/colors/colors_picker.asp
