import json
import requests
import os
import csv

# Folder containing the text files
text_folder = "2000-"  # Ensure this path is correct and exists

# Check if the folder exists
if not os.path.exists(text_folder):
    raise FileNotFoundError(f"The directory {text_folder} does not exist.")

# Get list of text file paths from the folder
text_paths = []
for root, dirs, files in os.walk(text_folder):
    for file in files:
        if file.lower().endswith('.txt'):
            text_paths.append(os.path.join(root, file))

# OpenAI API Key
with open('api_key.txt', 'r') as file:
    api_key = file.read().strip()

headers = {
    "Content-Type": "application/json",
    "Authorization": f"Bearer {api_key}"
}

# Extract the base folder name for output
base_folder_name = os.path.basename(text_folder.rstrip('/'))

# Define the new folder path
csv_folder_path = os.path.join('2000-', 'csv', base_folder_name)
os.makedirs(csv_folder_path, exist_ok=True)

# Process each text file in the folder
for text_path in text_paths:
    try:
        # Read the content of the text file
        with open(text_path, 'r') as file:
            text_content = file.read()

        # Construct the payload for the single text file
        messages = [
            {
                "role": "user",
                "content": f"Format this for me as a 3 column csv. The first number refers to the part of the code of federal regulations. Column 2 is what was changed. Column 3 is the Page of the Federal Register where it happened. Do not generate additional text other than the csv.\n\n{text_content}"
            }
        ]

        payload = {
            "model": "gpt-4",
            "messages": messages
        }

        response = requests.post("https://api.openai.com/v1/chat/completions", headers=headers, json=payload)

        # Check if the response is successful
        if response.status_code == 200:
            # Parse the response as JSON
            response_data = response.json()
            
            # Extract the content from the response
            content = response_data['choices'][0]['message']['content']

            # Define the CSV file path for saving the transcription
            file_name = os.path.splitext(os.path.basename(text_path))[0] + '.csv'
            file_path = os.path.join(csv_folder_path, file_name)

            # Save the content to a CSV file
            with open(file_path, 'w', newline='') as file:
                writer = csv.writer(file)
                writer.writerow(["Part", "Change", "Page"])
                for line in content.split('\n'):
                    writer.writerow(line.split(','))

            print(f"Content saved to {file_path}")
        else:
            # Print an error message if the request failed
            print(f"Failed to retrieve data for {text_path}: {response.status_code}, {response.text}")

    except ValueError as e:
        print(f"Error with text file {text_path}: {e}")

    except Exception as e:
        print(f"An unexpected error occurred with file {text_path}: {e}")
