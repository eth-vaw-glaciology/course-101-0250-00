<!--
Add here global page variables to use throughout your website.
The website_* must be defined for the RSS to work
-->
@def website_title = "Solving partial differential equations in parallel on GPUs"
@def website_descr = "Website for the Julia GPU course"
@def website_url   = "https://pde-on-gpu.vaw.ethz.ch/"
@def course_url    = "https://www.vorlesungen.ethz.ch/Vorlesungsverzeichnis/lerneinheit.view?semkez=2025W&ansicht=KATALOGDATEN&lerneinheitId=193496&lang=en"

@def author   = "ETHZ - VAW-GL"
@def year     = "2025"
@def semester = "Fall"

@def moodle_url     = "https://moodle-app2.let.ethz.ch/course/view.php?id=26390"
@def zoom_url       = "https://moodle-app2.let.ethz.ch/mod/zoom/view.php?id=1275857"
@def jupyterhub_url = "https://moodle-app2.let.ethz.ch/mod/lti/view.php?id=1275858"

@def mintoclevel = 1
@def maxtoclevel = 2

<!--
Add here files or directories that should be ignored by Franklin, otherwise
these files might be copied and, if markdown, processed by Franklin which
you might not want. Indicate directories by ending the name with a `/`.
-->
@def ignore = ["node_modules/", "franklin", "franklin.pub"]

<!--
Add here global latex commands to use throughout your
pages. It can be math commands but does not need to be.
For instance:
* \newcommand{\phrase}{This is a long phrase to copy.}
-->
\newcommand{\R}{\mathbb R}
\newcommand{\scal}[1]{\langle #1 \rangle}

\newcommand{\note}[1]{@@note @@title :bulb: Note@@ @@messg #1 @@ @@}
\newcommand{\warn}[1]{@@warning @@title ⚠️ Warning!@@ @@messg #1 @@ @@}
