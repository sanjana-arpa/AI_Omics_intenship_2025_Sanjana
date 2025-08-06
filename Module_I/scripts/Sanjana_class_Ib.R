# 1. Set Working Directory
# Create a new folder on your computer "AI_Omics_Internship_2025".
setwd("F:/AI_Omics_internship_2025")
getwd()

# 2. Create Project Folder
# In RStudio, create a new project named "Module_I" in your "AI_Omics_Internship_2025" folder.
setwd("F:/AI_Omics_internship_2025/Module_I")

# Inside the project directory, create the following subfolders using R code:
# raw_data, clean_data, scripts, results or Tasks, plots etc
dir.create("raw_data")
dir.create("clean_data")
dir.create("scripts")
dir.create("results")
dir.create("plots")

# 3. Download "patient_info.csv" dataset from GitHub repository
# load the dataset into your R environment
data <- read.csv(file.choose())

# Inspect the structure of the dataset using appropriate R functions
View(data)
str(data)

# Identify variables with incorrect or inconsistent data types.
# Convert variables to appropriate data types where needed
data$gender <- as.factor(data$gender)
class(data$gender)
data$diagnosis <- as.factor(data$diagnosis)
class(data$diagnosis)
data$smoker <- as.factor(data$smoker)
class(data$smoker)

# Create a new variable for smoking status as a binary factor:
# 1 for "Yes", 0 for "No"
data$smoker_num <- ifelse(data$smoker == "Yes", 1, 0)
data$smoker_num <- as.factor(data$smoker_num)
class(data$smoker_num)

# Save the cleaned dataset in your clean_data folder with the name patient_info_clean.csv
write.csv(data, file = "clean_data/patient_info_clean.csv")

# Save your R script in your script folder with name "class_Ib"
save.image(file = "scripts/class_Ib.R")

# Save your R script in your script folder with name "Your Name_class_Ib.RData"
save.image(file = "scripts/Sanjana_class_Ib.RData")