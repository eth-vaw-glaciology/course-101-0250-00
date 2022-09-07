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

Head to the [_Course chat space (Element)_ link on Moodle](https://moodle-app2.let.ethz.ch/mod/url/view.php?id=781163) to get started with Element:
1. Select **Start Student-Chat**.
2. Login using your NETHZ credentials to start using the browser-based client.
3. Join the **_General_** and **_Helpdesk_** rooms.
4. Download the [Element Desktop/Mobile client](https://element.io/) for more comfortable access.

## Homework

:construction: This section needs update

[Homework](/homework) tasks will be announced after each week's lecture. The exercise session following the lecture will get you started.

Homework **due date will be Thursday 23h59 CET** every following week (9 days) to allow for Q&A during the following in-class exercise session.

Homework assignments can be carried-out by groups of 2. However, **_note that every student has to hand in a version of the homework_**.

### Submission
- Submission of scripts (weeks 1 & 2), GitHub commit hash (or SHA) (week 3 and onwards) or other documents happens on the course's [Moodle](https://moodle-app2.let.ethz.ch/course/view.php?id=18084).
- Actions and tasks related to GitHub will happen on your private course-related GitHub repository.

**Starting from lecture 3 and onwards**, homework script submission happens on GitHub:
1. Create a private GitHub repository named `pde-on-gpu-<lastname>`, where `<lastname>` has to be replaced by your last name. Select an `MIT License` and add a `README`.
2. Share this private repository on GitHub with the teaching staff: [luraess](https://github.com/luraess), [utkinis](https://github.com/utkinis), [mauro3](https://github.com/mauro3), [omlins](https://github.com/omlins)
3. **For each homework submission**, you will:
    - create a new folder named `lectureX` (X $\in [4-...]$) to push the exercise codes into;
    - copy **the single git commit hash (or SHA) of the final push** and upload it on [Moodle](https://moodle-app2.let.ethz.ch/course/view.php?id=18084). It will serve to control the material was pushed on time.

> ➡ Check out the [Homework](/homework) page for an overview on expected hand-in and deadlines.

\note{Homework folders on GitHub should be Julia projects and thus contain a `Project.toml` file. The `Manifest.toml` file should be kept local. An automated way of doing so is to add it as entry to a `.gitignore` file in the root of your repo. Mac users may also add `.DS_Store` to their `.gitignore`. Codes could be placed in a `scripts/` folder. Output material to be displayed in the `README.md` could be placed in a `docs/` folder.}


## Evaluation
Enrolled ETHZ students will have to hand in on [Moodle](https://moodle-app2.let.ethz.ch/course/view.php?id=18084) (& GitHub):
1. 5 (out of 6) weekly assignments (30% of the final grade) during the course's Part 1. _**Weekly coding exercises can be done alone or in groups of two**_.
2. A project during Part 2 (35% of the final grade). _**Projects submission includes codes in a git repository and an automatic generated documentation**_.
3. A final project during Part 3 (35% of the final grade). _**Final projects submission includes codes in a git repository and an automatic generated documentation**_.
