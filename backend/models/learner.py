from typing import Dict, List, Optional
from pydantic import BaseModel, Field
from datetime import datetime

class TurnRecord(BaseModel):
    turn_number: int
    skill: str
    topic: str
    grammar_focus: Optional[str] = None
    artifact_id: str
    score: float
    timestamp: str

class LearnerProfile(BaseModel):
    """Tracks everything about the single user across sessions."""
    user_id: str = "demo_user"
    target_language: str = "no" # Default to Norwegian or specified
    base_language: str = "en"
    overall_level: str = "B1" # A1, A2, B1, B2, C1, C2

    skill_levels: Dict[str, str] = Field(default_factory=lambda: {
        "reading": "B1",
        "writing": "B1",
        "listening": "B1",
        "speaking": "B1",
    })

    # Performance tracking
    turn_history: List[TurnRecord] = Field(default_factory=list)
    topic_scores: Dict[str, float] = Field(default_factory=dict)
    grammar_scores: Dict[str, float] = Field(default_factory=dict)

    # Adaptive difficulty tracking
    consecutive_correct: int = 0
    consecutive_incorrect: int = 0
