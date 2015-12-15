#!/bin/bash
#SBATCH -J IOR-load3
#SBATCH -N 10
#SBATCH -t 8:00:00
#SBATCH -p regular
#SBATCH --mail-user=glock@lbl.gov
#SBATCH --mail-type=FAIL,END

cd $SCRATCH

srun -N 10 -n 240 /global/u2/g/glock/src/git/ior/src/ior -f /global/u2/g/glock/src/git/ior-apex/inputs.apex/load3-posix-filepertask.ior
srun -N 10 -n 240 /global/u2/g/glock/src/git/ior/src/ior -f /global/u2/g/glock/src/git/ior-apex/inputs.apex/load3-posix-sharedfile.ior
