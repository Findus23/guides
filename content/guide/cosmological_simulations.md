---
title: "Running Cosmological N-Body Simulations"  
date: 2025-02-21  
categories: cosmology  
author: Lukas Winkler  
cc_license: true  
description: "A basic beginners guide for students"  
---

This is a basic guide on how to get started running cosmological simulations using monofonIC and SWIFT.

<!--more-->

## Preparation

This guide assumes that one has access to a Linux setup similar to Ubuntu.
If you are using Windows, the Windows Subsystem for Linux or connecting to a university computer is the easiest way to get started.

- follow https://learn.microsoft.com/en-us/windows/wsl/install for instructions
- install the Windows Terminal (https://apps.microsoft.com/detail/9n0dx20hk701?hl=en-US&gl=US) for a much more user-friendly terminal


While the instructions in this guide are a bit terse, I try to not skip any "obvious" steps. After you succeeded with all steps, try to go back to the start and understand what each step does.

This guide was tested on 21.02.2025 on a fresh install of Debian 12.

## Generating initial conditions

You can learn more about monofonIC and how to use it here: https://github.com/cosmo-sims/monofonIC

```bash
➜ sudo apt update
➜ sudo apt install git
➜ git clone https://github.com/cosmo-sims/monofonIC.git
Cloning into 'monofonIC'...  
remote: Enumerating objects: 3387, done.  
remote: Counting objects: 100% (3387/3387), done.  
remote: Compressing objects: 100% (871/871), done.  
remote: Total 3387 (delta 2543), reused 3333 (delta 2506), pack-reused 0 (from 0)  
Receiving objects: 100% (3387/3387), 1.20 MiB | 12.41 MiB/s, done.  
Resolving deltas: 100% (2543/2543), done.
➜ cd monofonIC
~/monofonIC ➜ ls  
CITATION.bib     FindFFTW3.cmake          example.conf  testing  
CMakeLists.txt   LICENSE                  external      version.cmake  
CONTRIBUTING.md  README.md                include  
Doxyfile.in      bitbucket-pipelines.yml  src
~/monofonIC ➜ sudo apt install build-essentials # install all basic requirements to compile C/C++ code
~/monofonIC ➜ sudo apt install cmake # monofonIC uses cmake for compilation
~/monofonIC ➜ sudo apt install libhdf5-dev libhdf5-mpi-dev # for writing HDF5 files
~/monofonIC ➜ sudo apt install libopenmpi-dev # for MPI
~/monofonIC ➜ sudo apt install libfftw3-dev libfftw3-mpi-dev # for FFTs
~/monofonIC ➜ sudo apt install pkgconf # for detection of these libraries 
~/monofonIC ➜ sudo apt install libgsl-dev # for various numerical algorithms
~/monofonIC ➜ mkdir build
~/monofonIC ➜ cd build
~/monofonIC/build ➜ cmake .. # this should now run through without any issues
[...]
-- Build files have been written to: /home/lukas/monofonIC/build
~/monofonIC/build ➜ make # this should now compile all of the code. If it fails somewhere, please check if all dependencies are installed and redo cmake and make
[...]
[100%] Built target class
~/monofonIC/build ➜ ls  
CMakeCache.txt  _deps                pan_state.mod  rand_int.mod  
CMakeFiles      cmake_install.cmake  rand.mod       version.cc  
Makefile        monofonIC            rand_base.mod
# monofonIC is now the binary program
~/monofonIC/build ➜ ./monofonIC # this should give some info
~/monofonIC/build ➜ cd ..
~/monofonIC ➜ nano example.conf # read through the example configuration
```
Now edit the configuration in `example.conf` to comment out the section for generic output and uncomment the section for swift output:

```diff
--- a/example.conf  
+++ b/example.conf  
@@ -153,11 +153,11 @@ NumThreads      = 8  
##> SWIFT compatible HDF5 format. Format broadly similar to gadget_hdf5 but in a single  
##> file even when using MPI. No h-factors for position and masses and no sqrt(a)-factor for the velocities.  
##> IDs are stored using 64-bits unless UseLongids is set to false.  
-# format          = SWIFT  
-# filename        = ics_swift.hdf5  
-# UseLongids      = true  
+format          = SWIFT  
+filename        = ics_swift.hdf5  
+UseLongids      = true  
   
##> Generic HDF5 output format for testing or PT-based calculations  
-format          = generic  
-filename        = debug.hdf5  
-generic_out_eulerian = yes  # if yes then uses PPT for output  
+#format          = generic  
+#filename        = debug.hdf5  
+#generic_out_eulerian = yes  # if yes then uses PPT for output
```
Also change `NumThreads` to the number of CPU cores available.

Now save the file (CTRL+O and Enter) and close nano (CTRL+X).

```bash
~/monofonIC ➜ ./build/monofonIC example.conf # this now runs the actual initial conditions generation; with a resolution of 128^3 particles this should finish very quickly
~/monofonIC ➜ ls # we now have a hdf5 file containing our initial conditions
[...] 
ics_swift.hdf5  
[...]

```

### Understanding HDF5 files (optional tangent) 

HDF5 files can contain arbitrary amounts of groups, metadata and (high-dimensional) arrays. `h5glance` can quickly show the content of an hdf5 file. It is a python script and we can quickly install it:

```bash
➜ cd # go back to the home directory for now
➜ sudo apt install python3-pip
➜ sudo apt install python3-venv
➜ python3 -m venv h5glance-venv
➜ cd monofonIC
~/monofonIC ➜ ~/h5glance-venv/bin/h5glance ics_swift.hdf5    
ics_swift.hdf5  
├Header (10 attributes)  
├ICs_parameters (18 attributes)  
├PartType1  
│ ├Coordinates  [float64: 2097152 × 3]  # X/Y/Z coordinates of all 128^3 particles
│ ├Masses       [float64: 2097152] # their masses  
│ ├ParticleIDs  [uint64: 2097152] # their IDs  
│ └Velocities   [float64: 2097152 × 3]  # and their X/Y/Z velocities
└Units (5 attributes)
~/h5glance-venv/bin/h5glance --attrs ics_swif  
t.hdf5
[...] # also showing the attributes stored in Header
```

## Installing SWIFT

You can learn more about SWIFT here: https://swift.strw.leidenuniv.nl/

If you are using macOS, [additional notes apply](https://swift.strw.leidenuniv.nl/docs/GettingStarted/compiling_code.html#macos-specific-oddities). There is also [a cliff-notes summary of this information](https://swift.strw.leidenuniv.nl/onboarding.pdf ).


```bash
➜ cd # go back to the home directory
➜ git clone https://gitlab.cosma.dur.ac.uk/swift/swiftsim.git
➜ cd swiftsim
~/swiftsim ➜ sudo apt install autoconf # this might already be installed
~/swiftsim ➜ sudo apt install libnuma-dev

~/swiftsim ➜ ./autogen.sh
# the parameters here depend on your use-case. In case you change them, you need to recompile swift (redo all steps below)
~/swiftsim ➜ ./configure --help # this shows you all possible options
~/swiftsim ➜ ./configure --enable-fof --with-numa
[...]
# this summary should look something like this. If you didn't get this summary, check if all dependencies are installed and re-run configure
------- Summary --------  
  
  SWIFT v.2025.01  
  
  Compiler             : mpicc    
   - vendor            : gnu  
   - version           : 12.2.0  
   - flags             :  -flto -O3 -fomit-frame-pointer -malign-double -fstrict-aliasing -ffast-math -funroll-loops -march=amdfam10 -mavx2 -pthread -Wall -  
Wextra -Wno-unused-parameter -Wshadow -Werror -Wno-alloc-size-larger-than -Wstrict-prototypes  
  MPI enabled          : yes  
  HDF5 enabled         : yes  
   - parallel          : no  
  METIS/ParMETIS       : no / no  
  FFTW3 enabled        : yes  
   - threaded/openmp   : yes / no  
   - MPI               : no  
   - ARM               : no  
  GSL enabled          : yes  
  GMP enabled          : no  
  HEALPix C enabled    : no  
  libNUMA enabled      : yes  
  GRACKLE enabled      : no  
  Sundials enabled     : no  
  Special allocators   : no  
  CPU profiler         : no  
  Pthread barriers     : yes  
  VELOCIraptor enabled : no  
  FoF activated:       : yes  
  Lightcones enabled   : no  
  Moving-mesh enabled  : no  
  
  Hydro scheme       : sphenix  
  Dimensionality     : 3  
  Kernel function    : cubic-spline  
  Equation of state  : ideal-gas  
  Adiabatic index    : 5/3  
  Riemann solver     : none  
  SPMHD scheme       : none  
  Adaptive softening : no  
  
  Gravity scheme      : with-multi-softening  
  Multipole order     : 4  
  Compute potential   : yes  
  No gravity below ID : no  
  Make gravity glass  : no  
  External potential  : none  
  Forcing terms       : none  
  
  Pressure floor       : none  
  Entropy floor        : none  
  Cooling function     : none  
  Chemistry            : none  
  Tracers              : none  
  Stellar model        : basic  
  Star formation model : none  
  Star feedback model  : none  
  Sink particle model  : none  
  Black holes model    : none  
  Radiative transfer   : none  
  Extra i/o            : none  
  
  Atomic operations in tasks  : yes  
  Individual timers           : no  
  Task debugging              : no  
  Threadpool debugging        : no  
  Debugging checks            : no  
  Interaction debugging       : no  
  Stars interaction debugging : no  
  Naive interactions          : no  
  Naive stars interactions    : no  
  Gravity checks              : no  
  Custom icbrtf               : no  
  Boundary particles          : no  
  Fixed boundary particles    : no  
  Planetary fixed entropy     : no  
  Ghost statistics            : no  
  
  Continuous Sim. Data Stream : no
# now we can compile swift
~/swiftsim ➜ make -j 10 # replace 10 with the number of CPU cores you have to speed up the compilation
# compilation can take quite a while depending on your system
# if you see it end with 
# make: *** [Makefile:599: all] Error 2
# something went wrong
[...]
make[1]: Leaving directory '/home/lukas/swiftsim'
~/swiftsim ➜ ls # you now have two programs. Unless you want to run on large systems, you can ignore the MPI version of swift.
[...]
swift  
[...] 
swift_mpi
[...]
~/swiftsim ➜ ./swift  
Welcome to the cosmological hydrodynamical code  
   ______       _________________  
  / ___/ |     / /  _/ ___/_  __/  
  \__ \| | /| / // // /_   / /      
 ___/ /| |/ |/ // // __/  / /       
/____/ |__/|__/___/_/    /_/
[...]

```

## Running an N-Body simulation

```bash
➜ cd # go back to the home directory
➜ mkdir test-simulation
➜ cd test-simulation
~/test-simulation ➜ cp ../monofonIC/ics_swift.hdf5 . # copy our ICs over
~/test-simulation ➜ nano swift-config.yml # create the config for swift
```

You can use this as a starting-point for a dark-matter only cosmological simulation. All parameters (and their default values) are described [in the swift documentation]( https://swift.strw.leidenuniv.nl/docs/ParameterFiles/index.html) and you might need to tweak some things depending on your goal:
```yaml
InternalUnitSystem:
  UnitMass_in_cgs:     1.98841e43    # 10^10 M_sun
  UnitLength_in_cgs:   3.08567758e24 # 1 Mpc
  UnitVelocity_in_cgs: 1e5           # 1 km/s
  UnitCurrent_in_cgs:  1             # Amperes
  UnitTemp_in_cgs:     1             # Kelvin

Cosmology:
  Omega_cdm:      0.3099
  Omega_lambda:   0.6901
  Omega_b:        0
  h:              0.67742
  a_begin:        0.04
  a_end:          1.0

TimeIntegration:
  dt_min:     1e-6
  dt_max:     1e-2

Gravity:
  eta:          0.025
  MAC:          adaptive
  theta_cr:     0.6
  epsilon_fmm:  0.001
  comoving_DM_softening:     0.078125
  max_physical_DM_softening: 0.078125
  mesh_side_length:       512

Snapshots:
  basename:            output
  delta_time:          1.0816
  scale_factor_first:  0.1
  compression:         4
  invoke_ps:           1
  invoke_fof:          1
  output_list_on:      1
  output_list:         outputs.txt

Statistics:
  delta_time:          1.01
  scale_factor_first:  1.0
  output_list_on:      1
  output_list:         outputs.txt

InitialConditions:
  file_name:                   ics_swift.hdf5
  periodic:                    1
  cleanup_h_factors:           0
  cleanup_velocity_factors:    0

Restarts:
  enable:             1
  save:               1
  subdir:             restart
  basename:           swift
  delta_hours:        2.0
  stop_steps:         100
  max_run_time:       24.0

FOF:
   basename:                        fof_output
   scale_factor_first:              0.91
   time_first:                      0.2
   delta_time:                      1.005
   linking_types:                   [0, 1, 0, 0, 0, 0, 0]
   attaching_types:                 [1, 0, 0, 0, 1, 1, 0]
   min_group_size:                  256
   linking_length_ratio:            0.2
   seed_black_holes_enabled:        0

PowerSpectrum:
  grid_side_length: 512
  num_folds: 4
  fold_factor: 2
  window_order: 2
  requested_spectra: ["matter-matter"]
  output_list_on:      1
  output_list:         outputs.txt
```

The most important changes:
- set `Cosmology` to the same parameters you used in monofonIC
- set `Cosmology.a_begin` to the `zstart` you used in monofonIC (remember that `a=1/(z+1)`)
- Adapt `Gravity.comoving_DM_softening` and `Gravity.max_physical_DM_softening` to the resolution of your simulation. `boxsize/resolution/30` is a possible starting-point
- set `mesh_side_length` (the resolution of the PM grid) to 2x the resolution of your particles 
- set `InitialConditions.file_name` to your initial conditions file
- check that `Restarts.max_run_time` is not lower than the time you would expect the simulation to take as it gets halted at this time

Create another file called `outputs.txt` (`nano outputs.txt`) where you specify at which times swift should write all outputs. You can either use scale factor a or redshift z as the time unit:
```yaml
# Scale Factor
0.025
0.05
0.1
0.166666
0.333333
0.5
0.666666
1.0
```

```yaml
# Redshift
[...]
15
10
2
0
```

Now you can start the actual N-Body simulation:

```bash
# use the correct path to the swift program you compiled before
# set the number of threads to the number of CPU cores you have available
~/test-simulation ➜ ../swiftsim/swift --self-gravity --cosmology --fof --power --threads=6 --pin swift-config.yml
# if everything goes well, you should see this line after a while
[00010.6] engine_init_particles: Running initial fake time-step.
# afterwards swift will report the progress of the simulation (remember that we are running the simulation until a=1 or z=0)

#   Step           Time Scale-factor     Redshift      Time-step Time-bins      Updates    g-Updates    s-Updates sink-Updates    b-Updates  Wall-clock time  [ms]  Props    Dead time [ms]    
      0   1.414229e-04    0.0400000   24.0000000   0.000000e+00    1   56            0      2097152            0            0            0             33757.457    257            15.167
[...]
```

## Miscellaneous notes

- If you had to abort a simulation, you can continue it from the last restart-file (written every `Restart.delta_hours` hours) by adding `--restart` to the swift command
- While the monofonIC config uses Mpc/h as the length unit, SWIFT uses Mpc as a length unit in all output and configuration options.

## Reading the Output

One easy way to read and use the simulation output in python is the `swiftsimio` package. You can find out more about it [in the documentation](https://swiftsimio.readthedocs.io/en/latest/).
Alternatively most data can easily be read directly in python:

```python


```
