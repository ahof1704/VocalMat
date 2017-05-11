#!/bin/bash
#SBATCH -p scavenge                # partition (queue)
#SBATCH -n 1                      # number of cores
#SBATCH --output=VocalMat.txt
#SBATCH --job-name=VocalMat
#SBATCH -o outmain_tracing.out        # STDOUT
#SBATCH -e outmain_tracing.err        # STDERR
#SBATCH --mail-type=ALL
#SBATCH --mail-user=antonio.fonseca@yale.edu

FOLDER=/ysm-gpfs/project/ahf38/Antonio_VocalMat/USVs/2017_05_06

cd ${FOLDER}
pwd

for FILE in *.WAV; 
do

echo ${FILE}

OUT0=$(sbatch -o ${FILE}.stdout.txt -e ${FILE}.stderr.txt /ysm-gpfs/project/ahf38/Antonio_VocalMat/VocalMat-Identifier/VocalMat_Ident_job.sh ${FILE} ${FOLDER})
#OUT1=$(sbatch --dependency=afterany:${OUT0##* }  slurm_files/step1.sh) 

sleep 1 # pause to be kind to the scheduler

done
echo $OUT0
echo "Waiting for job ${OUT0##* } to be done "

all_done=$(sbatch --dependency=afterany:${OUT0##* } /ysm-gpfs/project/ahf38/Antonio_VocalMat/VocalMat-Classifier/mult_jobs_class.sh ${FOLDER}) 
echo $all_done