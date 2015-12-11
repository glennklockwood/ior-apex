Crossroads/NERSC-9 IOR Benchmark 
================================================================================

Benchmark Description
--------------------------------------------------------------------------------
IOR is designed to measure parallel I/O performance at both the POSIX and MPI-IO
level.  All of the general run rules for APEX benchmarking apply.


Build Instructions
--------------------------------------------------------------------------------
MPI, MPI-IO, and OpenMP are required in order to build and run the code. The
source code used for this benchmark is derived from IOR 3.0.1 and it is
included here.  More information about IOR is available on 
https://github.com/LLNL/ior.

After extracting the tar file,

    cd ior-apex
    ./configure
    make

This will build both IOR with the POSIX and MPI-IO interfaces and create the
IOR executable located in `src/ior`.

Run Rules
--------------------------------------------------------------------------------
The intent of these benchmarks is to measure the performance of I/O operations
on the platform storage under two loads:

1. fully sequential, large-transaction reads and writes

2. locally random, overlapping, small-transaction reads 

Observed benchmark performance shall be obtained from a storage system
configured as closely as possible to the proposed platform storage.  If the
proposed solution includes multiple file access protocols (e.g., pNFS and NFS)
or multiple tiers accessible by applications, benchmark results for IOR
shall be provided for each protocol and/or tier.

Performance projections are permissible if they are derived from a similar
system that is considered an earlier generation of the proposed system.

### Load 1. Sequential Loads

This benchmark is intended to measure the throughput of the storage subsystem
and contains features that minimize caching/buffering effects.  As such, the
Offerer should not utilize optimizations that cache or buffer the transferred
data in system memory.

The Offeror shall run the following tests:

* MPI/IO file per process (i.e., N processes operate on N files)
* MPI/IO shared file (i.e., N processes operate on 1 file)
* POSIX I/O file per process 
* POSIX I/O shared file 

Each of these four tests must be run at the following levels of concurrency:

a) a single compute node
b) 10% of the proposed system's compute nodes
c) 50% of the proposed system's compute nodes

These tests must be configured via a combination of input configuration files
and command line options.  Annotated input configuration files are provided in
the `inputs.apex/` subdirectory that demonstrate how these tests can be defined
for the purposes of these benchmarks.

The Offeror MUST modify the following parameters for each benchmark test:

* `numTasks` - the number of MPI processes to use.  The Offeror may choose to
  run however multiple MPI processes per compute node to achieve the highest
  bandwidth results.
* `segmentCount` - number of segments (blocks * numTasks) in a file.  This
  governs the size of the file(s) written/read, and the amount of data 
  written/read by each node must exceed 1.5 times the memory available for the
  file system's page cache (typically the entire node's DRAM).
* `memoryPerNode` - size (in bytes) of each node's DRAM to be filled before
  running the benchmark test.  This value must be no less than 80% of the total
  DRAM available on each compute node and is intended to represent the memory
  footprint of a real application.

In addition, the Offeror MAY modify the following parameters for each test:

* `transferSize` and `blockSize` - `transferSize` is the size (in bytes) of a
   single data buffer to be transferred in a single I/O call.  The Offeror
   should find the transferSize that produces the highest bandwidth results
   and report this optimal transferSize.  `blockSize` must always be equal to
   transferSize.
* `testFile` - path to data files to be read or written for this benchmark
* `hintsFileName` - path to MPI-IO hints file
* `collective` - MPI-IO collective vs. independent operation mode

As mentioned above, `segmentCount` must be set so that the total amount of
data written is greater than 1.5 times the amount of DRAM on the compute nodes.
The total fileSize is given by

    fileSize = segmentCount * blockSize * numTasks

So for a 10-node test with an aggregate 320 GB of DRAM, fileSize must be 480 GB.
Assuming the optimal blockSize=1 MB and numTasks=40 (4 MPI processes per node),
an appropriate segmentCount would be

    segmentCount = fileSize / ( blockSize * numTasks ) = 12

Page caches on the storage subsystem servers may still be used, but they must be
configured as they would be for the delivered Crossroads/NERSC-9 systems.

Providing an MPI-IO "hints" file for the MPI-IO runs, which the program will
look for in a file called "hintfile" (or in a file specified by the
hintsFileName keyword in the input file), is allowed.

### Load 2. Localized Random Read Load

This benchmark is designed to emulate the I/O workload that results from an
application that comprises a significant fraction of the bioinformatics
workload at NERSC.  This benchmark runs as a hybrid MPI+OpenMP application
where each MPI process reads its own input file, and each OpenMP thread

1. obtains a lock that prevents other threads from performing IO
2. reads a 10 MB block of the input file sequentially using 4K transfers
3. releases the lock from step #1
4. re-reads the 10 MB block of input using 4K transactions without locking
5. repeats the process starting at step #1

The result of multiple threads executing Step #4 is localizized random I/O and
nontrivial queue depths.

The Offeror shall run the following tests:

* POSIX file per process (i.e., N processes operate on N files)
* POSIX shared file (i.e., N processes operate on 1 file)

Each of these four tests must be run at the following levels of concurrency:

a) a single compute node
b) 10% of the proposed system's compute nodes

These tests must be configured via a combination of input configuration files
and command line options.  Annotated input configuration files are provided in
the `inputs.apex/` subdirectory that demonstrate how these tests can be defined
for the purposes of these benchmarks.

The Offeror MUST modify the following parameters for each benchmark test:

* `numTasks` - the number of MPI processes to use.  This parameter must equal
  the number of nodes used so that there is, at maximum, one MPI process per
  compute node.
* `segmentCount` - number of segments (blocks) in a file.  This governs the
  size of the file(s) read, and the amount of data read by each node must
  exceed 1.5 times the memory available for the file system's page cache
  (typically the entire node's DRAM).

In addition, the Offeror MAY modify the following parameters for each test:

* `testFile` - path to data files to be read or written for this benchmark
* `threadsPerTask`- the number of threads per MPI process to use.  This number
  must not be less than four.

Because this test is a read-only test, the input data files to be read by IOR
must be generated before these benchmark tests are run.  This can be done either
using dd (e.g., `dd if=/dev/urandom of=/scratch/blast.data bs=1G count=5` would
generate a 5 GB input file for `testFile=/scratch/blast.data`) or using a
separate IOR run.  An example IOR input to do this is included in the 
`inputs.apex/` subdirectory.

### Running IOR

The exact execution line cannot be provided here, as it depends on the
particular MPI implementation.  A generic execution line might be:

    mpirun -np 64 ./IOR -f ./ N8TrinityScript

This command will execute IOR on 64 clients with the supplied input
configuration file called "N8TrinityScript".

Six sample batch submission scripts (run.platform.n, where platform refers to
the job scheduler used, and n refers to the number of MPI processes to be
used with this file) are provided that contain the execution lines for all
required runs. 

For each run the program does eight repetitions of the write/read process. 
The maximum values are calculated and these values are to be reported as the
benchmark result.

Permitted Modifications
--------------------------------------------------------------------------------
Modifications to the benchmark are only permissible to enable correct
execution on the target platform.  Any modifications must be fully documented
and reported back to NERSC/ACES.  Changes related to optimization and tuning
must be practical for production utilization of the filesystem.  For example,
optimizations that are tuning hints that can be controlled by users on the
system are permissible, but optimizations that would require superuser
privilege (but are not part of the steady-state configuration of the
filesystem) are not permissible.  

Reporting Results
--------------------------------------------------------------------------------
For all runs it is required to report the maximum write and maximum read
bandwidth. Write bandwidth is the most important, so when in doubt report the
parameters where maximum write bandwidth was achieved.

IOR will execute both read and write tests for each run, doing two
repetitions of each and calculating the maximum values. The bandwidth numbers
to be reported are the results listed as "Max Write" and "Max Read" measured
in "MB/s".

### Benchmark Platform Description

The Offeror must also provide an end-to-end description of the environment
in which each benchmark was run.  This will include:

* Client and server system configurations, including node and processor counts,
  processor models, memory size and speed, and OS (names and versions)
* Storage used for global file system and storage configurations.
* Network fabric used to connect servers, clients, and storage, including
  network configuration settings.  
* Client and server configuration settings.  These should include:
    * Client and server sysctl settings
    * Driver options
    * Network interface options
    * File system configuration options
* Compiler name and version, compiler options, and libraries used to build
  benchmarks.

### Performance Projections

Benchmark results (or projections including original results) for the proposed
system shall be reported in the APEX results spreadsheet. Projections shall be
rigorously derived, easily understood, and thoroughly documented.  Specifically,
output files on which the projections are based and a description of the
projection method must be included. In addition, each system used for benchmark
projections must be described. Enter the corresponding letter of the "System"
column of Table 3 into the "System" column of the benchmark result tables. For
solutions that use multiple phases of technology to increase value, duplicate
the tables and provide the performance information for each phase.

Note that in the supplied spreadsheet, the "Proposed System Node Count" entry
refers to the value for the full, proposed system, whether benchmarked or
projected. 

### Code Modifications

An audit trail showing any changes made to the benchmark codes must be supplied
and it must be sufficient to determine that the changes made conform to the
spirit of the benchmark and do not violate any specific restrictions on the
benchmark.

### Submission of Results

A paper version of all completed tables shall be submitted as part of the RFP
response. Additionally, the Offeror shall submit electronically all completed
tables, benchmark codes, and output files (excluding binary data files), and
documentation on any code optimizations or configuration changes. The submitted
source should be in a form that can be readily compiled on the proposed system.
