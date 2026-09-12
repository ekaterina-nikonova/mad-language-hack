from typing import List, Dict, Any, Optional
from pydantic import BaseModel, Field
from .learner import LearnerProfile, TurnRecord

class Session(BaseModel):
    """Represents an active learning session."""
    session_id: str
    learner: LearnerProfile
    target_language: str
    base_language: str = "en"
    topic: Optional[str] = None

    # Turn tracking
    current_turn: int = 0
    max_turns: int = 10
    history: List[TurnRecord] = Field(default_factory=list)

    # Current state
    current_artifact: Optional[Dict[str, Any]] = None
    
    # Session config
    skills_to_practice: List[str] = Field(default_factory=lambda: ["reading", "writing", "listening", "speaking"])
