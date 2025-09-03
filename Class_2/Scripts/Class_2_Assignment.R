# Write a function classify_gene() 

# that takes:
#   - logFC (log2FoldChange)
#   - padj  (adjusted p-value)
# and returns:
#   - "Upregulated" if log2FC > 1 and padj < 0.05
#   - "Downregulated" if log2FC < -1 and padj < 0.05
#   - "Not_Significant" otherwise

classify_gene <- function(log2FC, padj) {
  if (log2FC > 1 & padj < 0.05) {
    return("Upregulated")
  } else if (log2FC < -1 & padj < 0.05) {
    return("Downregulated")
  } else {
    return("Not_Significant")
  }
}

# Setup Folders
input_dir <- "Raw_Data"
output_dir <- "Results"
#check if the output folder exists
if (!dir.exists(output_dir)) {
  dir.create(output_dir)
}

#List which files to process
files_to_process <- c("DEGs_Data_1.csv", "DEGs_Data_2.csv")

#Prepare empty list to store results in R
result_list <- list()

#for loop
for (file_names in files_to_process) {
  cat("\nProcessing:", file_names, "\n")
  input_file_path <- file.path(input_dir, file_names)
  
  #import dataset
  data <- read.csv(input_file_path, header = TRUE)
  cat("File imported. Checking for missing values!\n")
  
  #Replace missing padj values with 1
  data$padj[is.na(data$padj)] <- 1
  cat("Missing values are replaced.\n")
  
  #Add a new column 'status'
  data$status <- NA
  for (i in 1:nrow(data)) {
    data$status[i] <- classify_gene(data$logFC[i], data$padj[i])
  }
}

# - Print summary counts of significant, upregulated, and downregulated genes
up_count <- sum(data$status == "Upregulated")
cat("Upregulated genes:", up_count, "\n")

down_count <- sum(data$status == "Downregulated")
cat("Downregulated genes:", down_count, "\n")

sig_count <- up_count + down_count
cat("Significant genes:", sig_count, "\n")

# Print results
summary_table <- c(Upregulated = up_count, Downregulated = down_count, Significant = sig_count)
print(summary_table)

#Save results in R
result_list[[file_names]] <- data

#Save results in results folder
output_file_path <- file.path(output_dir, paste0("Classified_Data", file_names))

write.csv(data, output_file_path, row.names = FALSE)
cat("Results saved to:", output_file_path,"\n")

# Save R script in scripts folder with name "class_2_Assignment"
save.image(file = "Scripts/Sanjana_class_2_Assignment.R")

# Save R script in scripts folder with name "Your Name_class_2_Assignment.RData"
save.image(file = "Scripts/Sanjana_Class_2_Assignment.RData")