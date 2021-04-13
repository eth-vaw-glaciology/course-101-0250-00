# website-memo
This document lists the basic on how to edit the course website accessible at https://eth-vaw-glaciology.github.io/course-101-0250-00/.

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

## Misc

### HTML color-picker

https://www.w3schools.com/colors/colors_picker.asp
