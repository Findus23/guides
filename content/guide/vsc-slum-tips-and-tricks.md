---
title: "VSC/Slurm/Spack Tips and Tricks"
slug: vsc-slurm-spack-tips-and-tricks
date: 2022-05-18
categories: cheatsheet
author: Lukas Winkler
cc_license: true
description: "An assorted list of tricks for using the Vienna Scientific Cluster"
aliases:
  - /vsc/slurm-tips-and-tricks/
---


This is not official documentation for the [Vienna Scientific Cluster](https://vsc.ac.at). For this check the [VSC Wiki](https://wiki.vsc.ac.at). Instead, this is my personal cheat sheet of things that are not well documented elsewhere. Also while the content is focused on the VSC, most of the things mentioned here also apply to similar setups that use Slurm at other universities.

<!--more-->

## Basics

**Always request an interactive session when running anything using a non-trivial amount of CPU power!**

### Quick interactive session

```bash
➜ salloc --ntasks=2 --mem=2G --time=01:00:00
```

Don't forget to then connect to the node you get assigned:

```bash
➜ ssh n1234-567
```

## Storage

official docs:

- [vsc4_storage](https://wiki.vsc.ac.at/doku.php?id=doku:vsc4_storage)
- [storage](https://wiki.vsc.ac.at/doku.php?id=doku:storage)
- [introduction-to-vsc:08_storage_infrastructure:storage_infrastructure](https://wiki.vsc.ac.at/doku.php?id=pandoc:introduction-to-vsc:08_storage_infrastructure:storage_infrastructure)

`$HOME` is limited to 100 GB and storing/compiling code. Anything else should be stored at `$DATA`.

### Quota

The file size and number of files is limited by group. The current status can be read using

```bash
➜ mmlsquota --block-size auto -j data_fs00000 data
```

for $DATA and

```bash
➜ mmlsquota --block-size auto -j home_fs00000 home
```

for $HOME where `00000` is the ID of the own project (accessible using `groups`)

## Job scripts

### Basic Template

Your job script is a regular bash script (`.sh` file). In addition, you can specify options to `sbatch` in the beginning of your file:

```bash
#!/bin/bash
#SBATCH --job-name=somename
#SBATCH --mail-type=ALL
#SBATCH --mail-user=yourmail@example.com
```

- `--job-name`: A short name for this job. It is often displayed truncated after a few characters.
- `--mail-type=ALL`: notify on all events per E-Mail

In these cases `--long-option=value` and `--long-option value` are equivalent.

### Single Core job

Only specify `--ntask=1` and the amount of memory you need.

```bash
#SBATCH --ntasks=1 # (also -n 1)
#SBATCH --mem 2G
```

### More `sbatch` options

All options can be found in the [slurm documentation](https://slurm.schedmd.com/sbatch.html). A few useful ones are:

- [`--nodes`](https://slurm.schedmd.com/sbatch.html#OPT_nodes), `-N`: request X nodes
- [`--ntasks`](https://slurm.schedmd.com/sbatch.html#OPT_ntasks)
- [`--time`](https://slurm.schedmd.com/sbatch.html#OPT_time): limit the run time, e.g. `10:00` for 10 hours
- [`--mem`](https://slurm.schedmd.com/sbatch.html#OPT_mem): memory limit, e.g. `20G`
- [`--output`](https://slurm.schedmd.com/sbatch.html#OPT_output), `-o`: where to store the output of the executed script
- [`--dependency=afterany:1234`](https://slurm.schedmd.com/sbatch.html#OPT_dependency): only run job after job with ID 1234 has terminated

### Useful Environment Variables

- `$SLURM_JOB_NAME`
- `$SLURM_NODELIST`
- `$SLURM_NNODES`
- `$SLURM_NPROCS`

Especially the latter can be used e.g. for running MPI programs with the requested number of CPU cores:

```bash
➜ mpiexec -np $SLURM_NPROCS ./program
```

### Submitting Jobs

A job script can be submitted using

```bash
➜ sbatch jobfile.sh # you can also add sbatch options here
```

Just like in regular shell scripts, you can pass arguments to `jobfile.sh` like this

```bash
➜ sbatch jobfile.sh somevalue
```

and then access `somevalue` as `$1` in your script. This way multiple similar jobs can be submitted without needing to edit the jobscript.

### Queue

The current status of jobs in the Queue can be seen using [`squeue`](https://slurm.schedmd.com/squeue.html).

```bash
➜ squeue -u username
➜ squeue --me
```

Especially useful is the estimated start time of a scheduled job:

```bash
➜ squeue -u username --start
```

A lot more information about scheduling including the calculated priority of jobs can be found using [`sprio`](https://slurm.schedmd.com/sprio.html)

```bash
➜ sprio -u username
```

This will also show the reason why the job is still queued for which an explanation can be found [in the slurm documentation](https://slurm.schedmd.com/squeue.html#lbAF) or the [VSC wiki](https://wiki.vsc.ac.at/doku.php?id=doku:slurm_job_reason_codes).

Details about past Jobs (like maximum memory usage), can be found using [`sacct`](https://slurm.schedmd.com/sacct.html). You can manually specify the needed columns or display most of them using `--long`

```bash
➜ sacct -j 2052157 --long 
```

### Watch job output

If you submit a job, the output of the jobscript will by default be written to `slurm-000000.out` in the same directory. If you want to watch the output as it is written to the file while the job is running, `tail -f filename` will watch the file.
But as the output file is only created once the job starts, this might fail.
Using `tail -F` instead avoids this issue by watching the filename instead, which detects once the file appears and then watches it:

```bash
➜ tail -F slurm-952347.out 
tail: cannot open 'slurm-952347.out' for reading: No such file or directory
tail: 'slurm-952347.out' has appeared;  following new file
The output of your job
[...]
```

## Advanced Slurm features

### QoS, accounts and partitions

Depending on access to private nodes, you might have access to many different QoS (*Quality of Service*), accounts and partitions.

On VSC you can get an overview over your account with `sqos` (this is also shown on login):

```bash
# this only works on VSC
➜ /opt/adm/vsc/cluster-admin/src/python_modules/vsc_node_tools/scripts/sqos.sh account
==============================================================
Your jobs can run with the following account(s) and quality of service (QoS):

default_account:                       p12345 
        account:                       p12345 

    default_qos:                  p12345_0512 
            qos:                  p12345_0512 
                              p12345_a100dual 
                               p12345_a40dual 

```

If you want to a different account or QoS than your default (e.g. if you want to access private nodes or GPU nodes), you can specify them with `--qos` and `--acccount` in `salloc`, `sbatch` or your job script.

You can also get an overview over all available partitions with `sinfo` and specify one explicitly with `--partition`.

You can get a better overview over the current usage of the QoS using `sqos`. This gives you the number of CPUs that are currently in use out of the limit for each QoS:

```bash
# this only works on VSC
➜ sqos
     qos name  type  total res   used res   free res        walltime   priority   total n*    used n*    free n* 
=================================================================================================================
  p71867_0512   cpu       7680       5632       2048     10-00:00:00     100000         30         22          8 
* node values do not always align with resource values since nodes can be partially allocated
```

### Array Jobs

Sometimes you might want to submit a larger number of similar jobs. This can be easily achieved using array jobs and the [`--array`](https://slurm.schedmd.com/sbatch.html#OPT_array) argument. With this, your job will be submitted multiple times with a different task ID that can be used from the `$SLURM_ARRAY_TASK_ID` environment variable.

```bash
#SBATCH --array=0-26
./your_program $SLURM_ARRAY_TASK_ID
```

{{< alert type="warning" >}}
Keep in mind that each individual job should not be too small (more than just a few minutes) as otherwise the computational overhead of scheduling the job and starting it will not be worth it. In these cases using one job that runs the program in a loop will be more efficient.
{{< /alert >}}

### Ignore specific nodes

Sometimes it is possible that one node is broken in some way (maybe one of the GPUs is no longer detected), but your jobs still get assigned to it. Then you can use
[`--exclude`](https://slurm.schedmd.com/sbatch.html#OPT_exclude) to exclude individual or ranges of nodes from your job.

```bash
➜ sbatch --exclude n1234-[001-002],n1234-008 job.sh
```

### Set job name dynamically

Setting a helpful `--job-name` makes it a lot easier to keep track of the currently submitted jobs. But once the number of job scripts gets larger, this either means always specifying `--job-name` when calling `sbatch` or editing a lot of job-scripts.

As the job name is one of the properties that can still be changed after a job has been submitted, one alternative is having the job rename itself based on some dynamical property (e.g. the name of the current directory).

For this it is enough to call `scontrol` from the job script itself:

```bash
scontrol update JobId=$JobID JobName=something-$(basename $PWD)
```

### Change the default table format

By default, the output of `squeue` only shows the first 8 characters of the job name, making it hard to distinguish them.

```bash
➜ squeue --me
  JOBID            PARTITION     NAME     USER ST       TIME  NODES     NODELIST(REASON)
4306686            zen3_0512 music-ic lwinkler PD       0:00      1           (Priority)
```

One can change the output of `squeue` by setting the environment variable `SQUEUE_FORMAT` (e.g. globally in the `~/.bashrc`):

```bash
➜ export SQUEUE_FORMAT="%.18i %.9P %.15j %.8u %.2t %.10M %.6D %R"
➜ squeue --me
  JOBID PARTITION            NAME     USER ST       TIME  NODES NODELIST(REASON)
4306686 zen3_0512       music-ics lwinkler PD       0:00      1 (Priority)
```


## SSH login to VSC at the University of Vienna

[official docs](https://wiki.vsc.ac.at/doku.php?id=doku:vpn_ssh_access)

Access to VSC is only possible from IP addresses of the partner universities. If you are from the University of Vienna and don't want to use the VPN, an SSH tunnel via `login.univie.ac.at` is an alternative.

If you are connected to the university network, you can directly connect using the following:

```bash
➜ ssh vscuser@vsc5.vsc.ac.at
```


Alternatively you can add a section in the  `~/.ssh/config` on your computer for VSC (if you still have a `ProxyJump` line here, you have to remove it).

```bash
Host vsc5
    Hostname vsc5.vsc.ac.at
    User vscuser
    # Port 27 # (only use if you are using ssh keys)
```
and then connect directly like this:
```bash
➜ ssh vsc5
```

### VPN

If you want to connect to VSC (or any other univie-PC) from outside the university network, you need to set up [the ZID VPN](https://zid.univie.ac.at/en/vpn/).
For the VPN to work, you will also need to first [set up multi-factor authentication](https://zid.univie.ac.at/en/mfa/) on your phone. If you don't yet have a TOPT client on your phone and are using Android, I recommend [Aegis Authenticator](https://getaegis.app/).

You will need to follow the guides here to [install the software by F5](https://zid.univie.ac.at/en/vpn/user-guides/) on your PC.
For Linux the installation instruction [**can be found here**](https://zid.univie.ac.at/en/vpn/user-guides/linux/). 

## Spack Modules

([official docs](https://wiki.vsc.ac.at/doku.php?id=doku:spack), that this guide builds on. More useful tips can be found in the [spack documentation](https://spack.readthedocs.io/en/latest/))

Software that is needed can be loaded via modules. The easiest way to find the right module for the current processor architecture, is directly querying `spack`, which is used to provide all compiled libraries and applications. There should never be a need to run `module` directly and doing so might accidentally pick libraries that are not intended for the current processor architecture.

### Finding the right module

The easiest way is using `spack find`.

```bash
➜ spack find cmake
```

In case this only returns one module that fits your requirements, you can directly replace `spack find` with `spack load` to load this module.

But most of the time, you will find multiple modules which differ in their properties (and `spack load` will fail if the query resolves to more than one package):

```bash
➜ spack find cmake
-- linux-almalinux8-zen / gcc@8.5.0 -----------------------------
cmake@3.24.3

-- linux-almalinux8-zen2 / gcc@9.5.0 ----------------------------
cmake@3.24.3

-- linux-almalinux8-zen3 / aocc@4.0.0 ---------------------------
cmake@3.24.3

-- linux-almalinux8-zen3 / gcc@12.2.0 ---------------------------
cmake@3.24.3

-- linux-almalinux8-zen3 / intel@2021.7.1 -----------------------
cmake@3.24.3
==> 5 installed packages
```

The most important property is the version and it is denoted with an `@` sign. Another property is the compiler the program or library was compiled with and it can be separated with a `%` (and an additional `@` for the version of the compiler).

So if you want to load e.g. `cmake` version 3.x.x compiled with `gcc` version 12, you could directly search for it and subsequently load it.

```bash
➜ spack find cmake@3%gcc@12
➜ spack load cmake@3%gcc@12 
```

This way if another minor update of cmake is released, your command will load it. If you don't like this, check the next section.

Sometimes there are also multiple variants of the same module. `spack info modulename` can give you an overview over all of them, but that doesn't mean that all combinations of variants/compilers/versions are offered at VSC. If you are for example interested in the `hdf5` library with MPI support, you can search for the following (`-v` gives you the exact properties of each module):

```bash
➜ spack find -v hdf5 +mpi
```

### "Locking" modules

If you dislike the fact that `spack load` queries don't resolve to specific packages, but just filters that describe the properties you want or prefer exactly specifying the version of a package for reproducibility, you can find the hash of package using `spack find -l` and can then use `/hash` to always refer to this exact package:

```bash
➜ spack find -l gsl%gcc@12
-- linux-almalinux8-zen3 / gcc@12.2.0 ---------------------------
whc7rma gsl@2.7.1
==> 1 installed package
➜ spack load /whc7rma
```

### Find currently loaded modules

```bash
# List all currently loaded packages
➜ spack find --loaded
# Unload all currently loaded packages
➜ spack unload --all
```

### Libraries not found at runtime

Sometimes a program that just compiled without any issues (as the correct spack modules are loaded) won't run afterwards as the libraries are not found at run time.

```
./your_program: error while loading shared libraries: libhdf5.so.103: cannot open shared object file: No such file or directory
```

This is caused by a recent change in Spack: `$LD_LIBRARY_PATH` is no longer set by default, to avoid loading a module breaking unrelated software.
You can avoid this by setting `$LD_LIBRARY_PATH` to the value of `$LIBRARY_PATH` after loading your modules (as the latter is managed by spack).

```bash
➜ export LD_LIBRARY_PATH=$LIBRARY_PATH
```

Keep in mind that doing so might bring back [the issues](#avoiding-broken-programs-due-to-loaded-dependencies) that changing `$LD_LIBRARY_PATH` causes.

### Comparing modules

Sometimes two packages look exactly the same:

```bash
➜ spack find -vl fftw
-- linux-almalinux8-zen3 / intel@2021.9.0 -----------------------
ugklsjz fftw@3.3.10+mpi+openmp~pfft_patches build_system=autotools precision=double,float
j7dhzrq fftw@3.3.10+mpi+openmp~pfft_patches build_system=autotools precision=double,float
```

Then you can use `spack diff` to find the exact difference in them (most likely the modules that were used to compile this module)

```bash
➜ spack diff /mmgor5w /cy5tkce
```

```diff
--- fftw@3.3.10/mmgor5w3daiwtsdbyl4dfhjsueaciry2
+++ fftw@3.3.10/cy5tkcetpgx35rok2lqfi3d66rjptkva
@@ depends_on @@
-  fftw intel-oneapi-mpi build
+  fftw openmpi build
[...]
```

Therefore, we know that in this example the first package depends on intel-oneapi-mpi and the second one on `openmpi`.

### Debugging modules

Sometimes one needs to know what `spack load somepackage` does exactly (e.g. because a library is still not found even though you loaded the module). Adding `--sh` to `spack load` prints out all commands that would be executed during the `module load` allowing you to understand what is going on.

```bash
➜ spack load --sh cmake%gcc@12
export ACLOCAL_PATH=[...];
export CMAKE_PREFIX_PATH=[...];
export CPATH=[...];
export LD_RUN_PATH=[...];
export LIBRARY_PATH=[...];
export MANPATH=[...];
export PATH=[...];
export PKG_CONFIG_PATH=[...];
export SPACK_LOADED_HASHES=[...];
```

### Commonly used modules

This is a list of modules I commonly use. While it might not be directly usable for other people and will go out of date quickly, it might still serve as a good starting point.

```bash
spack load openmpi@4.1.6%gcc@12.2/exh7lqk
spack load --only package fftw@3.3%gcc@12.2/42q2cmu
spack load libtool%gcc@12.2 # GNU Autotools
spack load --only package hdf5%gcc@12.2/z3jjmoe # +mpi
spack load numactl%gcc@12.2
spack load metis%gcc@12.2
spack load intel-tbb%gcc@12.2
spack load gsl%gcc@12.2
spack load cmake@3.24%gcc@12.2
spack load gcc@12.2
spack load --only package python@3.11.3%gcc@12
```

## Examples

The examples in this section are not intended to be official documentation on how to use these software packages or the most efficient way to utilize VSC, but rather examples on how VSC usage can look in practice and inspiration for own jobscripts.

### MUSIC and SWIFT

We are using [MUSIC](https://github.com/cosmo-sims/music) to generate initial simulations for cosmological simulations and then run them using [SWIFT](https://swift.strw.leidenuniv.nl/).

#### Managing modules

```bash
➜ cat modules.sh 
spack load openmpi@4.1.6%gcc@12.2/exh7lqk
spack load --only package fftw@3.3%gcc@12.2/42q2cmu
spack load libtool%gcc@12.2 # GNU Autotools
spack load --only package hdf5%gcc@12.2/z3jjmoe # +mpi
spack load numactl%gcc@12.2
spack load metis%gcc@12.2
spack load intel-tbb%gcc@12.2
spack load gsl%gcc@12.2
spack load cmake@3.24%gcc@12.2
spack load gcc@12.2
➜ source modules.sh
➜ export LD_LIBRARY_PATH=$LIBRARY_PATH
```

#### Compiling MUSIC
```bash
➜ git clone https://github.com/cosmo-sims/MUSIC2.git
➜ cd music/
➜ mkdir build
➜ cd build/
➜ cmake ..
➜ make -j 20
➜ ./MUSIC
```

#### Compiling SWIFT
```bash
➜ git clone https://gitlab.cosma.dur.ac.uk/swift/swiftsim.git
➜ cd swiftsim/
➜ ./autogen.sh
➜ ./autogen.sh
➜ ./configure --enable-fof --enable-compiler-warnings=yes --enable-stand-alone-fof --with-numa --with-tbbmalloc 
# check the summary to see if everything you need is enabled/detected
➜ make -j 20
➜ ./swift # or ./swift_mpi
```

#### A job-script for MUSIC

```bash
#!/bin/bash
#SBATCH --job-name=music-auriga6
#SBATCH --mail-type=ALL
#SBATCH --mail-user=test@example.com
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --exclusive
#SBATCH --time=2:00:00

ROOT=/gpfs/data/fs12345/path/to/project
MUSIC=$ROOT/music/build/MUSIC
run=$1

cd $ROOT
source ./modules.sh
export LD_LIBRARY_PATH=$LIBRARY_PATH

cd $ROOT/data/$run/

$MUSIC music.conf
```
Submit as `sbatch music_job.sh something` to run using `data/something/music.conf`.

#### A job-script for small SWIFT simulations

For (very) small numbers of particles MPI overhead might slow down the simulation more than speed it up. Therefore, we could just use one of the CPUs of a shared node.

```bash
#!/bin/bash
#SBATCH --job-name=auriga6
#SBATCH --mail-type=ALL
#SBATCH --mail-user=test@example.com
#SBATCH --ntasks=1
#SBATCH --cpus-per-task 64
#SBATCH --ntasks-per-node=1
#SBATCH --time=24:00:00
#SBATCH --mem=128GB

ROOT=/gpfs/data/fs72085/lwinkler/projects/cosmos_data/auriga-resim
swift=$ROOT/swiftsim/swift
run=$1

cd $ROOT
source ./modules.sh
export LD_LIBRARY_PATH=$LIBRARY_PATH

cd $ROOT/data/$run/

$swift --cosmology --self-gravity --fof --limiter --threads=64 --pin run_auriga6.yml
```
#### A job-script for large SWIFT simulations

Check ["Running on Large Systems"](https://swift.strw.leidenuniv.nl/docs/GettingStarted/running_on_large_systems.html) for more information.

```bash
#!/bin/bash
#SBATCH --job-name=auriga6
#SBATCH --mail-type=ALL
#SBATCH --mail-user=test@example.com
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=2
#SBATCH --exclusive
#SBATCH --time=24:00:00

ROOT=/gpfs/data/fs72085/lwinkler/projects/cosmos_data/auriga-resim
swift=$ROOT/swiftsim/swift_mpi
run=$1

cd $ROOT
source ./modules.sh
export LD_LIBRARY_PATH=$LIBRARY_PATH

cd $ROOT/data/$run/

mpirun -np 8 $swift --cosmology --self-gravity --fof --limiter --threads=64 --pin run_auriga6.yml
```

## Former guides

The following sections have been removed from the main guide as they are most likely no longer valid.

### Avoiding broken programs due to loaded dependencies

{{< alert type="warning" >}} Recent versions of spack don't set `$LD_LIBRARY_PATH` any more, which means that "unnecessarily" loaded spack modules should no longer affect other programs at runtime. If you manually modify `$LD_LIBRARY_PATH` you might still run into these issues now.
{{< /alert >}}

Loading a spack module not just loads the specified module, but also all dependencies of this module. With some modules like `openmpi` that dependency tree can be quite large.

```bash
➜ spack find -d openmpi%gcc
-- linux-almalinux8-zen3 / gcc@11.2.0 ---------------------------
openmpi@4.1.4
    hwloc@2.6.0
        libpciaccess@0.16
        libxml2@2.9.12
            libiconv@1.16
            xz@5.2.5
            zlib@1.2.11
        ncurses@6.2
    libevent@2.1.8
        openssl@1.1.1l
    numactl@2.0.14
    openssh@8.7p1
        libedit@3.1-20210216
    pmix@3.2.1
    slurm@22-05-2-1
        curl@7.79.0
        glib@2.70.0
            gettext@0.21
                bzip2@1.0.8
                tar@1.34
            libffi@3.3
            pcre@8.44
            perl@5.34.0
                berkeley-db@18.1.40
                gdbm@1.19
                    readline@8.1
            python@3.8.12
                expat@2.4.1
                    libbsd@0.11.3
                        libmd@1.0.3
                sqlite@3.36.0
                util-linux-uuid@2.36.2
        json-c@0.15
        lz4@1.9.3
        munge@0.5.14
            libgcrypt@1.9.3
                libgpg-error@1.42
    ucx@1.12.1

```

And loading module like `openssl` or `ncurses` from spack means that programs that depend on those libraries, but the versions provided by the base operating system, will crash.

```bash
➜ spack load openmpi%gcc
➜ nano somefile.txt
Segmentation fault (core dumped)
➜ htop
Segmentation fault (core dumped)
```

One can avoid this by unloading the affected modules afterwards.

```bash
➜ spack unload ncurses
➜ spack unload openssl
```

But in many cases one doesn't need all dependency modules and is really just interested in e.g. `openmpi` itself. Therefore, one can ignore the dependencies with `--only package`.

```bash
# doesn't affect non-openmpi programs
➜ spack load --only package openmpi%gcc 
```
