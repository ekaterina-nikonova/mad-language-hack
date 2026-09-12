from typing import List, Optional
from pydantic import BaseModel, Field

class GeminiContentBlock(BaseModel):
    id: str = Field(description="Unique ID for this block, e.g., 'text_1'")
    type: str = Field(description="Must be one of: 'text', 'rich_text', 'vocabulary_grid', 'dialogue', 'image', 'audio', 'conjugation_table'")
    text: Optional[str] = Field(None, description="The actual text content, formatted appropriately for the block type.")

class GeminiInputBlock(BaseModel):
    id: str = Field(description="Unique ID matching the answer key, e.g., 'input_1'")
    type: str = Field(description="Must be one of: 'multiple_choice', 'fill_blanks', 'matching', 'boolean', 'free_text', 'reorder', 'audio_recorder', 'slider'")
    question: Optional[str] = Field(None, description="The prompt or question shown to the user.")
    options: Optional[List[str]] = Field(None, description="List of options for multiple_choice, matching, or boolean.")
    correct_answer: Optional[str] = Field(None, description="The correct answer. We will store this server-side and not send it to the frontend.")

class GeminiGeneratedArtifact(BaseModel):
    """
    This is the exact JSON structure Gemini must output.
    We separate this from the main Artifact model to hide system-level fields (like session_id) from the LLM.
    """
    skill: str = Field(description="One of: 'reading', 'writing', 'listening', 'speaking'")
    level: str = Field(description="CEFR Level: 'A1', 'A2', 'B1', 'B2', 'C1', 'C2'")
    topic: str = Field(description="The topic of the exercise")
    grammar_focus: Optional[str] = Field(None, description="Specific grammar rule if applicable")
    agent_message: Optional[str] = Field(None, description="A short, encouraging message from the AI tutor to the learner.")
    content: List[GeminiContentBlock] = Field(default_factory=list, description="The teaching material (reading passage, image prompt, etc.)")
    inputs: List[GeminiInputBlock] = Field(default_factory=list, description="The interactive questions for the user to answer.")
