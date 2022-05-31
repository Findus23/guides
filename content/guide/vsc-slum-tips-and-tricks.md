---
title: "VSC/Slurm Tips and Tricks"
date: 2022-05-18
categories: cheatsheet
author: Lukas Winkler
cc_license: true
description: "An assorted list of tricks for using the Vienna Scientific Cluster"
---


This is not official documentation for the [Vienna Scientific Cluster](https://vsc.ac.at). For this check the [VSC Wiki](https://wiki.vsc.ac.at). Instead, this is my personal cheat sheet of things that are not well documented elsewhere. Also while the content is focused on the VSC, most of the things mentioned here also apply to similar setups that use Slurm at other universities.

<!--more-->

## Basics

**Always request an interactive session when running anything using a non-trivial amount of CPU power!**


### Quick interactive session

```bash
salloc --ntasks=2 --mem=2G --time=01:00:00
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
