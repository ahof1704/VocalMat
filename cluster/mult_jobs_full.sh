#!/bin/bash
#SBATCH -p scavenge                # partition (queue)
#SBATCH -n 1                      # number of cores
#SBATCH --output=setup_%A.txt
#SBATCH --job-name=VocalMat

user_email="antonio.fonseca@yale.edu"
export FOLDER=/gpfs/ysm/project/ahf38/Antonio_VocalMat/USVs/test_vocalmat_analysis
folder_name=$(basename $FOLDER)

cd ${FOLDER}
pwd


# grab the files, and export it so the 'child' sbatch jobs can access it
ls *.WAV *.wav> filenames.txt

vocalmat="vocalmat_$folder_name"
echo "running job $vocalmat"
rm -f joblist.txt

while read p; do
  OUT0=$(sbatch -p scavenge --requeue --parsable -J $p -o $p.stdout.txt -e $p.stderr.txt /ysm-gpfs/project/ahf38/Antonio_VocalMat/cluster/VocalMat_Full.sh ${p} ${folder_name})
#  echo $OUT0 >> joblist.txt
#  joblist += $OUT0
  #OUT0=$(sbatch -p scavenge --requeue  -J $p -o $p.stdout.txt -e $p.stderr.txt /ysm-gpfs/project/ahf38/Antonio_VocalMat/VocalMat-Identifier/VocalMat_Full.sh ${p} ${folder_name})
  
  sleep 1 # pause to be kind to the scheduler
done <filenames.txt

ID_LIST=$(squeue -u ahf38|  awk '{ printf (":%i", $1 )}')
ID_LIST=${ID_LIST:3}
#C=("${A[@]:1}")
echo $ID_LIST

OUT2=$(sbatch -p scavenge --requeue  -J kerner_alignment -o kernel_aligment.stdout.txt -e kernel_aligment.stderr.txt --dependency=afterok:${ID_LIST} /ysm-gpfs/project/ahf38/Antonio_VocalMat/end.sh ${folder_name})



