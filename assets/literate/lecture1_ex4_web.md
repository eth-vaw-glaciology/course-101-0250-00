<!--This file was generated, do not modify it.-->
## Exercise 4 _(optional)_ - **Orbital around a centre of mass**

👉 [Download the notebook to get started with this exercise!](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/exercise-notebooks/notebooks/lecture1_ex4.ipynb)

\warn{Write a monolithic Julia script to solve this exercise in a Jupyter notebook and hand it in on Moodle ([more](/homework)).}

The goal of this exercise is to consolidate:
- code structure `# Physics, # Numerics, # Time loop, # Visualisation`
- physics implementation
- update rule

The goal of this exercise is to reproduce an orbital around a fixed centre of mass, which is also the origin of the coordinate system (e.g. Earth - Sun). To solve this problem, you will have to know about the definition of velocity, Newton's second law and universal gravitation's law:
$$
\frac{dr_i}{dt}=v_i \\[10pt]
\frac{dv_i}{dt}=\frac{F_i}{m} \\[10pt]
F_i = -G\frac{mM}{|r_i|^2}\frac{r_i}{|r_i|}~,
$$
where $r_i$ is the position vector, $v_i$ the velocity vector, $F_i$ the force vector, $G$ is the gravitational constant, $m$ is the mass of the orbiting object, $M$ is the mass of the centre of mass and $|r_i|$ is the norm of the position vector.

---

The sample code you can use to get started looks like:

````julia:ex1
using Plots

@views function orbital()
    # Physics
    G    = 1.0
    # TODO - add physics input
    tt   = 6.0
    # Numerics
    dt   = 0.05
    # Initial conditions
    xpos = ??
    ypos = ??
    # TODO - add further initial conditions
    # Time loop
    for it = 1:nt
        # TODO - Add physics equations
        # Visualisation
        display(scatter!([xpos], [ypos], title="$it",
                         aspect_ratio=1, markersize=5, markercolor=:blue, framestyle=:box,
                         legend=:none, xlims=(-1.1, 1.1), ylims=(-1.1, 1.1)))
    end
    return
end

orbital()
````

### Question 1

For a safe start, set all physical parameters $(G, m, M)$ equal to 1, and use as initial conditions $x_0=0$ and $y_0=1$, and $v_x=1$ and $v_y=0$. You should obtain a circular orbital.

Report the last $(x,y)$ position of the Earth for a total time of `tt=6.0` with a time step `dt=0.05`.

\note{- $r_i=[x,y]$
- $|r_i|=\sqrt{x^2 + y^2}$
- $r_i/|r_i|$ stands for the unity vector (of length 1) pointing from $m$ towards $M$}

### Question 2

Head to e.g. Wikipedia and look up for approximate of real values and asses whether the Earth indeed needs ~365 days to achieve one rotation around the Sun.

