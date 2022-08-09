<!--
Add here global page variables to use throughout your website.
The website_* must be defined for the RSS to work
-->
@def website_title = "Solving partial differential equations in parallel on GPUs"
@def website_descr = "Website for the Julia GPU course"
<!-- @def website_url   = "https://eth-vaw-glaciology.github.io/course-101-0250-00/" -->
@def website_url   = "https://pde-on-gpu.vaw.ethz.ch/"

@def author = "ETHZ - VAW-GL"

@def mintoclevel = 1
@def maxtoclevel = 2

<!-- @def prepath = "course-101-0250-00" -->
@def prepath = ""
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