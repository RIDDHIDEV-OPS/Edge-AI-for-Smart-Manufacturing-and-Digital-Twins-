import requests
import os

API_KEY = os.environ.get("GROQ_API_KEY", "")

try:
    response = requests.get(
        "https://api.groq.com/openai/v1/models",
        headers={
            "Authorization": f"Bearer {API_KEY}",
            "Content-Type": "application/json"
        }
    )
    import json
    print(json.dumps(response.json(), indent=2))
except Exception as e:
    print("Error:", str(e))
