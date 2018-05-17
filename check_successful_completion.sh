#!/bin/bash

export SL_DIR_PATH="/gpfs/gpfs1/home/schhetri/wgbs_run/wgbs_split_VIIth_batch/wgbs_pe"
export LOG_FILES_PATH="/gpfs/gpfs1/home/schhetri/wgbs_run/wgbs_split_VIIth_batch/wgbs_pe/log_files"

rm Successful_completion_test.txt
echo -e "\nCompletion Status\n\n" >> Successful_completion_test.txt
echo -e "\nSL# NAME     Total_files     Successful_reports_txt    Mapping_eff_marker\n" >> Successful_completion_test.txt
for each in $(ls -d $SL_DIR_PATH/SL*);do 
    file_num=$(($(ls $each/H*| wc -l)/2)); 
    bam_num=$(ls $each/bam_files/*report.txt|wc -l); 
    map_num=$(egrep "Mapping efficiency" $each/bam_files/*report.txt | wc -l);
    echo -e "$(basename $each)\t$file_num\t$bam_num\t$map_num" >> Successful_completion_test.txt
done 

#echo -e "\n\n\nCount the successful bam reports generated\n" >> Successful_completion_test.txt
#for each in $(ls -d $SL_DIR_PATH/SL*); do 
#    bam_num=$(ls $each/bam_files/*report.txt|wc -l); 
#    echo $(basename $each|cut -f1 -d"_") : $bam_num >> Successful_completion_test.txt;
#done
#
echo -e "\n\n\nCount the morgans successful completion test\n" >> Successful_completion_test.txt
for each in $(ls $LOG_FILES_PATH/*bismarkrun_log.out); do 
    morgan_num=$(grep "Successfully completed" $each|wc -l); 
    echo $(basename $each|cut -f1 -d"_") : $morgan_num >> Successful_completion_test.txt;
done
