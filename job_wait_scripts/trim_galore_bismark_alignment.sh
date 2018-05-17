#!/bin/bash

### Instructions: This script executes bismark and trim galore for each single-end fastqs.

SOURCE_DIR="/opt/HAIB/myerslab/etc"

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


### Variables passed from the previous script call_trim_galore_bismark_alignment.sh retained:
INPUT_FILE_R1=$1
OUTPUT_DIR=$2
LAMBDA_OUTPUT_DIR=$4

### Set the temporary dir:
#TEMP_DIR=$(get_temp_dir)
TEMP_DIR=$3

### Run trim galore on each splitted paired-end fastqs with 18 million reads, and clip 4-bp from each end to get rid of any poor read quality bias: 
#$TRIMGALORE_PATH/trim_galore -o $TEMP_DIR --fastqc --dont_gzip --clip_R1 3 --three_prime_clip_R1 3 $INPUT_FILE_R1

#echo "Here are the trimmed files:"
#ls -l $TEMP_DIR

### Set names to trimmed fastqs for read_1:
TRIMMED_R1=$TEMP_DIR/$(basename $INPUT_FILE_R1 .fastq.gz)_trimmed.fq  ### read_1
echo "here is the trimmmed file that would be forwarded for the analysis: $TRIMMED_R1"
echo -e "\nBismark alignment starts here\n"

### Run bismark alignment on single-end trimmed fastqs (read_1) using bowtie-2:
#$BISMARK_PATH/bismark --bowtie2 -p 8 --bam --temp_dir $TEMP_DIR --path_to_bowtie $BOWTIE_PATH/ -o $OUTPUT_DIR $GENOME_PATH $TRIMMED_R1 

### Run lambda genome alignment for QC on single-end trimmed fastqs (read_1) using bowtie-2:
$BISMARK_PATH/bismark --bowtie2 -p 4 --bam --temp_dir $TEMP_DIR --path_to_bowtie $BOWTIE_PATH -o $LAMBDA_OUTPUT_DIR $LAMBDA_GENOME_PATH $TRIMMED_R1
