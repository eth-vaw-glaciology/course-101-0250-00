+++
title = "Software install"
hascode = true
+++

# Software install

\toc

## Opening and running the Jupyter Julia notebook

### Course slides and lecture material
Most of the course slides are a [Jupyter notebook](https://jupyter.org/); a browser-based computational notebook.

You can follow the lecture along live at https://achtzack01.ethz.ch/, login with your nethz-name and an arbitrary password (**but don't use your nethz password**).  You have to be within the ETHZ network or use a VPN connection.

Code cells are executed by putting the cursor into the cell and hitting `shift + enter`.  For more info see the [documentation](https://jupyter-notebook.readthedocs.io/en/stable/).

### Exercises and homework
The first two (and maybe more) homework assignements will be [Jupyter notebooks](https://jupyter.org/).

🚧 WIP Procedure on how-to with the notebook exercises.

## Installing Julia v1.6 (or later)
Check you have an active internet connexion and [download Julia v1.6](https://julialang.org/downloads/) for your platform following the install directions provided under **[help]** if needed.

Alternatively, open a terminal and download the binaries (select the one for your platform):
```sh
wget https://julialang-s3.julialang.org/bin/winnt/x64/1.6/julia-1.6.2-win64.exe # Windows
wget https://julialang-s3.julialang.org/bin/mac/x64/1.6/julia-1.6.2-mac64.dmg # macOS
wget https://julialang-s3.julialang.org/bin/linux/x64/1.6/julia-1.6.2-linux-x86_64.tar.gz # Linux x86
```
Then add Julia to `PATH` (usually done in your `.bashrc`, `.profile`, or `config` file).

### Terminal + external editor
Ensure you have a text editor with syntax highlighting support for Julia. [Sublime Text](https://www.sublimetext.com/download) and [Atom](https://atom.io) can be recommended.

From within the terminal, type
```sh
julia
```
to make sure that the Julia REPL (aka terminal) starts. Then you should ba able to add `1+1` and verify you get the expected result. Exit with `Ctrl-d`.

![Julia from Terminal](/assets/julia_terminal.png)

### VS Code
If you'd enjoy a more IDE type of environment, [check out VS Code](https://code.visualstudio.com). Follow the [installation directions](https://github.com/julia-vscode/julia-vscode#getting-started) for the [Julia VS Code extension](https://www.julia-vscode.org).
<!-- 
## Running the scripts
To get started with the workshop,
1. clone (or download the ZIP archive) the workshop repository ([help here](https://docs.github.com/en/github/creating-cloning-and-archiving-repositories/cloning-a-repository))
```sh
git clone https://github.com/luraess/parallel-gpu-workshop-JuliaCon21.git
```
2. Navigate to `parallel-gpu-workshop-JuliaCon21`
```sh
cd parallel-gpu-workshop-JuliaCon21
```
3. From the terminal, launch Julia with the `--project` flag to read-in project environment related informations such as used packages
```sh
julia --project
```
3. From VS Code, follow the [instructions from the documentation](https://www.julia-vscode.org/docs/stable/gettingstarted/) to get started.

### Packages installation
Now that you launched Julia, you should be in the [Julia REPL]. You need to ensure all the packages you need are installed before using them. To do so, enter the [Pkg mode](https://docs.julialang.org/en/v1/stdlib/REPL/#Pkg-mode) by typing `]`. Then, `instantiate` the project which should trigger the download of the packages (`st` lists the package status). Exit the Pkg mode with `Ctrl-c`:
```julia-repl
julia> ]

(parallel-gpu-workshop-JuliaCon21) pkg> st
Status `~/parallel-gpu-workshop-JuliaCon21/Project.toml`
    # [...]

(parallel-gpu-workshop-JuliaCon21) pkg> instantiate
   Updating registry at `~/.julia/registries/General`
   Updating git-repo `https://github.com/JuliaRegistries/General.git`
   # [...]

julia>
```
To test your install, go to the [scripts](../scripts) folder and run the [`diffusion_2D_expl.jl`](/scripts/diffusion_2D_expl.jl) code. You can execute shell commands from within the [Julia REPL] first typing `;`:
```julia-repl
julia> ;

shell> cd scripts/

julia> include("diffusion_2D_expl.jl")
```
Running this the first time will (pre-)complie the various installed packages and will take some time. Subsequent runs, by executing `include("diffusion_2D_expl.jl")`, should take around 2s.

You should then see a figure displayed showing the nonlinear diffusion of a quantity `H` after `nt=666` steps:

![](docs/diff2D_expl.png)

## Multi-threading on CPUs
On the CPU, multi-threading is made accessible via [Base.Threads]. To make use of threads, Julia needs to be launched with
```sh
julia --project -t auto
```
which will launch Julia with as many threads are there are cores on your machine (including hyper-threaded cores).  Alternatively set
the environment variable [JULIA_NUM_THREADS], e.g. `export JULIA_NUM_THREADS=2` to enable 2 threads.

## Running on GPUs
The [CUDA.jl] module permits to launch compute kernels on Nvidia GPUs natively from within [Julia]. [JuliaGPU] provides further reading and [introductory material](https://juliagpu.gitlab.io/CUDA.jl/tutorials/introduction/) about GPU ecosystems within Julia. If you have an Nvidia CUDA capable GPU device, also export following environment vaiable prior to installing the [CUDA.jl] package:
```sh
export JULIA_CUDA_USE_BINARYBUILDER=false
```

## Julia MPI
The following steps permit you to install [MPI.jl] on your machine and test it:
1. Julia MPI being a dependency of this Julia project [MPI.jl] should have been added upon executing the `instantiate` command from within the package manager [see here](#packages-installation).

2. Install `mpiexecjl`:
```julia-repl
julia> using MPI

julia> MPI.install_mpiexecjl()
[ Info: Installing `mpiexecjl` to `HOME/.julia/bin`...
[ Info: Done!
```
3. Then, one should add `HOME/.julia/bin` to PATH in order to launch the Julia MPI wrapper `mpiexecjl`.

4. Running a Julia MPI code `<my_script.jl>` on `np` processes:
```sh
$ mpiexecjl -n np julia --project <my_script.jl>
```

5. To test the Julia MPI installation, launch the [`hello_mpi.jl`](extras/hello_mpi.jl) using the Julia MPI wrapper `mpiexecjl` (located in `~/.julia/bin`) on 4 processes:
```sh
$ mpiexecjl -n 4 julia --project extras/hello_mpi.jl
$ Hello world, I am 0 of 3
$ Hello world, I am 1 of 3
$ Hello world, I am 2 of 3
$ Hello world, I am 3 of 3
```
> 💡 Note: On MacOS, you may encounter this issue (https://github.com/JuliaParallel/MPI.jl/issues/407). To fix it, define following `ENV` variable:
```sh
$ export MPICH_INTERFACE_HOSTNAME=localhost
```
> and add `-host localhost` to the execution script:
```sh
$ mpiexecjl -n 4 -host localhost julia --project extras/hello_mpi.jl
``` -->
