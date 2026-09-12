import asyncio
import os
from dotenv import load_dotenv

load_dotenv()
from services.llm_service import llm_service

async def main():
    try:
        print("Testing TTS...")
        audio_bytes = await llm_service.text_to_speech("Hei! Hvordan går det?", "no")
        print(f"Success! Received {len(audio_bytes)} bytes of audio.")
    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    asyncio.run(main())
