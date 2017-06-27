#!/bin/bash

project_name=$1
merge_list=$2
# TODO figure out easy way to input fq1 and fq2 without
# needing to use a sample id list
core_num=${3:-6}
mem_num=${4:-96}


cur_module=StringTie
cmd_string=stringtie

script_file=$project_name/assemblies/scripts/stringtie_merged.sh
ref_gtf=/mnt/mobydisk/groupshares/dtaylor/del53/genome_refs/hisat2_indexed_refs/hg38_ucsc.annotated.gtf
out_gtf=${project_name}/assemblies/${project_name}_stringtie_merged.gtf

cat > $script_file <<EOF
#!/bin/bash
#
#SBATCH -N 1 # Ensure that all cores are on one machine
#SBATCH -t 3-00:00 # Runtime in D-HH:MM
#SBATCH -J ${cur_module}
#SBATCH -o /ihome/dtaylor/del53/slurm_output_logs/out_${cur_module}_%N_%j
#SBATCH -e /ihome/dtaylor/del53/slurm_error_logs/err_${cur_module}_%N_%j
#SBATCH --cpus-per-task=$core_num # Request that ncpus be allocated per process.
#SBATCH --mem=${mem_num}g # Memory pool for all cores (see also --mem-per-cpu)

module load $cur_module

$cmd_string --merge -p $core_num -G $ref_gtf -o $out_gtf $bam_in

EOF

qsub $script_file
