from typing import Dict, Any, Optional
from pydantic import BaseModel

class UserResponse(BaseModel):
    session_id: str
    artifact_id: str
    turn_number: int
    answers: Dict[str, Any]
    justification: Optional[str] = None
    audio_url: Optional[str] = None
    timestamp: Optional[str] = None
