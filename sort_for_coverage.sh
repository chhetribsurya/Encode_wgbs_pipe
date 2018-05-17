#!/bin/bash

LIB=$1

if [[ ! -d $OUTPUT_DIR/$LIB/sorted_bam_files ]]; then
    mkdir -p $OUTPUT_DIR/$LIB/sorted_bam_files
fi

SORTED_BAM_DIR="$OUTPUT_DIR/$LIB/sorted_bam_files"

for file in $(ls $OUTPUT_DIR/$LIB/unsortedButMerged_ForBismark_file/*.deduplicated.bam); do
    ### Sorting of deduplicated and merged bam file:
    echo "Sorting the file : $file"
    SORT_NAME="$((basename $file) | sed 's/.bam//')"
    $SAMTOOLS_PATH/samtools sort $file $SORTED_BAM_DIR/${SORT_NAME}_coverage
    echo "Sorting of $file completed!"

    ### Indexing of deduplicated and merged bam file:
    echo "Indexing the file : ${SORT_NAME}_coverage.bam"
    $SAMTOOLS_PATH/samtools index $SORTED_BAM_DIR/${SORT_NAME}_coverage.bam
    echo "Indexing of ${SORT_NAME}_coverage.bam completed!"
done

### Calling the coverage metrics chromosome wise on each SL# libraries:
for file in $(ls $SORTED_BAM_DIR/${SORT_NAME}_coverage.bam); do
   $COVERAGE_METRICS/bam_metrics_wg.py $file --bychrom > $OUTPUT_DIR/${LIB}_metrics.txt
done			
