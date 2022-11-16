md"""
## Exercise 2 - **Multi-xPU computing**
"""

#md # 👉 See [Logistics](/logistics/#submission) for submission details.

md"""
The goal of this exercise is to:
- Familiarise with distributed computing
- Combine [ImplicitGlobalGrid.jl](https://github.com/eth-cscs/ImplicitGlobalGrid.jl) and [ParallelStencil.jl](https://github.com/omlins/ParallelStencil.jl)
- Learn about GPU MPI on the way
"""

md"""
In this exercise, you will:
- Create a multi-xPU version of your the 2D xPU diffusion solver
- Keep it xPU compatible using `ParallelStencil.jl`
- Deploy it on multiple xPUs using `ImplicitGlobalGrid.jl`

Start by fetching the [`l8_diffusion_2D_perf_xpu.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/l8_scripts/) code from the `scripts/l8_scripts` folder and copy it to your `lectrue_8` folder.

Make a copy and rename it `diffusion_2D_perf_multixpu.jl`.

### Task 1

Follow the steps listed in the section from lecture 8 about [using `ImplicitGlobalGrid.jl`](#using_implicitglobalgridjl) to add multi-xPU support to the 2D diffusion code. 

The 5 steps you'll need to implement are summarised hereafter:
1. Initialise the implicit global grid
2. Use global coordinates to compute the initial condition
3. Update halo (and overlap communication with computation)
4. Finalise the global grid
5. Tune visualisation

Once the above steps are implemented, head to Piz Daint and configure either an `salloc` or prepare a `sbatch` script to access 4 nodes.

### Task 2

Run the single xPU `l8_diffusion_2D_perf_xpu.jl` code on a single CPU and single GPU (changing the `USE_GPU` flag accordingly) for following parameters
"""

## Physics
Lx, Ly  = 10.0, 10.0
D       = 1.0
ttot    = 1.0
## Numerics
nx, ny  = 126, 126
nout    = 20

md"""
and save output `C` data. Confirm that the difference between CPU and GPU implementation is negligible, reporting it in a new section of the `README.md` for this exercise 2 within the `lecture_8` folder in your shared private GitHub repo.

### Task 3

Then run the newly created `diffusion_2D_perf_multixpu.jl` script with following parameters on **4 MPI processes** having set `USE_GPU = true`: 
"""

## Physics
Lx, Ly  = 10.0, 10.0
D       = 1.0
ttot    = 1e0
## Numerics
nx, ny  = 64, 64 # number of grid points
nout    = 20
## Derived numerics
me, dims = init_global_grid(nx, ny, 1)  # Initialization of MPI and more...

md"""
Save the global `C_v` output array. Ensure its size matches the inner points of the single xPU produced output (`C[2:end-1,2:end-1]`) and then compare the results to the existing 2 outputs produced in Task 2

### Task 4

Now that we are confident the xPU and multi-xPU codes produce correct physical output, we will asses performance.

Use the code `diffusion_2D_perf_multixpu.jl` and make sure to deactivate visualisation, saving or any other operation that would save to disk or slow the code down.

**Strong scaling:** Using a single GPU, gather the effective memory throughput `T_eff` varying `nx, ny` as following
"""
 nx = ny = 16 * 2 .^ (1:10)

md"""
\warn{Make sur the code only spends about 1-2 seconds in the time loop, adapting `ttot` or `nt` accordingly.}

In a new figure you'll add to the `README.md`, report `T_eff` as function of `nx`, and include a short comment on what you see.

### Task 5

**Weak scaling:** Select the smallest `nx,ny` values from previous step (2.) for which you've gotten the best `T_eff`. Run now the same code using this optimal local resolution varying the number of MPI process as following `np = 1,4,16,25,64`.

\warn{Make sure the code only executes a couple of seconds each time otherwise we will run out of node hours for the rest of the course.}

In a new figure, report the execution time for the various runs **normalising them with the execution time of the single process run**. Comment in one sentence on what you see.

### Task 6

Finally, let's assess the impact of hiding communication behind computation achieved using the `@hide_communication` macro in the multi-xPU code.

Using the 64 MPI processes configuration, run the multi-xPU code changing the values of the tuple after `@hide_communication` such that
"""

@hide_communication (2,2)
@hide_communication (16,4)
@hide_communication (16,16)

md"""
Then, you should also run once the code commenting both `@hide_communication` and corresponding `end` statements. On a figure report the execution time as function of `[no-hidecomm, (2,2), (8,2), (16,4), (16,16)]` (note that the `(8,2)` case you should have from Task 4 and/or 5) making sure to **normalise it by the single process execution time** (from Task 5). Add a short comment related to your results.
"""


