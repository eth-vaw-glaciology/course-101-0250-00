# Course 1

**Welcome to ETH's course 101-0250-00L on solving partial differential equations (PDEs) in parallel on graphical processing untis (GPUs) with the Julia language.**

## Objective

In this first course, we will discuss:
- The Julia basics
- Visualisation
- ...


```julia
using Plots
```


```julia
# Generate a 2D array of random numbers
A = rand(10,10)

# Visualise the output
heatmap(A')
```




![svg](course1_files/course1_2_0.svg)

