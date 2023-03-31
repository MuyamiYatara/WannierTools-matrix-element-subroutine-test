#!/bin/bash -l
#
###SBATCH --exclusive
###SBATCH --time=3-00:00:00
#SBATCH -N 15
#SBATCH -n 20
#SBATCH --partition=regular
#SBATCH --ntasks-per-core=1
#SBATCH --cpus-per-task=1
#SBATCH --partition=long
#SBATCH --job-name=vasp_run
#SBATCH --output=./log
#SBATCH --error=./errormsg
export OMP_NUM_THREADS=1
export MKL_NUM_THREADS=1
export MV2_ENABLE_AFFINITY=0
echo "The current job ID is $SLURM_JOB_ID"
echo "Running on $SLURM_JOB_NUM_NODES nodes:"
echo $SLURM_JOB_NODELIST
echo "Using $SLURM_NTASKS_PER_NODE tasks per node"
echo "A total of $SLURM_NTASKS tasks is used"


ulimit -s unlimited
ulimit -c unlimited
module load oneapi22.3
module load mkl/mkl2022.2.1
module load nvhpc/22.11
module load vasp/vasp6.3.0_nv
export LD_LIBRARY_PATH=/usr/local/lib64:$LD_LIBRARY_PATH
echo $LD_LIBRARY_PATH

mpirun -np 300 /home/ycshen/wannier_tools_test/bin/wt.x
echo work done
