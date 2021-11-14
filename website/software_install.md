+++
title = "Software install"
hascode = true
+++

# Software install

\toc

## Opening and running the Jupyter Julia notebook

### Course slides and lecture material
Most of the course slides are a [Jupyter notebook](https://jupyter.org/); a browser-based computational notebook.

You can follow the lecture along live at [https://achtzack01.ethz.ch/](https://achtzack01.ethz.ch/), login with your nethz-name and an arbitrary password (**but don't use your nethz password**).  _You have to be within the ETHZ network or use a VPN connection._

Code cells are executed by putting the cursor into the cell and hitting `shift + enter`. For more info see the [documentation](https://jupyter-notebook.readthedocs.io/en/stable/).

### Exercises and homework
The first two lecture's homework assignments will be [Jupyter notebooks](https://jupyter.org/). You'll find them on [https://achtzack01.ethz.ch/](https://achtzack01.ethz.ch/) as well. You can execute them on the server or download and run them them locally as well.

For submission, download the final `.ipynb` notebooks from the server, or collect the local `.ipynb` notebooks into a single local folder you then upload to Moodle. See [Logistics](/logistics) and [Homework](/homework) for details.

Starting from lecture 3, exercise scripts will be mostly standalone regular Julia scripts that have to be uploaded to your private git repo (shared with the teaching staff only). Details in [Logistics](/logistics/#submission).

\warn{The `achtzack01` is **not** backed up. Make sure to keep local copy of your data!}

## Installing Julia v1.6 (or later)
Check you have an active internet connexion and [download Julia v1.6](https://julialang.org/downloads/) for your platform following the install directions provided under **[help]**.

Alternatively, open a terminal and download the binaries (select the one for your platform):
```sh
wget https://julialang-s3.julialang.org/bin/winnt/x64/1.6/julia-1.6.3-win64.exe # Windows
wget https://julialang-s3.julialang.org/bin/mac/x64/1.6/julia-1.6.3-mac64.dmg # macOS
wget https://julialang-s3.julialang.org/bin/linux/x64/1.6/julia-1.6.3-linux-x86_64.tar.gz # Linux x86
```
Then extract them and add Julia to `PATH` (usually done in your `.bashrc`, `.profile`, or `config` file).

> **Note for Windows users**\
> When installing Julia 1.6 on Windows, make sure to check the "Add PATH" tick or ensure Julia is on PATH (see **[help]**). Julia's REPL has a built-in shell mode you can access typing `;` that natively works on Unix-based systems. On Windows, you can access the Windows shell by typing `Powershell` within the shell mode, and exit it typing `exit`, as described [here](https://docs.julialang.org/en/v1/stdlib/REPL/#man-shell-mode).

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
3. [Advanced options](https://code.visualstudio.com/docs/remote/ssh#_remember-hosts-and-advanced-settings) permit you to [access a remote compute node from within VS Code](#connect_to_the_machine_and_to_your_compute_node_from_vs_code) (e.g. a GPU node on `octopus`).

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
  | | |_| | | | (_| |  |  Version 1.6.3 (2021-09-23)
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
(@v1.6) pkg> 
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

(@v1.6) pkg> 

(@v1.6) pkg> activate .
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

(@v1.6) pkg> activate .
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

### Running on GPUs
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

\note{See [Julia MPI GPU on your `octopus` node](#julia_mpi_gpu_on_your_octopus_node) for detailed information on how to run MPI GPU (multi-GPU) applications on your assigned `octopus` node.}

## Accessing the GPU resources on `octopus`

The following steps will permit you to access the GPU resources, the [octopus supercomputer](https://wp.unil.ch/geocomputing/octopus/).

Look-up your username (`<username>`) and assigned node (`node`), both listed in [Moodle - General](https://moodle-app2.let.ethz.ch/course/view.php?id=15755#section-0) under `Connecting to the GPU resources (octopus)`. Your password was sent via email.

### Connect to the machine via ssh
```sh
ssh <username>@octopus.unil.ch
```

### Connect to the machine and to your compute node from VS Code
[Using VS Code](#vs_code_remote_-_ssh_setup) with the [Remote - SSH](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh) extension enables direct ssh access to your compute node `nodeXX`.

Edit your ssh config file (on Unix-based systems `.ssh/config`) as suggested in the [advanced settings](https://code.visualstudio.com/docs/remote/ssh#_remember-hosts-and-advanced-settings) by adding following information (replacing `nodeXX` and `<username>`):

```txt
Host octopus
  HostName octopus.unil.ch
  User <username>
  IdentityFile ~/.ssh/id_rsa

Host nodeXX
  HostName nodeXX.octopoda
  User <username>
  ProxyJump <username>@octopus.unil.ch

```
This will create a ProxyJump, setting up a connexion to your node via the master (login node).

### Initialise your remote desktop (first time only)
1. On your local machine (laptop), head to [RealVNC's download page](https://www.realvnc.com/en/connect/download/viewer/) to download the **VNC viewer**.
2. On _octopus_, trigger the remote desktop creation typing in the terminal
    ```sh
    vncserver :<VNC screen>
    ```
    where `<VNC screen>` refers to the screen number.
3. You will get prompted a line
    ```sh
    New 'octopus.unil.ch:<VNC screen> (<username>)' desktop is octopus.unil.ch:<VNC screen>
    ```

### Connect to remote desktop
1. On your local machine (laptop), open **VNC viewer** and paste the address you got prompted at remote desktop creation, i.e., `octopus.unil.ch:<VNC screen>` in the search bar - hit `enter`.
2. Type in the VNC password your received by email and you should be connected.
3. **Make sure to disable screensaver** when connecting for the first time to the remote desktop. You can do so accessing the `Applications` menu in the upper left corner and selecting: `Applications > Settings > Screensaver` and turning it `off`.
4. You can open a terminal (`Applications` menu in the upper left corner) and follow the next steps:
    - [Login to `node40`](#login_to_node40) (only during lecture 6 and for exercise 1)
    - [Login to your node](#login_to_your_node) (all other coming classes)

\warn{Never "logout" from your remote desktop, just close the VNC viewer window!}

#### Login to node40
This node only needed to be accessed during lecture 6 and for the exercise 1 (lecture 6).

<!-- This node should only be accessed during lecture 6 and for the exercise 1 (lecture 6).

1. **In your remote desktop**, open a terminal, `ssh` to `node40` enabling graphics redirecting `-YC`
```sh
ssh -YC node40
```
2. Load the required modules:
```sh
module load julia cuda/11.4
```
3. List the available GPU resources:
```sh
nvidia-smi
```
4. Navigate to `/scratch/<username>/lecture06`
```sh
cd /scratch/<username>/lecture06
```
5. Launch Julia
```sh
julia
```
6. See [here](#running_a_jupyter_notebook) for running a Jupyter notebook

7. Open the `l6_1-gpu-memcopy.ipynb` notebook. You are all set 🚀

\warn{Do not save data in your `/home` as the space is very limited. Always Navigate to your scratch-space `cd /scratch/<username>`, as this is the place where you should work from, save data, etc...} -->

#### Login to your node
Except for doing the hands-on in lecture 6 and for exercise 1 (lecture 6), you should connect to your corresponding GPU node according to the node list available on [Moodle](https://moodle-app2.let.ethz.ch/course/view.php?id=15755#section-0):
1. From the _octopus_ login node, you can access your compute node (replacing `<node>` by the 2 digit node number assigned to you) typing
```sh
ssh node<node>
```
in your local terminal or in the terminal within the remote desktop (e.g. `ssh node39`).
2. Typing `pwd()` should confirm you are in your `/home` folder.

\warn{Do not save data in your `/home` as the space is very limited. Always Navigate to your scratch-space `cd /scratch/<username>`, as this is the place where you should work from, save data, etc...}

3. Navigate to your scratch-space
```sh
cd /scratch/<username>
```
as this is the place where you should work from, save data, etc...
4. Load the required modules:
```sh
module load julia cuda/11.4
```
5. CUDA.jl ships with precompiled CUDA binaries (called [artifacts](https://juliagpu.gitlab.io/CUDA.jl/installation/overview/#Artifacts)). On `octopus` we want to disallow use of artifacts, because an optimized CUDA installation is available for the system. You can do so by setting the environment variable `JULIA_CUDA_USE_BINARYBUILDER` to `false` when importing CUDA.jl.
```sh
export JULIA_CUDA_USE_BINARYBUILDER=false
```
6. Launch Julia
```sh
julia
```
and you are all set 🚀

7. See [here](#running_a_jupyter_notebook) for running a Jupyter notebook

\note{You can use the `nvidia-smi` command as `top` alternative to monitor processes on the GPU(s).}

### Running a Jupyter notebook

If you need to run a Julia notebook within Jupyter, do following:

1. Navigate to the notebook's parent folder (e.g. `/scratch/<username>/lecture06`)
```sh
cd /scratch/<username>/lecture06
```
2. Launch Julia
```sh
julia
```
3. Activate and instantiate the project (this should download all packages you need 🙂)
```julia-repl
julia> ]

(@v1.6) pkg> activate .

(lecture06) pkg> instantiate
```
If you are not running in a particular project, you may need to add the `IJulia` package
```julia-repl
julia> ]

(@v1.6) pkg> add IJulia
```
4. Launch Jupyter
```julia-repl
julia> using IJulia

julia> notebook(dir=pwd())
```
You will get prompted to `install jupyter [y/N]` the first time running the `notebook()` command. Type `Yes` or `y`.

You should see Firefox opening a Jupyter tab (make sure you connected using `-YC` or `-X`).

5. Open the notebook. You are all set 🚀


### Julia MPI GPU on your `octopus` node

This section will get you set-up to exercise with multi-GPU programs on your assigned `octopus` node:
1. Open a terminal on your local machine and connect to `octopus` over `ssh` (or open your VNC remote desktop)
2. Connect to your node: node03 - node26 (no longer node40 - see [Moodle - General](https://moodle-app2.let.ethz.ch/course/view.php?id=15755#section-0))
3. Navigate to your `scratch` folder, then `lecture08` (you should have a copy of _**Lecture 8**_ material)
```sh
ssh -YC nodeXX
cd /scratch/<username>/lecture08
```
4. Load the required modules and use system CUDA
```sh
module load cuda/11.4 julia
export JULIA_CUDA_USE_BINARYBUILDER=false
```
5. Start Julia in project mode
```sh
julia --project
```
6. Resolve and instantiate the project to download all required packages
```julia-repl
julia> ]

(lecture08) pkg> resolve

(lecture08) pkg> instantiate
``` 
7. Install `mpiexecjl` launcher:
```julia-repl
julia> using MPI

julia> MPI.install_mpiexecjl()
[ Info: Installing `mpiexecjl` to `/home/<username>/.julia/bin`...
[ Info: Done!
```
8. Then, one should add `/home/<username>/.julia/bin` to PATH in order to launch the Julia MPI wrapper `mpiexecjl`.
9. Running a Julia MPI code `<my_script.jl>` on `np` MPI processes:
```sh
$ mpiexecjl -n np julia --project <my_script.jl>
```
10. To test the Julia MPI GPU installation, launch the [`hello_mpi_gpu.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/hello_mpi_gpu.jl) using the Julia MPI wrapper `mpiexecjl` (located in `/home/<username>/.julia/bin`) on, e.g., 4 processes:
```sh
$ mpiexecjl -n 4 julia --project ./hello_mpi_gpu.jl 
$ Hello world, I am 0 of 4 using CuDevice(0)
$ Hello world, I am 1 of 4 using CuDevice(1)
$ Hello world, I am 2 of 4 using CuDevice(2)
$ Hello world, I am 3 of 4 using CuDevice(3)
```
If you made it to here you should be all set 🚀
