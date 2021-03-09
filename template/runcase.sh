#!/bin/bash
# run from case folder

module load openfoam/last

solver=`cat system/controlDict | grep application | tr -s " " | cut -d' ' -f2 | cut -d';' -f1 | tail -1`

foamGet Allclean
chmod +x Allclean
sh ./Allclean
blockMesh
decomposePar


#cpus=`lscpu | grep "CPU(s):" | head -1 |tr -s " " | cut -d' ' -f2` # how many mpi processes to launch (e.g. Nr of CPUs we have on local the machine)

cpus=$SLURM_NTASKS
mpirun -np $cpus $solver -parallel

./reconstruct_parallel.sh
