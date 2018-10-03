#!/bin/bash
#SBATCH --partition=scavenge
#SBATCH --job-name=update_CNN
#SBATCH --gres=gpu:k80:1 
#SBATCH --ntasks=1 --nodes=1
#SBATCH --cpus-per-task=6
#SBATCH --mem-per-cpu=5000 
#SBATCH --time=24:00:00
#SBATCH --mail-user=antonio.fonseca@yale.edu,rafael.daipradaluz@yale.edu,gabriela.bosque@yale.edu
#SBATCH --mail-type=END

BASEDIR=$(dirname "$0")
echo "$BASEDIR"

#export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

module load MATLAB/2017b

matlab -nodisplay -nosplash -nodesktop -r "cd('/gpfs/ysm/project/ahf38/Antonio_VocalMat/Reference_CNN'); parpool; update_CNN"



