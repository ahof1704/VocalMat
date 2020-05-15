#!/bin/bash
#SBATCH --partition=scavenge
#SBATCH --requeue
#SBATCH --ntasks=1 --nodes=1
#SBATCH --cpus-per-task=20
#SBATCH --mem-per-cpu=6000 
#SBATCH --time=12:00:00


export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

module load MATLAB/2018b

matlab -nodisplay -nosplash -nodesktop -r "root_path='/gpfs/ysm/project/ahf38/Antonio_VocalMat/VocalMat2'; identifier_path=fullfile(root_path,'vocalmat_identifier'); classifier_path=fullfile(root_path,'vocalmat_classifier'); analysis_path=fullfile(root_path,'vocalmat_analysis'); cd(identifier_path); vfilename = '"${1}"', vpathname = '"$FOLDER"', run('vocalmat_identifier_cluster.m'), cd(classifier_path); run('vocalmat_classifier_cluster.m'); cd(analysis_path); run('diffusion_maps_cluster.m'), "
#toc"