# Julia MPI "Hello world" code
# from: https://juliaparallel.github.io/MPI.jl/stable/examples/01-hello/
# run: ~/.julia/bin/mpiexecjl -n 4 julia --project scripts/hello_mpi_gpu.jl
using MPI, CUDA
MPI.Init()

comm = MPI.COMM_WORLD
me   = MPI.Comm_rank(comm)
# select device
comm_l = MPI.Comm_split_type(comm, MPI.MPI_COMM_TYPE_SHARED, me)
me_l   = MPI.Comm_rank(comm_l)
GPU_ID = CUDA.device!(me_l)

println("Hello world, I am $(me) of $(MPI.Comm_size(comm)) using $(GPU_ID)")
MPI.Barrier(comm)
