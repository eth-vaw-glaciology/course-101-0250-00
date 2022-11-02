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
For the project, you will have to create a `PorousConvection` folder **within** your `pde-on-gpu-<lastname>` shared private GitHub repo. To do so, you can follow these steps:
1. Within your `pde-on-gpu-<lastname>` folder, copy over the `PorousConvection` you can find in the `l7_project_template` folder within the [scripts](https://github.com/eth-vaw-glaciology/course-101-0250-00/tree/main/scripts) folder. Make sure to copy the entire folder as not to loose the hidden files.
2. Also, make sure the hidden file `.gitignore` includes `Manifest.toml` and `.DS_Store` for mac users.
3. At the root of your `pde-on-gpu-<lastname>` folder, create a (hidden) `.github/workflows/` folder and add in there the remaining `CI.yml` file from the `l7_project_template` (which is the same as from the lecture - see [here](#wait_a_second_we_submit_our_homework_as_subfolders_of_our_github_repo)).
4. Now, you'll need to edit the `Project.toml` file to add your full name and email address (the ones you are using for GitHub), and add a UUID as well.
5. To add a UUID, execute in Julia `using UUIDs` and then `uuid1()`. Copy the returned UUID (including the `"`) to the `Project.toml` file.
6. The last part is to update the badge URL in the `README` within the `PorousConvection` folder. Replace the `<USER>/<REPO>` with your username and the name of your repo:
```
[![Build Status](https://github.com/<USER>/<REPO>/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/<USER>/<REPO>/actions/workflows/CI.yml?query=branch%3Amain)
```
7. Pushing any changes to your `PorousConvection` folder should now trigger CI and as for now no tests are executed the status should be green, i.e., passing.

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
