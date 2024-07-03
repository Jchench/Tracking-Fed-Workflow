library(dplyr)

# Set the path to your folder
folder_path <- "1964-1972/csv/combine"

# List all CSV files in the folder
file_list <- list.files(path = folder_path, pattern = "*.csv", full.names = TRUE)

# Read all CSV files into a list of data frames
data_frames <- lapply(file_list, read.csv)

# Combine all data frames into one
combined_changes <- do.call(rbind, data_frames)

# Group and summarize the combined data frame
combined_changes <- combined_changes |> 
  group_by(Part.Number, Change, FedReg_Number, Year) |> 
  summarize(Page = paste(Page, collapse = ", ")) |> 
  ungroup()

combined_changes <- combined_changes |> 
  select(Part.Number, Change, Page, FedReg_Number, Year)

# Write the combined data frame to a CSV file
write.csv(combined_changes, file = "cleaned_csv/1964_1972.csv", row.names = FALSE)
