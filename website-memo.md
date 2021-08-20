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

### Export `.ipynb` to Markdown and use it as course page
To export an ipython notebook, and statically render it as webpage (e.g. course 1 page), type following command in the shell.
```sh
nbconvert --to markdown  course1.ipynb
```
Then, you need to move the generated `course1_files` folder and the `course1.md` file to the `website` folder.

**Important**: For now, one needs to manually
- fix the links to images as the first `/` is missing, e.g.:
`![](course1_files/course1_2_0.svg)` needs to be modified to `![](/course1_files/course1_2_0.svg)`.
- add code highlight command on page's top:
```md
+++
title = "Course 1"
hascode = true
+++
```
- add the link to which notebook the output refers to, e.g.
```md
> This it the output of the [course1.ipynb](https://github.com/eth-vaw-glaciology/course-101-0250-00/course1/course1.ipynb)
```


## Misc

### HTML color-picker

https://www.w3schools.com/colors/colors_picker.asp