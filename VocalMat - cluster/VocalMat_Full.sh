#!/bin/bash
#SBATCH --partition=scavenge
#SBATCH -o vocalmat_%A_%a.out
#SBATCH --requeue
#SBATCH -e vocalmat_%A_%a.err
#SBATCH --ntasks=1 --nodes=1
#SBATCH --cpus-per-task=20
#SBATCH --mem-per-cpu=6000 
#SBATCH --time=12:00:00


export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

module load MATLAB/2017b

matlab -nodisplay -nosplash -nodesktop -r ", identifier_path = '/ysm-gpfs/project/ahf38/Antonio_VocalMat/VocalMat-Identifier'; classifier_path = '/gpfs/ysm/project/ahf38/Antonio_VocalMat/VocalMat-Classifier'; cd(identifier_path); vfilename = '"${1}"', vpathname = '"$FOLDER"',VocalMat_Identifier_v9f_v2; cd(classifier_path); VocalMat_Classifier_v20d_v3; toc"