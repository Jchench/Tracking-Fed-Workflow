# Load necessary library
library(dplyr)

# Define the year value you want to add
year_value <- 2007

# Read the CSV file
data <- read.csv("2001-/csv_odd/2007.csv")

# Add the new columns
data <- data %>%
  mutate(year = year_value,
         fedreg_number = year_value - 1935)

# Write the updated data back to a CSV file
write.csv(data, "2001-/2007_output.csv", row.names = FALSE)

# Print a message to confirm completion
cat("Columns 'year' and 'fedreg_number' added successfully.\n")
