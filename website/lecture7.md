+++
title = "Lecture 7"
hascode = true
literate_mds = true
showall = false
noeval = true
+++

# Lecture 7

> **Agenda**\
> :books: The "two-language problem", `ParallelStencil.jl` xPU implementation\
> :computer: Reference testing, GitHub CI and workflows\
> :construction: Exercises - (Project 1):
> - xPU codes for 2D thermal porous convection
> - 2D and 3D xPU implementation
> - CI workflows

---

\label{content}
**Content**

\toc

[_👉 get started with exercises_](#exercises_-_lecture_7)

---

\literate{/_literate/l7_1-xpu_web.jl}

[⤴ _**back to Content**_](#content)

\literate{/_literate/l7_2-tests-ci_web.jl}

[⤴ _**back to Content**_](#content)

# Exercises - lecture 7

## Infos about projects
Starting from this lecture (and until to lecture 9), homework will contribute to the course's first project. Make sure to carefully follow the instructions from the Project section in [Logistics](/logistics#project) as well as the specific steps listed hereafter.

\warn{This project being identical to all students. We ask you to strictly follow the demanded structure and steps as this will be part of the evaluation criteria, besides running 3D codes.}

### Preparing the project folder in your GitHub repo
For the project, you will have to create a `PorousConvection` folder Within your `pde-on-gpu-<lastname>` shared private GitHub repo. To do so, you can use [`PkgTemplates.jl`](https://github.com/JuliaCI/PkgTemplates.jl).
1. Within Julia, run following command while **being in the root** of your `pde-on-gpu-<lastname>` folder:
    ```
    using PkgTemplates
    Template(; dir=".", plugins=[Git(; ssh=true), GitHubActions(; x86=true)],)("PorousConvection")
    ```
2. From the automatically generated files and folders, you can remove the `.git` since we are already in a git folder, as well as the `.github/workflows/CompatHelper.yml` and `.github/workflows/TagBot.yml` files as we won't use them.
3. This should give you the basic structure. Then edit the `.gitignore` file to include `Manifest.toml` and `.DS_Store` for mac users.
4. Also, add following folders to the repo: `docs`, `scripts`. You will place all assets linked from the `README.md` in `docs`, and add your scripts to `scripts`. We won't touch `src`.
5. Your final structure should be as following:
    ```
    PorousConvection
    |-- .github
    |   `-- workflows
    |       `-- CI.yml
    |-- .gitignore
    |-- LICENSE
    |-- Manifest.toml
    |-- Project.toml
    |-- README.md
    |-- docs
    |-- scripts
    |-- src
    |   `-- PorousConvection.jl
    `-- test
        `-- runtests.jl
    ```
In the next 3 lectures (7,8,9), we will populate the `scripts` folder with 2D and 3D porous convection applications, add tests and use the `README.md` as main "documentation".

You should now be all set and ready to get started 🚀

\literate{/_literate/lecture7_ex1_web.jl}

[⤴ _**back to Content**_](#content)

---

\literate{/_literate/lecture7_ex2_web.jl}

[⤴ _**back to Content**_](#content)

---

\literate{/_literate/lecture7_ex3_web.jl}

[⤴ _**back to Content**_](#content)
