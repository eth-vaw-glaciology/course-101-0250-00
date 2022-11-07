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
VS Code's [Remote-SSH](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh) extension allows you to connect and open a remote folder on any remote machine with a running SSH server. Once connected to a server, you can interact with files and folders anywhere on the remote filesystem ([more](https://code.visualstudio.com/docs/remote/ssh)).

1. To get started, follow [the install steps](https://code.visualstudio.com/docs/remote/ssh#_installation).
2. Then, you can [connect to a remote host](https://code.visualstudio.com/docs/remote/ssh#_connect-to-a-remote-host), using `ssh user@hostname` and your password (selecting `Remote-SSH: Connect to Host...` from the Command Palette).
3. [Advanced options](https://code.visualstudio.com/docs/remote/ssh#_remember-hosts-and-advanced-settings) permit you to [access a remote compute node from within VS Code](#running_julia_interactively_on_piz_daint).

\note{This remote configuration supports Julia graphics to render within VS Code's plot pane. However, this "remote" visualisation option is only functional when plotting from a Julia instance launched as `Julia: Start REPL` from the Command Palette. Displaying a plot from a Julia instance launched from the remote terminal (which allows, e.g., to include custom options such as `ENV` variables or load modules) will fail. To work around this limitation, select `Julia: Connect external REPL` from the Command Palette and follow the prompted instructions.}

\warn{The Remote-SSH setup is limited on Piz Daint because of a security issue, not allowing direct node execution nor supporting remote command execution which would be needed to correctly launch the Julia extension to allow for e.g. graphics redirection (more [here](https://user.cscs.ch/news/#23-10-2020-remote-vscode-configuration)).}

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

_For running Julia at scale on Piz Daint, refer to the [Julia MPI GPU on Piz Daint](#julia_mpi_gpu_on_piz_daint) section._

## GPU computing on Piz Daint

GPU computing on [Piz Daint](https://www.cscs.ch/computers/piz-daint/) at [CSCS](https://www.cscs.ch). The supercomputer Piz Daint is composed of about 5700 compute nodes, each hosting a single Nvidia P100 16GB PCIe graphics card. We have a 2000 node hour allocation for our course on the system. 

\warn{Since the course allocation is exceptional, make sure not to open any help tickets directly at CSCS help, but report questions and issue to our **helpdesk** room on Element. Also, better ask about good practice before launching anything you are unsure in order to avoid any disturbance on the machine.}

The login procedure is as follow. First a login to the front-end (or login) machine Ela (hereafter referred to as "ela") is needed before one can log into Piz Daint. Login is performed using `ssh`. We will set-up a proxy-jump in order to simplify the procedure and directly access Piz Daint (hereafter referred to as "daint")

Both daint and ela share a `home` folder. However, the `scratch` folder is only accessible on daint. We can use VS code in combination with the proxy-jump to conveniently edit files on daint's scratch directly. We will use Julia module to have all Julia-related tools ready.

Please follow the steps listed hereafter to get ready and set-up on daint.

### Account setup
1. Fetch your personal username and password credentials from the shared Polybox folder, stored in a `daint_login.md` file.

2. Open a terminal (in Windows, use a tool as e.g. [PuTTY]() or [OpenSSH](https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse?tabs=gui)) and `ssh` to ela and enter the password:
```sh
ssh <username>@ela.cscs.ch
```

3. On ela, change the password to another one and remember it! Password policy. The new password should comply with the following: 
   - be at least 12 characters
   - include upper and lower case letters
   - include numeric digits
   - include special characters like `# , . / : = ? @ [ ] ^ { } ~`
```sh
[test@ela1 ~]$ kpasswd
Password for <username>@CSCS.CH: (current password) 
Enter new password: (new password) 
Enter it again: (new password)
```

\note{👉 For Lecture 6, you can jump directly to the [JupyterLab](#jupyterlab_access_on_piz_daint) setup.}

4. Generate a `ed25519` keypair as described in the [CSCS user website](https://user.cscs.ch/access/auth/#generating-ssh-keys-if-not-required-to-provide-a-2nd-factor). On your local machine (not ela), do `ssh-keygen` leaving the passphrase empty. Then copy your public key to the remote server (ela) using `ssh-copy-id`. Alternatively, you can copy the keys manually as described in the [CSCS user website](https://user.cscs.ch/access/auth/#generating-ssh-keys-if-not-required-to-provide-a-2nd-factor).
```sh
ssh-keygen -t ed25519
ssh-copy-id <username>@ela.cscs.ch
ssh-copy-id -i ~/.ssh/id_ed25519.pub <username>@ela.cscs.ch
```

5. Edit your ssh config file located in `~/.ssh/config` and add following entries to it, making sure to replace `<username>` and key file with correct names, if needed:
```sh
Host ela
  HostName ela.cscs.ch
  User <username>
  IdentityFile ~/.ssh/id_ed25519

Host daint
  HostName daint.cscs.ch
  User <username>
  IdentityFile ~/.ssh/id_ed25519
  ProxyJump ela
  RequestTTY yes
  RemoteCommand module load daint-gpu Julia/1.7.2-CrayGNU-21.09-cuda && bash -l

Host nid*
  HostName %h
  User <username>
  IdentityFile ~/.ssh/id_ed25519
  ProxyJump daint
  RequestTTY yes
  RemoteCommand module load daint-gpu Julia/1.7.2-CrayGNU-21.09-cuda && bash -l
``` 

6. Now you should be able to perform password-less login to daint as following
```sh
ssh daint
``` 
Moreover, you will get the Julia related modules loaded as we add the `RemoteCommand`

> At this stage, you are logged into daint, but still on a login node and not a compute node.

You can reach your home folder upon typing `$HOME`, and your scratch space upon typing `$SCRATCH`. Always make sure to run and save files from scratch folder.

\note{To make things easier, you can create a soft link from your `$HOME` pointing to `$SCRATCH` as this will also be useful in a JupyterLab setting
```sh
ln -s $SCRATCH scratch
```
}

\warn{There is interactive visualisation on daint. Make sure to produce `png` or `gifs`. Also to avoid plotting to fail, make sure to set the following `ENV["GKSwstype"]="nul"` in the code. Also, it may be good practice to define the animation directory to avoid filling a `tmp`, such as
```julia
ENV["GKSwstype"]="nul"
if isdir("viz_out")==false mkdir("viz_out") end
loadpath = "./viz_out/"; anim = Animation(loadpath,String[])
println("Animation directory: $(anim.dir)")
```
}

### Running Julia interactively on Piz Daint
So now, how do we actually run some GPU Julia code on Piz Daint?

1. Open a terminal (other than from within VS code) and login to daint:
```sh
ssh daint
```

2. The next step is to secure an allocation using `salloc`, a functionality provided by the SLURM scheduler. Use `salloc` command to allocate one node (`N1`) and one process (`n1`) on the GPU partition `-C'gpu'` on the project `class04` for 1 hour:
```sh
salloc -C'gpu' -Aclass04 -N1 -n1 --time=01:00:00
```

\note{You can check the status of the allocation typing `squeue -u <username>`.}

👉 *Running **remote job** instead? [Jump right there](#running_a_remote_job_on_piz_daint)*

3. Make sure to remember the **node number** returned upon successful allocation, e.g., `salloc: Nodes nid02145 are ready for job`

4. Once you have your allocation and the node (here `nid02145`) you requested, open another terminal (tab) **without closing the previous one** and `ssh` to your node replacing the `XXXXX` with appropriate node id from step 2. If needed, accept the key fingerprint prompt and you should be on the node with Julia environment loaded.
```sh
ssh nidXXXXX
```

4. You should not be able to launch Julia
```sh
julia
```

#### :eyes: ONLY the first time
1. Assuming you are on a node and launched Julia. To finalise your install, enter the package manager and query status `] st` and add `CUDA`:
```julia-repl
(@1.7-daint-gpu) pkg> st
  Installing known registries into `/scratch/snx3000/class230/../julia/class230/daint-gpu`
      Status `/scratch/snx3000/julia/class230/daint-gpu/environments/1.7-daint-gpu/Project.toml` (empty project)

(@1.7-daint-gpu) pkg> add CUDA
```

2. Then load it and query version info
```julia-repl
julia> using CUDA

julia> CUDA.versioninfo()
  Downloaded artifact: CUDA_compat
CUDA toolkit 11.0, local installation
NVIDIA driver 470.57.2, for CUDA 11.4
CUDA driver 11.7
```

3. Try out your first calculation on the P100 GPU
```julia-repl
julia> a = CUDA.ones(3,4);

julia> b = CUDA.rand(3,4);

julia> c = CUDA.zeros(3,4);

julia> c. = a .+ b
```

If you made it up to here, you're all set 🚀

\note{Alternatively, you can also access a compute node after having performed the `salloc` step by following:
```sh
srun -n1 --pty /bin/bash -l
module load daint-gpu Julia/1.7.2-CrayGNU-21.09-cuda
```
}

#### Monitoring GPU usage
You can use the `nvidia-smi` command to monitor GPU usage on a compute node on daint. Just type in the terminal or with Julia's REPL (in shell mode):
```julia-repl
shell> nvidia-smi
Tue Oct 25 08:18:11 2022       
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 470.57.02    Driver Version: 470.57.02    CUDA Version: 11.4     |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|                               |                      |               MIG M. |
|===============================+======================+======================|
|   0  Tesla P100-PCIE...  On   | 00000000:02:00.0 Off |                    0 |
| N/A   23C    P0    25W / 250W |      0MiB / 16280MiB |      0%   E. Process |
|                               |                      |                  N/A |
+-------------------------------+----------------------+----------------------+
                                                                               
+-----------------------------------------------------------------------------+
| Processes:                                                                  |
|  GPU   GI   CI        PID   Type   Process name                  GPU Memory |
|        ID   ID                                                   Usage      |
|=============================================================================|
|  No running processes found                                                 |
+-----------------------------------------------------------------------------+
```

### Running a remote job on Piz Daint
If you do not want to use an interactive session you can use the `sbatch` command to launch a job remotely on the machine. Example of a `submit.sh` you can launch (without need of an allocation) as `sbatch submit.sh`:
```sh
#!/bin/bash -l
#SBATCH --job-name="my_gpu_run"
#SBATCH --output=my_gpu_run.%j.o
#SBATCH --error=my_gpu_run.%j.e
#SBATCH --time=00:30:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --partition=normal
#SBATCH --constraint=gpu
#SBATCH --account class04

module load daint-gpu
module load Julia/1.7.2-CrayGNU-21.09-cuda

srun julia -O3 --check-bounds=no <my_julia_gpu_script.jl>
```

### JupyterLab access on Piz Daint
Some tasks and homework, are prepared as Jupyter notebook and can easily be executed within a JupyterLab environment. CSCS offers a convenient [JupyterLab access](https://user.cscs.ch/tools/interactive/jupyterlab/#access-and-setup).

1. If possible, create a soft link from your `$HOME` pointing to `$SCRATCH` (do this on daint):
```sh
ln -s $SCRATCH scratch
```

2. Head to [https://jupyter.cscs.ch/](https://jupyter.cscs.ch/).

3. Login with your username and password you've set for in the [Account setup](#account_setup) step

4. Select `Node Type: GPU`, `Node: 1` and the duration you want and **Launch JupyterLab**.

5. From with JupyterLab, upload the notebook to work on and get started!

### Transferring files on Piz Daint
Given that daint's `scratch` is not mounted on ela, it is unfortunately impossible to transfer files from/to daint using common sftp tools as they do not support the proxy-jump. Various solutions exist to workaround this, including manually handling transfers over terminal, using a tool which supports proxy-jump, or VS code.

To use VS code as development tool, make sure to have installed the `Remote-SSH` extension as described in the [VS Code Remote - SSH setup](#vs_code_remote_-_ssh_setup) section. Then, in VS code Remote-SSH settings, make sure the `Remote Server Listen On Socket` is set to `true`.

The next step should work out of the box. You should be able to select `daint` from within the Remote Explorer side-pane. You should get logged into daint. You now can browse your files, change directory to, e.g., your scratch at `/scratch/snx3000/<username>/`. Just drag and drop files in there to transfer them.

\note{You can also use VS code's integrated terminal to launch Julia on daint. However, you can't use the Julia extension nor the direct node login and would have to use `srun -n1 --pty /bin/bash -l` and load the needed modules, namely `module load daint-gpu Julia/1.7.2-CrayGNU-21.09-cuda`.}

### Julia MPI GPU on Piz Daint
The following step should allow you to run distributed memory parallelisation application on multiple GPU nodes on Piz Daint.
1. Make sure to have the Julia GPU environment loaded
```sh
module load daint-gpu
module load Julia/1.7.2-CrayGNU-21.09-cuda
```
2. Then, you would need to allocate more than one node, let's say 4 nodes for 2 hours, using `salloc`
```
salloc -C'gpu' -Aclass04 -N4 -n4 --time=02:00:00
```
3. To launch a Julia (GPU) MPI script on 4 nodes (GPUs) using MPI, you can simply use `srun`
```sh
srun -n4 julia -O3 --check-bounds=no <my_script.jl>
```

#### CUDA-aware MPI on Piz Daint
You may want to leverage CUDA-aware MPI, i.e., passing GPU pointers directly through the MPI-based update halo functions, then make sure to 
1. Export the appropriate `ENV` vars 
```sh
export MPICH_RDMA_ENABLED_CUDA=1
export IGG_CUDAAWARE_MPI=1
```
2. Because of a current issue with Cray-MPICH (the Cray MPI distribution used on Piz Daint), you need also to dynamically preload `libcudart.so` library. This can be achieved upon launching your Julia executable script
```sh
LD_PRELOAD="/usr/lib64/libcuda.so:/usr/local/cuda/lib64/libcudart.so" julia -O3 --check-bounds=no <my_script.jl>
```

In the CUDA-aware MPI case, a more robust launch procedure may be to launch a shell script via `srun`. You can create, e.g., a [`runme_mpi_daint.sh`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/l8_scripts/l8_runme_mpi_daint.sh) script containing:
```sh
#!/bin/bash -l

module load daint-gpu
module load Julia/1.7.2-CrayGNU-21.09-cuda

export MPICH_RDMA_ENABLED_CUDA=1
export IGG_CUDAAWARE_MPI=1

LD_PRELOAD="/usr/lib64/libcuda.so:/usr/local/cuda/lib64/libcudart.so" julia -O3 --check-bounds=no <my_script.jl>
```

Which you then launch using `srun` upon having made it executable (`chmod +x runme_mpi_daint.sh`)
```sh
srun -n4 ./runme_mpi_daint.sh
```

If you do not want to use an interactive session you can use the `sbatch` command to launch a job remotely on the machine. Example of a `sbatch_mpi_daint.sh` you can launch (without need of an allocation) as [`sbatch sbatch_mpi_daint.sh`](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/l8_scripts/l8_sbatch_mpi_daint.sh):
```sh
#!/bin/bash -l
#SBATCH --job-name="diff2D"
#SBATCH --output=diff2D.%j.o
#SBATCH --error=diff2D.%j.e
#SBATCH --time=00:05:00
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=1
#SBATCH --partition=normal
#SBATCH --constraint=gpu
#SBATCH --account class04

module load daint-gpu
module load Julia/1.7.2-CrayGNU-21.09-cuda

export MPICH_RDMA_ENABLED_CUDA=1
export IGG_CUDAAWARE_MPI=1

srun -n4 bash -c 'LD_PRELOAD="/usr/lib64/libcuda.so:/usr/local/cuda/lib64/libcudart.so" julia -O3 --check-bounds=no <my_julia_mpi_gpu_script.jl>'
```

\note{The 2 scripts above can be found in the [scripts](https://github.com/eth-vaw-glaciology/course-101-0250-00/blob/main/scripts/l8_scripts/) folder.}
