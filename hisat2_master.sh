#!/bin/bash

# Args
project_name=$1
sample_ids=$2
# TODO figure out easy way to input fq1 and fq2 without
# needing to use a sample id list
core_num=${3:-4}
mem_num=${4:-64}


# TODO remove hardcoding ref file
cur_ref=/mnt/mobydisk/groupshares/dtaylor/del53/genome_refs/hisat2_indexed_refs
#hisat2_refs=/mnt/mobydisk/groupshares/dtaylor/del53/genome_refs/hisat2_refs/hg38_tran



while read SAMPLE_ID; do
  # idea for master script was taken from:
  # https://gist.github.com/alyssafrazee/9376121
  # creates the appropiate file names for each
  # fastq PE set
  fq1=$project_name/data/${SAMPLE_ID}_1.fastq.gz
  fq2=$project_name/data/${SAMPLE_ID}_2.fastq.gz
  script_file=$project_name/alignments/scripts/hisat2_${SAMPLE_ID}.sh
  sam_file=$project_name/alignments/${SAMPLE_ID}.sam
  bam_file=$project_name/alignments/${SAMPLE_ID}.bam

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
#SBATCH --cpus-per-task=$core_num # Request that ncpus be allocated per process.
#SBATCH --mem=${mem_num}g # Memory pool for all cores (see also --mem-per-cpu)

module load HISAT2/2.0.5
module load samtools/1.3.1-gcc5.2.0

hisat2 -p $core_num --dta -x $cur_ref/hg38_tran -1 $fq1 -2 $fq2 -S $sam_file
samtools sort -@ $core_num -m 2G -o $bam_file $sam_file
rm $sam_file

EOF

qsub $script_file

done < $sample_ids
