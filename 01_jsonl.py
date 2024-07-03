import json
import os

# Specify the folder containing the files
folder_path = '2001-'

# Get a sorted list of all text files in the folder
file_list = sorted([f for f in os.listdir(folder_path) if f.endswith('.txt')])

# Initialize an empty list to store the data
data = []

# Loop through each file in the folder
for file_name in file_list:
    try:
        # Construct the full file path
        file_path = os.path.join(folder_path, file_name)
        
        # Read the contents of the file
        with open(file_path, 'r') as file:
            file_content = file.read()
        
        # Extract the page number from the file name (assuming format 'page_X.txt')
        page_number = file_name.split('.')[0].split('_')[-1]
        
        # Construct the dictionary for this file
        entry = {
            "custom_id": f"page {page_number}",
            "method": "POST",
            "url": "/v1/chat/completions",
            "body": {
                "model": "gpt-4",
                "messages": [
                    {
                        "role": "system",
                        "content": "Format this for me as a 3 column csv. The first number refers to the part of the code of federal regulations. Column 2 is what was changed. Column 3 is the Page of the Federal Register where it happened. Do not generate additional text other than the csv."
                    },
                    {
                        "role": "user",
                        "content": file_content
                    }
                ]
            }
        }
        
        # Append the entry to the data list
        data.append(entry)
        
        # Print debug information
        print(f"Processed file: {file_name}, Page number: {page_number}")
        
    except Exception as e:
        print(f"Error processing file: {file_name}, Error: {e}")

# Ensure the output directory exists
output_dir = os.path.dirname('2000-/2000.jsonl')
if not os.path.exists(output_dir):
    os.makedirs(output_dir)

# Specify the output file path
output_file_path = '2001-/2001.jsonl'

# Write the data to the JSON Lines file
try:
    with open(output_file_path, 'w') as outfile:
        for entry in data:
            json.dump(entry, outfile)
            outfile.write('\n')
    print(f"Successfully wrote data to {output_file_path}")
except Exception as e:
    print(f"Error writing to output file: {output_file_path}, Error: {e}")
