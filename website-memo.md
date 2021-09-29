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

To allow `mdstring` to render correctly in Franklin, one need to set the page variable `literate_mds = true`.

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

#### Notebook deploy

Running the `deploy_notebooks.jl` scripts located in [slide-notebooks](slide-notebooks) and [exercise-notebooks](exercise-notebooks) folder will:
- create `.ipynb` from the `.jl` script
- move the `.ipynb` and figures to the `./notebook` folder (and `./notebook/figures`)
- create a `_web.jl` script and move it to `website/_literate` to be included in the website lecture pages. Figure links in the `_web.jl` files are changes from `./figures/` to `../website/_assets/literate_figures/` for correct rendering in html file.
- create, if needed, a figures folder in `website/_assets/literate_figures` folder to hold figures for Literate scripts
- :bulb: both deploy script contain a variable `incl::String` you can set to only include specific scripts (e.g. `incl=l2`, `incl=lecture2`)

**Important note:** The `deploy_notebooks.jl` script in [slide-notebooks](slide-notebooks) makes it possible to preprocess the Literate script for _hints_ and _solution_ keywords:
```julia
## Set `sol=true` to produce output with solutions contained and hints stripts. Otherwise the other way around.
sol = true
```

You can populate lines beginning of Literate script with `#hint` or `#sol` which will permit to corresponding lines to be removed upon preprocessing (e.g. before / after the lecture).

**To deploy notebooks**
1. Run the deploy script from its folder
2. Include the correct `_web.jl` filename in e.g. `website/lectureXY.md` file
3. Push

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

### gif and loopcount

You can use [gifsicle](https://www.lcdf.org/gifsicle/) as command line tool to modify the loopcount for gifs to be included in the scripts (tested on MacOS):
```sh
gifsicle gif_loopcount_inf.gif --no-loopcount > new_gif_no_loopcount.gif
gifsicle gif_loopcount_inf.gif --loop=3 > new_gif_loopcount_3.gif
```

## Misc

### Control the global page content width

Put in `_layout/head` the following, before the opening of the body and after the loading of the css:
```html
<style>
.content {max-width: 50rem}
</style>
```

### HTML color-picker

https://www.w3schools.com/colors/colors_picker.asp
