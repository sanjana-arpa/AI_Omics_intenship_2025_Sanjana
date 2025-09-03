# 1. Check Cholesterol level (using if) 
# Write an If statement to check cholesterol level is greater than 240, 
# if true, it will prints “High Cholesterol”

cholesterol <- 230
if (cholesterol > 240) {
  print("High Cholesterol")
} else {
  print("Cholesterol is normal")
}

# ----------------------------------------------------------------------------------------------------------------

# 2. Blood Pressure Status (using if...else)
# Write an if…else statement to check if blood pressure is normal.
# If it’s less than 120, print: “Blood Pressure is normal”
# If false then print: “Blood Pressure is high”

Systolic_bp <- 130
if (Systolic_bp < 120) {
  print("Blood pressure is normal")
} else {
  print("Blood pressure is high")
}

# ----------------------------------------------------------------------------------------------------------------

# 3. Automating Data Type Conversion with for loop

# Use patient_info.csv data and metadata.csv
# Perform the following steps separately on each dataset (patient_info.csv data and metadata.csv)
# Create a copy of the dataset to work on.
# Identify all columns that should be converted to factor type.
# Store their names in a variable (factor_cols).

# Example: factor_cols <- c("gender", "smoking_status")

# Use a for loop to convert all the columns in factor_cols to factor type.
# Pass factor_cols to the loop as a vector.

# Hint:
# for (col in factor_cols) {
#   data[[col]] <- as.factor(data[[col]])  # Replace 'data' with the name of your dataset
# }

patient_data <- read.csv(file.choose())
metadata <- read.csv(file.choose())

View(patient_data)
str(patient_data)
View(metadata)
str(metadata)

# Keep a copy of originals
original_patient_data <- patient_data
original_metadata <- metadata

# For patient_data
factor_cols_patient <- c("gender", "diagnosis", "smoker")
for (col in factor_cols_patient) {
  patient_data[[col]] <- as.factor(patient_data[[col]])
}

# For metadata
factor_cols_metadata <- c("height", "gender")
for (col in factor_cols_metadata) {
  metadata[[col]] <- as.factor(metadata[[col]])
}

# ----------------------------------------------------------------------------------------------------------------

# 4. Converting Factors to Numeric Codes

# Choose one or more factor columns (e.g., smoking_status).
# Convert "Yes" to 1 and "No" to 0 using a for loop.

# Hint:
# binary_cols <- c("smoking_status")   # store column names in a vector
# use ifelse() condition inside the loop to replace Yes with 1 and No with 0
# for (col in binary_cols) {
#   data[[col]] <- # insert your ifelse() code here
# }

binary_cols <- c("smoker")
for (col in binary_cols) {
  patient_data[[col]] <- ifelse(patient_data[[col]] == "Yes", 1, 0)
}

# ----------------------------------------------------------------------------------------------------------------

#  Verification:
#    Compare the original and modified datasets to confirm changes.
#    str(original_data)
#    str(data)

str(original_patient_data)
str(patient_data)
str(original_metadata)
str(metadata)

# Save the cleaned dataset in clean_data folder
write.csv(patient_data, file = "clean_data/patient_info_clean.csv")
write.csv(metadata, file = "clean_data/metadata_clean.csv")


# Save the R script
save.image(file = "scripts/Sanjana_class_Ic.RData")