#!/bin/bash -l
#
#SBATCH --exclusive
#SBATCH --time=3-00:00:00
#SBATCH --nodes=4
#SBATCH --partition=regular
#SBATCH --ntasks-per-core=1
#SBATCH --cpus-per-task=1
#SBATCH --ntasks-per-node=52
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
module load pmix/2.2.2
module load parallel_studio/2020.2.254
module load intelmpi/2020.2.254
#module load vasp6/6.1
export LD_LIBRARY_PATH=/usr/local/lib64:$LD_LIBRARY_PATH
echo $LD_LIBRARY_PATH
#srun --mpi=pmi2 vasp_std


# SCF calculation
#cp -f INCAR-scf INCAR
#cp -f KPOINTS-scf KPOINTS

mpirun -np 208 /home/users/shenyc/wannier_tools_test/bin/wt.x
echo work done
#srun --mpi=pmi2 /home/users/yzwang/software/VASP/vasp.5.4.4/bin/vasp_ncl
#cp OUTCAR OUTCAR-scf
#cp OSZICAR OSZICAR-scf
#cp EIGENVAL EIGENVAL-scf
#cp CHGCAR CHGCAR-scf
#cp WAVECAR WAVECAR-scf

# SCF calculation
#cp -f INCAR-relax INCAR
#cp -f KPOINTS-scf KPOINTS
#srun --mpi=pmi2 /home/users/qwu/software/VASP/vasp6.3.0/vasp.6.3.0/bin/vasp_std
#srun --mpi=pmi2 /home/users/yzwang/software/VASP/vasp.6.1.1/bin/vasp_std
#cp OUTCAR OUTCAR-relax
#cp OSZICAR OSZICAR-relax
#cp EIGENVAL EIGENVAL-relax




#rm WAVECAR
# calculate for energy bands
#cp -f INCAR-band INCAR
#cp -f KPOINTS-band KPOINTS
#srun --mpi=pmi2 /home/users/yzwang/software/VASP/vasp.5.4.4/bin/vasp_ncl
#cp OUTCAR OUTCAR-band
#cp OSZICAR OSZICAR-band
#cp PROCAR PROCAR-band
#cp EIGENVAL EIGENVAL-band


#cp -f INCAR-wannier INCAR
#cp -f KPOINTS-wannier KPOINTS
#srun --mpi=pmi2 vasp_std
#srun --mpi=pmi2 /home/users/qwu/software/VASP/vasp6.3.0/vasp.6.3.0/bin/vasp_std
#srun --mpi=pmi2 /home/users/yzwang/software/VASP/vasp.5.4.4/bin/vasp_ncl
#cp OUTCAR OUTCAR-wannier
#cp OSZICAR OSZICAR-wannier
#cp EIGENVAL EIGENVAL-wannier
#
#sbatch sub-wannier.sh
