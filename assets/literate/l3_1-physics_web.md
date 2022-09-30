<!--This file was generated, do not modify it.-->
# Solving elliptic PDEs

### The goal of this lecture 3 is to familiarise (or refresh) with:
- The damped wave equation
- Spectral analysis of linear PDEs
- Pseudo-transient method for solving elliptic PDEs
- Spatial discretisation: 1D and 2D

In the previous lecture, we established that the solution to the elliptic PDE could be obtained through integrating in time a corresponding parabolic PDE:

$$
\frac{\partial C}{\partial t} - \frac{\partial^2 C}{\partial x^2} = 0
$$

and discussed the limitation of this approach, for numerical modelling, i.e., the quadratic dependence of the number of time steps on the number of grid points in spatial discretisation.

~~~
<center>
  <video width="80%" autoplay loop controls src="../assets/literate_figures/l2_diffusion_1D_steady_state.mp4"/>
</center>
~~~

## Accelerating elliptic solver convergence: intuition

In this lecture, we'll improve the convergence rate of the elliptic solver, and consider the generalisation to higher dimensions

Let's recall the stability conditions for diffusion and acoustic wave propagation:

```julia
dt = dx^2/dc/2      # diffusion
dt = dx/sqrt(1/β/ρ) # acoustic wave propagation
```

We can see that the acceptable time step for an acoustic problem is proportional to the grid spacing `dx`, and not `dx^2` as for the diffusion.

The number of time steps required for the wave to propagate through the domain is only proportional to the number of grid points `nx`.

Can we use that information to reduce the time required for the elliptic solver to converge?
In the solution to the wave equation, the waves do not attenuate with time: _there is no steady state!_

~~~
<center>
  <video width="80%" autoplay loop controls src="../assets/literate_figures/l2_acoustic_1D.mp4"/>
</center>
~~~

## Damped wave equation

Let's add diffusive properties to the wave equation by simply combining the physics:

\begin{align}
\rho\frac{\partial V_x}{\partial t}                 &= -\frac{\partial P}{\partial x} \\[10pt]
\beta\frac{\partial P}{\partial t} + \frac{P}{\eta} &= -\frac{\partial V_x}{\partial x}
\end{align}

Note the addition of the new term $\frac{Pr}{\eta}$ to the left-hand side of the mass balance equation, which could be interpreted physically as accounting for the bulk viscosity of the gas.

Equvalently, we could add the time derivative to the diffusion equation

\begin{align}
\rho\frac{\partial q}{\partial t} + \frac{q}{D} &= -\frac{\partial C}{\partial x} \\[10pt]
\frac{\partial C}{\partial t}                   &= -\frac{\partial q}{\partial x}
\end{align}

In that case, the new term would be $\rho\frac{\partial q}{\partial t}$, which could be interpreted physically as adding the inertia to the momentum equation for diffusive flux.

Note that in 1D the both modifications are equivalent up to renaming the variables. The conceptual difference is that in the former case we add new terms to the vector quantity (diffusive flux $q$), and in the latter case we modify the equation governing the evolution of the scalar quantity (pressure $P$).

Let's eliminate $V_x$ and $q$ in both systems to get one governing equation for $P$ and $C$, respectively:

\begin{align}
\beta\frac{\partial^2 P}{\partial t^2} + \frac{1}{\eta}\frac{\partial P}{\partial t} &= \frac{1}{\rho}\frac{\partial^2 P}{\partial x^2} \\[10pt]
\rho\frac{\partial^2 C}{\partial t^2} + \frac{1}{D}\frac{\partial C}{\partial t}     &= \frac{\partial^2 C}{\partial x^2}
\end{align}

We refer to such equations as the _damped wave equations_. They combine wave propagation with diffusion, which manifests as wave attenuation, or decay. The damped wave equation is a hyperbolic PDE.

### Implementing the damped wave equation

In the following, we'll use the damped wave equation for concentration $C$ obtained by augmenting the diffusion equation with density $\rho$.

Starting from the existing code implementing time-dependent diffusion, let's add the intertial term $\rho\frac{\partial q}{\partial t}$.

First step is to add the new physical parameter $\rho$ to the `# physics` section:

```julia
# physics
...
ρ   = 20.0
```

And to change the initial conditions to have more interesting time evolution:

```julia
# array initialisation
C    = @. exp(-(xc-lx/4)^2); C_i = copy(C); C[1] = 1
```

Then we modify the time loop to incorporate the new physics:

```julia
for it = 1:nt
    #qx         .-= ...
    C[2:end-1] .-= dt.*diff(qx)./dx
    ...
end
```

👉 Your turn. Try to add the intertial term.

> Hint: There are two ways of adding the intertial term into the update rule.
> - We could either take the known flux `q` in `q/dc` from the previous time step (explicit time integration), or the unknown flux from the next time step (implicit time integration).
> - Could we treat the flux implicitly without having to solve the linear system?
> - What are the benefits of the implicit time integration compared to the explicit one?

If the implementation is correct, we should see this:

~~~
<center>
  <video width="80%" autoplay loop controls src="../assets/literate_figures/l3_damped_diffusion_1D.mp4"/>
</center>
~~~

The waves decay, now there is a steady state! 🎉 The time it takes to converge, however, doesn't seem to improve...

Now we solve the hyperbolic PDE, and with the implicit flux term treatment, the time step should be now proportional to the grid spacing `dx` instead of `dx^2`. Looking at the damped wave equation for $C$, and recalling the stability condition for wave propagation, we modify the time step, reduce the total number of time steps, and increase the frequency of plotting calls:

```julia
# numerics
...
nvis = 5
# derived numerics
...
dt   = dx/sqrt(1/ρ)
nt   = 5nx
```

Re-run the simulation and see the results:

~~~
<center>
  <video width="80%" autoplay loop controls src="../assets/literate_figures/l3_damped_diffusion_better_1D.mp4"/>
</center>
~~~

Now, this is much better! We observe that in less time steps, we get a much faster convergence. However, we introduced the new parameter, $\rho$. Does the solution depend on the value of $\rho$?

## Problem of finding the iteration parameters

👉 Try changing the new parameter `ρ`, increase and decrease it. What happens to the solution?

We noticed that depending on the value of the parameter `ρ`, the convergence to steady-state can be faster or slower. If `ρ` is too small, the process becomes diffusion-dominated, and we're back to the non-accelerated version. If `ρ` is too large, waves decay too slow.

If the parameter `ρ` has optimal value, the convergence to steady-state could be achieved in the number of time steps proportional to the number of grid points `nx` and not `nx^2` as for the parabolic PDE.

### Historical perspective

The idea of accelerating the convergence by increasing the order of PDE dates back to the work by [Frankel (1950)](https://doi.org/10.2307/2002770) where he studied the convergence rates of different iterative methods. Frankel noted the analogy between the iteration process and transient physics. In his work, the accelerated method was called the _second-order Richardson method_

In this course, we call this and any method that builds upon the analogy to transient physics... the _pseudo-transient_ method.

Using this analogy proves useful when studying multi-physics and nonlinear processes. The pseudo-transient method isn't restricted to solving the Poisson problems, but can be applied to a wide range of problems that are modeled with PDEs.

## Pseudo-transient method

In a pseudo-transient method, we are interested only in a steady-state distributions of the unknown field variables such as concentration, temperature, etc.

We consider time steps as iterations in a numerical method. Therefore, we replace the time $t$ in the equations with _pseudo-time_ $\tau$, and a time step `it` with iteration counter `iter`. When a pseudo-transient method converges, all the pseudo-time derivatives $\partial/\partial\tau$, $\partial^2/\partial\tau^2$ etc., vanish.

We should be careful when introducing the new pseudo-physical terms into the governing equations. We need to make sure that when iterations converge, i.e., if the pseudo-time derivatives are set to 0, the system of equations is identical to the original steady-state formulation.

For example, consider the damped acoustic problem that we introduced in the beggining:

\begin{align}
\rho\frac{\partial V_x}{\partial\tau}                 &= -\frac{\partial P}{\partial x} \\[10pt]
\beta\frac{\partial P}{\partial\tau} + \frac{P}{\eta} &= -\frac{\partial V_x}{\partial x}
\end{align}

At the steady-state, the second equation reads:

$$
\frac{P}{\eta} = -\frac{\partial V_x}{\partial x}
$$

The velocity divergence is proportional to the pressure. If we wanted to solve the incompressible problem (i.e. the velocty divergence = 0), and were interested in the velocity distribution, this approach would lead to incorrect results. If we only want to solve the Laplace problem $\partial^2 P/\partial x^2 = 0$, we could consider $V_x$ purely as a numerical variable.

In other words: only add those new terms to the governing equations that vanish when the iterations converge!

## Dispersion analysis of the PDEs

We don't want to guess the optimal parameter values for every problem.
For linear problems with constant coefficients, there is a way to get an exact optimal value for any combination of phyisics and boundary conditions. Analytics is hard, so we'll consider only the simplest elliptic problem with constant values at boundaries:

Let's try this value:

```julia
ρ    = (lx/(dc*2π))^2
```

