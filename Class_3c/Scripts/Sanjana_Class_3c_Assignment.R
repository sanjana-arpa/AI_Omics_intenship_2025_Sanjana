# ---------------------------------------------------------------------
#              Sanjana Chowdhury Arpa
#                Assignment_Class_3c
# ---------------------------------------------------------------------

gc()  # Clear memory to free up space before analysis

# Check if BiocManager is installed; install if missing
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

# Install Bioconductor packages required for microarray analysis
BiocManager::install(c("limma", "AnnotationDbi", "hgu133plus2.db"))

# Install CRAN packages for data manipulation and visualization
install.packages(c("dplyr", "tibble", "ggplot2", "pheatmap"))

# Load Bioconductor packages
library(AnnotationDbi)
library(hgu133plus2.db)
library(limma)
library(dplyr)
library(tibble)          
library(ggplot2)
library(pheatmap)


# -------------------------------------------------------------
# Probe-to-Gene Mapping using AnnotationDbi

# Load preprocessed expression and phenotype data
load("GSE8671.RData")

# check annotation slot of your dataset
annotation(raw_data) 
# annotation package for GSE8671 is "hgu133plus2"

# Display objects available in the annotation package
ls("package:hgu133plus2.db")

columns(hgu133plus2.db)
keytypes(hgu133plus2.db)

# Extract probe IDs from processed microarray data
probe_ids <- rownames(processed_data)

# Map probe IDs to gene symbols using the platform annotation database
gene_symbols <- mapIds(
  hgu133plus2.db,          # Database used for mapping
  keys = probe_ids,        # Input probe IDs
  keytype = "PROBEID",     # Probe ID key type
  column = "SYMBOL",       # Desired annotation column (gene symbols)
  multiVals = "first"      # Return first match if multiple exist
)

# Convert mapping to a data frame and rename columns
gene_map_df <- gene_symbols %>%
  as.data.frame() %>%
  tibble::rownames_to_column("PROBEID") %>%
  dplyr::rename(SYMBOL = 2)

# -------------------------------------------------------------
# Handle multiple probes mapping to a single gene

# Summarize number of probes per gene symbol
duplicate_summary <- gene_map_df %>%
  group_by(SYMBOL) %>%
  summarise(probes_per_gene = n()) %>%
  arrange(desc(probes_per_gene))

# Identify genes associated with multiple probes
duplicate_genes <- duplicate_summary %>%
  filter(probes_per_gene > 1)

sum(duplicate_genes$probes_per_gene) 
# 32227 probes map to the same gene
# 5475 probes map to no genes (NA)


# Merge annotation mapping with expression data
# Verify if probe IDs in mapping correspond to expression data
all(gene_map_df$PROBEID == row.names(processed_data))

# Merge annotation (SYMBOL) with expression matrix
processed_data_df <- processed_data %>%
  as.data.frame() %>%
  tibble::rownames_to_column("PROBEID") %>%
  dplyr::mutate(SYMBOL = gene_symbols[PROBEID]) %>%
  dplyr::relocate(SYMBOL, .after = PROBEID)

# Remove probes without valid gene symbol annotation (NA)
processed_data_df <- processed_data_df %>%
  dplyr::filter(!is.na(SYMBOL))

# Select only numeric expression columns
expr_only <- processed_data_df %>%
  dplyr::select(-PROBEID, -SYMBOL)


# Collapse multiple probes per gene using average expression
averaged_data <- limma::avereps(expr_only, ID = processed_data_df$SYMBOL)

dim(averaged_data)
# 18340    64

# Convert averaged expression data to matrix format
data <- as.data.frame(averaged_data)
data <- data.matrix(data)
str(data)
is.numeric(data)

# -------------------------------------------------------------
#### Differential Gene Expression Analysis ####
# -------------------------------------------------------------

# Define sample groups based on phenotype data
# Adjust group labels according to dataset annotation
groups <- factor(phenotype_data$source_name_ch1,
                 levels = c("Human colonic normal mucosa", "Human colorectal adenoma"),
                 label = c("normal", "cancer"))

class(groups)
levels(groups)

# Create design matrix for linear modeling
design <- model.matrix(~0 + groups)
colnames(design) <- levels(groups)

# Fit linear model to expression data
fit_1 <- lmFit(data, design)

# Define contrast to compare cancer vs normal samples
contrast_matrix <- makeContrasts(cancer_vs_normal = cancer - normal,
                                 levels = design)

# Apply contrasts and compute moderated statistics
fit_contrast <- contrasts.fit(fit_1, contrast_matrix)

fit_2 <- eBayes(fit_contrast)

# Extract list of differentially expressed genes (DEGs)
deg_results <- topTable(fit_2,
                        coef = "cancer_vs_normal",  # Specify contrast of interest
                        number = Inf,               # Return all genes
                        adjust.method = "BH")       # Benjamini-Hochberg correction

# Classify DEGs into Upregulated, Downregulated, or Not Significant
deg_results$threshold <- as.factor(ifelse(
  deg_results$adj.P.Val < 0.05 & deg_results$logFC > 1, "Upregulated",
  ifelse(deg_results$adj.P.Val < 0.05 & deg_results$logFC < -1, "Downregulated",
         "Not Significant")
))

# Subset genes by regulation direction
upregulated <- subset(deg_results, threshold == "Upregulated")
downregulated <- subset(deg_results, threshold == "Downregulated")

nrow(upregulated)
# Upregulated Genes: 479
nrow(downregulated)
# Upregulated Genes: 550

# Combine both sets of DEGs
updown_combined_deg <- rbind(upregulated, downregulated)

write.csv(deg_results, file = "Results/DEGs_Results.csv")
write.csv(upregulated, file = "Results/Upregulated_DEGs.csv")
write.csv(downregulated, file = "Results/Downregulated_DEGs.csv")
write.csv(updown_combined_deg, file = "Results/UpDown_Combined_DEGs.csv")

# -------------------------------------------------------------
#### Data Visualization ####
# -------------------------------------------------------------

# Volcano Plot

png("Results/Result_Plots/volcano_plot.png", width = 2000, height = 1500, res = 300)

ggplot(deg_results, aes(x = logFC, y = -log10(adj.P.Val), color = threshold)) +
  geom_point(alpha = 0.7, size = 2) +
  scale_color_manual(values = c("Upregulated" = "red",
                                "Downregulated" = "green")) +
  theme_minimal() +
  labs(title = "Volcano Plot of Differentially Expressed Genes",
       x = "log2 Fold Change",
       y = "-log10(P-value)",
       color = "Regulation")

dev.off()

# Heatmap of Top 25 Differentially Expressed Genes

# Select top 25 genes with smallest adjusted p-values
top_genes <- head(rownames(updown_combined_deg[order(updown_combined_deg$adj.P.Val), ]), 25)

# Subset averaged expression matrix for selected genes
heatmap_data <- data[top_genes, ]

# Generate unique column names per sample group for display
group_char <- as.character(groups)
heatmap_names <- ave(group_char, group_char, FUN = function(x) paste0(x, "_", seq_along(x)))

# Assign formatted names to heatmap columns
colnames(heatmap_data) <- heatmap_names

# Save heatmap as PNG
png("Results/Result_Plots/Heatmap_Top25_DEGs.png", width = 2000, height = 1500, res = 300)

# Generate heatmap
pheatmap(
  heatmap_data,
  scale = "none", # for already normalized data
  cluster_rows = FALSE,
  cluster_cols = TRUE,
  show_rownames = TRUE,
  show_colnames = TRUE,
  color = colorRampPalette(c("blue", "white", "red"))(100),
  fontsize_row = 6,
  fontsize_col = 8,
  main = "Top 25 Differentially Expressed Genes"
)

dev.off()

save.image(file = "Scripts/Sanjana_Class_3c_Assignment.RData")

# ---------------------------------------------------------------------
#              Result Summary
# ---------------------------------------------------------------------

# i. 32227 probes mapped to the same gene, while 5,475 probes had no gene annotation
#    and to solve it, average expression method was used using Limma
# ii. Cancer vs Normal contrast was performed
# iii. Number of upregulated genes: 479 and Number of downregulated genes: 550