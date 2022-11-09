<!--This file was generated, do not modify it.-->
## Exercise 1 - **Towards distributed memory computing on GPUs**

👉 See [Logistics](/logistics/#submission) for submission details.

The goal of this exercise is to:
- Familiarise with distributed computing
- Learn about MPI on the way

In this exercise, you will:
- Finalise the fake parallelisation scripts discussed in lecture 8 (2 procs and `n` procs)
- Finalise the 2D Julia MPI script
- Create a Julia MPI GPU version of the 2D Julia MPI script discussed [here](#task_5_multi-gpu_homework)

Create a new `lectrue_8` folder for this first exercise in your shared private GitHub repository for this week's exercises.

### Task 1

Finalise the [`l8_diffusion_1D_2procs.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/l8_scripts/) and [`l8_diffusion_1D_nprocs.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/l8_scripts/) scripts discussed during lecture 8. Make sure to correctly implement the halo update in order to exchange the internal boundaries among the fake parallel processes (left and right and `ip` in the "2procs" and "nprocs" codes, respectively). See [here](#fake_parallelisation) for details.

Report in two separate figures the final distribution of concentration `C` for both fake parallel codes. Include these figure in a first section of your lecture's 8 `README.md` adding a description sentence to each.

### Task 2

Finalise the [`l8_diffusion_2D_mpi.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/l8_scripts/) script discussed during lecture 8. In particular, finalise the `update_halo` functions to allow for correct internal boundary exchange among the distributed parallel MPI processes. Add the final code to your GitHub lecture 8 folder.

For each of the (4) neighbour exchanges:
1. Start by defining a sendbuffer `sendbuf` to hold the vector you need to send
2. Initialise a receive buffer `recvbuf` to later hold the vector received from the corresponding neighbouring process
3. Use `MPI.Send` and `MPI.Recv!` functions to perform the boundary exchange
4. Assign the values within the receive buffer to the corresponding row or column of the array `A`

\note{Apply similar overlap and halo update as in the fake parallelisation examples. Look-up [MPI.Send](https://juliaparallel.github.io/MPI.jl/latest/pointtopoint/#MPI.Send) and [MPI.recv!](https://juliaparallel.github.io/MPI.jl/latest/pointtopoint/#MPI.Recv!) for further details.}

In a new section of your lecture's 8 `README.md`, add a .gif animation showing the diffusion of the quantity `C`, **running on 4 MPI processes**, for the physical and numerical parameters suggested in the [initial file](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/l8_scripts/l8_diffusion_2D_mpi.jl). Add a short description of the results and provide the command used to launch the script in the `README.md` as well.

### Task 3

Create a multi-GPU implementation of the [`l8_diffusion_2D_mpi.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/l8_scripts/) script as suggested [here](#task_5_multi-gpu_homework). To this end, create a new script `l8_diffusion_2D_mpi_gpu.jl` that you will upload to your lecture 8 GitHub repository upon completion.

Translate the `l8_diffusion_2D_mpi.jl` code from exercise 1 (task 3) to GPU using GPU array programming. You can use a similar approach as in the CPU code to perform the boundary updates. You should use `copyto!` function in order to copy the data from the GPU memory into the send buffers (CPU memory) or to copy the receive buffer data to the GPU array.

The steps to realise this task summarise as following:
1. Select the GPU based on node-local MPI infos (see the [`l8_hello_mpi_gpu.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/l8_scripts/) code to get started.)
2. Use GPU array initialisation (`CUDA.zeros`, `CuArray()`, ...)
3. Gather the GPU arrays back on the host memory for visualisation or saving (using `Array()`)
4. Modify the `update_halo` function; use `copyto!` to copy device data to the host into the send buffer or to copy host data to the device from the receive buffer

In a new (3rd) section of your lecture's 8 `README.md`, add .gif animation showing the diffusion of the quantity `C`, **running on 4 GPUs (MPI processes)**, for the physical and numerical parameters suggested in the [initial file](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/l8_scripts/l8_diffusion_2D_mpi.jl). Add a short description of the results and provide the command used to launch the script in the `README.md` as well. Note what changes were needed to go from CPU to GPU in this distributed solver.

