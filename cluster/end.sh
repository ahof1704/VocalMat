#!/bin/bash
#SBATCH --partition=scavenge
#SBATCH -o kernel_alignment.out
#SBATCH --requeue
#SBATCH -e kernel_alignment.err
#SBATCH --ntasks=1 --nodes=1
#SBATCH --cpus-per-task=20
#SBATCH --mem-per-cpu=6000 
#SBATCH --time=12:00:00


export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

module load MATLAB/2018b

matlab -nodisplay -nosplash -nodesktop -r "root_path='/gpfs/ysm/project/ahf38/Antonio_VocalMat/VocalMat2'; work_dir = '"$FOLDER"', analysis_path = fullfile(root_path,'vocalmat_analysis'); cd(analysis_path); run('kernel_alignment_cluster.m'), "
