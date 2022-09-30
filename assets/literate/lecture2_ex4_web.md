<!--This file was generated, do not modify it.-->
## Exercise 4 - **Julia install and Git repo**

The goal of this homework is to:
- finalise your local Julia install
- create a private git repo to upload your homework

As final homework task for this second lecture, you will have to
1. Finalise your local Julia install
2. Create a private git repository on GitHub and share it only with the teaching staff

### Julia install
Ensure you have access to
- the latest version of Julia (>= v1.8)
- a fully functional REPL (command window)

You should be able to visualise scripts' output graphically when, e.g., plotting something:

```julia
using Plots
display(heatmap(rand(10,10)))
```

![random-noise](../assets/literate_figures/l2_random-noise.png)

### Git repository
Once you have your GitHub account ready (see lecture 2 [how-to](/lecture2/#a_brief_git_demo_session)), create a private repository you will _**share with the teaching staff only**_ to upload your weekly assignments (scripts):
1. Create a **private** GitHub repository named `pde-on-gpu-<lastname>`, where `<lastname>` has to be replaced by your last name. Select an `MIT License` and add a `README`.
2. Share this private repository on GitHub with the [exercise-bot (https://github.com/eth-vaw-glaciology-exercise-bot)](https://github.com/eth-vaw-glaciology-exercise-bot)
3. **For each homework submission**, you will:
    - create a new folder named `lectureX` (X $\in [3-...]$) to push the exercise codes into;
    - copy **the single git commit hash (or SHA) of the final push** and upload it on [Moodle](https://moodle-app2.let.ethz.ch/course/view.php?id=18084). It will serve to control the material was pushed on time.

👉 See [Logistics](/logistics/#submission) for details.

### GitHub task
For this week, edit the `README.md` of your private repository:
- Add one or two description sentences in there (to get familiar with the Markdown syntax).
- Then `commit` the change and `push` it.
- Copy the commit hash (or SHA) and past it to [Moodle](https://moodle-app2.let.ethz.ch/course/view.php?id=18084) in the _git commit hash (SHA)_ activity.

