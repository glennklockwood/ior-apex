#!/bin/bash
#SBATCH -J IOR-load2
#SBATCH -N 10
#SBATCH -t 8:00:00
#SBATCH -p regular
#SBATCH --mail-user=glock@lbl.gov
#SBATCH --mail-type=FAIL,END

cd $SCRATCH

export OMP_NUM_THREADS=24
srun -N 10 -n 10 -c 24 /global/u2/g/glock/src/git/ior/src/ior -f /global/u2/g/glock/src/git/ior-apex/inputs.apex/load2-posix-filepertask.ior
srun -N 10 -n 10 -c 24 /global/u2/g/glock/src/git/ior/src/ior -f /global/u2/g/glock/src/git/ior-apex/inputs.apex/load2-posix-sharedfile.ior
