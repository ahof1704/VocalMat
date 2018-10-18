#!/bin/bash

#SBATCH --job-name=VOCALMAT_CLASSIFIER_1080ti_2DAYS_2CORES_16GB
#SBATCH --output=/gpfs/ysm/project/gms58/cnn/outputs/train_model_%A_%a.out
#SBATCH --error=/gpfs/ysm/project/gms58/cnn/outputs/train_model_%A_%a.err
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1080ti:1
#SBATCH --gres-flags=enforce-binding
#SBATCH --requeue
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=16g 
#SBATCH --time=2800
#SBATCH --array=0-23
#SBATCH --mail-type=BEGIN,END,FAIL,TIME_LIMIT,REQUEUE
#SBATCH --mail-user=gumadeiras@gmail.com

/ysm-gpfs/apps/software/dSQ/0.92/dSQBatch.py jobs_train.txt
