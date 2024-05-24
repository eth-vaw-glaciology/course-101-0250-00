md"""
## Exercise 3 - **Advanced data transfer optimisations (part 2)**
"""

#md # 👉 See [Logistics](/logistics/#submission) for submission details.

md"""
The goal of this exercise is to:
- learn how to control registers for storing intermediate results on-chip;
- learn how to use shared memory (on-chip) to communicate between threads.

Prerequisites:
- the introduction notebook *Benchmarking memory copy and establishing peak memory access performance* ([`l6_1-gpu-memcopy.ipynb`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/slide-notebooks/notebooks/l6_1-gpu-memcopy.ipynb))
- the *Data transfer optimisation notebook* ([`lecture6_ex1.ipynb`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/exercise-notebooks/notebooks/lecture6_ex1.ipynb))
- the second *Data transfer optimisation notebook* (Exercise 2 [`lecture10_ex2.ipynb`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/exercise-notebooks/notebooks/lecture10_ex2.ipynb))

[*This content is distributed under MIT licence. Authors: S. Omlin (CSCS), L. Räss (ETHZ).*](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/LICENSE.md)
"""

md"""
### Getting started

👉 Download the [`lecture10_ex3.ipynb`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/exercise-notebooks/notebooks/lecture10_ex3.ipynb) notebook and edit it.
"""

md"""
We will again use the packages `CUDA`, `BenchmarkTools` and `Plots` to create a little performance laboratory:
"""
] activate .
#-
] instantiate

#-

#src #using IJulia
using CUDA
using BenchmarkTools
using Plots

md"""
In the previous notebook ([`lecture10_ex2.ipynb`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/exercise-notebooks/notebooks/lecture10_ex2.ipynb)), you learned how to explicitly control part of the the on-chip memory usage, using so called "shared memory". We will learn now how to control a second kind of fast memory on-chip: registers. To this purpose we will implement the `cumsum!` function on GPU - for the sake of simplicity, we will only write it for 3-D arrays.

Here is the documentation of the function `cumsum!`
```julia-repl
help?> CUDA.cumsum!
  cumsum!(B, A; dims::Integer)

  Cumulative sum of A along the dimension dims, storing the result in B. See
  also cumsum.
```

And here is a small example of how cumsum! works for 3-D arrays:
"""
A = CUDA.ones(4,4,4)
B = CUDA.zeros(4,4,4)
cumsum!(B, A; dims=1)
cumsum!(B, A; dims=2)
cumsum!(B, A; dims=3)

md"""
For benchmarking activities, we will allocate again large arrays, matching closely the number of grid points of the array size found best in the introduction notebook (you can modify the value if it is not right for you):
"""
nx = ny = nz = 512
A = CUDA.rand(Float64, nx, ny, nz);
B = CUDA.zeros(Float64, nx, ny, nz);

md"""
Moreover, we preallocate also an array to store reference results obtained from `CUDA.cumsum!` for verification.
"""
B_ref = CUDA.zeros(Float64, nx, ny, nz);

md"""
Now, we are set up to get started.

If we only consider main memory access, then the `cumsum!` will ideally need to read one array (`A`) and write one array (`B`). No other main memory access should be required. Let us therefore create an ad hoc adaption of the effective memory throughput metric for iterative PDE solvers (presented in the second notebook) to this problem. We will call the metric `T_eff_cs` and compute it as follows:
`T_eff_cs = 2*1/1e9*nx*ny*nz*sizeof(Float64)/t_it`

The upper bound of `T_eff_cs` is given by the maximum throughput achievable when copying exactly one aray to another. For this specific case, you might have measured in our benchmarks in the introduction notebook a slightly less good performance (measured 550 GB/s with the Tesla P100 GPU) then what we established as `T_peak`. Thus, we will consider here this measured value to be the upper bound of `T_eff_cs`.

We will now adapt the corresponding 2-D memory copy kernel in the most straightforward way to work for 3-D arrays. Then, we will modify this memory copy code in little steps until we have a well performing `cumsum!` GPU function.

Here is the adapted memory copy kernel from the introduction notebook and the `T_tot` we achieve with it (for the first two dimensions, we use again the thread/block configuration that we found best in the introduction notebook and we use one thread in the third dimension; you can modify the values if it is not right for you):
"""

#nb # > 💡 note: The usage of the variables `A` and `B` is reversed in comparison with the previous notebooks in order to match the documentation of cumsum!.
#md # \note{The usage of the variables `A` and `B` is reversed in comparison with the previous notebooks in order to match the documentation of cumsum!.}

function memcopy!(B, A)
    ix = (blockIdx().x-1) * blockDim().x + threadIdx().x
    iy = (blockIdx().y-1) * blockDim().y + threadIdx().y
    iz = (blockIdx().z-1) * blockDim().z + threadIdx().z
    @inbounds B[ix,iy,iz] = A[ix,iy,iz]
    return nothing
end

#-

threads = (32, 8, 1)
blocks  = nx.÷threads
t_it = @belapsed begin @cuda blocks=$blocks threads=$threads memcopy!($B, $A); synchronize() end
T_tot = 2*1/1e9*nx*ny*nz*sizeof(Float64)/t_it

md"""
Let us first implement the cummulative sum over the third dimension (index `iz`). The first step is to read in A (and write B) in a way that will later allow to easily do the required cumsums, which is an inherently serial operation. However, we want to try to avoid a serious degradation of the memory throughput when doing so.
"""

md"""
### Task 1 (grid-stride loops)

Modify the above `memcopy!` kernel to read in A and write B in a serial manner with respect to the third dimension (index `iz`), i.e., with parallelization only over the first two dimensions (index `ix` and `iy`). Launch the kernel with the same thread configuration as above and adapt the the block configuration for the third dimension correctly. Verify the correctness of your kernel. Then, compute `T_tot` and explain the measured performance.
"""
#nb # > 💡 Hint: you need to launch the kernel with only one thread and one block in the third dimension and, inside the kernel, do a loop over the third dimension. Use `iz` as loop index as it will replace the previous `iz` computed from the thread location in the grid.
#nb # >
#nb # > 💡 Note: The operator `≈` allows to check if two arrays contain the same values (within a tolerance). Use this to verify your memory copy kernel.
#md # \note{You need to launch the kernel with only one thread and one block in the third dimension and, inside the kernel, do a loop over the third dimension. Use `iz` as loop index as it will replace the previous `iz` computed from the thread location in the grid.}
#md # \note{The operator `≈` allows to check if two arrays contain the same values (within a tolerance). Use this to verify your memory copy kernel.}

#-
function memcopy!(B, A)
    ix = (blockIdx().x-1) * blockDim().x + threadIdx().x
    iy = (blockIdx().y-1) * blockDim().y + threadIdx().y
    for iz = 1:size(A,3)
        @inbounds B[ix,iy,iz] = A[ix,iy,iz]
    end
    return nothing
end

threads = (32, 8, 1)
blocks  = (nx÷threads[1], ny÷threads[2], 1)
#-
## Verification
B .= 0.0;
@cuda blocks=blocks threads=threads memcopy!(B, A); synchronize()
B ≈ A
#-
## Performance
t_it = @belapsed begin @cuda blocks=$blocks threads=$threads memcopy!($B, $A); synchronize() end
T_tot = 2*1/1e9*nx*ny*nz*sizeof(Float64)/t_it

md"""
Great! You just implemented a so called [grid-stride loop](https://developer.nvidia.com/blog/cuda-pro-tip-write-flexible-kernels-grid-stride-loops/). It exhibits a good memory access pattern and it allows to easily reuse, e.g., intermediate results from previous iterations in the loop. You probably observe a `T_tot` that is a bit below the one measured in the previous experiment (measured 520 GB/s with the Tesla P100 GPU). There is certainly room to improve this memory copy kernel a bit, but we will consider it sufficient in order to continue with this exercise.
"""

md"""
### Task 2 (controlling registers)

Write a kernel `cumsum_dim3!` which computes the cumulative sum over the 3rd dimension of a 3-D array. To this purpose modify the memory copy kernel from Task 1. Verify the correctness of your kernel against `CUDA.cumsum!`. Then, compute `T_eff_cs` as defined above, explain the measured performance and compare it to the one obtained with the generic `CUDA.cumsum!`.
"""
#nb # > 💡 Hint: define a variable `cumsum_iz` before the loop and initialize it to 0.0 in order to cumulate the sum.
#nb # >
#nb # > 💡 Note: The operator `≈` allows to check if two arrays contain the same values (within a tolerance). Use this to verify your results against `CUDA.cumsum!` (remember that for the verification, we already preallocated an array `B_ref` at the beginning, which you can use now).
#md # \note{Define a variable `cumsum_iz` before the loop and initialize it to 0.0 in order to cumulate the sum.}
#md # \note{The operator `≈` allows to check if two arrays contain the same values (within a tolerance). Use this to verify your results against `CUDA.cumsum!` (remember that for the verification, we already preallocated an array `B_ref` at the beginning, which you can use now).}

#-
function cumsum_dim3!(B, A)
    ix = (blockIdx().x-1) * blockDim().x + threadIdx().x
    iy = (blockIdx().y-1) * blockDim().y + threadIdx().y
    cumsum_iz = 0.0
    for iz = 1:size(A,3)
        @inbounds cumsum_iz  += A[ix,iy,iz]
        @inbounds B[ix,iy,iz] = cumsum_iz
    end
    return nothing
end

## Verification
@cuda blocks=blocks threads=threads cumsum_dim3!(B, A); synchronize()
CUDA.cumsum!(B_ref, A; dims=3);
B ≈ B_ref
#-
## Performance
t_it = @belapsed begin @cuda blocks=$blocks threads=$threads cumsum_dim3!($B, $A); synchronize() end
T_eff_cs = 2*1/1e9*nx*ny*nz*sizeof(Float64)/t_it
#-
t_it = @belapsed begin CUDA.cumsum!($B, $A; dims=3); synchronize() end
T_eff_cs = 2*1/1e9*nx*ny*nz*sizeof(Float64)/t_it

md"""
You should observe no significant difference between `T_eff_cs` measured here and `T_tot` computed in Task 1 (measured 520 GB/s with the Tesla P100 GPU). In fact, scalar variables defined in a kernel, like `cumsum_iz`, will be stored in registers as long as there are enough available (if not, then so called [register spilling](https://developer.download.nvidia.com/CUDA/training/register_spilling.pdf) to main memory takes place). As access to register is extremely fast, the summation added in this Task did certainly not reduce the measured performance. It is, once again, the memory copy speed that completely determines the performance of the kernel, because we have successfully controlled the use of registers!

We will now implement the cummulative sum over the 2nd dimension (index `iy`). As for the previous implementation, the first step is to read in A (and write B) in a way that will later allow to easily do the required cumsums without exhibiting significant memory throughput degradation.
"""

md"""
### Task 3 (kernel loops)

Modify the `memcopy!` kernel given in the beginning to read in A and write B in a serial manner with respect to the second dimension (index `iy`), i.e., with parallelization only over the first and the last dimensions (index `ix` and `iz`). Launch the kernel with the same amount of threads as in Task 1, however, place them all in the first dimension (i.e. use one thread in the second and third dimensions); adapt the the block configuration correctly. Verify the correctness of your kernel. Then, compute `T_tot` and explain the measured performance.
"""
#-
function memcopy!(B, A)
    ix = (blockIdx().x-1) * blockDim().x + threadIdx().x
    iz = (blockIdx().z-1) * blockDim().z + threadIdx().z
    for iy = 1:size(A,2)
        @inbounds B[ix,iy,iz] = A[ix,iy,iz]
    end
    return nothing
end

threads = (256, 1, 1)
blocks  = (nx÷threads[1], 1, nz÷threads[3])
#-
## Verification
B .= 0.0;
@cuda blocks=blocks threads=threads memcopy!(B, A); synchronize()
B ≈ A
#-
## Performance
t_it = @belapsed begin @cuda blocks=$blocks threads=$threads memcopy!($B, $A); synchronize() end
T_tot = 2*1/1e9*nx*ny*nz*sizeof(Float64)/t_it

md"""
You should observe no big difference between `T_tot` measured here and `T_tot` computed in Task 1 (measured 519 GB/s with the Tesla P100 GPU) as this kernel is accessing memory also in large contiguous chunks.
"""

md"""
### Task 4 (controlling registers)

Write a kernel `cumsum_dim2!` which computes the cumulative sum over the 2nd dimension of a 3-D array. To this purpose modify the memory copy kernel from Task 3. Verify the correctness of your kernel against `CUDA.cumsum!`. Then, compute `T_eff_cs` as defined above, explain the measured performance and compare it to the one obtained with the generic `CUDA.cumsum!`.
"""

#-
function cumsum_dim2!(B, A)
    ix = (blockIdx().x-1) * blockDim().x + threadIdx().x
    iz = (blockIdx().z-1) * blockDim().z + threadIdx().z
    cumsum_iy = 0.0
    for iy = 1:size(A,2)
        @inbounds cumsum_iy  += A[ix,iy,iz]
        @inbounds B[ix,iy,iz] = cumsum_iy
    end
    return nothing
end

## Verification
@cuda blocks=blocks threads=threads cumsum_dim2!(B, A); synchronize()
CUDA.cumsum!(B_ref, A; dims=2);
B ≈ B_ref
#-
## Performance
t_it = @belapsed begin @cuda blocks=$blocks threads=$threads cumsum_dim2!($B, $A); synchronize() end
T_eff_cs = 2*1/1e9*nx*ny*nz*sizeof(Float64)/t_it
#-
t_it = @belapsed begin CUDA.cumsum!($B, $A; dims=2); synchronize() end
T_eff_cs = 2*1/1e9*nx*ny*nz*sizeof(Float64)/t_it

md"""
Again, you should observe no significant difference between `T_eff_cs` measured here and `T_tot` computed in Task 3 (measured 519 GB/s with the Tesla P100 GPU), as you probably expected.

We will now implement the cumulative sum over the 1st dimension (index `ix`). As for the previous implementations, the first step is to read in A (and write B) in a way that will later allow to easily do the required cumsums without exhibiting significant memory throughput degradation.
"""

md"""
### Task 5 (kernel loops)

Modify the `memcopy!` kernel given in the beginning to read in A and write B in a serial manner with respect to the first dimension (index `ix`), i.e., with parallelization only over the second and third dimensions (index `iy` and `iz`). Launch the kernel with the same amount of threads as in Task 1, however, place them all in the second dimension (i.e. use one thread in the first and third dimensions); adapt the the block configuration correctly. Verify the correctness of your kernel. Then, think about what performance you expect, compute `T_tot` and explain the measured performance.
"""

#-
function memcopy!(B, A)
    iy = (blockIdx().y-1) * blockDim().y + threadIdx().y
    iz = (blockIdx().z-1) * blockDim().z + threadIdx().z
    for ix = 1:size(A,1)
        @inbounds B[ix,iy,iz] = A[ix,iy,iz]
    end
    return nothing
end

threads = (1, 256, 1)
blocks  = (1, ny÷threads[2], nz÷threads[3])
#-
## Verification
B .= 0.0;
@cuda blocks=blocks threads=threads memcopy!(B, A); synchronize()
B ≈ A
#-
## Performance
t_it = @belapsed begin @cuda blocks=$blocks threads=$threads memcopy!($B, $A); synchronize() end
T_tot = 2*1/1e9*nx*ny*nz*sizeof(Float64)/t_it

md"""
You likely observe `T_tot` to be an order of magnitude or more below `T_tot` measured in Task 1 and 3 (measured 36 GB/s with the Tesla P100 GPU) because, in contrast to the previous kernels, this kernel accesses memory discontinuously with a large stride (of `nx` numbers) between each requested number.

There obviously is no point in creating a `cumsum!` kernel out of this `memcopy!` kernel: the performance could only be the same or worse (even though worse is not to expect). Hence, we will try to improve this memory copy kernel by accessing multiple contiguous numbers from memory, which we can achieve by launching more then one threads in the first dimension, adapting the loop accordingly.
"""

md"""
### Task 6 (kernel loops)

Modify the `memcopy!` kernel from Task 5 to enable reading in 32 numbers at a time in the first dimension (index `ix`) rather than one number at a time as before. Launch the kernel with just 32 threads, all placed in the first dimension; adapt the the block configuration if you need to. Verify the correctness of your kernel. Then, think about what performance you expect now, compute `T_tot` and explain the measured performance.
"""
#nb # > 💡 Hint: you could hardcode the kernel to read 32 numbers at a time, but we prefer to write it more generally allowing to launch the kernel with a different number of threads in the first dimension (however, we do not want to enable more then one block though in this dimension).
#md # \note{You could hardcode the kernel to read 32 numbers at a time, but we prefer to write it more generally allowing to launch the kernel with a different number of threads in the first dimension (however, we do not want to enable more then one block though in this dimension).}

#-
function memcopy!(B, A)
    iy = (blockIdx().y-1) * blockDim().y + threadIdx().y
    iz = (blockIdx().z-1) * blockDim().z + threadIdx().z
    for ix_offset = 0 : blockDim().x : size(A,1)-1
        ix = threadIdx().x + ix_offset
        @inbounds B[ix,iy,iz] = A[ix,iy,iz]
    end
    return nothing
end

threads = (32, 1, 1)
blocks  = (1, ny÷threads[2], nz÷threads[3])
#-
## Verification
B .= 0.0;
@cuda blocks=blocks threads=threads memcopy!(B, A); synchronize()
B ≈ A
#-
## Performance
t_it = @belapsed begin @cuda blocks=$blocks threads=$threads memcopy!($B, $A); synchronize() end
T_tot = 2*1/1e9*nx*ny*nz*sizeof(Float64)/t_it

md"""
`T_tot` should now be similar to the one obtained in Task 1 and 3 or even a bit better (measured 534 GB/s with the Tesla P100 GPU) thanks to the additional concurrency compared to the other `memcopy!` versions. We are therefore ready to implement the cummulative sum over the 1st dimension.
"""

md"""
### Task 7 (communication via shared memory)

Write a kernel `cumsum_dim1!` which computes the cumulative sum over the 1st dimension of a 3-D array. To this purpose modify the memory copy kernel from Task 6. Verify the correctness of your kernel against `CUDA.cumsum!`. Then, compute `T_eff_cs` as defined above, explain the measured performance and compare it to the one obtained with the generic `CUDA.cumsum!`.
"""
#nb # > 💡 Hint: if you read the data into shared memory, then you can compute the cumulative sum, e.g., with the first thread.
#md # \note{If you read the data into shared memory, then you can compute the cumulative sum, e.g., with the first thread.}

#-
function cumsum_dim1!(B, A)
    iy = (blockIdx().y-1) * blockDim().y + threadIdx().y
    iz = (blockIdx().z-1) * blockDim().z + threadIdx().z
    tx = threadIdx().x
    shmem = @cuDynamicSharedMem(eltype(A), blockDim().x)
    cumsum_ix = 0.0
    for ix_offset = 0 : blockDim().x : size(A,1)-1
        ix = threadIdx().x + ix_offset
        @inbounds shmem[tx] = A[ix,iy,iz]       # Read the x-dimension chunk into shared memory.
        sync_threads()
        if tx == 1                            # Compute the cumsum only with the first thread, accessing only shared memory
            for i = 1:blockDim().x
                @inbounds cumsum_ix += shmem[i]
                @inbounds shmem[i] = cumsum_ix
            end
        end
        sync_threads()
        @inbounds B[ix,iy,iz] = shmem[tx]       # Write the x-dimension chunk to main memory.
    end
    return nothing
end

## Verification
@cuda blocks=blocks threads=threads shmem=prod(threads)*sizeof(Float64) cumsum_dim1!(B, A); synchronize()
CUDA.cumsum!(B_ref, A; dims=1);
B ≈ B_ref
#-
## Performance
t_it = @belapsed begin @cuda blocks=$blocks threads=$threads shmem=2*prod($threads)*sizeof(Float64) cumsum_dim1!($B, $A); synchronize() end
T_eff_cs = 2*1/1e9*nx*ny*nz*sizeof(Float64)/t_it
#-
t_it = @belapsed begin CUDA.cumsum!($B, $A; dims=1); synchronize() end
T_eff_cs = 2*1/1e9*nx*ny*nz*sizeof(Float64)/t_it

md"""
`T_eff_cs` is probably significantly less good than the one obtained for the cumulative sums over the other dimensions, but still quite good if we keep in mind the `T_tot` achieved with the first memcopy manner in Task 5. A good strategy for tackling an optimal implementation would certainly be to use warp-level functions (and if needed a more complex summation algorithm).
"""


