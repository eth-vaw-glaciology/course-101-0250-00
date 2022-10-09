md"""
## Exercise 1 - **Implicit transient diffusion using dual timestepping**
"""

#md # 👉 See [Logistics](/logistics/#submission) for submission details.

md"""
The goal of this exercise is to:
- Solidify the understanding of the pseudo-transient method
- Implement transient diffusion solver with implicit time integration using pseudo-transient method
- Grasp the difference between physical time stepping and pseudo-transient iterations
"""

md"""
In this first exercise, you will modify the diffusion-reaction example to model transient diffusion, but this time including not just the pseudo-time derivative $\partial/\partial\tau$, but also the physical time derivative $\partial/\partial t$.

Recall the transient diffusion equation:

$$
D\frac{\partial^2 C}{\partial x^2} = \frac{\partial C}{\partial t}
$$

Let's discretise only the time derivative using the first-order Euler integration rule:
$$
\frac{\partial C}{\partial t} \approx \frac{C - C_\mathrm{old}}{\mathrm{d}t}
$$
where $\mathrm{d}t$ is the physical time step, and $C_\mathrm{old}$ is the concentration at the previous time step. If we discretise the spatial derivatives is a usual way and update $C$ using the explicit update rule, the maximum value for the time step is restricted by the stability criteria, and is proportional to the grid spacing $\mathrm{d}x$. However, if we consider the $C$ to be from the implicit layer of the time integration scheme, we don't have that restriction anymore and are free to use any time step. The downside is that in this case we have to solve the linear system to get the values at the next time step.

A close look at the equation with the discretised time derivative reveals that this equation is mathematically identical to the diffusion-reaction equation that we already learned how to solve! The value for the concentration at the old time step $C_\mathrm{old}$ and the physical time step $\mathrm{d}t$ correspond to the equilibrium concentration $C_\mathrm{eq}$ and the time scale of reaction, respectively.

At each physical time step the implicit problem could be solved using the PT method. Thus, there are present time derivatives both in physical time and in pseudo-time. This approach is therefore called _the dual-time method_. The code structure would include the two nested loops, one for the physical time and one for the pseudo-transient iterations:

```julia
anim = @animate for it = 1:nt
    C_old .= C
    iter = 1; err = 2ϵtol; iter_evo = Float64[]; err_evo = []
    while err >= ϵtol && iter <= maxiter
        ...
        iter += 1
    end
    # visualisation
    ...
end
gif(anim,"anim.gif";fps=2)
```

👉 Download the `l3_steady_diffusion_reaction_1D.jl` script [here](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/) if needed (available after the course).
"""

md"""
### Getting started
1. Create a new folder `lecture3` in your private GitHub repository.
2. Add a `README.md` to that folder.
3. Add a copy of the `l3_steady_diffusion_reaction_1D.jl` script we did in class to your exercise folder and rename it `implicit_diffusion_1D.jl`.
4. Modify that script so that it includes the physical time loop and performs the numerical experiment as follows.
"""

md"""
### Task 1
As a first task, rename the `C_eq` to `C_old` and `ξ` to `dt`. Make `C_old` an array and initialise it with copy of `C`. Set the `da` number equal to `da = 1000.0`. Add the new parameter `nt = 10` indicating the number of physical time steps. Wrap the iteration loop in the outer `for`-loop to make physical time steps. Move the visualisation outside from the iteration loop, so that the plots are only updated once per physical timestep (keeping error checking for iterations).
"""

md"""
### Task 2
Perform the numerical experiment using the developed code. Report your results in a 2-panel gif, plotting a) the spatial distribution of concentration `C` after `nt=10` time steps, on top of the plot of the initial concentration distribution, and b) the error as function of iteration/nx. Include the gif in the `README.md` and provide one or two sentence of description.
"""

#nb # > 💡 hint: Use the `@animate` macro as in the provided code snippet to realise a gif of your simulation results. Use `![fig_name](./<relative-path>/my_fig.png)` to insert a figure or animation in the `README.md`.
#md # \note{Use the `@animate` macro as in the provided code snippet to realise a gif of your simulation results. Use `![fig_name](./<relative-path>/my_fig.png)` to insert a figure or animation in the `README.md`.}


