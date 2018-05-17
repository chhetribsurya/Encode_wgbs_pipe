#!/bin/bash

INPUT_DIR="/gpfs/gpfs1/myerslab/data/Flowcells"
FLOWCELL_LIST="HJL37CCXY"
#FLOWCELL_LIST="HKWKGCCXY HKW35CCXY"
#FLOWCELL_LIST="H3HNYCCXY H3LVYCCXY H3MFNCCXY H3K5TCCXY H3J23CCXY H3VJKCCXY"
#OUTPUT_DIR="/gpfs/gpfs1/home/schhetri/wgbs_run/wgbs_split_VIIth_batch/raw_fastq"
OUTPUT_DIR="/gpfs/gpfs1/home/schhetri/wgbs_run/wgbs_split_IX_batch/raw_fastq"


for flowcell in ${FLOWCELL_LIST}; do
    for each_lane in $(ls -d $INPUT_DIR/$flowcell/s*); do
        #echo -e "\nhere's the lane path" $each_lane
        for each_file in $(ls $each_lane/BIOO*/*.fastq.gz); do
            LIB_ID=$(basename $each_file | cut -f8 -d"_" | cut -f1 -d".")
            echo "LIB" $LIB_ID

            ### Generates the directory for each SL# inside the main output dir to retain the fastq files:	
            if [[ ! -d $OUTPUT_DIR/$flowcell/$LIB_ID ]]; then
                mkdir -p $OUTPUT_DIR/$flowcell/$LIB_ID
            fi
            ls $each_file
            ln -fs $each_file $OUTPUT_DIR/$flowcell/$LIB_ID
            # cp $each_file $OUTPUT_DIR/$flowcell/$LIB_ID
        done
	done
done
