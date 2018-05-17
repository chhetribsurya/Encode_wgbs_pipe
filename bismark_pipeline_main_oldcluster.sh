#!/bin/bash

####################################################
## WGBS Pipeline for HAIB ##                       #
#                                                  #
# Set the output dir, input dir, library list,     # 
# and paths for all the tools with this script     #   
# This script would further call on other scripts  #
# residing in the bismark_pipeline directory.      # 
####################################################


### Usage: ./bismark_pipeline_main.sh
### Input should be provided to the variables: OUTPUT_LOC, INPUT_LOC, LIB_LIST, GENOME_PATH, BISMARK_PATH, SAMTOOLS_PATH, TRIMGALORE_PATH, BOWTIE_PATH, CORE_NUM


SOURCE_DIR="/opt/HAIB/myerslab/etc"
#SOURCE_DIR="/gpfs/gpfs2/software/HAIB/myerslab/etc"

### Mandatory sourcing of bashrc for necessary environment variables. ###
if [ -e $SOURCE_DIR/bashrc ]; then
    . $SOURCE_DIR/bashrc
else echo "[fatal] - Could not find myerslab bashrc file. Exiting"; exit 1; fi

### Mandatory sourcing of functions to get helper functions (like call_cmd). ###
if [ -e $SOURCE_DIR/functions ]; then
    . $SOURCE_DIR/functions
else echo "[fatal] - Could not find functions file. Exiting"; exit 1; fi

### Verify we are not running on the head node. ###
#if [ -z "$LSB_JOBID" ]; then log_msg fatal "Please run on a compute node. Exiting"; exit 1; fi


#####################################################
#                                                   #
#         INPUT INFORMATION REQUIRED                #
#                                                   #
#####################################################


export RUN_PATH=`pwd`

### Provide the input dir location containing all the SL# libraries to access the fastq files of interest:
#export INPUT_LOC="/gpfs/gpfs1/myerslab/data/Libraries"
export INPUT_LOC="/gpfs/gpfs1/home/schhetri/wgbs_run/wgbs_split_VIth_batch/raw_fastq"

### Search these SL# or library numbers containing all the wgbs fastqs under myerslab data repository:
export LIB_LIST='SL233075 SL233076 SL233077'

### Set the main output dir location to retain all the splitted fastq files:
export OUTPUT_LOC="/gpfs/gpfs1/home/schhetri/wgbs_run/wgbs_split_VIth_batch/wgbs_pe"

### Set the genome path location, hg19 or grch38:
export GENOME_PATH="/gpfs/gpfs1/home/schhetri/bismark_genome_link/bismark_genome/"

### Set the genome path location for lambda geome:
export LAMBDA_GENOME_PATH="/gpfs/gpfs1/home/schhetri/bismark_lamda_genome/" 

### Though bismark could be in path, set full bismark path location for consistency:
#export BISMARK_PATH="/gpfs/gpfs2/software/bismark-0.11.1"
export BISMARK_PATH="/opt/bismark-0.11.1"

### Though samtools could be in path, set full samtools path location for consistency:
#export SAMTOOLS_PATH="/gpfs/gpfs2/software/samtools-0.1.7a"
export SAMTOOLS_PATH="/opt/samtools-0.1.7a"

### Set trimgalore path location for consistency:
export TRIMGALORE_PATH="/gpfs/gpfs1/home/schhetri/Tools/trim_galore_zip"

### Set bowtie path location for consistency:
#export BOWTIE_PATH="/gpfs/gpfs2/software/bowtie2-2.1.0"
export BOWTIE_PATH="/opt/bowtie2-2.1.0"

### Set coverage script path:
#export COVERAGE_METRICS="/gpfs/gpfs2/software/HAIB/myerslab/repos/Analysis-blessed/NEW_Analysis/scripts/"
export COVERAGE_METRICS="/opt/HAIB/myerslab/repos/Analysis-blessed/NEW_Analysis/scripts/"

### Input the type of experiment i.e either single-end or paired-end:
export ASSAY_TYPE="PE"

### Set the no. of cores you want:
export CORE_NUM=2

### Bsub parameters:
export BSUB_MEM_OPTIONS="-We 24:00 -q priority -R rusage[mem=51200]"  
export BSUB_OPTIONS_FOR_COV="-We 24:00 -q normal -R rusage[mem=6146]"  
export BSUB_OPTIONS="-We 40:00 -q normal -n $CORE_NUM -R span[hosts=1] -R rusage[mem=16000]"  
export BSUB_DEFAULT_OPTIONS="-We 10:00 -q normal"  

export JOB_PREFIX="batch_VI"

### Create main output dir:
if [[ ! -d $OUTPUT_LOC ]]; then
	mkdir -p $OUTPUT_LOC
fi

export OUTPUT_DIR=$OUTPUT_LOC
export LOG_FILES=$OUTPUT_DIR/"log_files"
export QC_SUMMARY_DIR=$OUTPUT_LOC/"summary_report_ofall_LIBS"

if [[ ! -d $LOG_FILES ]]; then
	mkdir -p $LOG_FILES
fi

#####################################################
#                                                   #
#         PIPELINE STARTS HERE                      #
#                                                   #
#####################################################


### This job calls the script call_fastq_split.sh, which has all the job submission information for fastq splitting with job name -J "Splitting of fastq":
#bsub -We 24:00 -q priority -J "Fastq splitting" -o $LOG_FILES/${JOB_PREFIX}_fastq_split_main.out $RUN_PATH/call_fastq_split.sh

### This job calls the script call_trim_galore_bismark_alignment.sh, which further calls the script trim_galore_bismark_alignment.sh: 
#bsub -We 24:00 -q priority -J "Bismark and trim galore run for single-end fastq" -o $LOG_FILES/${JOB_PREFIX}_bismarkrun_main.out $RUN_PATH/call_trim_galore_bismark_alignment.sh  

### This job calls the script call_mergeUnsorted_dedup_files_for_methExtraction.sh, which further calls the script mergeUnsorted_dedup_files_for_methExtraction.sh
#bsub -We 24:00 -q priority -J "Deduplication and methylation calling" -o $LOG_FILES/${JOB_PREFIX}_deduplication_methylationCall_main.out $RUN_PATH/call_mergeUnsorted_dedup_files_for_methExtraction.sh

### This job calls the script call_sort_for_coverage.sh, which further calls the sort_for_coverage.sh: 
#bsub -We 24:00 -q priority -J "Coverage metrics" -o $LOG_FILES/${JOB_PREFIX}_coverage_metrics_main.out $RUN_PATH/call_sort_for_coverage.sh

### This job calls the script python_bismark_qc_analysis.py for the QC analysis: 
#bsub -We 24:00 -q priority -J "Bismark QC analysis" -o $LOG_FILES/${JOB_PREFIX}_python_QC_analysis.out "python $RUN_PATH/python_bismark_qc_analysis.py $ASSAY_TYPE $OUTPUT_DIR" 

### This job calls the script final_samtools_insertsize.sh, which further calls final_samtools_insertsize.R script for the R plots generation: 
bsub -We 24:00 -q priority -J "QC analysis for Insert size" -o $LOG_FILES/${JOB_PREFIX}_insert_size_main.out $RUN_PATH/call_insert_size_plots_using_samtools.sh





