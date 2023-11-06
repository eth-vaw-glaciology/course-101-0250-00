# Julia MPI "Hello world" code
# from: https://juliaparallel.github.io/MPI.jl/stable/examples/01-hello/
# run: ~/.julia/bin/mpiexecjl -n 4 julia --project scripts/l8_hello_mpi.jl
using MPI
MPI.Init()

comm = MPI.COMM_WORLD
me = MPI.Comm_rank(comm)
sleep(0.1me)
println("Hello world, I am $(me) of $(MPI.Comm_size(comm))")
MPI.Barrier(comm)
