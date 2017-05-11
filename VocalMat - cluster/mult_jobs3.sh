#!/bin/bash
#SBATCH -p scavenge                # partition (queue)
#SBATCH -n 1                      # number of cores
#SBATCH --output=VocalMat_%A.txt
#SBATCH --job-name=VocalMat

user_email="antonio.fonseca@yale.edu"

export FOLDER=/ysm-gpfs/project/ahf38/Antonio_VocalMat/USVs/test2
folder_name=$(basename $FOLDER)

cd ${FOLDER}
pwd


# grab the files, and export it so the 'child' sbatch jobs can access it
ls *.WAV> filenames.txt

identifier="identifier_$folder_name"
echo "running job $identifier "
classifier="classifier_$folder_name"


while read p; do
  echo $p
  OUT0=$(sbatch -J $identifier -o $p.stdout.txt -e $p.stderr.txt /ysm-gpfs/project/ahf38/Antonio_VocalMat/VocalMat-Identifier/VocalMat_Ident_job.sh ${p} ${folder_name})
  name2=${p:0:-4}
  name3=output_${name2}.mat
  echo "Expecting for $name3 "
  OUT1=$(sbatch -J $classifier -o $name3.stdout.txt -e $name3.stderr.txt --dependency=afterany:${OUT0##* } /ysm-gpfs/project/ahf38/Antonio_VocalMat/VocalMat-Classifier/VocalMat_Class_batch.sh ${name3})
  sleep 1 # pause to be kind to the scheduler
done <filenames.txt

ID_LIST=$(squeue -n ${classifier}|  awk '{ printf (":%i", $1 )}')
ID_LIST=${ID_LIST:3}
#C=("${A[@]:1}")
#echo $ID_LIST

OUT2=$(sbatch -J $folder_name --mail-user=$user_email --mail-type=END --dependency=afterany:${ID_LIST} /ysm-gpfs/project/ahf38/Antonio_VocalMat/end.sh)



