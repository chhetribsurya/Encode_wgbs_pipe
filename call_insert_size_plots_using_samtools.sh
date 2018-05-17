#!/bin/bash

export RUN_PATH=`pwd`

if [[ ! -d $QC_SUMMARY_DIR ]]; then
	mkdir -p $QC_SUMMARY_DIR
fi

if [[ ! -d $QC_SUMMARY_DIR/insert_size_data ]]; then
	mkdir -p $QC_SUMMARY_DIR/insert_size_data
fi

export INSERT_SIZE_DIR=$QC_SUMMARY_DIR/insert_size_data

for LIB in ${LIB_LIST}; do
    export BAM_PATH=$OUTPUT_DIR/$LIB/unsortedButMerged_ForBismark_file
    echo "Processing the insertsize of $LIB"
    for bam_file in $(/bin/ls $BAM_PATH/*_unsorted_merged.deduplicated.bam); do
        bsub $BSUB_DEFAULT_OPTIONS -J "QC insert size analysis for $(basename $bam_file)" -o $LOG_FILES/${JOB_PREFIX}_insert_size_plot.out $RUN_PATH/insert_size_plots_using_samtools.sh $LIB $bam_file $QC_SUMMARY_DIR 
    done
done

echo "Task completed!!"
