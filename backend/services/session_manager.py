import json
import os
from pathlib import Path
from models.learner import LearnerProfile
from models.session import Session
import uuid

# Define the path to the local storage file
STORAGE_FILE = Path(__file__).parent.parent / "user_memory.json"

class SessionManager:
    def __init__(self):
        # We only keep the active session in memory
        self.active_session: Session | None = None

    def get_or_create_profile(self) -> LearnerProfile:
        """Loads the single user profile from disk, or creates a default one."""
        if STORAGE_FILE.exists():
            try:
                with open(STORAGE_FILE, "r", encoding="utf-8") as f:
                    data = json.load(f)
                    return LearnerProfile(**data)
            except Exception as e:
                print(f"Error loading profile, returning default: {e}")
                
        # Return default if not exists or error
        return LearnerProfile()

    def save_profile(self, profile: LearnerProfile) -> None:
        """Saves the single user profile to disk."""
        with open(STORAGE_FILE, "w", encoding="utf-8") as f:
            json.dump(profile.model_dump(), f, indent=4)

    def start_session(self, target_language: str, topic: str = "General") -> Session:
        """Starts a new learning session, loading the persistent learner profile."""
        profile = self.get_or_create_profile()
        profile.target_language = target_language
        
        session_id = f"sess_{uuid.uuid4().hex[:8]}"
        
        self.active_session = Session(
            session_id=session_id,
            learner=profile,
            target_language=target_language,
            topic=topic
        )
        
        # Save profile right away in case target_language changed
        self.save_profile(profile)
        
        return self.active_session

    def get_active_session(self) -> Session | None:
        """Returns the currently active session."""
        return self.active_session
    
    def end_session(self) -> None:
        """Ends the active session and saves the latest profile state."""
        if self.active_session:
            # The profile might have been updated during the session
            self.save_profile(self.active_session.learner)
            self.active_session = None

session_manager = SessionManager()
