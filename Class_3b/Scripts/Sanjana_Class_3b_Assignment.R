#### Install and Load Required Packages ####

if (!requireNamespace("BiocManager", quietly = TRUE)) 
  install.packages("BiocManager")

# Install Bioconductor packages
BiocManager::install("GEOquery")
BiocManager::install("affy")
BiocManager::install("arrayQualityMetrics")

# Install CRAN packages for data manipulation
install.packages("dplyr")

library(GEOquery)
library(affy)
library(arrayQualityMetrics)
#### Download Series Matrix Files ####

gse_data <- getGEO("GSE8671", GSEMatrix = TRUE)

# Extract expression data matrix (genes/probes × samples)
# Rows corresponds to probes and columns corresponds to samples
expression_data <- exprs(gse_data$GSE8671_series_matrix.txt.gz)

# Extract feature (probe annotation) data
feature_data <- fData(gse_data$GSE8671_series_matrix.txt.gz)

# Extract phenotype (sample metadata) data
phenotype_data <- pData(gse_data$GSE8671_series_matrix.txt.gz)

# Check missing values in sample annotation
sum(is.na(phenotype_data$source_name_ch1)) 


# Untar CEL files
untar("Raw_Data/GSE8671_RAW.tar", exdir = "Raw_Data/CEL_Files")

# Read CEL files into R
raw_data <- ReadAffy(celfile.path = "Raw_Data/CEL_Files")

raw_data

#### Quality Control (QC) Before Normalization ####

arrayQualityMetrics(expressionset = raw_data,
                    outdir = "Results/QC_Raw_Data",
                    force = TRUE,
                    do.logtransform = TRUE)

#### RMA (Robust Multi-array Average) Normalization ####

normalized_data <- rma(raw_data)

# QC after data normalization 
arrayQualityMetrics(expressionset = normalized_data,
                    outdir = "Results/QC_Normalized_Data",
                    force = TRUE)


#### Observation on Number of Outliers ####

# Before Normalization: 8 (sample: 1, 13, 16, 17, 43, 58, 59, 62)
# After Normalization: 2 (sample: 13, 43)


# Extract normalized expression values into a data frame
processed_data <- as.data.frame(exprs(normalized_data))

dim(processed_data) 
# NOTE: number of transcripts = 54675


#### Filter Low-Intensity Probes ####

# Calculate median intensity per probe across samples
row_median <- rowMedians(as.matrix(processed_data))

# Visualize distribution of probe median intensities
hist(row_median,
     breaks = 100,
     freq = FALSE,
     main = "Median Intensity Distribution")

# Set a threshold to remove low variance probes
threshold <- 3.7 
abline(v = threshold, col = "red", lwd = 2) 

# Select probes above threshold
indx <- row_median > threshold 
filtered_data <- processed_data[indx, ] 

# Rename filtered expression data with sample metadata
colnames(filtered_data) <- rownames(phenotype_data)

# Overwrite processed data with filtered dataset
processed_data <- filtered_data 

dim(processed_data) 
# NOTE:remaining number of transcripts = 41275

#### Phenotype Data Preparation ####

class(phenotype_data$source_name_ch1) 

# Define experimental groups (normal vs cancer)
sample_groups <- factor(phenotype_data$source_name_ch1,
                 levels = c("Human colonic normal mucosa", "Human colorectal adenoma"),
                 label = c("normal", "cancer"))

class(sample_groups)
levels(sample_groups)

# Save R script in scripts folder with name "Your Name_class_3b_Assignment.RData"
save.image(file = "Scripts/Sanjana_Class_3b_Assignment.RData")

#### Save Processed Data for Next Class (3C) ####
# Save processed data and metadata
save(processed_data, phenotype_data, feature_data, groups,
     file = "Results/GSE79973.RData")

cat("Processed data successfully saved in 'Results/GSE79973.RData'\n")

