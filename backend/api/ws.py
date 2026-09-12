import os
import json
import logging
import asyncio
from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from services.session_manager import session_manager
from agent.generator import generator
from agent.loop_engine import loop_engine
from models.user_response import UserResponse
from models.artifact import FeedbackModel

router = APIRouter()
logger = logging.getLogger(__name__)

def save_to_disk(folder: str, filename: str, data: dict):
    base_dir = os.path.join(os.path.dirname(__file__), "..", "storage", folder)
    os.makedirs(base_dir, exist_ok=True)
    with open(os.path.join(base_dir, filename), "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

@router.websocket("/ws/session")
async def websocket_session(websocket: WebSocket):
    await websocket.accept()
    logger.info("WebSocket connection established on /ws/session")
    
    # Start a new session (defaults to "no" / Norwegian and "General" topic)
    session = session_manager.start_session(target_language="no", topic="IT sector for developers")
    
    try:
        async def send_event(msg_type: str, data):
            await websocket.send_json({"type": msg_type, "data": data})

        print("DEBUG: Proposing first plan...")
        await loop_engine.propose_plan(session, send_event)
        
        while session.current_turn < session.max_turns:
            # Wait for user response
            data = await websocket.receive_json()
            msg_type = data.get("type")
            payload = data.get("data", data)
            
            if msg_type == "plan_approval":
                action = data.get("action")
                logger.info(f"Received plan approval action: {action}")
                if action == "approve":
                    await send_event("agent_thought", "Plan approved. Generating artifact...")
                    skill = payload.get("skill") if isinstance(payload, dict) else None
                    artifact = await loop_engine.run_turn(session, skill=skill)
                    artifact_dict = artifact.model_dump()
                    session.current_artifact = artifact_dict
                    save_to_disk("artifacts", f"{artifact.artifact_id}.json", artifact_dict)
                    await websocket.send_json({"type": "artifact", "data": artifact_dict})
                else:
                    await send_event("agent_thought", f"Plan {action}d. Re-evaluating...")
                    await asyncio.sleep(1)
                    await loop_engine.propose_plan(session, send_event, retry=True)
            
            elif msg_type == "response":
                logger.info("Received user response")
                response = UserResponse(**payload)
                
                # Save response to disk
                save_to_disk("responses", f"{session.session_id}_turn_{session.current_turn}_resp.json", payload)
                
                # REAL RCE EVALUATION via LoopEngine
                await send_event("agent_thought", "Evaluating user response...")
                mock_feedback = await loop_engine.process_response(session, response)
                await send_event("agent_thought", "Evaluation complete.")
                
                # Save feedback to disk
                save_to_disk("artifacts", f"{session.session_id}_turn_{session.current_turn}_feedback.json", mock_feedback)
                
                # Send feedback artifact back to UI
                await websocket.send_json({
                    "type": "feedback",
                    "data": mock_feedback
                })
                
            elif msg_type == "continue":
                logger.info("Received continue signal")
                await loop_engine.propose_plan(session, send_event)
                
            else:
                logger.warning(f"Unexpected message type: {msg_type}")
                
        # Session complete
        logger.info("Session complete.")
        session_manager.end_session()
        
    except WebSocketDisconnect:
        print("DEBUG: WebSocket disconnected")
        logger.info("WebSocket disconnected")
        session_manager.end_session()
    except Exception as e:
        print(f"DEBUG ERROR in websocket connection: {e}")
        import traceback
        traceback.print_exc()
        logger.error(f"Error in websocket connection: {e}")
        session_manager.end_session()
        await websocket.close(code=1011, reason=str(e)[:100])
