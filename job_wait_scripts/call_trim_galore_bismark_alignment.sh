#!/bin/bash

### Instruction: This script finds single-end splitted fastqs. And further runs trim-galore, and bismark on each splitted fastqs on different 
### nodes for parallel job completion using trim_galore_bismark_alignment.sh script. Moreover, the parameter for job run has been designed in such a way that the job submission of this 
### trim_galore_bismark_alignment.sh to the morgan cluster is dependent on completion of all fastq splitting executed by prior fastq splitting based scripts.
  

### LIB_LIST environment variable, containing the list of SL# library with the wgbs fastqs, created in prior script imported:
for LIB in ${LIB_LIST}; do
	
	if [[ ! -d $OUTPUT_DIR/$LIB ]]; then
		mkdir $OUTPUT_DIR/$LIB
	fi

	DIR_PATH=$OUTPUT_DIR/$LIB
	echo "Processing ${LIB}"
	echo "Using FASTQ files in ${DIR_PATH}"
	
	### Create all sub-directories in main dir:
	if [[ ! -d $OUTPUT_DIR/${LIB} ]]; then
		mkdir $OUTPUT_DIR/${LIB}
	fi
	
	if [[ ! -d $OUTPUT_DIR/${LIB}/temp_dir ]]; then
		mkdir $OUTPUT_DIR/${LIB}/temp_dir
	fi
	
	if [[ ! -d $OUTPUT_DIR/${LIB}/bam_files ]]; then
		mkdir $OUTPUT_DIR/${LIB}/bam_files
	fi
	
	if [[ ! -d $OUTPUT_DIR/${LIB}/log_files ]]; then
		mkdir $OUTPUT_DIR/${LIB}/log_files
	fi
	
	
	echo "Using $OUTPUT_DIR for output, and all sub directories created.."
	export LOG_DIR=$OUTPUT_DIR/${LIB}/log_files ### Env var for later usage to store all log files
	export BAM_OUTPUT_DIR=$OUTPUT_DIR/${LIB}/bam_files
	export TEMP_DIR=$OUTPUT_DIR/${LIB}/temp_dir
	
	### File preparation for the lambda genome:
	if [[ ! -d $OUTPUT_DIR/${LIB}/lambda_genome ]]; then
		mkdir $OUTPUT_DIR/${LIB}/lambda_genome
	fi
	
	export LAMBDA_OUTPUT_DIR=$OUTPUT_DIR/${LIB}/lambda_genome
	
	if [[ ! -d $LAMBDA_OUTPUT_DIR/temp_dir ]]; then
		mkdir $LAMBDA_OUTPUT_DIR/temp_dir
	fi
	
	if [[ ! -d $LAMBDA_OUTPUT_DIR/bam_files ]]; then
		mkdir $LAMBDA_OUTPUT_DIR/bam_files
	fi
	
	if [[ ! -d $LAMBDA_OUTPUT_DIR/log_files ]]; then
		mkdir $LAMBDA_OUTPUT_DIR/log_files
	fi
	
	export BAM_LAMBDA_OUTPUT_DIR=$LAMBDA_OUTPUT_DIR/bam_files

	### Feed the fastq files into the bismark alignment pipeline for further processing using trim_galore_bismark_alignment.sh script:
	### The fastq considered here would be of the format instance like : C6RLPANXX_s4_1_7bp_Index_7_SL83766.00 
	for fastq in $( ls $DIR_PATH/*.*); do
		LOG_BASE=$(basename $fastq)
		JOB_NAME='Running bismark'
		### Will take $CORE_NUM cores of the morgan cluster for each bismark alignment instances:
		bsub $BSUB_OPTIONS -J "$JOB_NAME" -o $OUTPUT_DIR/${LIB}_bismarkrun_log.out ./trim_galore_bismark_alignment.sh $fastq $BAM_OUTPUT_DIR $TEMP_DIR $BAM_LAMBDA_OUTPUT_DIR
	done
done

