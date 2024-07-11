# Load necessary libraries
library(tidyverse)

# Define the path to the main directory containing the folders
main_directory <- "1949-1963/csv"

# Define the path to the output directory
output_directory <- "1949-1963/combine"

# Create the output directory if it doesn't exist
if (!dir.exists(output_directory)) {
  dir.create(output_directory)
}

# Get a list of all folders in the main directory
folders <- list.dirs(main_directory, full.names = TRUE, recursive = FALSE)

# Function to process each folder
process_folder <- function(folder_path) {
  # Extract the folder name
  folder_name <- basename(folder_path)
  
  # Extract year and fedreg_number from the folder name
  year <- strsplit(folder_name, "_")[[1]][1]
  fedreg_number <- strsplit(folder_name, "_")[[1]][2]
  
  # Get a list of all CSV files in the folder
  csv_files <- list.files(folder_path, pattern = "\\.csv$", full.names = TRUE)
  
  # Process each CSV file
  for (csv_file in csv_files) {
    # Read the CSV file
    data <- read.csv(csv_file)
    
    # Add the new columns
    data <- data %>%
      mutate(
        change = "unknown",
        year = year,
        fedreg_number = fedreg_number
      )
    
    # Define the output file path
    output_file <- file.path(output_directory, paste0(folder_name, "_", basename(csv_file)))
    
    # Write the updated data to the output file
    write.csv(data, output_file, row.names = FALSE)
  }
}

# Apply the function to each folder
lapply(folders, process_folder)
