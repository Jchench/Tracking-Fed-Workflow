from openai import OpenAI
import time

with open('api_key.txt', 'r') as file:
    api_key = file.read().strip()

client = OpenAI(api_key=api_key)

batch_input_file_id = "file-FxavKGeMqkCOb994rPzKNcvN"

batch_response = client.batches.create(
    input_file_id=batch_input_file_id,
    endpoint="/v1/chat/completions",
    completion_window="24h",
    metadata={
        "description": "cleaned OCR excerpts"
    }
)

print("Batch job created successfully!")
print("Batch ID:", batch_response.id)

output_file_id = batch_response.output_file_id

batch_status = client.batches.retrieve(batch_response.id)
print("Batch status:", batch_status.status)

while batch_status.status not in ["completed", "failed", "expired", "cancelled"]:
    batch_status = client.batches.retrieve(batch_response.id)
    print("Batch status:", batch_status.status)
    time.sleep(10)

if batch_status.status == "completed":
    result_file_id = batch_status.output_file_id
    print(result_file_id)

