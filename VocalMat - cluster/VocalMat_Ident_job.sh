#!/bin/bash
#SBATCH --partition=scavenge
#SBATCH -o identifier_%A_%a.out
#SBATCH -e identifier_%A_%a.err
#SBATCH --ntasks=1 --nodes=1
#SBATCH --cpus-per-task=6
#SBATCH --mem-per-cpu=10000 
#SBATCH --time=12:00:00


export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

module load MATLAB/2016b

matlab -nodisplay -nosplash -nodesktop -r "cd('/ysm-gpfs/project/ahf38/Antonio_VocalMat/VocalMat-Identifier'); vfilename = '"${1}"', vpathname = '"$FOLDER"', VocalMat_Identifier_v5b"
