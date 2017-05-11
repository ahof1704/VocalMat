#!/bin/bash
#SBATCH -p scavenge                # partition (queue)
#SBATCH -n 1                      # number of cores
#SBATCH --output=VocalMat_%A.txt
#SBATCH --job-name=VocalMat


export FOLDER=/ysm-gpfs/project/ahf38/Antonio_VocalMat/USVs/2017_05_09_Onur
folder_name=$(basename $FOLDER)

cd ${FOLDER}
pwd


# grab the files, and export it so the 'child' sbatch jobs can access it
ls *.WAV> filenames.txt

# get size of array
#NUMFASTQ=${#FILES[@]}
# now subtract 1 as we have to use zero-based indexing (first cell is 0)
#ZBNUMFASTQ=$(($NUMFASTQ - 1))
#echo ${ZBNUMFASTQ}
 
# now submit to SLURM
#if [ $ZBNUMFASTQ -ge 0 ]; then
#sbatch --array=0-$ZBNUMFASTQ tophat_double_array.sbatch
#OUT0=$(sbatch --array=0-$ZBNUMFASTQ /ysm-gpfs/project/ahf38/Antonio_VocalMat/VocalMat-Identifier/mult_jobs_ident.sh )
#fi

identifier="identifier_$folder_name"
echo "running job $identifier "


while read p; do
  echo $p
  OUT0=$(sbatch -J $identifier -o $p.stdout.txt -e $p.stderr.txt /ysm-gpfs/project/ahf38/Antonio_VocalMat/VocalMat-Identifier/VocalMat_Ident_job.sh ${p} ${folder_name})
  name2=${p:0:-4}
  name3=output_${name2}.mat
  echo "Expecting for $name3 "
  OUT1=$(sbatch -o $name3.stdout.txt -e $name3.stderr.txt --dependency=afterany:${OUT0##* } /ysm-gpfs/project/ahf38/Antonio_VocalMat/VocalMat-Classifier/VocalMat_Class_batch.sh ${name3})
  sleep 1 # pause to be kind to the scheduler
done <filenames.txt

#ID_LIST=$(squeue -n ${identifier}|  awk '{ printf (":%i", $1 )}')
#ID_LIST=${ID_LIST:3}
#C=("${A[@]:1}")
#echo $ID_LIST



#sleep 120

#squeue -n $identifier > job_stats.txt
#NUM_LINES=$(wc -l < job_stats.txt)

#echo "$[$NUM_LINES-1] processes running"

#while [ "$NUM_LINES" -ge "2" ]; do
#  squeue -n $identifier > job_stats.txt
#  NUM_LINES=$(wc -l < job_stats.txt)
#  sleep 1 
#done


#ls *.mat> outputs.txt

#i="0"
#while read p; do
#  echo $p
#  OUT6=$(sbatch --dependency=afterany:${ID_LIST} /ysm-gpfs/project/ahf38/Antonio_VocalMat/VocalMat-Classifier/VocalMat_Class_batch.sh ${p})
#  i=$[$i+1]
#  sleep 1 # pause to be kind to the scheduler
#done <outputs.txt




