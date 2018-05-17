#!/bin/bash

LIB=$1
bam_file=$2
QC_SUMMARY_DIR=$3

echo "Processing the insertsize of $LIB"
echo "Processing bam file: $bam_file"
$SAMTOOLS_PATH/samtools view $bam_file | cut -f9 | awk '{if ($1>0) print}' > $INSERT_SIZE_DIR/$(basename $bam_file)_insertsize.txt        
Rscript ./final_samtools_insertsize.R $INSERT_SIZE_DIR/$(basename $bam_file)_insertsize.txt $QC_SUMMARY_DIR ${LIB}_insert_size_plot.pdf
echo "JOBS COMPLETED!"
