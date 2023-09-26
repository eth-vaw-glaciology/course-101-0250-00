md"""
## Exercise 4 - **Julia install and Git repo**
"""

md"""
The goal of this homework is to:
- finalise your local Julia install
- create a private git repo to upload your homework
"""

md"""
As final homework task for this second lecture, you will have to
1. Finalise your local Julia install
2. Create a private git repository on GitHub and share it only with the teaching staff

### Julia install
Ensure you have access to
- the latest version of Julia (>= v1.9)
- a fully functional REPL (command window)

You should be able to visualise scripts' output graphically when, e.g., plotting something:

```julia
using Plots
display(heatmap(rand(10,10)))
```

![random-noise](./figures/l2_random-noise.png)

### Git repository
Once you have your GitHub account ready (see lecture 2 [how-to](/lecture2/#a_brief_git_demo_session)), create a private repository you will _**share with the teaching staff only**_ to upload your weekly assignments (scripts):
1. Create a **private** GitHub repository named `pde-on-gpu-<moodleprofilename>`, where `<moodleprofilename>` has to be replaced by your name **as displayed on Moodle, lowercase, diacritics removed, spacing replaced with hyphens (-)**. For example, if your Moodle profile name is "Joël Désirée van der Linde" your repository should be named `pde-on-gpu-joel-desiree-van-der-linde`.
2. Select an `MIT License` and add a `README.md` file.
3. Share this private repository on GitHub with the [teaching-bot (https://github.com/teaching-bot)](https://github.com/teaching-bot).
4. **For each homework submission**, you will:
    - create a new folder named `lectureX` (X $\in [3-...]$) to push the exercise codes into (except for lecture 2 homework);
    - copy **the single git commit hash (or SHA) of the final push** and upload it on [Moodle](https://moodle-app2.let.ethz.ch/course/view.php?id=20175). It will serve to control the material was pushed on time.

👉 See [Logistics](/logistics/#submission) for details.

### GitHub task
For this week:

First an edit without a PR
- edit the `README.md` of your private repository (add one or two description sentences in there (to get familiar with the Markdown syntax).
- commit this to the `main` branch (i.e. no PR) and push

Second, an edit with a PR:
- create and switch to `homework-2` branch
- create a file `homework-2/just-a-test` with content `This is to make a PR"
- push and create a PR


Copy the commit hash (or SHA) and past it to [Moodle](https://moodle-app2.let.ethz.ch/course/view.php?id=18084) in the _git commit hash (SHA)_ activity as well as the link to the PR.
"""
