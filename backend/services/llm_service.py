import os
import json
from google import genai
from google.genai import types
from pydantic import BaseModel

class LLMService:
    """
    Wrapper around the Google Generative AI SDK.
    Supports structured output generation.
    """
    def __init__(self, api_key: str = None, model: str = "gemini-3.7-flash"):
        self.api_key = api_key or os.getenv("GEMINI_API_KEY")
        if not self.api_key:
            raise ValueError("GEMINI_API_KEY environment variable is not set")
        
        self.client = genai.Client(
            api_key=self.api_key,
            http_options={'api_version': 'v1alpha'}
        )
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
            model="gemini-3.1-flash-tts-preview",
            contents=f"Read this aloud in {language}: {text}",
            config=types.GenerateContentConfig(
                response_modalities=["AUDIO"],
                speech_config=types.SpeechConfig(
                    voice_config=types.VoiceConfig(
                        prebuilt_voice_config=types.PrebuiltVoiceConfig(
                            voice_name="Aoede"
                        )
                    )
                )
            ),
        )
        
        part = response.candidates[0].content.parts[0]
        if part.inline_data:
            pcm_data = part.inline_data.data
            # Convert raw PCM (24kHz, 16-bit mono) to WAV
            import wave
            import io
            with io.BytesIO() as wav_io:
                with wave.open(wav_io, 'wb') as wav_file:
                    wav_file.setnchannels(1)
                    wav_file.setsampwidth(2) # 16-bit
                    wav_file.setframerate(24000)
                    wav_file.writeframes(pcm_data)
                return wav_io.getvalue()
        elif part.text:
            raise ValueError(f"TTS model returned text instead of audio: {part.text}")
        else:
            raise ValueError(f"Unexpected TTS response format: {part}")

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

    async def start_chat(self, system_instruction: str = None, tools: list = None):
        """
        Starts an AsyncChat session.
        Use this for automatic function calling (AFC) via send_message,
        as using AFC in generate_content is not recommended.
        """
        config_kwargs = {}
        if system_instruction:
            config_kwargs["system_instruction"] = system_instruction
        if tools:
            config_kwargs["tools"] = tools
            
        config = types.GenerateContentConfig(**config_kwargs) if config_kwargs else None
        
        return self.client.aio.chats.create(
            model=self.model,
            config=config
        )

llm_service = LLMService()
