Crossroads/NERSC-9 IOR Benchmark 
================================================================================

I. Benchmark Description
--------------------------------------------------------------------------------
IOR is designed to measure parallel I/O performance at both the POSIX and MPI-IO
level.  All of the general run rules for APEX benchmarking apply.


II. Build Instructions
--------------------------------------------------------------------------------
MPI, MPI-IO, and OpenMP are required in order to build and run the code. The
source code used for this benchmark is derived from IOR 3.0.1 and it is
included here.  More information about IOR is available on 
https://github.com/LLNL/ior.

After extracting the tar file, ensure that the MPI compiler wrappers (e.g.,
`mpicc`) are in `$PATH` and then

    cd ior-3.0.1-apex
    ./configure
    make

This will build both IOR with the POSIX and MPI-IO interfaces and create the
IOR executable at `src/ior`.


III. Run Rules
--------------------------------------------------------------------------------
The intent of these benchmarks is to measure the performance of I/O operations
on the platform storage under three loads:

1. fully sequential, large-transaction reads and writes
2. locally random, overlapping, small-transaction reads 
3. fully random, small-transaction reads and writes

Observed benchmark performance shall be obtained from a storage system
configured as closely as possible to the proposed platform storage.  If the
proposed solution includes multiple file access protocols (e.g., pNFS and NFS)
or multiple tiers accessible by applications, benchmark results for IOR
shall be provided for each protocol and/or tier.

Performance projections are permissible if they are derived from a similar
system that is considered an earlier generation of the proposed system.

### Load 1: Sequential Loads

This benchmark is intended to measure the throughput of the storage subsystem
and contains features that minimize caching/buffering effects.  As such, the
Offerer should not utilize optimizations that cache or buffer the transferred
data in compute node memory.

The Offeror shall run the following tests:

* MPI/IO file per process (i.e., N processes operate on N files)
* MPI/IO shared file (i.e., N processes operate on 1 file)
* POSIX I/O file per process 
* POSIX I/O shared file 

Each of these four tests must be run at the following levels of concurrency:

1. a single compute node
2. 10% of the proposed system's compute nodes
3. 50% of the proposed system's compute nodes

These tests must be configured via a combination of input configuration files
and command line options.  Annotated input configuration files are provided in
the `inputs.apex/` subdirectory and demonstrate how these tests can be defined
for the purposes of these benchmarks.

The Offeror MUST modify the following parameters for each benchmark test:

* `numTasks` - the number of MPI processes to use.  The Offeror may choose to
  run multiple MPI processes per compute node to achieve the highest bandwidth
  results.
* `segmentCount` - number of segments (blocks * numTasks) in a file.  This
  governs the size of the file(s) written/read, and the amount of data 
  written/read by each node must exceed 1.5 times the memory available for the
  file system's page cache (typically the entire node's RAM).
* `memoryPerNode` - size (in bytes) of each node's RAM to be filled before
  running the benchmark test.  This value must be no less than 80% of the total
  RAM available on each compute node and is intended to represent the memory
  footprint of a real application.

In addition, the Offeror MAY modify the following parameters for each test:

* `transferSize` - the size (in bytes) of a single data buffer to be transferred
   in a single I/O call.  The Offeror should find the transferSize that produces
   the highest bandwidth results and report this optimal transferSize.
   `blockSize` must always be equal to `transferSize`.
* `testFile` - path to data files to be read or written for this benchmark
* `hintsFileName` - path to MPI-IO hints file
* `collective` - MPI-IO collective vs. independent operation mode

As mentioned above, `segmentCount` must be set so that the total amount of
data written is greater than 1.5 times the amount of RAM on the compute nodes.
The total fileSize is given by

    fileSize = segmentCount * blockSize * numTasks

So for a 10-node test with an aggregate 640 GB of RAM, fileSize must be at
least 960 GB.  Assuming `blockSize=1MB` and `numTasks=240` (24 MPI processes
per node) is optimal, an appropriate `segmentCount` would be

    segmentCount = fileSize / ( blockSize * numTasks ) = 4096

Page caches on the storage subsystem's servers may still be used, but they must
be configured as they would be for the delivered Crossroads/NERSC-9 systems.

Providing an MPI-IO "hints" file for the MPI-IO runs, which IOR will look for in
the file specified by the `hintsFileName` keyword in the input file, is allowed.
Documentation on IOR's support for MPI-IO hints can be found in the "HOW DO I
USE HINTS?" section of the IOR User Guide (found in `doc/USER_GUIDE`).

### Load 2: Localized Random Read Loads

This benchmark is designed to emulate the I/O workload from an
application that comprises a significant fraction of the bioinformatics
workload at NERSC.  This benchmark runs as a hybrid MPI+OpenMP application
where each OpenMP thread

1. obtains a lock that prevents other threads from performing IO
2. reads a 10 MB block of the input file sequentially using 4K transfers
3. releases the lock from step #1
4. re-reads the 10 MB block of input using 4K transactions without locking
5. repeats the process starting at step #1

The result of multiple threads executing Step #4 is localized random I/O and
nontrivial queue depths.

The Offeror shall run the following tests:

* POSIX file per process (i.e., N processes operate on N files)
* POSIX shared file (i.e., N processes operate on 1 file)

Each of these four tests must be run at the following levels of concurrency:

1. a single compute node
2. 10% of the proposed system's compute nodes

These tests must be configured via a combination of input configuration files
and command line options.  Annotated input configuration files are provided in
the `inputs.apex/` subdirectory and demonstrate how these tests can be defined
for the purposes of these benchmarks.

The Offeror MUST modify the following parameters for each benchmark test:

* `numTasks` - the number of MPI processes to use.  This parameter must equal
  the number of nodes used so that there is, at maximum, one MPI process per
  compute node.
* `segmentCount` - number of segments (blocks) in a file.  This governs the
  size of the file(s) read, and the amount of data read by each node must
  exceed 1.5 times the memory available for the file system's page cache
  (typically the entire node's RAM).

In addition, the Offeror MAY modify the following parameters for each test:

* `testFile` - path to data files to be read or written for this benchmark
* `threadsPerTask`- the number of threads per MPI process to use.  This number
  must not be less than four.

Because this test is a read-only test, the input data files to be read by IOR
must be generated before these benchmark tests are run.  This can be done either
using the standard `dd` command, e.g., 

    dd if=/dev/urandom of=/scratch/datafile.dat bs=1G count=5 iflag=fullblock oflag=direct

or using a separate IOR run (whose performance would NOT be reported).  An
example IOR input to do this is included in the `inputs.apex/` subdirectory.

However, it is critical to ensure that the input data files are NOT in the 
compute nodes' page cache before the benchmark is run.  This can be achieved by
executing the following on all compute nodes immediately before running the
Load 2 benchmark:

    su -c "echo 1 > /proc/sys/vm/drop_caches"

As with Load 1, `segmentCount` must be set so that the total amount of data
read is greater than 1.5 times the amount of RAM on the compute nodes.  The
total fileSize is given by

    fileSize = segmentCount * 10 MiB * numTasks

So for a 10-node test with an aggregate 640 GB of RAM, fileSize must be at
least 960 GB.  This test requires 1 MPI process per node, so an appropriate
`segmentCount` would be

    segmentCount = fileSize / ( 10 MiB * numTasks ) = 9831

### Load 3: Fully Random Loads

As with Load 1, this benchmark is intended to measure the throughput of the
storage subsystem and contains features that minimize caching/buffering effects.
As such, the Offerer should not utilize optimizations that cache or buffer the
transferred data in system memory.

The Offeror shall run the following tests:

* POSIX I/O file per process 
* POSIX I/O shared file 

Both of these tests must be run at the following levels of concurrency:

1. a single compute node
2. 10% of the proposed system's compute nodes

These tests must be configured via a combination of input configuration files
and command line options.  Annotated input configuration files are provided in
the `inputs.apex/` subdirectory and demonstrate how these tests can be defined
for the purposes of these benchmarks.

The Offeror MUST modify the following parameters for each benchmark test:

* `numTasks` - the number of MPI processes to use.  The Offeror may choose to
  run multiple MPI processes per compute node to achieve the highest bandwidth
  results.
* `segmentCount` - number of segments (blocks * numTasks) in a file.  This
  governs the size of the file(s) written/read, and the amount of data 
  written/read by each node must exceed 1.5 times the memory available for the
  file system's page cache (typically the entire node's RAM).
* `memoryPerNode` - size (in bytes) of each node's RAM to be filled before
  running the benchmark test.  This value must be no less than 80% of the total
  RAM available on each compute node and is intended to represent the memory
  footprint of a real application.

In addition, the Offeror MAY modify the following parameter for each test:

* `testFile` - path to data files to be read or written for this benchmark

As with the other loads, `segmentCount` must be set so that the total amount
of data written is greater than 1.5 times the amount of RAM on the compute
nodes.  The total fileSize is given by

    fileSize = segmentCount * 4K * numTasks

So for a 10-node test with an aggregate 640 GB of RAM, fileSize must be at
least 960 GB.  Assuming `numTasks=240` (24 MPI processes per node), an
appropriate `segmentCount` would be

    segmentCount = fileSize / ( 4K * numTasks ) = 1048576

### Running IOR

IOR is executed as any other standard MPI application would be on the proposed
system.  For example,

    mpirun -np 64 ./ior -f ./load1-posix-filepertask.ior

or

    srun -n 64 ./ior -f ./load1-posix-filepertask.ior

will execute IOR with 64 processes and use the input configuration file called
`load1-posix-filepertask.ior`.

Example input configuration files for all required tests are supplied in the
`inputs.apex/` directory with additional annotations and details where
appropriate.


IV. Permitted Modifications
--------------------------------------------------------------------------------

Modifications to the benchmark application code are only permissible to enable
correct compilation and execution on the target platform.  Any modifications
must be fully documented (e.g., as a diff or patch file) and reported with the
benchmark results.


V. Reporting Results
--------------------------------------------------------------------------------

### Load 1: Sequential Loads

IOR will execute both read and write tests for each run.  The bandwidth
measurements to be reported are the `Max Write` and `Max Read` values (in 
units of `MB/s`) reported to stdout.

The maximum write and read bandwidths for a single read-and-write test must be
reported for Load 1.  Reporting the maximum read bandwidth from one run and the
maximum write bandwidth from a different run is NOT valid.  Write bandwidth
has slightly higher importance for this test, so if the highest observed read
rate came from a different run than the highest observed write rate, report the
results from the run with the highest write rate.

### Load 2: Localized Random Read Load

IOR will execute a read test for each run.  The bandwidth measurement to be
reported is the `Max Read` value (in units of `MB/s`) reported to stdout.

If the input data file(s) are replicated, moved, or otherwise staged prior
to the launch of this test, the following data must also be provided:

1. time to move or replicate the data file(s) 
2. a description of how this data motion was achieved (e.g., via a resource
   specification in the job script) 
3. the total amount of data moved to prepare the input data for the benchmark
   (e.g., `3 * fileSize` if the file is replicated three times)

### Load 3: Fully Random Loads

IOR will execute both read and write tests for each run.  The bandwidth
measurements to be reported are the `Max Write` and `Max Read` values (in 
units of `MB/s`) reported to stdout.

As with Load 1, the maximum write and read bandwidths for a single 
read-and-write test must be reported for Load 3.  Read bandwidth has slightly
higher importance for this test, so report results from the run with the highest
read rate.

### Benchmark Platform Description

In addition to maximum bandwidths, the Offeror must also provide a comprehensive
description of the environment in which each benchmark was run.  This must
include:

* Client and server system configurations, including node and processor counts,
  processor models, memory size and speed, and OS (names and versions)
* Storage media and their configurations used for each tier of the storage
  subsystem
* Network fabric used to connect servers, clients, and storage, including
  network configuration settings and topology
* Client and server configuration settings including
    * Client and server sysctl settings
    * Driver options
    * Network interface options
    * File system configuration and mount options
* Compiler name and version, compiler options, and libraries used to build
  benchmarks

### Performance Projections

Benchmark results (or projections) for the proposed system shall be reported
in the APEX results spreadsheet. Projections shall be rigorously derived and
documented.  Specifically, the output files (including stdout and stderr) on
which the projections are based, as well as a description of the projection
method, must be included.  

In addition, each system used for benchmark projections must be described per
the "Benchmark Platform Description" section above.  Enter the corresponding
letter of the "System" column of Table 3 into the "System" column of the
benchmark result tables.  For proposals that call for a phased deployment of
technology, duplicate the tables and provide the performance information for
each proposed phase.

Note that in the supplied spreadsheet, the "Proposed System Node Count" entry
refers to the value for the full, proposed system, whether benchmarked or
projected.  The benchmark data from which projections are derived should be
included separately from the spreadsheet.

### Code Modifications

If the benchmark code is modified (per Section IV, Permitted Modifications),
a complete history of changes made to the benchmark code must be supplied.
These changes should take the form of one or more diffs (or patch files) along
with documentation justifying the changes.

### Submission of Results

A paper version of all completed tables shall be submitted as part of the RFP
response. Additionally, the Offeror shall submit electronically all completed
tables, benchmark codes, and output files (excluding binary data files), and
documentation on any code optimizations or configuration changes. The submitted
source should be in a form that can be readily compiled on the proposed system.
