<!--This file was generated, do not modify it.-->
## Exercise 3 - **Cauchy-Navier elastic waves**

👉 See [Logistics](/logistics/#submission) for submission details.

The goal of this exercise is to:
-

### Getting started

### Task 1 - adding shear stresses
Start by making a new duplicate of the current script, named `acoustic_2D_elast3.jl`. In this new script, add
Repeat this for the $xy$ component:
```julia
qVxy  .= qVxy .+ ??
```

### Task 2 - rearranging the code and renaming fluxes to stress

