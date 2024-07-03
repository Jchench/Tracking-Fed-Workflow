from openai import OpenAI

with open('api_key.txt', 'r') as file:
    api_key = file.read().strip()

client = OpenAI(api_key=api_key)

jsonl_file_path = "2001-/2001.jsonl"

with open(jsonl_file_path, "rb") as file:
    batch_input_file = client.files.create(
        file=file,
        purpose="batch"
    )

print("Batch input file uploaded successfully!")

batch_input_file_id = batch_input_file.id
print("Batch input file ID:", batch_input_file_id)
