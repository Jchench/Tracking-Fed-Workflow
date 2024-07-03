# Set the path to your folder
folder_path <- "1973-1985/csv/1985_50"

# List all CSV files in the folder
file_list <- list.files(path = folder_path, pattern = "*.csv", full.names = TRUE)

# Initialize an empty list to store the data frames
data_frames <- list()

# Loop through each file and read the data
for (file in file_list) {
  data <- read.csv(file)
  
  # Add the FedReg Number and Year columns
    data$FedReg_Number <- 50
    data$Year <- "1985"
  
  # Append the data frame to the list
  data_frames <- append(data_frames, list(data))
}

# Combine all data frames into one
combined_ <- do.call(rbind, data_frames)

write.csv(combined_, file = "1973-1985/csv/combine/1985_50.csv")
