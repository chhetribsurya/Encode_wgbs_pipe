#!/bin/bash

### Instruction: This script calls other fastq_split.sh script residing in bismark_pipeline dir, and splits all the####  fastqs to 18 million reads, for each SL# libraries in iterable LIB_LIST

export RUN_PATH=`pwd`

### Iterates over each SL# libraries, and runs the job parallel on different nodes:
for LIB in ${LIB_LIST}; do
	export LIST=$LIB
	export INPUT_DIR=$INPUT_LOC/$LIB
	JOB_NAME="Splitting fastq"	
	### Will take 4 cores of the HAIB morgan cluster for each library, submitting the jobs to different node instances 
	bsub $BSUB_DEFAULT_OPTIONS -J "$JOB_NAME of $LIB" -o $LOG_FILES/fastq_split.out $RUN_PATH/fastq_split.sh $LIB 
	echo " "
done

