<!--This file was generated, do not modify it.-->
## On-chip memory usage

We now want get a high-level overview on how we can control on-chip memory in order to reduce redundant main memory access.

In the essence, we want to store values that we need to access multiple times with a same thread or threadblock in on-chip memory, in order to avoid accessing them multiple times in main memory.

Let us first look at the different kinds of memory.

There is memory private to each thread ("local memory"), shared between thread blocks ("shared memory") and shared between all threads of the grid ("global memory" or "main memory").

![cuda_mem](../assets/literate_figures/l10_cuda_mem.png)

To use shared memory for our PDE solvers, we can use the strategy depicted in the following image:

![cuda_domain](../assets/literate_figures/l10_cuda_domain.png)

In this approach, we allocate a cell in shared memory per each thread of the block, **plus a halo on all sides**.

The threads at the boundaries of the block will read from there when doing finite differences.

As a result, we will need to read the data corresponding to a thread block (see image) only once to shared memory and then we can compute all the required finite differences reading only from there.

Making basic use of "local memory" is very simple: it is enough to define a variable inside a kernel and it will be allocated private to the each thread.

Scalars (and possibly small arrays) will be stored in registers if the kernel does not use too many resources (else it is stored in global memory as noted earlier).

This "control" of register usage becomes often particularly useful when each thread does not only compute the results for one cell but for multiple cells, e.g., adjacent in the last dimension.

In that case, the registers can store, e.g., intermediate results.

The following image shows the scenario where each thread computes the results for a column of cells in z dimension (this can be achieved by simply doing a loop over the z dimension):

![cuda_column](../assets/literate_figures/l10_cuda_column.png)

