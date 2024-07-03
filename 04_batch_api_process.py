from openai import OpenAI
import json
import os
import csv

# Read API key from a file
with open('api_key.txt', 'r') as file:
    api_key = file.read().strip()

client = OpenAI(api_key=api_key)

output_file_id = "file-mcD6hxJkqaU5rBvUDLiYzToq"

try:
    output_content_response = client.files.content(output_file_id)
    output_content_bytes = output_content_response.read()
    output_content = output_content_bytes.decode('utf-8')
except Exception as e:
    print(f"Error retrieving batch results: {e}")

table = []

lines = output_content.strip().split('\n')

for line in lines:
    try:
        json_obj = json.loads(line)
        custom_id = json_obj['custom_id']
        content = json_obj['response']['body']['choices'][0]['message']['content']
        table.append({
            'custom_id': custom_id,
            'content': content
        })
    except Exception as e:
        print(f"Error processing line: {line}. Error: {e}")

# Define the path to the directory where you want to save the text files
output_dir = "2001-/csv"  # Change this to your desired directory path

# Ensure the directory for the text files exists
os.makedirs(output_dir, exist_ok=True)

# Prepare the CSV file
csv_file_path = os.path.join(output_dir, "results.csv")

with open(csv_file_path, mode='w', encoding='utf-8', newline='') as csv_file:
    writer = csv.writer(csv_file)
    writer.writerow(['custom_id', 'content', 'file_path'])  # Write header row

    # Write each content to a separate text file, named after the custom_id, and add a row to the CSV file
    for row in table:
        file_name = f"{row['custom_id']}.txt"
        file_path = os.path.join(output_dir, file_name)
        
        try:
            with open(file_path, mode='w', encoding='utf-8') as file:
                file.write(row['content'])
            writer.writerow([row['custom_id'], row['content'], file_path])
        except Exception as e:
            print(f"Error writing file {file_name}: {e}")

print(f"Content successfully saved to individual text files and CSV file in {output_dir}")
