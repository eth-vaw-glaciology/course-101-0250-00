+++
title = "Logistics"
hascode = false
+++

# Logistics

[![Element chat](/assets/element_chat.svg#badge)](https://chat.ethz.ch)
[![Zoom Meeting](/assets/zoom_logo.svg#badge)](https://ethz.zoom.us/j/65687277265)
[![ETHZ Moodle](/assets/moodle.png#badge)](https://moodle-app2.let.ethz.ch/course/view.php?id=18084)

> **Suggestion:** Bookmark this page for easy access to all infos you need for the course.

## Course structure

Each lecture contains material on physics, numerics, technical concepts, as well as exercises. The lecture content is outlined in its introduction using the following items for each type of content:
- :books: Physics: equations, discretisation, implementation, solver, visualisation
- :computer: Code: technical, Julia, GitHub
- :construction: Exercises

The course will be taught in a hands-on fashion, putting emphasis on you writing code and completing exercises; lecturing will be kept at a minimum.

## Lectures

### Live lectures | Tuesdays 12h45-15h30
- In person lectures will take place in [HCI](http://www.mapsearch.ethz.ch/map/mapSearchPre.do?gebaeudeMap=HCI&geschossMap=E&raumMap=8&farbcode=c010&lang=en) [E8](http://www.rauminfo.ethz.ch/Rauminfo/grundrissplan.gif?gebaeude=HCI&geschoss=E&raumNr=8&lang=en).
- Online attendance will be possible on [Zoom](https://ethz.zoom.us/j/65687277265) (ETH Students only - Password _and password-less login_ available on [Moodle](https://moodle-app2.let.ethz.ch/course/view.php?id=18084)).
- **Exercise session** follow the lectures; they will not be broadcasted _(no online support will be provided during the exercise session)_.

### Office hours 
Schedule to be defined (on Element/Zoom or in-person)

## Discussion

We plan to use the [Element-chat (https://chat.ethz.ch/)](https://chat.ethz.ch/) as the main communication channel for the course, both between the teachers and the students, and hopefully also between students. We encourage ETH students to ask course, exercises and technical questions there.

Head to the [_Course chat space (Element)_ link on Moodle](https://moodle-app2.let.ethz.ch/course/view.php?id=18084) to get started with Element:
1. Select **Start Student-Chat**.
2. Login using your NETHZ credentials to start using the browser-based client.
3. Join the **_General_** and **_Helpdesk_** rooms _(you may see an error upon accessing the rooms - refreshing the app should solve the issue)._
4. Download the [Element Desktop/Mobile client](https://element.io/) for more comfortable access.

## Homework

[Homework](/homework) tasks will be announced after each week's lecture. The exercise session following the lecture will get you started.

Homework **due date will be Wednesday 23h59 CET** every following week (8 days) to allow for Q&A during the following in-class exercise session.

Homework assignments can be carried-out by groups of 2. However, **_note that every student has to hand in a personal version of the homework_**.

> ➡ Check out the [Homework](/homework) page for an overview on expected hand-in and deadlines.

Personal feedback and sample solution codes will be provided after submission deadline via a shared [Polybox](https://polyboxdoc.ethz.ch) folder. Make sure to register to the service and install the finder extension if possible.

### Submission
- Submission of scripts (weeks 1 & 2), GitHub commit hash (or SHA) (week 3 and onwards) or other documents happens on the course's [Moodle](https://moodle-app2.let.ethz.ch/course/view.php?id=18084).
- Actions and tasks related to GitHub will happen on your private course-related GitHub repository.

**Starting from lecture 3 and onwards**, homework script submission happens on GitHub:
1. Create a **private** GitHub repository named `pde-on-gpu-<lastname>`, where `<lastname>` has to be replaced by your last name. Select an `MIT License` and add a `README`.
2. Share this private repository on GitHub with the [exercise-bot (https://github.com/eth-vaw-glaciology-exercise-bot)](https://github.com/eth-vaw-glaciology-exercise-bot)
3. **For each homework submission**, you will:
    - create a new folder named `lectureX` (X $\in [3-...]$) to push the exercise codes into;
    - copy **the single git commit hash (or SHA) of the final push** and upload it on [Moodle](https://moodle-app2.let.ethz.ch/course/view.php?id=18084). It will serve to control the material was pushed on time.

\warn{Make sure to only include the `lectureX` folders and `README.md` in the GitHub repo you share with the exercise bot in order to keep the syncing as lightweight as possible.}

\note{Homework folders on GitHub should be Julia projects and thus contain a `Project.toml` file. The `Manifest.toml` file should be kept local. An automated way of doing so is to add it as entry to a `.gitignore` file in the root of your repo. Mac users may also add `.DS_Store` to their `.gitignore`. Codes could be placed in a `scripts/` folder. Output material to be displayed in the `README.md` could be placed in a `docs/` folder.}

### Feedback
After submission deadline, you will find relevant scripts in a shared Polybox folder. Information on how to access it is available on [Moodle](https://moodle-app2.let.ethz.ch/course/view.php?id=18084).

Personal feedback and points (not grades) for weekly homework exercises will be shared individually among participants using a private file or folder on Polybox.

## Project

Starting from lecture 7 (until lecture 9), homework contribute to the course's first project. The goal of this project is to have a multi-xPU thermal porous convection solver in 3D.

The exercises **in lecture 7** will serve as starting point for the first project:
1. Create a `project` directory at the root of your shared private `pde-on-gpu-<lastname>` repository.
2. Make sure to follow the basic repo structure (using `PkgTemplates.jl` to generate it) as described in [Lecture 7](/lecture7/#infos_about_projects)
3. During lectures 7,8,9, you will be asked to add material to this project folder as part of regular homework hand-in _which will serve as evaluation for the Part 2 (35% of the final grade)_ (see [Evaluation](#evaluation) section).

### Project hand-in checklist
The project submission deadline is set to **02.12.2022 - 23h59 CET** (see also [Homework](/homework)). The final GitHub SHA has to be added to [Moodle](https://moodle-app2.let.ethz.ch/course/view.php?id=18084) in the Lecture 9 section.

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
5. Share the final project private repository on GitHub with the [exercise-bot (https://github.com/eth-vaw-glaciology-exercise-bot)](https://github.com/eth-vaw-glaciology-exercise-bot)
6. Send and email to Ludovic (luraess@ethz.ch) and Ivan (iutkin@ethz.ch) by **Tuesday December 6, 2022**, with subject _**Final projects**_ including
    - your project mate
    - a brief description of your choice
    - a link to your final project GitHub repository
    - _anything else missing in this list_
7. Work on your final project, asking for help
    - in the Element _Helpdesk_ channel for general question
    - as **GitHub "issue"** for project specific questions
    - during class hours serving as helpdesk

### Final project submission
Submission deadline for the project is **December 23, 2022 -- 23h59 CET**.

Final submission timestamp is enforced upon tagging the v1.0.0 version release of your repository. See [GitHub docs](https://docs.github.com/en/repositories/releasing-projects-on-github/about-releases) for infos.

Also, add the last commit SHA to [Moodle](https://moodle-app2.let.ethz.ch/course/view.php?id=15755#section-10) as for the exercises.

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

Enrolled ETHZ students will have to hand in on [Moodle](https://moodle-app2.let.ethz.ch/course/view.php?id=18084) (& GitHub):
1. 5 (out of 6) weekly assignments (30% of the final grade) during the course's Part 1. _**Weekly coding exercises can be done alone or in groups of two**_.
2. A project during Part 2 (35% of the final grade). _**Projects submission includes codes in a git repository and an automatic generated documentation**_.
3. A final project during Part 3 (35% of the final grade). _**Final projects submission includes codes in a git repository and an automatic generated documentation**_.
