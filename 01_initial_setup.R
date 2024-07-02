# Set the path to your folder
folder_path <- ""

# List all CSV files in the folder
file_list <- list.files(path = folder_path, pattern = "*.csv", full.names = TRUE)

# Initialize an empty list to store the data frames
data_frames <- list()

# Loop through each file and read the data
for (file in file_list) {
  data <- read.csv(file)
  
  # Add the FedReg Number and Year columns
    data$FedReg_Number <- 38
    data$Year <- "1973"
  
  # Append the data frame to the list
  data_frames <- append(data_frames, list(data))
}

# Combine all data frames into one
combined_ <- do.call(rbind, data_frames)

write.csv(combined_, file = "")
