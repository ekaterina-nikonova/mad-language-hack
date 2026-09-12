import uuid
from models.artifact import Artifact, ContentBlock, InputBlock
from models.gemini_schemas import GeminiGeneratedArtifact
from services.gemini_client import gemini_client
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
            f"The topic is '{topic}'."
        )

        # Call Gemini using Structured Outputs
        gemini_artifact: GeminiGeneratedArtifact = await gemini_client.generate_structured(
            prompt=prompt,
            response_schema=GeminiGeneratedArtifact,
            system_instruction=system_instruction
        )
        
        # Convert Gemini models to our core Artifact models
        content_blocks = [
            ContentBlock(
                id=c.id,
                type=c.type,
                text=c.text
            ) for c in gemini_artifact.content
        ]
        
        input_blocks = [
            InputBlock(
                id=i.id,
                type=i.type,
                question=i.question,
                options=i.options
            ) for i in gemini_artifact.inputs
        ]
        
        # Save correct answers in metadata (so the frontend doesn't see them, 
        # but we can use them in the Evaluator)
        correct_answers = {
            i.id: i.correct_answer 
            for i in gemini_artifact.inputs 
            if i.correct_answer is not None
        }

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
