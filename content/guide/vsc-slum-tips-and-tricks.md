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
salloc --ntasks=2 --mem=2G --time=01:00:00
```

Don't forget to then connect to the node you get assigned:
```bash
ssh n1234-567
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
mmlsquota --block-size auto -j data_fs00000 data
```
for $DATA and 
```bash
mmlsquota --block-size auto -j home_fs00000 home
```
for $HOME where `00000` is the ID of the own project (accessible using `groups`)

## Job scripts

### Basic Template

Your job script is a regular bash script (`.sh` file). In addition, you can specify options to `sbatch` in the beginning of your file:

```text
#!/bin/bash
#SBATCH --job-name=somename
#SBATCH --mail-type=ALL
#SBATCH --mail-user=yourmail@example.com
```

- `--job-name`: A short name for this job. It is often displayed truncated after a few characters.
- `--mail-type=ALL`: notify on all events per E-Mail

`--long-option=value` and `--long-option value` are equivalent.

### Single Core job

Only specify `--ntask=1` and the amount of memory you need.

```
#SBATCH --ntasks=1 # (also -n 1`
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

- `$SLURM_NODELIST`
- `$SLURM_NNODES`
- `$SLURM_NPROCS`
- `SLURM_JOB_NAME`

Especially the latter can be used e.g. for running MPI programs with the requested number of CPU cores:

```bash
mpiexec -np $SLURM_NPROCS ./program
```

### Submitting Jobs

A job script can be submitted using 
```bash
sbatch jobfile.sh # you can also add sbatch options here
```
You can also 
As the `jobfile.sh` is a regular shell script, you can pass arguments like 

```bash
sbatch jobfile.sh somevalue
```

and then access `somevalue` as `$1` in your script. This way multiple similar jobs can be submitted without needing to edit the jobscript.

## Queue

The current status of jobs in the Queue can be seen using [`squeue`](https://slurm.schedmd.com/squeue.html).

```bash
squeue -u username
```

Especially useful is the estimated start time of a scheduled job:

```bash
squeue -u username --start
```

A lot more information about scheduling including the calculated priority of the job can be found using [`sprio`](https://slurm.schedmd.com/sprio.html)
```bash
sprio -u lwinkler
```

This will also show the reason why the job is still queued for which an explanation can be found [in the slurm documentation](https://slurm.schedmd.com/squeue.html#lbAF).


Details about past Jobs (like maximum memory usage), can be found using [`sacct`](https://slurm.schedmd.com/sacct.html). You can manually specify the needed columns or display most of them using `--long`

```bash
sacct -j 2052157 --long 
```

## SSH login via login.univie.ac.at

[official docs](https://wiki.vsc.ac.at/doku.php?id=doku:vpn_ssh_access) (but we are using the more modern ProxyJump instead of Agent forwarding as this way we don't have to trust the intermediate server with our private key)

Access to VSC is only possible from IP addresses of the partner universities. If you are from the university of vienna and don't want to use the VPN, an SSH tunnel via `login.univie.ac.at` is an alternative.


To connect to the login server, the easiest thing is to put the config for the host in your `~/.ssh/config` (create it, if it doesn't yet exist).

```ssh-config
Host loginUnivie
    HostName login.univie.ac.at
    User testuser12 # replace with your username
    # the following are needed if you are using OpenSSH 8.8
    # and the login server isn't yet updated to a never version
    HostkeyAlgorithms +ssh-rsa
    PubkeyAcceptedAlgorithms +ssh-rsa
```

This way you should now be able to connect to the login server using
```bash
ssh loginUnivie
```

Then you can add another entry to `~/.ssh/config` for VSC that uses `ProxyJump` to connect via the `loginUnivie` entry we just created. 


```ssh-config
Host vsc4
    Hostname vsc4.vsc.ac.at
    User vscuser
    ProxyJump loginUnivie
    # Port 27 # (only use if you are using ssh keys)
```

```bash
ssh vsc4
```

## Spack Modules

([official docs](https://wiki.vsc.ac.at/doku.php?id=doku:spack), that this guide builds on. More useful tips can be found in the [spack documentation](https://spack.readthedocs.io/en/latest/))

Software that is needed can be loaded via modules. The easiest way to find the right module for the current processor architecture, is directly querying `spack`, which is used to provide all compiled libraries and applications. There should never be a need to run `module` directly and doing so might accidentally pick libraries that are not intended for the current processor architecture.

### Finding the right module

The easiest way is using `spack find`.

```bash
$ spack find cmake
```

If you get a long output, you can ignore everything above the `==> N installed package(s)` line as it is unrelated to your current query. In case this only returns one module that fits your requirements, you can directly replace `spack find` with `spack load` to load this module.

But most of the time, you will find multiple modules which differ in their properties (and `spack load` will fail if the query resolves to more than one package):

```bash
$ spack find cmake
==> 4 installed packages
-- linux-almalinux8-zen / gcc@8.5.0 -----------------------------
cmake@3.21.4

-- linux-almalinux8-zen2 / intel@2021.5.0 -----------------------
cmake@3.21.4

-- linux-almalinux8-zen3 / aocc@3.2.0 ---------------------------
cmake@3.21.4

-- linux-almalinux8-zen3 / gcc@11.2.0 ---------------------------
cmake@3.21.4
```

The most important property is the version and it is denoted with an `@` sign. Another property is the compiler the program or library was compiled with and it can be separated with a `%`.

So if you want to load e.g. `cmake` version 3.x.x compiled with `gcc` version 11, you could directly search for it and subsequently load it.

```bash
$ spack find cmake@3%gcc@11
$ spack load spack find cmake@3%gcc@11 
```

This way if another minor update of cmake is released, your command will load it. If you don't like this, check the next section.

Sometimes there are also multiple variants of the same module. `spack info modulename` can give you an overview over all of them, but that doesn't mean that all combinations of variants/compilers/versions are offered at VSC. If you are for example interested in the `hdf5` library with MPI support, you can search for the following (`-v` gives you the exact properties of each module):

```bash
$ spack find -v hdf5 +mpi
```

### "Locking" modules

If you dislike the fact that `spack load` queries don't resolve to specific packages, but just filters that describe the properties you want or prefer exactly specifying the version of a package for reproducibility, you can find the hash of package using `spack find -l` and can then use `/hash` to always refer to this exact package:

```bash
$ spack find -l gsl
==> 1 installed package
-- linux-almalinux8-zen3 / gcc@11.2.0 ---------------------------
4rhrhm3 gsl@2.7
$ spack load /4rhrhm3
```

### Find currently loaded modules

```bash
# List all currently loaded packages
$ spack find --loaded
# Unload all currently loaded packages
$ spack unload --all
```

### Avoiding broken programs due to loaded dependencies

Loading a spack module not just loads the specified module, but also all dependencies of this module. With some modules like `openmpi` that dependency tree can be quite large.

```bash
$ spack find -d openmpi%gcc
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
$ spack load openmpi%gcc
$ nano somefile.txt
Segmentation fault (core dumped)
$ htop
Segmentation fault (core dumped)
```

One can avoid this by unloading the affected modules afterwards.
```bash
spack unload ncurses
spack unload openssl
```

But in many cases one doesn't need all dependency modules and is really just interested in e.g. `openmpi` itself. Therefore, one can ignore the dependencies with `--only package`.
```bash
# doesn't affect non-openmpi programs
$ spack load --only package openmpi%gcc 
```

### Comparing modules

Sometimes two packages look exactly the same:

```bash
$ spack find -vl fftw
-- linux-almalinux8-zen2 / intel@2021.5.0 -----------------------
mmgor5w fftw@3.3.10+mpi+openmp~pfft_patches precision=double,float  cy5tkce fftw@3.3.10+mpi+openmp~pfft_patches precision=double,float
```

Then you can use `spack diff` to
```bash
$ spack diff /mmgor5w /cy5tkce
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

Sometimes one needs to know what `spack load somepackage` does exactly (e.g. because a library is still not found even though )

> To be updated


### Commonly used modules

This is a list of modules I commonly used. While it might not be directly usable for other people and will go out of date quickly, it might still serve as a good starting point.

```bash
# To be updated
```