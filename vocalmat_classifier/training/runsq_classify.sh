#!/bin/bash

#SBATCH --job-name=VOCALMAT_CLASSIFIER_3HOURS_12CORES_64GB
#SBATCH --output=/gpfs/ysm/project/gms58/cnn/outputs/classify_model_%A_%a.out
#SBATCH --error=/gpfs/ysm/project/gms58/cnn/outputs/classify_model_%A_%a.err
#SBATCH --partition=scavenge
#SBATCH --requeue
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=64g 
#SBATCH --time=180
#SBATCH --array=0-11
#SBATCH --mail-type=BEGIN,END,FAIL,TIME_LIMIT,REQUEUE
#SBATCH --mail-user=gumadeiras@gmail.com

/ysm-gpfs/apps/software/dSQ/0.92/dSQBatch.py jobs_classify.txt
