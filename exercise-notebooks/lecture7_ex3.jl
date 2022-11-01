md"""
## Exercise 3 - **CI and GitHub Actions**
"""

#md # 👉 See [Logistics](/logistics/#submission) for submission details.

md"""
The goal of this exercise is to:
- setup Continuous Integration with GitHub Actions
"""

md"""
### Tasks
1. Add CI setup to your `PorousConvection` project to run **one unit and one reference test** for both the 2D and 3D thermal porous convection scripts.
   - 👉 make sure that the reference test runs on a very small grid.  It should complete in less than, say, 5 seconds.
2. Follow/revisit the lecture and in particular look at the example at [https://github.com/eth-vaw-glaciology/course-101-0250-00-L6Testing-subfolder.jl](https://github.com/eth-vaw-glaciology/course-101-0250-00-L6Testing-subfolder.jl) to setup CI for a folder that is part of another Git repo (your `PorousConvection` folder is part of your `pde-on-gpu-<username>` git repo).
3. Push to GitHub and make sure the CI runs and passes
4. Add the CI-badge to the `README.md` file from your `PorousConvection` folder, right below the title (as it is commonly done).
"""

#md # \note{If your CI setup fails, check-out again the procedure at the top of the exercise section [here](#infos_about_projects).}
