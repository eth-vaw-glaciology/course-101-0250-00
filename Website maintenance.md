# Website maintenance

This document describes how the course website at [pde-on-gpu.vaw.ethz.ch](https://pde-on-gpu.vaw.ethz.ch/) is built and maintained.

## Overview

The website is generated with [PlutoPages.jl](https://github.com/JuliaPluto/PlutoPages.jl), a static site generator inspired by [Eleventy](https://www.11ty.dev/). Its layout is adapted from the MIT course [Computational Thinking](https://computationalthinking.mit.edu). There are three template systems:
- **`.jlhtml` files** are rendered by [HypertextLiteral.jl](https://github.com/JuliaPluto/HypertextLiteral.jl)
- **`.jlmd` files** are rendered by [MarkdownLiteral.jl](https://github.com/JuliaPluto/MarkdownLiteral.jl)
- **`.jl` files** (Pluto notebooks) are rendered by [PlutoSliderServer.jl](https://github.com/JuliaPluto/PlutoSliderServer.jl)

The `src/` folder is scanned for files, and all files are turned into HTML pages.

Paths correspond to URLs. For example, `src/part1_introduction/lecture01.jl` becomes available at `https://pde-on-gpu.vaw.ethz.ch/part1_introduction/lecture01/`. For files called *"index"*, the URL points to their parent folder, e.g. `src/index.jlmd` becomes the homepage. Avoid changing URLs once a page is published: links shared with students (e.g. on Moodle or in the slides) would break.

> **To add something to the website, create a new file.** Lectures go in `lectures/` (see below); other pages go directly in `src/`.

## Lectures

Lecture sources live in `lectures/`, one folder per course part (e.g. `lectures/part1_introduction/`). Before every build, `split.jl` (included by both `generate.jl` and `develop.jl`) turns them into website pages. For each part folder, it:
- deletes and recreates the matching `src/part*` folder,
- copies `.md` files and sub-folders (e.g. `assets/`) unchanged,
- runs `.jl` notebooks through PlutoSplitter.jl, producing the `solution` variant for lectures numbered up to `SOLUTION_CUTOFF` and the `statement` variant otherwise.

Any other file type at the top level of a part folder stops the build with an error.

Because `src/part*` is regenerated on every build and ignored by git, **always edit lectures in `lectures/`**. Changes made in `src/part*` are lost.

## Content

### Literal templates

We use *Julia* as our templating system! Because we use HypertextLiteral and MarkdownLiteral, you can write regular Markdown and HTML files, but you can also include `$(interpolation)` to spice up your documents. For example:

```markdown
# Hey there!

This is some *text*. Here is a very big number: $(1 + 1).
```

Besides small inline values, you can also write big code blocks with `$(begin ... end)`, and you can output HTML. Take a look at the files in `src/` to learn more.

### Pluto notebooks

Pluto notebooks are rendered to HTML and included in the page. What you see is what you get!

Notebooks are exported as static pages: no PlutoSliderServer is running for this site, so sliders and other interactive elements do not react on the website. Readers can use the *Edit or run this notebook* button to run a notebook on their own computer or on Binder.

A notebook opened that way runs outside this repository, so relative paths such as `assets/image.png` do not exist. For images, use `RobustLocalResource` from PlutoTeachingTools.jl with a `https://raw.githubusercontent.com/...` URL as fallback. A `https://github.com/.../blob/...` URL points to a GitHub web page, not to the file itself.

Notebook outputs are **cached** (for a long time) by the file hash. This means that a notebook file only runs again when it changes, which makes working on the website much faster. On GitHub Actions, this cache (`_cache/`) is kept between runs. If you need to re-run a notebook, make a small change to its file, e.g. add a space somewhere in the code.

### `.css`, `.html`, `.gif`, etc.

Web assets are copied to the website unchanged.

## Frontmatter

Like many static site generators, PlutoPages uses [*frontmatter*](https://www.11ty.dev/docs/data-frontmatter/) to add metadata to pages. In `.md` and `.jlmd` files, this is done with a frontmatter block at the top of the file, e.g. in `src/installation.md`:

```markdown
---
title: "Software installation"
tags: ["welcome"]
order: 2
layout: "md.jlmd"
---

# Software installation

...
```

Every page **should** include:
- *`title`*: used in the sidebar, in search results, in the browser window title, and on social media.
- *`tags`*: list of *tags* used to group pages into collections. The sidebar lists one collection per section; section tags and their names are defined in `src/_data/sidebar.jl` (e.g. `welcome`, `module1`).
- *`order`*: position of the page within its sidebar section.
- *`layout`*: name of a layout file in `src/_includes/`. For Markdown pages, use `md.jlmd`. For Pluto notebooks, use `layout.jlhtml`.

Optional fields:
- *`description`*: shown when hovering over the page in the sidebar, and used in search results and on social media.
- *`chapter`* and *`section`* (notebooks): shown as "Section chapter.section" in the lecture header.

### How to write frontmatter

For `.md` and `.jlmd` files, see the example above.

For `.jl` notebooks, use the [frontmatter GUI](https://plutojl.org/en/docs/frontmatter/) built into Pluto.

`.jlhtml` files are only used as layout templates in `src/_includes/`, so they don't need frontmatter.

## Running locally

### Development server

From the repository root, run:

```
julia develop.jl
```

This activates the `pluto-deployment-environment` project, runs `split.jl`, and starts the [PlutoPages.jl](https://github.com/JuliaPluto/PlutoPages.jl) development server. The first run can take some time, as it builds up the notebook output cache. Leave it running.

The server starts two things in parallel: the PlutoPages server, which generates the website, and a static file server (LiveServer.jl). It opens two tabs in your browser: one is the generation dashboard (PlutoPages), the other is the current site preview (LiveServer).

Whenever you edit a file in `src/`, PlutoPages regenerates the website automatically; refresh your browser tab. If it does not pick up the change, go to the generation dashboard and click the "Read input files again" button. `split.jl` only runs at startup, so after editing files in `lectures/`, restart `develop.jl`.

This workflow is recommended for writing static content, styles, and for site maintenance. For Pluto notebooks, it is best to finish the notebook first and then run the site, because the entire notebook is re-run on every change.

### Full build

To build the website the same way GitHub Actions does, run:

```
julia generate.jl
```

The website is written to `_site/`, and a report to `generation_report.html`.

## Deployment

Deployment is handled by the GitHub Actions workflows in `.github/workflows/`:
- **Push to `main`:** `ExportNotebooks.yml` runs `julia generate.jl` and publishes `_site/` to the `gh-pages` branch, which GitHub Pages serves at [pde-on-gpu.vaw.ethz.ch](https://pde-on-gpu.vaw.ethz.ch/). The custom domain is set in the repository's GitHub Pages settings.
- **Pull request to `main`:** the same build runs, and for branches of this repository (not forks) the result is published under `previews/PR<number>/`. A bot comments on the pull request with the preview link, and the preview is deleted when the pull request is closed.
- **Every build:** `generation_report.html` is uploaded as a workflow artifact, which helps when debugging a failed build.
