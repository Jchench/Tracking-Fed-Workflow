import json
import base64
import requests
import os

# Function to encode the image
def encode_image(image_path):
    with open(image_path, "rb") as image_file:
        return base64.b64encode(image_file.read()).decode('utf-8')

# Verify the image format and size
def verify_image(image_path):
    valid_formats = ['jpeg', 'png', 'gif', 'webp']
    file_size = os.path.getsize(image_path)
    file_extension = image_path.split('.')[-1].lower()

    if file_extension not in valid_formats:
        raise ValueError(f"Unsupported image format: {file_extension}")
    if file_size > 20 * 1024 * 1024:
        raise ValueError(f"File size exceeds 20 MB: {file_size / (1024 * 1024)} MB")
    return True

# Folder containing the images
image_folder = "PL104_208"

# Get list of image paths from the folder
image_paths = [os.path.join(image_folder, file) for file in os.listdir(image_folder) if file.lower().split('.')[-1] in ['jpeg', 'png', 'gif', 'webp']]

# OpenAI API Key
with open('api_key.txt', 'r') as file:
    api_key = file.read().strip()

headers = {
    "Content-Type": "application/json",
    "Authorization": f"Bearer {api_key}"
}

# Process each image in the folder
for image_path in image_paths:
    try:
        verify_image(image_path)
        encoded_image = encode_image(image_path)

        # Construct the payload for the single image
        messages = [
            {
                "role": "user",
                "content": [
                    {
                        "type": "text",
                        "text": "Transcribe this image. Do not include any other text besides the transcription."
                    },
                    {
                        "type": "image_url",
                        "image_url": {
                            "url": f"data:image/jpeg;base64,{encoded_image}"
                        }
                    }
                ]
            }
        ]

        payload = {
            "model": "gpt-4o",
            "messages": messages
        }

        response = requests.post("https://api.openai.com/v1/chat/completions", headers=headers, json=payload)

        # Check if the response is successful
        if response.status_code == 200:
            # Parse the response as JSON
            response_data = response.json()
            
            # Extract the content from the response
            content = response_data['choices'][0]['message']['content']

            # Define the folder and file path for saving the transcription
            folder_path = 'clean/PL104_208_results'
            os.makedirs(folder_path, exist_ok=True)

            # Use the original image file name for the text file
            file_name = os.path.splitext(os.path.basename(image_path))[0] + '.txt'
            file_path = os.path.join(folder_path, file_name)

            # Save the content to a text file
            with open(file_path, 'w') as file:
                file.write(content)

            print(f"Content saved to {file_path}")
        else:
            # Print an error message if the request failed
            print(f"Failed to retrieve data for {image_path}: {response.status_code}, {response.text}")

    except ValueError as e:
        print(f"Error with image {image_path}: {e}")
