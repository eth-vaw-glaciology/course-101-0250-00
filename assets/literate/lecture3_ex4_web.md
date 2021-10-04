<!--This file was generated, do not modify it.-->
## Exercise 4 - **Seismic P-waves**

👉 See [Logistics](/logistics/#submission) for submission details.

The goal of this exercise is to:
- Implement 2D wave equation
- Record the signal on a synthetic seismic array
- Train visualisation

In this last exercise, you will implement a synthetic wave propagation solver, to resolve seismic pressure (P-)wave propagation in a sandstone. You will deploy an array of synthetic geophones and record the seismic signal.

Create a new Julia script `acoustic_2D_v4.jl` for this homework, starting from the code you developed for [exercise 2](#exercise_2_-_acoustic_waves_in_2d_-_v2).

![wave-ex4-sketch](../assets/literate_figures/wave_ex4_sketch.png)

### Task 1
Implement the following changes:
- Change the domain extend to $Lx=1000$ m, $Ly=500$ m (with origin located in the bottom left corner of the model)
- For sandstone, set the elastic moduli $K=40$ GPa and the density $ρ=2400$ Kg/m$^3$
- Define a Gaussian function for the source, with centre location $(xs, ys)$ at $xs = 200$ and at $50$ m below the surface. Use a standard deviation of $5$ m and an amplitude of $1$ Pa.
- Run the experiment for a total $ttot=0.2$ sec
- Set pressure values as `P[:,end] .= P[:,end-1]` in order to minimise boundary effects on the top boundary

You should obtain a similar output for your figure (try saving it as .png from within Julia)

![wave-ex4](../assets/literate_figures/wave_ex4.png)

### Task 2
In a second step,
- Add 5 monitoring station located at $y_{monit}$ ~$20$ m below the ground between $x=500$ and $900$ m, distant from each other by $100$ m.
- Record and store the pressure in each monitoring station throughout the entire simulation
- For the first station (located at $x=500$ m), find the arrival time for which the pressure > 0.02 Pa
- Knowing at which time the wave hit the first station, you can post-process and **report following (as formatted output in the REPL or on a figure)**:
  - First wave arrival time (in s) at station $xs=500$ m
  - Distance (`∆_dist`) the wave travelled
  - $x$-location of the seismic source

