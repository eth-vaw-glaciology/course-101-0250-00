# Julia MPI "Hello world" code
# from: https://juliaparallel.github.io/MPI.jl/stable/examples/01-hello/
# run: ~/.julia/bin/mpiexecjl -n 4 julia --project scripts/hello_mpi.jl
using MPI
MPI.Init()

comm = MPI.COMM_WORLD
me   = MPI.Comm_rank(comm)
println("Hello world, I am $(me) of $(MPI.Comm_size(comm))")
MPI.Barrier(comm)
