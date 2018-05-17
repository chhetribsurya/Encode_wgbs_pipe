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


#SOURCE_DIR="/opt/HAIB/myerslab/etc"
SOURCE_DIR="/gpfs/gpfs2/software/HAIB/myerslab/etc"

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
export LIB_LIST='SL233076 SL233077'

### Set the main output dir location to retain all the splitted fastq files:
export OUTPUT_LOC="/gpfs/gpfs1/home/schhetri/wgbs_run/wgbs_split_VIth_batch"

### Set the genome path location, hg19 or grch38:
export GENOME_PATH="/gpfs/gpfs1/home/schhetri/bismark_genome_link/bismark_genome/"

### Set the genome path location for lambda geome:
export LAMBDA_GENOME_PATH="/gpfs/gpfs1/home/schhetri/bismark_lamda_genome/" 

### Though bismark could be in path, set full bismark path location for consistency:
export BISMARK_PATH="/gpfs/gpfs2/software/bismark-0.11.1"

### Though samtools could be in path, set full samtools path location for consistency:
export SAMTOOLS_PATH="/gpfs/gpfs2/software/samtools-0.1.7a"

### Set trimgalore path location for consistency:
export TRIMGALORE_PATH="/gpfs/gpfs1/home/schhetri/Tools/trim_galore_zip"

### Set bowtie path location for consistency:
export BOWTIE_PATH="/gpfs/gpfs2/software/bowtie2-2.1.0"

### Set coverage script path:
export COVERAGE_METRICS="/gpfs/gpfs2/software/HAIB/myerslab/repos/Analysis-blessed/NEW_Analysis/scripts/"

### Set the no. of cores you want:
export CORE_NUM=4

### Bsub parameters:
#export BSUB_OPTIONS="-We 72:00 -q priority -n $CORE_NUM -R span[hosts=1]"  
#export BSUB_MEM_OPTIONS="-We 24:00 -q normal -R rusage[mem=8192]"  
export BSUB_MEM_OPTIONS="-We 24:00 -q priority -R rusage[mem=32768]"  
export BSUB_MEM_OPTIONS="-We 24:00 -q priority -R rusage[mem=40960]"  
export BSUB_OPTIONS="-We 40:00 -q normal -n $CORE_NUM -R span[hosts=1]"  

export JOB_PREFIX="batch_VI"

### Create main output dir:
if [[ ! -d $OUTPUT_LOC ]]; then
	mkdir $OUTPUT_LOC
fi

export OUTPUT_DIR=$OUTPUT_LOC


#####################################################
#                                                   #
#         PIPELINE STARTS HERE                      #
#                                                   #
#####################################################


### This job calls the script call_fastq_split.sh, which has all the job submission information for fastq splitting with job name -J "Splitting of fastq":
#bsub -We 24:00 -q c7normal -J "Fastq splitting" -o $OUTPUT_DIR/${JOB_PREFIX}_fastq_split_main.out $RUN_PATH/call_fastq_split.sh
bsub -We 24:00 -q priority -J "Fastq splitting" -o $OUTPUT_DIR/${JOB_PREFIX}_fastq_split_main.out $RUN_PATH/call_fastq_split.sh

### This job calls the script call_trim_galore_bismark_alignment.sh, which further calls the script trim_galore_bismark_alignment.sh: 
#bsub -w 'done("Fastq splitting")' -We 24:00 -q c7normal -J "Bismark and trim galore run for single-end fastq" -o $OUTPUT_DIR/${JOB_PREFIX}_bismarkrun_main.out $RUN_PATH/call_trim_galore_bismark_alignment.sh  
bsub -We 24:00 -q priority -J "Bismark and trim galore run for single-end fastq" -o $OUTPUT_DIR/${JOB_PREFIX}_bismarkrun_main.out $RUN_PATH/call_trim_galore_bismark_alignment.sh  

### This job calls the script call_mergeUnsorted_dedup_files_for_methExtraction.sh, which further calls the script mergeUnsorted_dedup_files_for_methExtraction.sh
bsub -We 24:00 -q priority -J "Deduplication and methylation calling" -o $OUTPUT_DIR/${JOB_PREFIX}_deduplication_methylationCall_main.out $RUN_PATH/call_mergeUnsorted_dedup_files_for_methExtraction.sh

### This job calls the script call_sort_for_coverage.sh, which further calls the sort_for_coverage.sh: 
bsub -We 24:00 -q priority -J "Coverage metrics" -o $OUTPUT_DIR/${JOB_PREFIX}_coverage_metrics_main.out $RUN_PATH/call_sort_for_coverage.sh






