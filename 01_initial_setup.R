# Set the path to your folder
folder_path <- "FedReg315/csv"

# List all CSV files in the folder
file_list <- list.files(path = folder_path, pattern = "*.csv", full.names = TRUE)

# Initialize an empty list to store the data frames
data_frames <- list()

# Loop through each file and read the data
for (file in file_list) {
  data <- read.csv(file)
  data_frames <- append(data_frames, list(data))
}

# Combine all data frames into one
combined_data_315 <- do.call(rbind, data_frames)

# View the combined data
print(combined_data_315)
