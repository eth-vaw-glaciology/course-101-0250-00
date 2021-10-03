<!--This file was generated, do not modify it.-->
## Exercise 3 - **Car travel in 2 dimensions**

👉 [Download the notebook to get started with this exercise!](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/exercise-notebooks/notebooks/lecture1_ex3.ipynb)

The goal of this exercise is to familiarise with:
- code structure `# Physics, # Numerics, # Time loop, # Visualisation`
- array initialisation
- `for` loop
- update rule
- `if` condition
- 2 spatial dimensions

Based on the experience you acquired solving the [Exercise 2](#exercise_2_-_car_travel) we can now consider a car moving within a 2-dimensional space. The car still travels at speed $V=113$ km/h, but now in North-East or North-West direction. The car's displacement in the West-East directions ($x$-axis) is limited to $L=200$ km. The speed in the North direction is constant remains constant.

Starting from the 1D code done in [Exercise 2](#exercise_2_-_car_travel), work towards adding the second spatial dimension. Now, the car's position $(x,y)$ as function of time $t$ has two components.

\note{- split velocity magnitude $V$ into $x$ and $y$ component
- use `sind()` or `cosd()` functions if passing the angle in _deg_ instead of _rad_
- use two vectors or an array to store the car's coordinates
- define the y-axis extend in the plot `ylims=(0, ttot*Vy)`}

### Question 1

Visualise graphically the trajectory of the travelling car for a simulation with time step parameter defined as `dt = 0.1`.

