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
Ensure you have access to latest version of Julia, access and a fully functional REPL (command window) and you can visualise script output graphically when, e.g., plotting something

```julia
using Plots
display(heatmap(rand(10,10)))
```

![random-noise](../assets/literate_figures/random-noise.png)

### Git repository
Once you have your GitHub account ready, create a private repository you will _**share with the teaching staff only**_ to upload your weekly assignments (scripts):
1. Create a private GitHub repository named `course-101-0250-00-<lastname>`, where `<lastname>` has to be replaced by your last name. Select an MIT License and add a README.
2. Share this private repository with the teaching staff on GitHub ([luraess](https://github.com/luraess), [mauro3](https://github.com/mauro3), [omlins](https://github.com/omlins))
3. **At each homework submission**, copy the git commit hash (or SHA) of the final push and upload it on [Moodle](https://moodle-app2.let.ethz.ch/course/view.php?id=15755). It will serve to control the material was pushed on time.

### GitHub task
For this week, edit the `README.md` of your private repository:
- Add one or two description sentences in there (to get familiar with the Markdown syntax).
- Then `commit` the change and `push` it.
- Copy the commit hash (or HSA) and past it to [Moodle](https://moodle-app2.let.ethz.ch/course/view.php?id=15755) in the _git commit hash (HSA)_ activity.
"""
