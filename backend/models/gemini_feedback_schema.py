from typing import List, Optional
from pydantic import BaseModel, Field

class GeminiFeedbackResult(BaseModel):
    is_correct: bool = Field(description="Whether the user answered correctly overall.")
    explanation: str = Field(description="Detailed explanation of the correct answer and why the user's answer was right/wrong. Written partly in the target language.")
    root_cause_category: Optional[str] = Field(None, description="One of: 'surface_typo', 'grammar_rule', 'vocabulary_gap', 'comprehension', 'pattern_confusion', 'pronunciation'. Null if correct.")
    root_cause_severity: Optional[str] = Field(None, description="'surface' or 'deep'. 'deep' implies we should generate a drill next. Null if correct.")
