import os
from dotenv import load_dotenv
import anthropic

# Load environment variables from .env file
load_dotenv()

# Get the API key from the environment variable
api_key = os.getenv("ANTHROPIC_API_KEY")

# Initialize the Anthropic client with the API key
client = anthropic.Anthropic(api_key=api_key)

message = client.messages.create(
    model="claude-3-5-sonnet-20240620",
    max_tokens=1000,
    temperature=0,
    # system="You are a world-class poet. Respond only with short poems.",
    messages=[
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "Why is the ocean salty?",
                }
            ],
        }
    ]
)

print(message.content)
