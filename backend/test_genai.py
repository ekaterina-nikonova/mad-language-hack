import os
from google import genai

try:
    print("Testing gemini-3.1-pro...")
    client = genai.Client(http_options={'api_version': 'v1alpha'})
    response = client.models.generate_content(
        model='gemini-3.1-pro',
        contents='Tell me a joke.'
    )
    print("Success:", response.text)
except Exception as e:
    print("Error:", e)
