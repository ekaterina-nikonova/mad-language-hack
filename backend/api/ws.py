import json
import logging
import asyncio
from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from services.session_manager import session_manager
from agent.generator import generator
from models.user_response import UserResponse
from models.artifact import FeedbackModel

router = APIRouter()
logger = logging.getLogger(__name__)

@router.websocket("/ws/session")
async def websocket_session(websocket: WebSocket):
    await websocket.accept()
    logger.info("WebSocket connection established on /ws/session")
    
    # Start a new session (defaults to "no" / Norwegian and "General" topic)
    session = session_manager.start_session(target_language="no", topic="Daily Life")
    
    try:
        # Generate the first artifact
        artifact = await generator.generate(session, skill="reading")
        session.current_artifact = artifact.model_dump()
        
        # Send first artifact to frontend
        await websocket.send_json({
            "type": "artifact",
            "data": artifact.model_dump()
        })
        
        while session.current_turn < session.max_turns:
            # Wait for user response
            data = await websocket.receive_json()
            logger.info(f"Received user response")
            
            # Parse the response (ignoring type wrapper if any)
            payload = data.get("data", data)
            response = UserResponse(**payload)
            
            # MOCK RCE EVALUATION
            # For now, just pretend they got it right to test the loop
            is_correct = True
            mock_feedback = artifact.model_copy()
            mock_feedback.mode = "feedback"
            mock_feedback.feedback = FeedbackModel(
                is_correct=is_correct,
                explanation="Great job! (This is a mock evaluation placeholder)"
            )
            
            # Send feedback artifact back to UI
            await websocket.send_json({
                "type": "feedback",
                "data": mock_feedback.model_dump()
            })
            
            # Brief pause for user to read feedback
            await asyncio.sleep(2)
            
            # Generate the next artifact
            artifact = await generator.generate(session, skill="reading")
            session.current_artifact = artifact.model_dump()
            
            # Send next artifact
            await websocket.send_json({
                "type": "artifact",
                "data": artifact.model_dump()
            })
            
        # Session complete
        logger.info("Session complete.")
        session_manager.end_session()
        
    except WebSocketDisconnect:
        logger.info("WebSocket disconnected")
        session_manager.end_session()
    except Exception as e:
        logger.error(f"Error in websocket connection: {e}")
        session_manager.end_session()
        await websocket.close()
