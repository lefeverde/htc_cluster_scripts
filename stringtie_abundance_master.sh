#!/bin/bash

project_name=$1
merge_list=$2

# Trying to make
# boiler plate code less
# hardcoded
cur_module=StringTie
cmd_string=stringtie


merged_gtf=${project_name}/assemblies/${project_name}_stringtie_merged.gtf


while read SAMPLE_ID; do
  # idea for master script was taken from:
  # https://gist.github.com/alyssafrazee/9376121
  # creates the appropiate file names for each
  # fastq PE set

  script_file=$project_name/DE_analysis/scripts/stringtie_abundance_${SAMPLE_ID}.sh
  bam_file=$project_name/alignments/${SAMPLE_ID}.bam
  # Pointsless dir was in original sbatch script
  # might be required for ballgown
  mkdir -p $project_name/DE_analysis/${SAMPLE_ID}
  out_abundance_gtf=$project_name/DE_analysis/${SAMPLE_ID}/${SAMPLE_ID}.gtf

  # This is all the text being put into the file
  touch $script_file
  cat > $script_file <<EOF

#!/bin/bash
#
#SBATCH -N 1 # Ensure that all cores are on one machine
#SBATCH -t 3-00:00 # Runtime in D-HH:MM
#SBATCH -J ${cur_module}
#SBATCH -o /ihome/dtaylor/del53/slurm_output_logs/out_${cur_module}_%N_%j
#SBATCH -e /ihome/dtaylor/del53/slurm_error_logs/err_${cur_module}_%N_%j
#SBATCH --cpus-per-task=8 # Request that ncpus be allocated per process.
#SBATCH --mem=115g # Memory pool for all cores (see also --mem-per-cpu)

module load $cur_module

$cmd_string -e -B -p 8 -G $merged_gtf -o $out_abundance_gtf


EOF

qsub $script_file

done < $sample_ids
