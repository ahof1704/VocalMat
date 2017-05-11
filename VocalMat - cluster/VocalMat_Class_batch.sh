#!/bin/bash

#SBATCH --partition=scavenge
#SBATCH --job-name=classifier
#SBATCH --ntasks=1 --nodes=1
#SBATCH --cpus-per-task=6
#SBATCH --mem-per-cpu=5000 
#SBATCH --time=24:00:00


BASEDIR=$(dirname "$0")
echo "$BASEDIR"

#export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

module load MATLAB/2016b

matlab -nodisplay -nosplash -nodesktop -r "cd('/ysm-gpfs/project/ahf38/Antonio_VocalMat/VocalMat-Classifier'); vpathname = '"$FOLDER"', vfilename = '"${1}"', VocalMat_Classifier_v18c"


