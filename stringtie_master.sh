#!/bin/bash

project_name=$1
sample_ids=$2
core_num=${3:-2}
mem_num=${4:-16}


cur_module=StringTie
cmd_string=stringtie

ref_gtf=/mnt/mobydisk/groupshares/dtaylor/del53/genome_refs/hisat2_indexed_refs/hg38_ucsc.annotated.gtf

while read SAMPLE_ID; do
  # TODO add some comments
  # idea for master script was taken from:
  # https://gist.github.com/alyssafrazee/9376121
  # creates the appropiate file names for each
  # fastq PE set

  script_file=$project_name/assemblies/scripts/stringtie_${SAMPLE_ID}.sh
  # GTF reference file


  bam_in=$project_name/alignments/${SAMPLE_ID}.bam
  out_gtf=$project_name/assemblies/${SAMPLE_ID}.gtf

  # This is all the text being put into the file
  touch $script_file
  cat > $script_file <<EOF
#!/bin/bash
#
#SBATCH -N 1 # Ensure that all cores are on one machine
#SBATCH -t 0-03:00 # Runtime in D-HH:MM
#SBATCH -J ${cur_module}_${SAMPLE_ID}
#SBATCH -o /ihome/dtaylor/del53/slurm_output_logs/out_${cur_module}_${SAMPLE_ID}_%N_%j
#SBATCH -e /ihome/dtaylor/del53/slurm_error_logs/err_${cur_module}_${SAMPLE_ID}_%N_%j
#SBATCH --cpus-per-task=$core_num # Request that ncpus be allocated per process.
#SBATCH --mem=${mem_num}g # Memory pool for all cores (see also --mem-per-cpu)


module load $cur_module

$cmd_string -p $core_num -G $ref_gtf -o $out_gtf -l ${SAMPLE_ID} $bam_in

EOF

qsub $script_file

done < $sample_ids
