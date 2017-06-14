#!/bin/bash

project_name=$1
sample_ids=$2
hisat2_refs=/ihome/dtaylor/del53/genome_refs/hisat2_refs/hg38_tran

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
#SBATCH -o /ihome/dtaylor/del53/slurm_output_logs/slurm.%N.%j.out
#SBATCH -e /ihome/dtaylor/del53/slurm_error_logs/slurm.%N.%j.err
#SBATCH --cpus-per-task=16 # Request that ncpus be allocated per process.
#SBATCH --mem=230g # Memory pool for all cores (see also --mem-per-cpu)

module load HISAT2/2.0.3-beta

hisat2 -p 16 --dta -x $hisat2_refs -1 $fq1 -2 $fq2 -S $sam_file


EOF

qsub $script_file

done < $sample_ids




#data_dir=$1/data
#output_dir=$1/alignments/sample
#while read SAMPLE_ID; do
#  cat > /ProjectName/alignments/scripts/tophat_${SAMPLE_ID}.sh <<EOF

#EOF
