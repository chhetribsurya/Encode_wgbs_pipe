#!/bin/bash

INPUT_DIR="/gpfs/gpfs1/home/schhetri/wgbs_run/wgbs_split_VIIIth_batch/wgbs_pe/summary_report_ofall_LIBS"

cat ${INPUT_DIR}/*.txt | egrep "###|Mapping|PCR|Genome|Lambda" | paste - - - - -
