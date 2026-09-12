import uuid
from models.artifact import Artifact, ContentBlock, InputBlock
from models.gemini_schemas import GeminiGeneratedArtifact
from services.llm_service import llm_service
from config.prompts import SYSTEM_PROMPT_GENERATOR
from models.session import Session

class ArtifactGenerator:
    """
    Uses Gemini to generate the UI artifact JSON based on the session parameters.
    """
    
    async def generate(self, session: Session, skill: str = "reading") -> Artifact:
        """
        Generates a new exercise artifact.
        For MVP, we just use the current session settings without a complex Planner.
        """
        level = session.learner.overall_level
        topic = session.topic or "General"
        grammar = "None"
        
        # Format the system prompt with session-specific context
        system_instruction = SYSTEM_PROMPT_GENERATOR.format(
            level=level,
            target_language=session.target_language,
            base_language=session.base_language,
            topic=topic,
            grammar_focus=grammar
        )
        
        prompt = (
            f"Generate a {skill} exercise for a {level} level student learning {session.target_language}. "
            f"The topic is '{topic}'.\n"
            f"CRITICAL: Any 'audio' content blocks MUST be extremely short (maximum 2 or 3 brief sentences). "
            f"Long text will be cut off by the TTS engine, so keep it very brief!"
        )

        # Call Gemini using Structured Outputs
        print(f"DEBUG: Calling Gemini API for generation (Skill: {skill}, Topic: {topic})")
        try:
            gemini_artifact: GeminiGeneratedArtifact = await llm_service.generate_structured(
                prompt=prompt,
                response_schema=GeminiGeneratedArtifact,
                system_instruction=system_instruction
            )
            print("DEBUG: Gemini API returned successfully.")
        except Exception as e:
            print(f"DEBUG ERROR in generator: {e}")
            raise
        
        content_blocks = []
        for c in gemini_artifact.content:
            block_url = None
            if c.type == "audio" and c.text:
                try:
                    print(f"DEBUG: Generating TTS for audio block {c.id}...")
                    import os
                    audio_bytes = await llm_service.text_to_speech(c.text, session.target_language)
                    audio_filename = f"{session.session_id}_turn_{session.current_turn}_{c.id}.wav"
                    file_path = os.path.join(os.path.dirname(__file__), "..", "storage", "audio", audio_filename)
                    with open(file_path, "wb") as f:
                        f.write(audio_bytes)
                    block_url = f"http://localhost:8001/storage/audio/{audio_filename}"
                    print(f"DEBUG: TTS generated and saved to {file_path}")
                except Exception as e:
                    print(f"DEBUG ERROR generating TTS: {e}")
                    import traceback
                    traceback.print_exc()
                    print(f"DEBUG TTS Request Details: text={c.text[:50]}..., language={session.target_language}")
                    
            content_blocks.append(
                ContentBlock(
                    id=c.id,
                    type=c.type,
                    text=c.text,
                    url=block_url
                )
            )
        
        input_blocks = []
        correct_answers = {}
        for i in gemini_artifact.inputs:
            unique_id = f"{i.id}_{uuid.uuid4().hex[:6]}"
            formatted_options = None
            if i.options:
                formatted_options = [
                    {"id": f"opt_{idx}", "text": opt} 
                    for idx, opt in enumerate(i.options)
                ]
            input_blocks.append(
                InputBlock(
                    id=unique_id,
                    type=i.type,
                    question=i.question,
                    options=formatted_options
                )
            )
            if i.correct_answer is not None:
                correct_answers[unique_id] = i.correct_answer

        # Build the final Artifact
        session.current_turn += 1
        artifact = Artifact(
            artifact_id=f"art_{uuid.uuid4().hex[:8]}",
            turn_number=session.current_turn,
            session_id=session.session_id,
            skill=gemini_artifact.skill,
            level=gemini_artifact.level,
            target_language=session.target_language,
            base_language=session.base_language,
            topic=gemini_artifact.topic,
            grammar_focus=gemini_artifact.grammar_focus,
            mode="exercise",
            agent_message=gemini_artifact.agent_message,
            content=content_blocks,
            inputs=input_blocks,
            metadata={"correct_answers": correct_answers}
        )
        
        return artifact

generator = ArtifactGenerator()
