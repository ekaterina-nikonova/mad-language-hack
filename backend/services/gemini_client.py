import os
import json
from google import genai
from google.genai import types
from pydantic import BaseModel

class GeminiClient:
    """
    Wrapper around the Google Generative AI SDK.
    Supports structured output generation.
    """
    def __init__(self, api_key: str = None, model: str = "gemini-3.1-pro"):
        self.api_key = api_key or os.getenv("GEMINI_API_KEY")
        if not self.api_key:
            raise ValueError("GEMINI_API_KEY environment variable is not set")
        
        self.client = genai.Client(api_key=self.api_key)
        self.model = model

    async def generate_structured(
        self,
        prompt: str,
        response_schema: type[BaseModel],
        system_instruction: str = None,
        temperature: float = 0.7,
    ) -> BaseModel:
        """
        Generate content with guaranteed JSON structure based on a Pydantic model.
        """
        config_kwargs = {
            "response_mime_type": "application/json",
            "response_schema": response_schema,
            "temperature": temperature,
        }
        
        if system_instruction:
            config_kwargs["system_instruction"] = system_instruction
            
        config = types.GenerateContentConfig(**config_kwargs)

        # We use aio for async generation
        response = await self.client.aio.models.generate_content(
            model=self.model,
            contents=prompt,
            config=config,
        )
        
        # Parse the JSON string into the provided Pydantic model
        response_dict = json.loads(response.text)
        return response_schema(**response_dict)

    async def text_to_speech(self, text: str, language: str) -> bytes:
        """Generate audio from text using Gemini TTS."""
        response = await self.client.aio.models.generate_content(
            model=self.model,
            contents=f"Read this aloud in {language}: {text}",
            config=types.GenerateContentConfig(
                response_modalities=["AUDIO"],
            ),
        )
        # Returns raw audio bytes
        return response.candidates[0].content.parts[0].inline_data.data

    async def speech_to_text(self, audio_bytes: bytes, language: str) -> str:
        """Transcribe audio using Gemini STT."""
        response = await self.client.aio.models.generate_content(
            model=self.model,
            contents=[
                types.Part.from_bytes(data=audio_bytes, mime_type="audio/webm"),
                f"Transcribe this audio. The language is {language}. Return only the transcription.",
            ],
        )
        return response.text

gemini_client = GeminiClient()
