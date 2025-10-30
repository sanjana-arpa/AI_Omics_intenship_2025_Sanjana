**AI and Omics Research Internship (2025)**

This repository contains my work during the AI and Omics Research Internship (2025), focusing on applying machine learning and deep learning to omics data (genomics, transcriptomics, proteomics).


**Module I: R Basic Operations**

Covers basics of R programing and how to perform basic functions for data analysis in R, such as
- Creating project folders and subdirectories for organized workflow in R.
- Imported the patient_info.csv dataset into R.
- Exploring different data types in R.
- Conversion of categorical variables to factors.


**Class 1C: R Basic Syntax**
- Covers the basics syntax of R programming such as variables, comments, keywords and
- essential functions such as if, if...else loops for data analysis


**Class 3B: Microarray Data Preprocessing in R**

Covers preprocessing of raw microarray data in R for downstream analysis.

**_Steps Covered:_**
- Installation of Bioconductor package in R.
- RMA (Robust Multiarray Average) Normalization of raw data.
- Quality check before and after normalization using arrayQualityMetrics package.
- Low variance probe filtering
- Preparing phenotype data by converting categorical variables into factors (e.g. normal vs cancer).
- Saving preprocessed expression and phenotype data for use in downstream analysis.


**Class 3C:  Microarray Data Analysis in R**

Covers microarray data analysis on the preprocessed data from Class_3B.

**_Steps Covered:_**
- Probe to gene mapping using AnnotationDbi and the appropriate platform annotation package (e.g. hgu133plus2.db).
- Performing differential gene expression analysis with the Limma package.
- Filtering significant genes based on adjusted p-value and log fold change thresholds.
- Visualization of significant genes through
  
         - volcano plots (for upregulated and downregulated genes)
         - heatmaps (for top 25 DEGs)


  		

**Dataset Information:**

**GEO Accession:** GSE8671

**Source:** NCBI Gene Expression Omnibus (GEO)

**Title:** Transcriptome profile of human colorectal adenomas

**Organism:** _Homo sapiens_

**Experiment type:**	Expression profiling by array

**Disease Type:** Colorectal Cancer

**Samples:** 64 human colonic tissue samples (32 normal mucosa and 32 adenoma tissues)

**Platform:** Affymetrix Human Genome U133 Plus 2.0 Array (GPL570)
