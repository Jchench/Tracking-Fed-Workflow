# Set the path to your folder
folder_path <- "1973-1985/csv/combine"

# List all CSV files in the folder
file_list <- list.files(path = folder_path, pattern = "*.csv", full.names = TRUE)

# Read all CSV files into a list of data frames
data_frames <- lapply(file_list, read.csv)

# Combine all data frames into one
combined_changes <- do.call(rbind, data_frames)

# Write the combined data frame to a CSV file
write.csv(combined_changes, file = "1973-1985/csv/1973-1985.csv", row.names = FALSE)