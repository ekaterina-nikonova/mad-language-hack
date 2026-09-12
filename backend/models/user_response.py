from typing import List, Dict, Any, Optional
from pydantic import BaseModel

class InputResponse(BaseModel):
    input_id: str
    type: str
    value: Optional[Any] = None
    audio_url: Optional[str] = None
    duration_seconds: Optional[float] = None

class UserResponse(BaseModel):
    session_id: str
    artifact_id: str
    turn_number: int
    timestamp: Optional[str] = None
    responses: List[InputResponse]
    client_metadata: Optional[Dict[str, Any]] = None
