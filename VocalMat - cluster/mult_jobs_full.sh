#!/bin/bash
#SBATCH -p scavenge                # partition (queue)
#SBATCH -n 1                      # number of cores
#SBATCH --output=setup_%A.txt
#SBATCH --job-name=VocalMat

user_email="antonio.fonseca@yale.edu"
export FOLDER=/gpfs/ysm/project/ahf38/Antonio_VocalMat/USVs/Biological_questions/new_pwks
folder_name=$(basename $FOLDER)

cd ${FOLDER}
pwd


# grab the files, and export it so the 'child' sbatch jobs can access it
ls *.WAV *.wav> filenames.txt

vocalmat="vocalmat_$folder_name"
echo "running job $identifier "

while read p; do
  echo $p
  OUT0=$(sbatch -p scavenge --requeue  -J $p -o $p.stdout.txt -e $p.stderr.txt /ysm-gpfs/project/ahf38/Antonio_VocalMat/VocalMat-Identifier/VocalMat_Full.sh ${p} ${folder_name})
  name2=${p:0:-4}
  name3=output_${name2}.mat
  sleep 1 # pause to be kind to the scheduler
done <filenames.txt

ID_LIST=$(squeue -n ${vocalmat}|  awk '{ printf (":%i", $1 )}')
ID_LIST=${ID_LIST:3}
#C=("${A[@]:1}")
#echo $ID_LIST

#OUT2=$(sbatch -J $folder_name --mail-user=$user_email --mail-type=END --dependency=afterok:${ID_LIST} /ysm-gpfs/project/ahf38/Antonio_VocalMat/end.sh)



