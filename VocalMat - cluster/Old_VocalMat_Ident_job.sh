#!/bin/bash
#SBATCH --partition=scavenge
#SBATCH --job-name=identifier
#SBATCH --output=identifier.txt
#SBATCH --ntasks=1 --nodes=1
#SBATCH --cpus-per-task=6
#SBATCH --mem-per-cpu=10000 
#SBATCH --time=12:00:00


BASEDIR=$(dirname "$0")
echo "$BASEDIR"

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

module load MATLAB/2016b

matlab -nodisplay -nosplash -nodesktop -r "cd('/ysm-gpfs/project/ahf38/Antonio_VocalMat/VocalMat-Identifier'); vpathname = '"${2}"', vfilename = '"${1}"', VocalMat_Identifier_v5b"

cat *.txt > all.txt