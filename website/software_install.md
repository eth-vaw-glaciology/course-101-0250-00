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

The first two lecture's homework assignments will be [Jupyter notebooks](https://jupyter.org/). You can import the notebooks from Moodle into your JupyterHub space. You can execute them on the [JupyterHub]({{jupyterhub_url}}) or download them and run them them locally if you're already set-up.

For submission, you can directly submit the folder containing all notebooks of a lecture from within the JupyterHub/Moodle integration. From the homework task on Moodle, you should be able to launch the notebooks in your JupyterHub. Once the homework completed, you should be able to see the folders you have worked on from your JupyterHub within the submission steps on Moodle. See [Logistics](/logistics) and [Homework](/homework) for details.

Starting from lecture 3, exercise scripts will be mostly standalone regular Julia scripts that have to be uploaded to your private GitHub repo (shared with the teaching staff only). Details in [Logistics](/logistics/#submission).

## JupyterHub

You can access the JupyterHub from the **General** section in [Moodle]({{moodle_url}}), clicking on [![JupyterHub](/assets/JHub2.png#badge)]({{jupyterhub_url}})

Upon login to the server, you should see the following launcher environment, including a notebook (file) browser, ability to create a notebook, launch a Julia console (REPL), or a regular terminal.

![JupyterHub](/assets/JHubLauncher.png)

\warn{It is recommended to download your work as back-up before leaving the session.}

## Installing Julia v1.11 (or later)

### Juliaup installer

Follow the instructions from the [Julia Download page](https://julialang.org/downloads/) to install Julia v1.11 (which is using the [**Juliaup**](https://github.com/JuliaLang/juliaup) Julia installer under the hood).

\note{_**For Windows users:**_ When installing Julia 1.11 on Windows, make sure to check the "Add PATH" tick or ensure Julia is on PATH (see **[help]**). Julia's REPL has a built-in shell mode you can access typing `;` that natively works on Unix-based systems. On Windows, you can access the Windows shell by typing `Powershell` within the shell mode, and exit it typing `exit`, as described [here](https://docs.julialang.org/en/v1/stdlib/REPL/#man-shell-mode).}

### Terminal + external editor

Ensure you have a text editor with syntax highlighting support for Julia.  We recommend to use VSCode, see below. However, other editors are available too such as Sublime, Emacs, Vim, Helix, etc.

From within the terminal, type

```sh
julia
```

to make sure that the Julia REPL (aka terminal) starts. Then you should be able to add `1+1` and verify you get the expected result. Exit with `Ctrl-d`.

![Julia from Terminal](/assets/julia_terminal.png)

### VS Code

If you'd enjoy a more IDE type of environment, [check out VS Code](https://code.visualstudio.com). Follow the [installation directions](https://github.com/julia-vscode/julia-vscode#getting-started) for the [Julia VS Code extension](https://www.julia-vscode.org).

#### VS Code Remote - SSH setup

VS Code's [Remote-SSH](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh) extension allows you to connect and open a remote folder on any remote machine with a running SSH server. Once connected to a server, you can interact with files and folders anywhere on the remote filesystem ([more](https://code.visualstudio.com/docs/remote/ssh)).

1. To get started, follow [the install steps](https://code.visualstudio.com/docs/remote/ssh#_installation).
2. Then, you can [connect to a remote host](https://code.visualstudio.com/docs/remote/ssh#_connect-to-a-remote-host), using `ssh user@hostname` and your password (selecting `Remote-SSH: Connect to Host...` from the Command Palette).
3. [Advanced options](https://code.visualstudio.com/docs/remote/ssh#_remember-hosts-and-advanced-settings) permit you to [access a remote compute node from within VS Code](#running_julia_interactively_on_alps).

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
  | | |_| | | | (_| |  |  Version 1.11.6 (2025-07-09)
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
(@v1.11) pkg>
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
julia -03 my_script.jl
```

here passing the `-O3` optimisation flag.

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

(@v1.11) pkg>

(@v1.11) pkg> activate .
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

(@v1.11) pkg> activate .
  Activating environment at `~/my_cool_project/Project.toml`

(my_cool_project) pkg>

(my_cool_project) pkg> st
      Status `~/my_cool_project/Project.toml`
  [91a5bcdd] Plots v1.40.20
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

5. To test the Julia MPI installation, launch the [`l8_hello_mpi.jl`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/) using the Julia MPI wrapper `mpiexecjl` (located in `~/.julia/bin`) on, e.g., 4 processes:

```sh
$ mpiexecjl -n 4 julia --project ./l8_hello_mpi.jl
$ Hello world, I am 0 of 3
$ Hello world, I am 1 of 3
$ Hello world, I am 2 of 3
$ Hello world, I am 3 of 3
```

\note{On macOS, you may encounter [this issue](https://github.com/JuliaParallel/MPI.jl/issues/407). To fix it, define following `ENV` variable:

```sh
$ export MPICH_INTERFACE_HOSTNAME=localhost
```

and add `-host localhost` to the execution script:

```sh
$ mpiexecjl -n 4 -host localhost julia --project ./hello_mpi.jl
```

}

## GPU computing on Alps

GPU computing on [Alps](https://www.cscs.ch/computers/alps) at [CSCS](https://www.cscs.ch). The supercomputer Alps is composed of 2688 compute nodes, each hosting 4 Nvidia GH200 96GB GPUs. We have a 4000 node hour allocation for our course on the HPC Platform **Daint**, a versatile cluster (vCluster) within the Alps infrastructure.

\warn{Since the course allocation is exceptional, make sure not to open any help tickets directly at CSCS help, but report questions and issue _exclusively_ to our **helpdesk** room on Element. Also, better ask about good practice before launching anything you are unsure in order to avoid any disturbance on the machine.}

The login procedure is as follow. First a login to the front-end (or login) machine Ela (hereafter referred to as "ela") is needed before one can log into Daint. Login is performed using `ssh`. We will set-up a proxy-jump in order to simplify the procedure and directly access Daint (hereafter referred to as "daint")

Both daint and ela share a `home` folder. However, the `scratch` folder is only accessible on daint. We can use VS code in combination with the proxy-jump to conveniently edit files on daint's scratch directly. We will use a Julia "uenv" to have all Julia-related tools ready.

Make sure to have the Remote-SSH extension installed in VS code [(see here for details on how-to)](#vs_code_remote_-_ssh_setup).

Please follow the steps listed hereafter to get ready and set-up on daint.

### Account setup

\warn{The course accounts somewhat differ from regular account and do not require MFA. The connection procedure from CSCS' user doc does thus not apply.}

1. Fetch your personal username and password credentials from Moodle.

2. Open a terminal (in Windows, use a tool as e.g. [PuTTY]() or [OpenSSH](https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse?tabs=gui)) and `ssh` to ela and enter the password:

```sh
ssh <username>@ela.cscs.ch
```

3. Generate a `ed25519` keypair. On your local machine (not ela), do `ssh-keygen` leaving the passphrase empty. Then copy your public key to the remote server (ela) using `ssh-copy-id`.

```sh
ssh-keygen -t ed25519
ssh-copy-id -i ~/.ssh/id_ed25519.pub <username>@ela.cscs.ch
```

Alternatively, you can copy the keys manually.

4. Once your key is added to ela, manually connect to daint to authorize your key for the first time, while making sure you are logged-in in ela. Execute:

```sh
[classXXX@ela2 ~]$ ssh daint
```

This step shall prompt you to accept the daint server’s SSH key and enter the password you got from Moodle again.

5. Edit your ssh config file located in `~/.ssh/config` and add following entries to it, making sure to replace `<username>` and key file with correct names, if needed:

```sh
Host daint.alps
  HostName daint.alps.cscs.ch
  User <username>
  IdentityFile ~/.ssh/id_ed25519
  ProxyJump <username>@ela.cscs.ch
  AddKeysToAgent yes
  ForwardAgent yes
```

6. Now you should be able to perform password-less login to daint as following

```sh
ssh daint.alps
```

> At this stage, you are logged into daint, but still on a login node and not a compute node.

You can reach your home folder upon typing `cd $HOME`, and your scratch space upon typing `cd $SCRATCH`. Always make sure to run and save files from scratch folder.

\note{To make things easier, you can create a soft link from your `$HOME` pointing to `$SCRATCH`

```sh
ln -s $SCRATCH scratch
```

}

Make sure to remove any folders you may find in your scratch as those are the empty remaining from last year's course.

### Setting up Julia on Alps

The Julia setup on daint is handled by [uenv](https://docs.cscs.ch/software/uenv/), user environments that provide scientific applications, libraries and tools. The [Julia uenv](https://docs.cscs.ch/software/prgenv/julia/) provides a fully configured environment to run Julia at Scales on Nvidia GPUs, using MPI as communication library. Julia is installed and managed by [JUHPC](https://github.com/JuliaParallel/JUHPC) which wraps Juliaup and ensures it smoothly works on the supercomputer.

**Only the first time** you will need to pull the Julia uenv on daint, and run Juliaup to install Julia.

1. Open a terminal (other than from within VS code) and login to daint:

```sh
ssh daint.alps
```

2. Download the Julia uenv image:

```sh
uenv image pull julia/25.5:v1
```

3. Once the download complete, start the uenv:

```sh
uenv start --view=juliaup,modules julia/25.5:v1
```

Adding a view (`--view=juliaup,modules`) gives you explicit access to Juliaup and to modules.

4. Only the first time, call into juliaup in order to install latest Julia

```sh
juliaup
```

At this point, you should be able to launch Julia by typing `julia` in the terminal.

\note{All Julia-related information can be found at [https://docs.cscs.ch/software/prgenv/julia/](https://docs.cscs.ch/software/prgenv/julia/)}

### Running Julia interactively on Alps

Once the initial setup is completed, you can simply use Julia on daint by starting the Julia uenv, accessing a compute node (using SLURM), and launching Julia to add CUDA.jl package:

\warn{To perform any computation, you need to access a compute node using the SLURM scheduler.}

1. SSH into daint and start the Julia uenv
```sh
ssh daint.alps

uenv start --view=juliaup,modules julia/25.5:v1
```

2. The next step is to secure an allocation using `salloc`, a functionality provided by the SLURM scheduler. Use `salloc` command to allocate one node (`N1`) and one process (`n1`) on the GPU partition `-C'gpu'` on the project `class04` for 1 hour:

```sh
salloc -C'gpu' -Aclass04 -N1 -n1 --time=01:00:00
```

\note{You can check the status of the allocation typing `squeue --me`.}

👉 _Running **remote job** instead? [Jump right there](#running_a_remote_job_on_alps)_

3. Once you have your allocation (`salloc`) and the node, you can access the compute node by using the following `srun` command:

```sh
srun -n1 --pty /bin/bash -l
```

4. Launch Julia in global or project environment

```sh
julia
```

5. Within Julia, enter the package mode `]`, check the status, and add `CUDA.jl` and `MPI.jl`:

```julia-repl
julia> ]

(@v1.12) pkg> st

(@v1.12) pkg> add CUDA, MPI
```

6. Then load CUDA and query version info

```julia-repl
julia> using CUDA

julia> CUDA.versioninfo()
CUDA toolchain:
- runtime 12.8, local installation
- driver 550.54.15 for 13.0
- compiler 12.9

# [skipped lines]

Preferences:
- CUDA_Runtime_jll.version: 12.8
- CUDA_Runtime_jll.local: true

4 devices:
  0: NVIDIA GH200 120GB (sm_90, 93.953 GiB / 95.577 GiB available)
  1: NVIDIA GH200 120GB (sm_90, 93.951 GiB / 95.577 GiB available)
  2: NVIDIA GH200 120GB (sm_90, 93.955 GiB / 95.577 GiB available)
  3: NVIDIA GH200 120GB (sm_90, 93.954 GiB / 95.577 GiB available)
```

7. Try out your first calculation on the GH200 GPU

```julia-repl
julia> a = CUDA.ones(3,4);

julia> b = CUDA.rand(3,4);

julia> c = CUDA.zeros(3,4);

julia> c .= a .+ b
```

If you made it to here, you're most likely all set 🚀

\warn{There is no interactive visualisation on daint. Make sure to produce `png` or `gifs`. Also to avoid plotting to fail, make sure to set the following `ENV["GKSwstype"]="nul"` in the code. Also, it may be good practice to define the animation directory to avoid filling a `tmp`, such as

```julia
ENV["GKSwstype"]="nul"
if isdir("viz_out")==false mkdir("viz_out") end
loadpath = "./viz_out/"; anim = Animation(loadpath,String[])
println("Animation directory: $(anim.dir)")
```

}

#### Monitoring GPU usage

You can use the `nvidia-smi` command to monitor GPU usage on a compute node on daint. Just type in the terminal or with Julia's REPL (in shell mode).

#### Using VS code on Alps

VS code support to remote connect to daint is getting better and better. If feeling adventurous, try out the [Connecting with VS Code](https://docs.cscs.ch/access/vscode/) procedure. Any feedback welcome.

### Running a remote job on Alps

If you do not want to use an interactive session you can use the `sbatch` command to launch a job remotely on the machine. Example of a `submit.sh` you can launch (without need of an allocation) as `sbatch submit.sh`:

```sh
#!/bin/bash -l
#SBATCH --account=class04
#SBATCH --job-name="my_gpu_run"
#SBATCH --output=my_gpu_run.%j.o
#SBATCH --error=my_gpu_run.%j.e
#SBATCH --time=00:10:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --gpus-per-task=1

srun --uenv julia/25.5:v1 --view=juliaup julia --project <my_julia_gpu_script.jl>
```

\warn{Make sure to have started the Julia uenv **before** executing the `sbatch` command or to include ` --uenv julia/25.5:v1 --view=juliaup` in the `srun` command.}

<!-- ### JupyterLab access on Alps

Some tasks and homework, are prepared as Jupyter notebook and can easily be executed within a JupyterLab environment. CSCS offers a convenient [JupyterLab access](https://docs.cscs.ch/access/jupyterlab/#using-julia-in-jupyter).

1. If possible, create a soft link from your `$HOME` pointing to `$SCRATCH` (do this on daint):

```sh
  ln -s $SCRATCH scratch
```

2. Head to [https://jupyter.cscs.ch/](https://jupyter.cscs.ch/).
3. Login with your username and password you've set for in the [Account setup](#account_setup) step
4. Select `Node Type: GPU`, `Node: 1` and the duration you want and **Launch JupyterLab**.
5. From with JupyterLab, upload the notebook to work on and get started!
-->

### Transferring files on Alps

Given that daint's `scratch` is not mounted on ela, it is unfortunately impossible to transfer files from/to daint using common sftp tools as they do not support the proxy-jump. Various solutions exist to workaround this, including manually handling transfers over terminal, using a tool which supports proxy-jump, or VS code.

To use VS code as development tool, make sure to have installed the `Remote-SSH` extension as described in the [VS Code Remote - SSH setup](#vs_code_remote_-_ssh_setup) section. Then, in VS code Remote-SSH settings, make sure the `Remote Server Listen On Socket` is set to `true`.

The next step should work out of the box. You should be able to select `daint` from within the Remote Explorer side-pane. You should get logged into daint. You now can browse your files, change directory to, e.g., your scratch at `/capstor/scratch/cscs/<username>/`. Just drag and drop files in there to transfer them.

<!--
Another way is to use `sshfs` which lets you mount the file system on servers with ssh-access (works on Linux, there are MacOS and Windows ports too).  After installing `sshfs` on your laptop, create a empty directory to mount (`mkdir -p ~/mnt/daint`), you should be able to mount via

```
sshfs <your username on daint>@daint.cscs.ch:/ /home/$USER/mnt_daint  -o compression=yes -o reconnect -o idmap=user -o gid=100 -o workaround=rename -o follow_symlinks -o ProxyJump=ela
```

and unmount via

```
fusermount -u -z /home/$USER/mnt_daint
```

For convenience it is suggested to also symlink to the home-directory `ln -s ~/mnt/daint/users/<your username on daint> ~/mnt/daint_home`.  (Note that we mount the root directory `/` with `sshfs` such that access to `/scratch` is possible.)
-->

<!--
### Julia MPI GPU on Alps

The following step should allow you to run distributed memory parallelisation application on multiple GPU nodes on Alps.

1. Make sure to have the Julia GPU environment loaded

```sh
uenv start --view=juliaup,modules julia/25.5:v1
```

2. Then, you would need to allocate more than one node, let's say 4 nodes for 2 hours, using `salloc`

```
salloc -C'gpu' -Aclass04 -N4 -n4 --time=02:00:00
```

3. To launch a Julia (GPU) MPI script on 4 nodes (GPUs) using MPI, you can simply use `srun`

```sh
srun -n4 julia --project <my_julia_mpi_script.jl>
```

If you do not want to use an interactive session you can use the `sbatch` command to launch an MPI job remotely on daint. Example of a `sbatch_mpi_daint.sh` you can launch (without need of an allocation) as [`sbatch sbatch_mpi_daint.sh`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/l8_scripts/l8_sbatch_mpi_daint.sh):

```sh
#!/bin/bash -l
#SBATCH --account=class04
#SBATCH --job-name="diff2D"
#SBATCH --output=diff2D.%j.o
#SBATCH --error=diff2D.%j.e
#SBATCH --time=00:05:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --gpus-per-task=4

export MPICH_GPU_SUPPORT_ENABLED=1
export IGG_CUDAAWARE_MPI=1 # IGG
export JULIA_CUDA_USE_COMPAT=false # IGG

srun --uenv julia/25.5:v1 --view=juliaup julia --project <my_julia_mpi_gpu_script.jl>
```

\note{The scripts above can be found in the [scripts](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/l8_scripts/) folder.}

-->

<!-- You may want to leverage CUDA-aware MPI, i.e., passing GPU pointers directly through the MPI-based update halo functions, then make sure to export the following `ENV` variables
```sh
export MPICH_RDMA_ENABLED_CUDA=1
export IGG_CUDAAWARE_MPI=1
```

In the CUDA-aware MPI case, a more robust launch procedure may be to launch a shell script via `srun`. You can create, e.g., a [`runme_mpi_daint.sh`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/l8_scripts/l8_runme_mpi_daint.sh) script containing:
```sh
#!/bin/bash -l

export MPICH_RDMA_ENABLED_CUDA=1
export IGG_CUDAAWARE_MPI=1

julia --project <my_script.jl>
```

Which you then launch using `srun` upon having made it executable (`chmod +x runme_mpi_daint.sh`)
```sh
srun -n4 ./runme_mpi_daint.sh
```
-->
