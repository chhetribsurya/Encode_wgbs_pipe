#!/bin/bash

### Instruction: This script calls mergeUnsorted_dedup_files_for_methExtraction_orig.sh, to merge the unsorted bam files, deduplicates, and does methylation calling.
### Furthermore, the job won't be submitted to morgan cluster, until the completion of job run by call_trim_galore_bismark_alignment.sh which basically does trims
### the fastqs, and does bismark alignment. 

export RUN_PATH=`pwd`
export BAM_DIR=$OUTPUT_DIR

for LIB in ${LIB_LIST}; do

	if [[ ! -d $OUTPUT_DIR/$LIB ]]; then
		mkdir $OUTPUT_DIR/$LIB
	fi
	
	export LIST=$LIB
	JOB_NAME="Merging & deduplication of unsorted file for methExtraction"

	### Will take $MEM_USAGE for the merging of the bam files for each SL# or libraries, and removes pcr deduplicates from those merged bam files, which is passed on to bismark methylation extractor:
    bsub $BSUB_MEM_OPTIONS -J "$JOB_NAME on $LIB bams" -o $LOG_FILES/${LIB}_full_pipeline_deduplication.out $RUN_PATH/mergeUnsorted_dedup_files_for_methExtraction.sh
	echo " "
done

