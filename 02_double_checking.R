# Load necessary library
library(dplyr)

# Read the CSV file
data <- read.csv("cleaned_csv/1964_1972.csv")

# Check for NA values in the entire data frame
na_count_total <- sum(is.na(data))
cat("Total number of NA values:", na_count_total, "\n")

# Check for NA values column-wise
na_by_column <- colSums(is.na(data))
cat("NA values by column:\n")
print(na_by_column)

# Identify rows with any NA values
rows_with_na <- which(rowSums(is.na(data)) > 0)
cat("Rows with NA values:\n")
print(data[rows_with_na, ])
