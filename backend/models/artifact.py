from typing import List, Dict, Any, Optional
from pydantic import BaseModel, Field

class ContentBlock(BaseModel):
    id: str
    type: str
    text: Optional[str] = None
    url: Optional[str] = None

class InputBlock(BaseModel):
    id: str
    type: str
    question: Optional[str] = None
    options: Optional[List[Dict[str, Any]]] = None

class RootCause(BaseModel):
    category: str
    severity: str
    explanation: str
    underlying_concept: str = ""
    will_drill: bool = False

class FeedbackModel(BaseModel):
    overall: str # 'correct' | 'partial' | 'incorrect'
    message: str
    score: float = 0.0
    root_cause: Optional[RootCause] = None

class Artifact(BaseModel):
    artifact_id: str
    turn_number: int
    session_id: str
    skill: str
    level: str
    target_language: str
    base_language: str
    topic: str
    grammar_focus: Optional[str] = None
    agent_message: Optional[str] = None
    mode: str = "exercise"
    content: List[ContentBlock] = Field(default_factory=list)
    inputs: List[InputBlock] = Field(default_factory=list)
    feedback: Optional[FeedbackModel] = None
    metadata: Dict[str, Any] = Field(default_factory=dict)
