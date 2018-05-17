import os
import re
import glob
import sys
from os.path import join

expt_type = sys.argv[1]
abs_parent_dir_path = sys.argv[2] 
#abs_parent_dir_path = "/gpfs/gpfs1/home/schhetri/wgbs_run/wgbs_split_VIth_batch" 
dir_pattern = "SL*/"

goto_bam_dir = "bam_files"
goto_trim_dir = "temp_dir"
goto_dedup_dir = "unsortedButMerged_ForBismark_file"
goto_meth_dir = "unsortedButMerged_ForBismark_file/methylation_extraction"
coverage_dir = abs_parent_dir_path
lambda_bam_dir = "lambda_genome/bam_files"

out_directory = os.path.join(abs_parent_dir_path, "summary_report_ofall_LIBS")
if not os.path.exists(out_directory):
    os.makedirs(out_directory)

dir_list = [ each_dir[:-1] for each_dir in glob.glob(join(abs_parent_dir_path,dir_pattern))]

if expt_type == "SE": 
    print_expt_type = "WGBS Assay Type: Single-End\n\n\n" 
    print print_expt_type
    for each_dir in dir_list:
        each_dir_basename = os.path.basename(each_dir)
        print_SL = "### QC for Lib (%s)\n" %(each_dir_basename)
        print print_SL    
    
        trimmed_read1_file_list = glob.glob(os.path.join(each_dir, goto_trim_dir, "*_1_*trimming_report.txt"))
        reports_file_list = glob.glob(os.path.join(each_dir, goto_bam_dir, "*SE_report.txt"))
        lambda_reports_file_list = glob.glob(os.path.join(each_dir, lambda_bam_dir, "*SE_report.txt"))

        ### single file based instead of list thus slice the list of file with [0] for each instance:
        deduplicated_file = glob.glob(os.path.join(each_dir, goto_dedup_dir, "*%s*deduplication_report.txt" %(each_dir_basename)))[0]
        meth_extractor_file = glob.glob(os.path.join(each_dir, goto_meth_dir, "*%s*splitting_report.txt" %(each_dir_basename)))[0]
        genome_cov_file = glob.glob(os.path.join(each_dir, coverage_dir, "*%s*metrics.txt" %(each_dir_basename)))[0]
        
        get_uniq_outfile = join(out_directory, each_dir_basename + "_bismark_analysis.txt")
        with open(get_uniq_outfile, "w") as outfile:
            outfile.write(print_expt_type)
            outfile.write(print_SL)

            ### Parse data from trim galore on total reads and trimmed reads: 
            processed_read1_count = []
            trimmed_read1_count = []
            quality_issues_trimmed_readcount = []
            for read1_file in trimmed_read1_file_list:
                with open(read1_file, "r") as file1:
                    data = file1.read()
                    processed_reads_1 = re.compile("Processed reads:\s+(\d+)").findall(data)
                    processed_read1_count.extend(processed_reads_1)
                    adap_trim_reads_1 = re.compile("Trimmed reads:\s+(\d+)").findall(data)
                    trimmed_read1_count.extend(adap_trim_reads_1)
                    quality_issues_trimmed_reads = re.compile("[a-zA-Z]+ shorter than the length cutoff .*?:\s+(\d+)").findall(data)
                    quality_issues_trimmed_readcount.extend(quality_issues_trimmed_reads)
                    #print "processed reads", processed_reads_1
                    #print "trimmed reads", adap_trim_reads_1


            #Convert list of strings to int lists
            Total_read1_count = sum(map(int, processed_read1_count))
            Total_trimmed_read1_count = sum(map(int, trimmed_read1_count))
            adap_content_read1 = round(float(Total_trimmed_read1_count)/float(Total_read1_count)*100, 2)
            Total_raw_read_count = Total_read1_count 

            Total_quality_issues_reads = sum(map(int, quality_issues_trimmed_readcount))
            Percent_quality_issues_reads = round(float(Total_quality_issues_reads)/float(Total_read1_count)*100, 2)            

            print_total_read_count = "Total reads processed : %s\n" %(Total_raw_read_count)
            print_adap_content_1 = "Adapter Trimmed reads for Read1 : %s%%\n" %(adap_content_read1)
            print_perc_quality_issues_reads = "Reads/Sequences discarded due to quality issues: %s%% (%s)\n" %(Percent_quality_issues_reads, Total_quality_issues_reads)
            outfile.write(print_total_read_count)
            outfile.write(print_adap_content_1)
            outfile.write(print_perc_quality_issues_reads)
            print print_total_read_count
            print print_adap_content_1
            print print_perc_quality_issues_reads
        
            ### Parse data on mapping eff: 
            final_analysed_read = []
            final_unique_hit = []
            for each_file in reports_file_list:
                with open(each_file, "r") as file:
                    data = file.read()
                    raw_read_pattern = "Sequences analysed in total:\s(\d+)"
                    regex_next = re.compile(raw_read_pattern)
                    read_count = regex_next.findall(data)
                    final_analysed_read.extend(read_count)
                    
                    unique_hit_pattern = "Number of alignments with a unique best hit from the different alignments:\s(\d+)"
                    regex_next = re.compile(unique_hit_pattern)
                    uniquehit_count = regex_next.findall(data)
                    final_unique_hit.extend(uniquehit_count)
                
            #Convert list of strings to int lists
            final_unique_hit_int = map(int, final_unique_hit)
            final_analysed_read_int = map(int, final_analysed_read)
            
            print_read_count = "\n\nTrim galore QC passed reads : %s\n" %(sum(final_analysed_read_int))
            print print_read_count
            outfile.write(print_read_count)
            
            Mapping_efficiency = round(float(sum(final_unique_hit_int))/float(sum(final_analysed_read_int))*100, 2)
            print_map_eff = "Mapping efficiency : %s%%\n" %(Mapping_efficiency) ## use %%  to selectively esc percent(%) in Python strings
            print print_map_eff
            outfile.write(print_map_eff)
            
            ### Parse data on pcr duplicates, cpg methylation: 
            with open(deduplicated_file, "r") as dedup_file:
                dedup_perc = re.compile("Total number duplicated alignments removed:\s+\d+\s+\((\d+.*)\)").findall(dedup_file.read())
                print_dedup_perc = "PCR duplicates : %s\n" %(dedup_perc[0])  #since regex captures the list
                print print_dedup_perc
                outfile.write(print_dedup_perc)

            with open(meth_extractor_file, "r") as meth_file:
                meth_perc = re.compile("C methylated in CpG context:\s+(\d+.*)").findall(meth_file.read())
                print_meth_perc = "CpG methylation : %s\n" %(meth_perc[0]) #since regex captures the list
                print print_meth_perc
                outfile.write(print_meth_perc)
    
            ### Parse the genome coverage:
            with open(genome_cov_file, "r") as cov_file:
                coverage = re.compile("(.*?)\s+(genome)\s+([0-9]+\.[0-9]{2})").findall(cov_file.read())
                print_coverage = "Genome Coverage : %sX\n" %(coverage[0][2])
                print print_coverage
                outfile.write(print_coverage)
            
            ### Parse data on lambda/Bisulfite non-conversion rate:
            lambda_meth_count = []
            lambda_unmeth_count = []
            for each_file in lambda_reports_file_list:
                with open(each_file, "r") as file:
                    data = file.read()
                    meth_pattern = "Total methylated C's in CpG context:\s+(\d+)"
                    regex_next = re.compile(meth_pattern)
                    meth_count = regex_next.findall(data)
                    lambda_meth_count.extend(meth_count)
                    
                    unmeth_pattern = "Total unmethylated C's in CpG context:\s+(\d+)"
                    regex_next = re.compile(unmeth_pattern)
                    unmeth_count = regex_next.findall(data)
                    lambda_unmeth_count.extend(unmeth_count)
                
            #Convert list of strings to int lists
            lambda_meth_count_int = map(int, lambda_meth_count)
            lambda_unmeth_count_int = map(int, lambda_unmeth_count)
            total_meth_unmeth_count_int = lambda_meth_count_int + lambda_unmeth_count_int
            try:
                lambda_meth_percent = round(float(sum(lambda_meth_count_int))/float(sum(total_meth_unmeth_count_int))*100, 2)
                print_lambda_meth_perc = "Lambda/Bisulfite non-conversion rate (CpG methylation) : %s%%\n\n\n" %(lambda_meth_percent)
            except ZeroDivisionError:
                lambda_meth_percent = "N/A"
                print_lambda_meth_perc = "Lambda/Bisulfite non-conversion rate (CpG methylation) : %s\n\n\n" %(lambda_meth_percent) 
            print print_lambda_meth_perc
            outfile.write(print_lambda_meth_perc)
             

elif expt_type == "PE": 
    print_expt_type = "WGBS Assay Type: Paired-End\n\n\n" 
    print print_expt_type

    for each_dir in dir_list:
        each_dir_basename = os.path.basename(each_dir)
        print_SL = "### QC for Lib (%s)\n" %(each_dir_basename)
        print print_SL
        
        trimmed_read1_file_list = glob.glob(os.path.join(each_dir, goto_trim_dir, "*_1_*trimming_report.txt"))
        trimmed_read2_file_list = glob.glob(os.path.join(each_dir, goto_trim_dir, "*_2_*trimming_report.txt"))
        #reports_file_list = glob.glob(os.path.join(each_dir, goto_bam_dir, "*%s*PE_report.txt" %(each_dir_basename)))
        reports_file_list = glob.glob(os.path.join(each_dir, goto_bam_dir, "*PE_report.txt"))
        lambda_reports_file_list = glob.glob(os.path.join(each_dir, lambda_bam_dir, "*PE_report.txt"))

        ### single file based instead of list thus slice the list of file with [0] for each instance:
        deduplicated_file = glob.glob(os.path.join(each_dir, goto_dedup_dir, "*%s*deduplication_report.txt" %(each_dir_basename)))[0]
        meth_extractor_file = glob.glob(os.path.join(each_dir, goto_meth_dir, "*%s*splitting_report.txt" %(each_dir_basename)))[0]
        genome_cov_file = glob.glob(os.path.join(each_dir, coverage_dir, "*%s*metrics.txt" %(each_dir_basename)))[0]
        
        get_uniq_outfile = os.path.join(out_directory, each_dir_basename + "_bismark_analysis.txt" )
        with open(get_uniq_outfile, "w") as outfile:
            outfile.write(print_expt_type)
            outfile.write(print_SL)

            ### Parse data from trim galore on total reads and trimmed reads: 
            processed_read1_count = []
            processed_read2_count = []
            trimmed_read1_count = []
            trimmed_read2_count = []
            quality_issues_trimmed_readcount = []
            for read1_file in trimmed_read1_file_list:
                for read2_file in trimmed_read2_file_list:
                    read1_id = re.compile("(.*?)_1_(.*)").findall(read1_file)
                    id_1 = "_".join([read1_id[0][0], read1_id[0][1]])

                    read2_id = re.compile("(.*?)_2_(.*)").findall(read2_file)
                    id_2 = "_".join([read2_id[0][0], read2_id[0][1]])

                    if id_1 == id_2:
                        #print "\nProcessing...", id_1, id_2
                        with open(read1_file, "r") as file1:
                            data = file1.read()
                            processed_reads_1 = re.compile("Processed reads:\s+(\d+)").findall(data)
                            processed_read1_count.extend(processed_reads_1)
                            adap_trim_reads_1 = re.compile("Trimmed reads:\s+(\d+)").findall(data)
                            trimmed_read1_count.extend(adap_trim_reads_1)
                            #print processed_reads_1
                            #print adap_trim_reads_1

                        with open(read2_file, "r") as file2:
                            data = file2.read()
                            processed_reads_2 = re.compile("Processed reads:\s+(\d+)").findall(data)
                            processed_read2_count.extend(processed_reads_2)
                            adap_trim_reads_2 = re.compile("Trimmed reads:\s+(\d+)").findall(data)
                            trimmed_read2_count.extend(adap_trim_reads_2)
                            quality_issues_trimmed_reads = re.compile("[a-zA-Z]+ shorter than the length cutoff .*?:\s+(\d+)").findall(data)
                            quality_issues_trimmed_readcount.extend(quality_issues_trimmed_reads)

                            #print processed_reads_2
                            #print adap_trim_reads_2

            Total_read1_count = sum(map(int, processed_read1_count))
            Total_trimmed_read1_count = sum(map(int, trimmed_read1_count))
            adap_content_read1 = round(float(Total_trimmed_read1_count)/float(Total_read1_count)*100, 2)

            Total_trimmed_read2_count = sum(map(int, trimmed_read2_count))
            Total_read2_count = sum(map(int, processed_read2_count))
            adap_content_read2 = round(float(Total_trimmed_read2_count)/float(Total_read2_count)*100, 2)
            Total_raw_read_count = Total_read1_count + Total_read2_count

            Total_quality_issues_reads = sum(map(int, quality_issues_trimmed_readcount))
            Percent_quality_issues_reads = round(float(Total_quality_issues_reads)/float(Total_read1_count)*100, 2) # Treated PE as total, represented by either read1 or read2          

            #print_total_read_count = "Total reads processed: %s PE\n" %(Total_raw_read_count)
            print_total_read_count = "Total reads processed: %s pairs (*2=%s reads)\n" %(Total_read1_count, Total_raw_read_count)
            print_adap_content_1 = "Adapter Trimmed reads for Read1: %s%%\n" %(adap_content_read1)
            print_adap_content_2 = "Adapter Trimmed reads for Read2: %s%%\n" %(adap_content_read2)
            print_perc_quality_issues_reads = "Reads/Sequences discarded due to quality issues: %s%% (%s)\n" %(Percent_quality_issues_reads, Total_quality_issues_reads)
            outfile.write(print_total_read_count)
            outfile.write(print_adap_content_1)
            outfile.write(print_adap_content_2)
            outfile.write(print_perc_quality_issues_reads)
            print print_total_read_count
            print print_adap_content_1
            print print_adap_content_2
            print print_perc_quality_issues_reads
        
            ### Parse data on mapping eff: 
            final_analysed_read = []
            final_unique_hit = []
            for each_file in reports_file_list:
                with open(each_file, "r") as file:
                    data = file.read()
                    raw_read_pattern = "Sequence pairs analysed in total:\s(\d+)"
                    regex_next = re.compile(raw_read_pattern)
                    read_count = regex_next.findall(data)
                    final_analysed_read.extend(read_count)
                    
                    unique_hit_pattern = "Number of paired-end alignments with a unique best hit:\s(\d+)"
                    regex_next = re.compile(unique_hit_pattern)
                    uniquehit_count = regex_next.findall(data)
                    final_unique_hit.extend(uniquehit_count)
                
            #Convert list of strings to int lists
            final_unique_hit_int = map(int, final_unique_hit)
            final_analysed_read_int = map(int, final_analysed_read)
            
            print_read_count = "\n\nTrim galore QC passed reads : %s pairs\n" %(sum(final_analysed_read_int))
            print print_read_count
            outfile.write(print_read_count)
            
            Mapping_efficiency = round(float(sum(final_unique_hit_int))/float(sum(final_analysed_read_int))*100, 2)
            print_map_eff = "Mapping efficiency : %s%%\n" %(Mapping_efficiency) ## use %%  to selectively esc percent(%) in Python strings
            print print_map_eff
            outfile.write(print_map_eff)
            
            ### Parse data on pcr duplicates, cpg methylation: 
            with open(deduplicated_file, "r") as dedup_file:
                dedup_perc = re.compile("Total number duplicated alignments removed:\s+\d+\s+\((\d+.*)\)").findall(dedup_file.read())
                print_dedup_perc = "PCR duplicates : %s\n" %(dedup_perc[0])  #since regex captures the list
                print print_dedup_perc
                outfile.write(print_dedup_perc)

            with open(meth_extractor_file, "r") as meth_file:
                meth_perc = re.compile("C methylated in CpG context:\s+(\d+.*)").findall(meth_file.read())
                print_meth_perc = "CpG methylation : %s\n" %(meth_perc[0]) #since regex captures the list
                print print_meth_perc 
                outfile.write(print_meth_perc)
    
            ### Parse the genome coverage:
            with open(genome_cov_file, "r") as cov_file:
                coverage = re.compile("(.*?)\s+(genome)\s+([0-9]+\.[0-9]{2})").findall(cov_file.read())
                print_coverage = "Genome Coverage : %sX\n" %(coverage[0][2])
                print print_coverage
                outfile.write(print_coverage)
            
            ### Parse data on lambda/Bisulfite non-conversion rate:
            lambda_meth_count = []
            lambda_unmeth_count = []
            for each_file in lambda_reports_file_list:
                with open(each_file, "r") as file:
                    data = file.read()
                    meth_pattern = "Total methylated C's in CpG context:\s+(\d+)"
                    regex_next = re.compile(meth_pattern)
                    meth_count = regex_next.findall(data)
                    lambda_meth_count.extend(meth_count)
                    
                    unmeth_pattern = "Total unmethylated C's in CpG context:\s+(\d+)"
                    regex_next = re.compile(unmeth_pattern)
                    unmeth_count = regex_next.findall(data)
                    lambda_unmeth_count.extend(unmeth_count)
                
            #Convert list of strings to int lists
            lambda_meth_count_int = map(int, lambda_meth_count)
            lambda_unmeth_count_int = map(int, lambda_unmeth_count)
            total_meth_unmeth_count_int = lambda_meth_count_int + lambda_unmeth_count_int
            try:
                lambda_meth_percent = round(float(sum(lambda_meth_count_int))/float(sum(total_meth_unmeth_count_int))*100, 2)
                print_lambda_meth_perc = "Lambda/Bisulfite non-conversion rate (CpG methylation) : %s%%\n\n\n" %(lambda_meth_percent)
            except ZeroDivisionError:
                lambda_meth_percent = "N/A"
                print_lambda_meth_perc = "Lambda/Bisulfite non-conversion rate (CpG methylation) : %s\n\n\n" %(lambda_meth_percent)
            print print_lambda_meth_perc
            outfile.write(print_lambda_meth_perc)

else:
    sys.exit('Please give input as <"PE"> or <"SE">')

