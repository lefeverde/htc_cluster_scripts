#!/bin/bash

# Args
project_name=$1
sample_ids=$2
# TODO figure out easy way to input fq1 and fq2 without
# needing to use a sample id list
core_num=${3:-4}
mem_num=${4:-64}
cur_ref=${5:-hisat2_indexed_refs}

# TODO remove hardcoding ref file
ref_path=/mnt/mobydisk/groupshares/dtaylor/del53/genome_refs




while read SAMPLE_ID; do
  # idea for master script was taken from:
  # https://gist.github.com/alyssafrazee/9376121
  # creates the appropiate file names for each
  # fastq PE set
  fastq_dir=${PWD}/${project_name}/data/ # breakin fp and file

  fq1=${SAMPLE_ID}_R1_001.fastq.gz
  fq2=${SAMPLE_ID}_R2_001.fastq.gz

  script_file=${PWD}/$project_name/alignments/scripts/hisat2_${SAMPLE_ID}.sh

  sam_file=${SAMPLE_ID}.sam

  alignment_path=${PWD}/$project_name/alignments/
  bam_file=${SAMPLE_ID}.bam

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


cp ${fastq_dir}${fq1} \$LOCAL
cp ${fastq_dir}${fq2} \$LOCAL
cp -R ${ref_path}/${cur_ref} \$LOCAL

cd \$LOCAL

module load HISAT2
module load samtools

hisat2 -p $core_num --dta -x $cur_ref/hg38_tran -1 $fq1 -2 $fq2 -S $sam_file
samtools sort -@ $core_num -m 2G -o $bam_file $sam_file
rm $sam_file

mv $bam_file ${alignment_path}

EOF

qsub $script_file

done < $sample_ids
