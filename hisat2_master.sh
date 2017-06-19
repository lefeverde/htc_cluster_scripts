#!/bin/bash

project_name=$1
sample_ids=$2
cur_ref=/mnt/mobydisk/groupshares/dtaylor/del53/genome_refs/hisat2_indexed_refs/
#hisat2_refs=/mnt/mobydisk/groupshares/dtaylor/del53/genome_refs/hisat2_refs/hg38_tran
# TODO figure out easy way to
# input fq1 and fq2 without
# needing to use a sample id list

while read SAMPLE_ID; do
  # idea for master script was taken from:
  # https://gist.github.com/alyssafrazee/9376121
  # creates the appropiate file names for each
  # fastq PE set
  fq1=$project_name/data/${SAMPLE_ID}_1.fastq.gz
  fq2=$project_name/data/${SAMPLE_ID}_2.fastq.gz
  script_file=$project_name/alignments/scripts/hisat2_${SAMPLE_ID}.sh
  sam_file=$project_name/alignments/${SAMPLE_ID}.sam

  # This is all the text being put into the file
  touch $script_file
  cat > $script_file <<EOF
#!/bin/bash
#
#SBATCH -N 1 # Ensure that all cores are on one machine
#SBATCH -t 3-00:00 # Runtime in D-HH:MM
#SBATCH -J hisat2_${SAMPLE_ID}
#SBATCH -o /ihome/dtaylor/del53/slurm_output_logs/out_hisat2_${SAMPLE_ID}_%N_%j
#SBATCH -e /ihome/dtaylor/del53/slurm_error_logs/err_hisat2_${SAMPLE_ID}_%N_%j
#SBATCH --cpus-per-task=16 # Request that ncpus be allocated per process.
#SBATCH --mem=230g # Memory pool for all cores (see also --mem-per-cpu)

module load HISAT2/2.0.5

hisat2 -p 16 --dta -x $cur_ref/hg38_tran -1 $fq1 -2 $fq2 -S $sam_file


EOF

qsub $script_file

done < $sample_ids
