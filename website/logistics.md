+++
title = "Logistics"
hascode = false
+++

# Logistics

[![Element chat](/assets/element_chat.svg#badge)](https://chat.ethz.ch)
[![Zoom Meeting](/assets/zoom_logo.svg#badge)](https://moodle-app2.let.ethz.ch/mod/zoom/view.php?id=1104644)
[![ETHZ Moodle](/assets/moodle.png#badge)](https://moodle-app2.let.ethz.ch/course/view.php?id=23586)

> **Suggestion:** Bookmark this page for easy access to all infos you need for the course.

## Course structure

Each lecture contains material on physics, numerics, technical concepts, as well as exercises. The lecture content is outlined in its introduction using the following items for each type of content:
- :books: Physics: equations, discretisation, implementation, solver, visualisation
- :computer: Code: technical, Julia, GitHub
- :construction: Exercises

The course will be taught in a hands-on fashion, putting emphasis on you writing code and completing exercises; lecturing will be kept at a minimum.

## Lectures

### Live lectures | Tuesdays 12h45-15h30
- Lectures will take place in [HCI](http://www.mapsearch.ethz.ch/map/mapSearchPre.do?gebaeudeMap=HCI&geschossMap=E&raumMap=8&farbcode=c010&lang=en) [E8](http://www.rauminfo.ethz.ch/Rauminfo/grundrissplan.gif?gebaeude=HCI&geschoss=E&raumNr=8&lang=en)
- Online attendance will be possible on [Zoom](https://moodle-app2.let.ethz.ch/mod/zoom/view.php?id=1104644) for ETH students only
- No online support will be provided during the exercise session, please follow the lectures

### Office hours
Schedule will be defined and communicated on the last lecture.

## Discussion

We use [Element](https://chat.ethz.ch/) as the main channel for communication between the teachers and the students, and hopefully also between students. We encourage ETH students to ask and answer questions related to the course, exercises and projects there.

Head to the [_Element chat_ link on Moodle](https://moodle-app2.let.ethz.ch/course/view.php?id=23586) to get started with Element:
1. Select **Start Student-Chat**
2. Login using your NETHZ credentials to start using the browser-based client
3. Join the **_General_** and **_Helpdesk_** rooms
4. Download the [desktop or mobile client](https://element.io/) for more convenient access or in case of encryption-related issues

## Homework

[Homework](/homework) tasks will be announced after each week's lecture. The exercise session following the lecture will get you started.

Homework **due date will be Wednesday 23h59 CET** every following week (8 days) to allow for Q&A during the following in-class exercise session.

All homework assignments can be carried out by groups of two. However, **note that every student has to hand in a personal version of the homework**.

> ➡ Check out the [Homework](/homework) page for an overview on expected hand-in and deadlines.

### Submission
- Submission of JupyterHub notebooks after weeks 1 and 2, then GitHub commit hash (SHA) after week 3 and onwards, or other documents happens on the course's [Moodle](https://moodle-app2.let.ethz.ch/course/view.php?id=23586).
- Actions and tasks related to GitHub will happen on your private course-related GitHub repository.

**Starting from lecture 3 and onwards**, the development of homework scripts happens on GitHub **and** you will have to submit the git commit hash (SHA) on [Moodle](https://moodle-app2.let.ethz.ch/course/view.php?id=23586) in the related _git commit hash (SHA)_ submission activity.

### Submission for Jupyter Hub to Moodle
- on the Hub place all notebooks of an assignment into one folder called `assignments/lectureX_homework`
  - note: maybe this folder magically already exists on your Hub with the notebooks added. If not, create it and download the notebooks yourself.
- in Moodle during submission, select that folder as JupyterHub submission

### Private GitHub repository setup
Once you have your GitHub account ready (see lecture 2 [how-to](/lecture2/#a_brief_git_demo_session)), create a private repository you will _**share with the teaching staff only**_ to upload your weekly assignments:
1. Create a **private** GitHub repository named `pde-on-gpu-<moodleprofilename>`, where `<moodleprofilename>` has to be replaced by your name **as displayed on Moodle, lowercase, diacritics removed, spacing replaced with hyphens (-)**. For example, if your Moodle profile name is "Joël Désirée van der Linde" your repository should be named `pde-on-gpu-joel-desiree-van-der-linde`.
2. Select an `MIT License` and add a `README.md` file.
3. Share this private repository on GitHub with the [teaching bot](https://github.com/teaching-bot).
4. **For each homework submission**, you will:
    - create a git branch named `homework-X` (X $\in [2-...]$) and switch to that branch (`git switch -c homework-X`);
    - create a new folder named `homework-X` to put the exercise codes into;
    - (don't forget to `git add` the code-files and `git commit` them);
    - push to GitHub and open a pull request (PR) on the `main` branch on GitHub;
    - copy **the single git commit hash (SHA) after the final push and the link to the PR** and submit **both** on [Moodle](https://moodle-app2.let.ethz.ch/course/view.php?id=23586) as the assignment hand-in (it will serve to control the material was pushed on time);
    - (do not merge the PR yet).

\warn{Make sure to only include the `homework-X` folders and `README.md` in the GitHub repo you share with the exercise bot in order to keep the repository lightweight.}

\note{For homework 3 and later, the respective folders on GitHub should be Julia projects and thus must contain a `Project.toml` file. The `Manifest.toml` file should be excluded from version control. To do so, add it as entry to a `.gitignore` file in the root of your repo. Mac users may also add `.DS_Store` to their [global `.gitignore`](https://docs.github.com/en/get-started/getting-started-with-git/ignoring-files#configuring-ignored-files-for-all-repositories-on-your-computer). Codes could be placed in a `scripts/` folder. Output material to be displayed in the `README.md` could be placed in a `docs/` folder.}

### Feedback

After the submission deadline, we will correct and grade your assignments. You will get personal feedback directly on the PR as well as on [Moodle](https://moodle-app2.let.ethz.ch/course/view.php?id=23586).  Once you got feedback, please merge the PR.

We will try to correct your assignments before the lecture following the homework's deadline. This should allow you to get rapid feedback in order to clarify the points you may struggle on as soon as possible.

## Project

Starting from lecture 7, and until lecture 9, homework assigments contribute to the course's first project. The goal of this project is to have a multi-xPU thermal porous convection solver in 3D.

The exercises **in lecture 7** will serve as starting point for the first project:

1. Within your `pde-on-gpu-<moodleprofilename>` folder, copy over the `PorousConvection` you can find in the `l7_project_template` folder within the [scripts](https://github.com/eth-vaw-glaciology/course-101-0250-00/tree/main/scripts) folder. Make sure to copy the entire folder as not to loose the hidden files.
2. Follow the specific instructions given in [Lecture 7 - infos about projects](/lecture7/#infos_about_projects).
3. During lectures 7 and 9 you will be asked to add material to the `PorousConvection` folder as part of regular homework hand-in _which will serve as evaluation for the Part 2 (35% of the final grade)_ (see [Evaluation](#evaluation) section).

### Project hand-in checklist
The project submission deadline is set to **28.11.2024 - 23h59 CET** (see also [Homework](/homework)). The final GitHub SHA has to be added to [Moodle](https://moodle-app2.let.ethz.ch/mod/assign/view.php?id=1103857) in the Lecture 9 section.

Make sure to have following items in your private GitHub repository:
- a `PorousConvection` folder containing the structure proposed in [Lecture 7](/lecture7/#preparing_the_project_folder_in_your_github_repo)
- the 2D and 3D scripts from Lecture 7
- the CI set-up to test the 2D and 3D porous convection scripts
- a `lecture_8` folder (different from the PorousConvection folder) containing the codes, `README.md` and material listed in [Exercises - Lecture 8](/lecture8/#exercises_-_lecture_8)
- the 3D multi-xPU thermal porous convection script and output as per directions from [Exercises - Lecture 9](/lecture9/#exercises_-_lecture_9).

**In addition** enhance the `README.md` within the `PorousConvection` folder to include:
- a short motivation/introduction
- concise information about the equations you are solving
- concise information about the numerical method and implementation
- the results, incl. figures with labels, captions, etc...
- a short discussion/conclusion section about the performed work, results, and outlook

_Note that for evaluation will be considered the following (non-exhaustive) items: code correctness, style, and conciseness; implementation of demanded tasks; final layout and rendering, ..._

## Final project

For information about **topics** for the final project, head to [Information about final projects](/final_proj) page.

### Getting started
The following steps will get you started with the final projects:
1. Find a classmate to work with (being your own mate is fine too)
2. Select a topic of your choice
4. Initiate a private GitHub repository for your project (CamelCaps, including `.jl` at the end - e.g.: `MyProject.jl`)
5. Share the final project private repository on GitHub with the [teaching-bot (https://github.com/teaching-bot)](https://github.com/teaching-bot)
6. Send and email to Ivan (iutkin@ethz.ch) and Ludovic (luraess@ethz.ch) by **Tuesday December 3, 2024**, with subject _**Final projects**_ including
    - your project partner
    - a brief description of your choice
    - a link to your final project GitHub repository
    - _anything else missing in this list_
7. Work on your final project, asking for help
    - in the Element _Helpdesk_ channel for general question
    - as **GitHub "issue"** for project specific questions
    - during class hours serving as helpdesk

### Final project submission
Submission deadline for the project is **December 20, 2024 -- 23h59 CET**.

Final submission timestamp is enforced upon tagging the v1.0.0 version release of your repository. See [GitHub docs](https://docs.github.com/en/repositories/releasing-projects-on-github/about-releases) for infos.

Also, add the last commit SHA to [Moodle - Final project submission](https://moodle-app2.let.ethz.ch/mod/assign/view.php?id=1103859) as for the exercises.

### Final project grading
Grading of the final project will contribute 35% of the final grade.

For a successful outcome, final projects are expected to be handed-in as single GitHub repository featuring the following items:
- documented and polished scripts (using e.g. docstrings, in-line comments)
- documentation including:
  - an enhanced `README.md` following to proposed structure with equations, cross-references, figures, figure captions
  - instructions to run the software and reproduce the results
  - references
- unit and reference testing
- Continuous Integration (CI - using e.g. GitHub Actions)
- additional features if needed

## Evaluation

All homework assignments can be done alone or in groups of two.

Enrolled ETHZ students will have to hand in on [Moodle](https://moodle-app2.let.ethz.ch/course/view.php?id=23586) and GitHub:
1. Six weekly assignments during the course's Part 1 and Part 2 constitute 30% of the final grade. **The best five out of six homework will be counted**.
2. A project developed during Part 3 of the course constitutes 35% of the final grade
3. A final project constitutes 35% of the final grade

**Project submission includes code in a Github repository and an automatically generated documentation**.
