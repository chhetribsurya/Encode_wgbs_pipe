#!/usr/bin/env Rscript

library(data.table)
library(ggplot2)

### Input variables passed over:
args <-  commandArgs(TRUE)
input_file <- args[1]
output_dir <- args[2]
file_name <- args[3]


insert_df <- fread(input_file, sep="\t")
names(insert_df) <- c("insert_size")
mean_insert <- mean(insert_df$insert_size)


insert_size_plot <- ggplot(insert_df, aes(x=insert_size)) + geom_histogram(aes(fill = ..count..)) +
                    geom_vline(xintercept=mean_insert, linetype="dashed") 

insert_size_plot + annotate(geom="text",label=paste("Mean insert: ", round(mean_insert,2)), x =mean_insert+10, y= max(ggplot_build(insert_size_plot)$data[[1]]$count), size =4, color="red", hjust=0)

ggsave(file.path(output_dir, file_name))
