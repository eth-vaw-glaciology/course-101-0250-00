+++
title = "Software install"
hascode = true
+++

# Software install

\toc

## Opening and running the Jupyter Julia notebook

### Course slides and lecture material
All the course slides are [Jupyter notebooks](https://jupyter.org/); browser-based computational notebooks.

Code cells are executed by putting the cursor into the cell and hitting `shift + enter`. For more info see the [documentation](https://jupyter-notebook.readthedocs.io/en/stable/).

### Exercises and homework
The first two lecture's homework assignments will be [Jupyter notebooks](https://jupyter.org/). You'll find them on Moodle within your [JupyterHub](https://moodle-app2.let.ethz.ch/course/view.php?id=18084) space. You can execute them on the [JupyterHub](https://moodle-app2.let.ethz.ch/course/view.php?id=18084) or download them and run them them locally if you're already set-up.

For submission, download the final `.ipynb` notebooks from the server, or collect the local `.ipynb` notebooks into a single local folder you then upload to Moodle. See [Logistics](/logistics) and [Homework](/homework) for details.

Starting from lecture 3, exercise scripts will be mostly standalone regular Julia scripts that have to be uploaded to your private GitHub repo (shared with the teaching staff only). Details in [Logistics](/logistics/#submission).

## JupyterHub
You can access the JupyterHub from the **General** section in [Moodle](https://moodle-app2.let.ethz.ch/course/view.php?id=18084), clicking on [![JupyterHub](/assets/JHub.png#badge)](https://moodle-app2.let.ethz.ch/course/view.php?id=18084)

Upon login to the server, you should see the following launcher environment, including a notebook (file) browser, ability to create a notebook, launch a Julia console (REPL), or a regular terminal.

![JupyterHub](/assets/JHubLauncher.png)

\warn{It is recommended to duplicate and rename any files you are planning to work on and to download your work as back-up before leaving the session.}

## Installing Julia v1.8 (or later)
Check you have an active internet connexion and [download Julia v1.8](https://julialang.org/downloads/) for your platform following the install directions provided under **[help]**.

Alternatively, open a terminal and download the binaries (select the one for your platform):
```sh
wget https://julialang-s3.julialang.org/bin/winnt/x64/1.8/julia-1.8.2-win64.exe # Windows
wget https://julialang-s3.julialang.org/bin/mac/x64/1.8/julia-1.8.2-mac64.dmg # macOS
wget https://julialang-s3.julialang.org/bin/linux/x64/1.8/julia-1.8.2-linux-x86_64.tar.gz # Linux x86
```
Then extract them and add Julia to `PATH` (usually done in your `.bashrc`, `.profile`, or `config` file).

\note{_**For Windows users:**_ When installing Julia 1.8 on Windows, make sure to check the "Add PATH" tick or ensure Julia is on PATH (see **[help]**). Julia's REPL has a built-in shell mode you can access typing `;` that natively works on Unix-based systems. On Windows, you can access the Windows shell by typing `Powershell` within the shell mode, and exit it typing `exit`, as described [here](https://docs.julialang.org/en/v1/stdlib/REPL/#man-shell-mode).}

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

#### VS Code Remote - SSH setup
VS Code's [Remote - SSH](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh) extension allows you to connect and open a remote folder on any remote machine with a running SSH server. Once connected to a server, you can interact with files and folders anywhere on the remote filesystem ([more](https://code.visualstudio.com/docs/remote/ssh)).

1. To get started, follow [the install steps](https://code.visualstudio.com/docs/remote/ssh#_installation).
2. Then, you can [connect to a remote host](https://code.visualstudio.com/docs/remote/ssh#_connect-to-a-remote-host), using `ssh user@hostname` and your password (selecting `Remote-SSH: Connect to Host...` from the Command Palette).
3. [Advanced options](https://code.visualstudio.com/docs/remote/ssh#_remember-hosts-and-advanced-settings) permit you to [access a remote compute node from within VS Code](#connect_to_the_machine_and_to_your_compute_node_from_vs_code).

\note{This remote configuration supports Julia graphics to render within VS Code's plot pane. However, this "remote" visualisation option is only functional when plotting from a Julia instance launched as `Julia: Start REPL` from the Command Palette. Displaying a plot from a Julia instance launched from the remote terminal (which allows, e.g., to include custom options such as `ENV` variables or load modules) will fail. To work around this limitation, select `Julia: Connect external REPL` from the Command Palette and follow the prompted instructions.}

## Running Julia

### First steps
Now that you have a running Julia install, launch Julia (e.g. by typing `julia` in the shell since it should be on path)
```sh
julia
```

Welcome in the [Julia REPL](https://docs.julialang.org/en/v1/stdlib/REPL/) (command window). There, you have 3 "modes", the standard
```julia-repl
[user@comp ~]$ julia
               _
   _       _ _(_)_     |  Documentation: https://docs.julialang.org
  (_)     | (_) (_)    |
   _ _   _| |_  __ _   |  Type "?" for help, "]?" for Pkg help.
  | | | | | | |/ _` |  |
  | | |_| | | | (_| |  |  Version 1.8.1 (2022-09-06)
 _/ |\__'_|_|_|\__'_|  |  Official https://julialang.org/ release
|__/                   |

julia>
```
the shell mode by hitting `;`, where you can enter Unix commands,
```julia-repl
shell> 
```
and the [Pkg mode](https://docs.julialang.org/en/v1/stdlib/REPL/#Pkg-mode) (package manager) by hitting `]`, that will be used to add and manage packages, and environments,
```julia-repl
(@v1.8) pkg> 
```

You can interactively execute commands in the REPL, like adding two numbers
```julia-repl
julia> 2+2
4

julia>
```
Within this class, we will mainly work with Julia scripts. You can run them using the `include()` function in the REPL
```julia-repl
julia> include("my_script.jl")
```
Alternatively, you can also execute a Julia script from the shell
```sh
julia -O3 --check-bounds=no my_script.jl
```
here passing the `-O3` optimisation flag, and the Julia `--check-bounds` flag set to `no` in order to deactivate out-of-bound checking.

### Package manager
The [Pkg mode](https://docs.julialang.org/en/v1/stdlib/REPL/#Pkg-mode) permits you to install and manage Julia packages, and control the project's environment.

Environments or Projects are an efficient way that enable portability and reproducibility. Upon activating a local environment, you generate a local `Project.toml` file that stores the packages and version you are using within a specific project (code-s), and a `Manifest.toml` file that keeps track locally of the state of the environment. 

To activate an project-specific environment, navigate to your targeted project folder, launch Julia
```sh
mkdir my_cool_project
cd my_cool_project 
julia
```
and activate it

```julia-repl
julia> ]

(@v1.8) pkg> 

(@v1.8) pkg> activate .
  Activating new environment at `~/my_cool_project/Project.toml`

(my_cool_project) pkg> 
```

Then, let's install the `Plots.jl` package
```julia-repl
(my_cool_project) pkg> add Plots
```
and check the status
```julia-repl
(my_cool_project) pkg> st
      Status `~/my_cool_project/Project.toml`
  [91a5bcdd] Plots v1.22.3
```
as well as the `.toml` files
```julia-repl
julia> ;

shell> ls
Manifest.toml Project.toml
```
We can now load `Plots.jl` and plot some random noise
```julia-repl
julia> using Plots

julia> heatmap(rand(10,10))
```

Let's assume you're handed your `my_cool_project` to someone to reproduce your cool random plot. To do so, you can open julia from the `my_cool_project` folder with the `--project` option
```sh
cd my_cool_project 
julia --project
```

Or you can rather activate it afterwards
```sh
cd my_cool_project 
julia
```
and then,
```julia-repl
julia> ]

(@v1.8) pkg> activate .
  Activating environment at `~/my_cool_project/Project.toml`

(my_cool_project) pkg> 

(my_cool_project) pkg> st
      Status `~/my_cool_project/Project.toml`
  [91a5bcdd] Plots v1.22.3
```

Here we go, you can now share that folder with colleagues or with yourself on another machine and have a reproducible environment 🙂

### Multi-threading on CPUs
On the CPU, [multi-threading](https://docs.julialang.org/en/v1/manual/multi-threading/#man-multithreading) is made accessible via [Base.Threads](https://docs.julialang.org/en/v1/base/multi-threading/). To make use of threads, Julia needs to be launched with
```sh
julia --project -t auto
```
which will launch Julia with as many threads are there are cores on your machine (including hyper-threaded cores). Alternatively set the environment variable `JULIA_NUM_THREADS`, e.g. `export JULIA_NUM_THREADS=2` to enable 2 threads.

### Julia on GPUs
The [CUDA.jl](https://github.com/JuliaGPU/CUDA.jl) module permits to launch compute kernels on Nvidia GPUs natively from within Julia. [JuliaGPU](https://juliagpu.org) provides further reading and [introductory material](https://juliagpu.gitlab.io/CUDA.jl/tutorials/introduction/) about GPU ecosystems within Julia.

### Julia MPI
The following steps permit you to install [MPI.jl](https://github.com/JuliaParallel/MPI.jl) on your machine and test it:
1. If Julia MPI is a dependency of a Julia project MPI.jl should have been added upon executing the `instantiate` command from within the package manager [see here](#package_manager). If not, MPI.jl can be added from within the package manager (typing `add MPI` in package mode).

2. Install `mpiexecjl`:
```julia-repl
julia> using MPI

julia> MPI.install_mpiexecjl()
[ Info: Installing `mpiexecjl` to `HOME/.julia/bin`...
[ Info: Done!
```
3. Then, one should add `HOME/.julia/bin` to PATH in order to launch the Julia MPI wrapper `mpiexecjl`.

4. Running a Julia MPI code `<my_script.jl>` on `np` MPI processes:
```sh
$ mpiexecjl -n np julia --project <my_script.jl>
```

5. To test the Julia MPI installation, launch the [`hello_mpi.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/hello_mpi.jl) using the Julia MPI wrapper `mpiexecjl` (located in `~/.julia/bin`) on, e.g., 4 processes:
```sh
$ mpiexecjl -n 4 julia --project ./hello_mpi.jl
$ Hello world, I am 0 of 3
$ Hello world, I am 1 of 3
$ Hello world, I am 2 of 3
$ Hello world, I am 3 of 3
```
\note{On MacOS, you may encounter [this issue](https://github.com/JuliaParallel/MPI.jl/issues/407). To fix it, define following `ENV` variable:
```sh
$ export MPICH_INTERFACE_HOSTNAME=localhost
```
and add `-host localhost` to the execution script:
```sh
$ mpiexecjl -n 4 -host localhost julia --project ./hello_mpi.jl
```
}
