import asyncio
import os
import sys
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "backend")))

from services.gemini_client import gemini_client
from models.gemini_schemas import GeminiGeneratedArtifact

async def main():
    print("Testing gemini generate_structured...")
    try:
        res = await gemini_client.generate_structured(
            prompt="Generate a reading exercise for B1 Norwegian about Daily Life",
            response_schema=GeminiGeneratedArtifact,
            system_instruction="You are a helpful assistant."
        )
        print("Success!")
        print(res)
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    asyncio.run(main())
