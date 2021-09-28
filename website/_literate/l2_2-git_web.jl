#src # This is needed to make this run as normal Julia file
using Markdown #src

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
#nb # _Lecture 2_: Git
md"""
# A brief intro to Git

Git is a version control software, useful to
- keep track of your progress on code (and other files)
- to collaborate on code
- to distribute code, to onself (on other computers) and others
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
# Previous experience

You are familiar with git already:

![git-survey](../assets/literate_figures/survey-git-question.png)
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Questions:
- how often do you use git?
- who has git installed on their laptop?
- do you use: `commit`, `push`, `pull`, `clone`?
- do you use: `branch`, `merge`, `rebase`?
- github/gitlab etc?
"""

#src ###################################################################
#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
# A brief git demo session

Please follow along!

If you don't have git installed, head to https://achtzack01.ethz.ch and open a terminal.

- git setup:
  ```
  git config --global user.name "Your Name"
  git config --global user.email "youremail@yourdomain.com"
  ```
- make a repo
- add some files (`add`, `commit`)
- do some changes (`commit` some more)
- make a feature branch (`branch`, `diff`, `difftool`)
- merge branch (`merge`)
- tag (`tag`)
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
# Further reading

There are (too) many resources on the web...
- book: https://git-scm.com/book/en/v2
- videos: https://git-scm.com/doc
- cheat sheet (click on boxes) https://git-scm.com/doc
- get out of a git mess: http://justinhileman.info/article/git-pretty/git-pretty.png

## Other tools for git
There is plenty of software to interact with git, graphical, command line, etc.  Feel free to use those.

But we will only be able to help you with vanilla git.
"""

#src ###################################################################

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
# Getting started on GitHub (similar on Gitlab, or elsewhere)

Github and Gitlab are social coding websites
  - they host code
  - they facilitate for developers to interact
  - they provide infrastructure for software testing, deployment, etc

Note: ETH has a Gitlab instance which you can use with your NETHZ credentials
https://gitlab.ethz.ch/
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "fragment"}}
md"""
Question: who has a Github account?

Let's make one (because most of Julia development happens on Github)

https://github.com/ -> "Sign up"
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
# Github setup

Make such that you can push and pull without entering a password

![github-bar](../assets/literate_figures/github-bar.png)

- local: tell git to store credentials:
  `git config --global credential.helper cache`
- github.com:
  - "Settings" -> "Developer settings" -> "Personal access tokens" -> "Generate new token"
    - Give the token a description/name and select the scope of the token
    - I selected "repo only" to facilitate pull, push, clone, and commit actions
  - -> "Generate token" and copy it (keep that website open for now)
"""


#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
# Let's get our repo onto github

![github-bar](../assets/literate_figures/github-bar.png)

- create a repository on github.com: click the "+"
- local: follow setup given on website
- local: `git push`
  - here enter your username + the **token** generated before
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
# Work with other peoples code: fork

![github-bar](../assets/literate_figures/github-bar.png)

- fork a repository on github.com (top right)
"""

#nb # %% A slide [markdown] {"slideshow": {"slide_type": "slide"}}
md"""
# Git: questions?


![git-me](../assets/literate_figures/git-me.png)
"""
