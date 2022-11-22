<!--This file was generated, do not modify it.-->
# GPU computing and performance assessment

### The goal of this lecture 10 is to:

- learn how to use shared memory (on-chip) to avoid main memory accesses and communicate between threads; and
- learn how to control registers for storing intermediate results on-chip.

## Recap on scientific applications' performance

We will start with a brief recap on the peak performance of current hardware and on performance evaluation of iterative stencil-based PDE solvers.

The performance of most scientific applications nowadays is bound by memory access speed (*memory-bound*) rather than by the speed computations can be done (*compute-bound*).

The reason is that current GPUs (and CPUs) can do many more computations in a given amount of time than they can access numbers from main memory.

This situation is the result of a much faster increase of computation speed with respect to memory access speed over the last decades, until we hit the "memory wall" at the beginning of the century:

![flop_to_memaccess_ratio](../assets/literate_figures/l10_flop_to_memaccess_ratio.png)
*Source: John McCalpin, Texas Advanced Computing Center (modified)*
\note{The position of the memory wall is to be considered very approximative.}

This imbalance can be quantified by dividing the computation peak performance [GFLOP/s] by the memory access peak performance [GB/s] and multiplied by the size of a number in Bytes (for simplicity, theoretical peak performance values as specified by the vendors can be used). For example for the Tesla P100 GPU, it is:

$$ \frac{5300 ~\mathrm{[GFlop/s]}}{732 ~\mathrm{[GB/s]}}~×~8 = 58 $$

(here computed with double precision values taken from [the vendor's product specification sheet](https://www.nvidia.com/content/dam/en-zz/Solutions/Data-Center/tesla-p100/pdf/nvidia-tesla-p100-PCIe-datasheet.pdf)).

So we can do 58 floating point operations per number read from main memory or written to it.

As a consequence, we can consider **floating point operations be "for free"** when we work in the memory-bounded regime as in this lecture.

Naturally, when realizing that our PDE solvers' are memory-bound, we start to analyze the memory throughput.

In lecture 6, we have though seen that the *total memory throughput* is often not a good metric to evaluate the optimality of an implementation.

As a result, we defined the *effective memory throughput*, $T_\mathrm{eff}$, metric for iterative stencil-based PDE solvers.

The effective memory access $A_\mathrm{eff}$ [GB]
Sum of:
- twice the memory footprint of the unknown fields, $D_\mathrm{u}$, (fields that depend on their own history and that need to be updated every iteration)
- known fields, $D_\mathrm{k}$, that do not change every iteration.

The effective memory access divided by the execution time per iteration, $t_\mathrm{it}$ [sec], defines the effective memory throughput, $T_\mathrm{eff}$ [GB/s]:

$$ A_\mathrm{eff} = 2~D_\mathrm{u} + D_\mathrm{k} $$

$$ T_\mathrm{eff} = \frac{A_\mathrm{eff}}{t_\mathrm{it}} $$

The upper bound of $T_\mathrm{eff}$ is $T_\mathrm{peak}$ as measured, e.g., by [McCalpin, 1995](https://www.researchgate.net/publication/51992086_Memory_bandwidth_and_machine_balance_in_high_performance_computers) for CPUs or a GPU analogue.
Defining the $T_\mathrm{eff}$ metric, we assume that:
1. we evaluate an iterative stencil-based solver,
2. the problem size is much larger than the cache sizes and
3. the usage of time blocking is not feasible or advantageous (reasonable for real-world applications).

\note{Fields within the effective memory access that do not depend on their own history; such fields can be re-computed on the fly or stored on-chip.}

