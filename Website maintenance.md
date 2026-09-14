# Website maintenance

This document describes how the website works.

# Overview

This is the source code for the computational thinking website! It uses a site generation system inspired by [https://www.11ty.dev/](https://www.11ty.dev/), but there are only three template systems:
- **`.jlhtml` files** are rendered by [HypertextLiteral.jl](https://github.com/JuliaPluto/HypertextLiteral.jl)
- **`.jlmd` files** are rendered by [MarkdownLiteral.jl](https://github.com/JuliaPluto/MarkdownLiteral.jl)
- **`.jl` files** are rendered by [PlutoSliderServer.jl](https://github.com/JuliaPluto/PlutoSliderServer.jl)

The `/src/` folder is scanned for files, and all files are turned into HTML pages. 

Paths correspond to URLs. For example, `src/data_science/pca.jl` will become available at `https://computationalthinking.mit.edu/data_science/pca/`. For files called *"index"*, the URL will point to its parent, e.g. `src/docs/index.jlmd` becomes `https://computationalthinking.mit.edu/docs/`. Remember that changing URLs is very bad! You can't share this site with your friends if the links break.

> **To add something to our website, just create a new file!** Fons will be happy to figure out the technical bits.

You can generate & preview the website locally (more on this later), and we have a github action generating the website when we push to the `Fall23` branch. The result (in the `Fall23-output` branch) is deployed with GitHub Pages.

# Content

## Literal templates
We use *Julia* as our templating system! Because we use HypertextLiteral and MarkdownLiteral, you can write regular Markdown files and HTML files, but you can also include `$(interpolation)` to spice up your documents! For example:

```markdown
# Hey there!

This is some *text*. Here is a very big number: $(1 + 1).
```

Besides small inline values, you can also write big code blocks, with `$(begin ... end)`, and you can output HTML. Take a look at some of our files to learn more!

## Pluto notebooks

Pluto notebooks will be rendered to HTML and included in the page. What you see is what you get!

On a separate system, we are running a PlutoSliderServer that is synchronized to the `Fall23` brach. This makes our notebooks interactive!

Notebook outputs are **cached** (for a long time) by the file hash. This means that a notebook file will only ever run once, which makes it much faster to work on the website. If you need to re-run your notebook, add a space somewhere in the code :)

## `.css`, `.html`, `.gif`, etc

Web assets go through the system unchanged.

# Frontmatter

Like many SSG systems, we use [*frontmatter*](https://www.11ty.dev/docs/data-frontmatter/) to add metadata to pages. In `.jlmd` files, this is done with a frontmatter block, e.g.:

```markdown
---
title: "🌼 How to install"
description: "Instructions to install Pluto.jl"
tags: ["docs", "introduction"]
layout: "md.jlmd"
---

# Let's install Pluto

here is how you do it
```

Every page **should probably** include:
- *`title`*: Will be used in the sidebar, on Google, in the window header, and on social media.
- *`description`*: Will be used on hover, on Google, and on social media.
- *`tags`*: List of *tags* that are used to create collections out of pages. Our sidebar uses collections to know which pages to list. (more details in `sidebar data.jl`)
- *`layout`*: The name of a layout file in `src/_includes`. For basic Markdown or HTML, you probably want `md.jlmd`. For Pluto, you should use `layout.jlhtml`.

## How to write frontmatter
For `.jlmd` files, see the example above. 

For `.jl` notebooks, use the [Frontmatter GUI](https://plutojl.org/en/docs/frontmatter/) built into Pluto.

For `.jlhtml`, we still need to figure something out 😄. Get in touch if you need this.

# Running locally

## Developing *content, styles, etc.*

Open this repository in VS Code, and install the recommended extensions.

To start running the development server, open the VS Code *command palette* (press `Cmd+Shift+P`), and search for **`Tasks: Run Task`**, then **`🌳 PlutoPages: run development server`**. The first run can take some time, as it builds up the notebook outputs cache. Leave it running.

This will start two things in parallel: the [PlutoPages.jl](https://github.com/JuliaPluto/PlutoPages.jl) server (which generates the website), and a static file server (with LiveServer.jl). It will open two tabs in your browser: one is the generation dashboard (PlutoPages), the other is the current site preview (LiveServer).
 
Whenever you edit a file, PlutoPages will automatically regenerate! Refresh your browser tab. If it does not pick up the change, go to the generation dashboard and click the "Read input files again" button.

This workflow is recommended for writing static content, styles, and for site maintenance. But for writing Pluto notebooks, it's best to prepare the notebook first, and then run the site (because it re-runs the entire notebook on any change).
