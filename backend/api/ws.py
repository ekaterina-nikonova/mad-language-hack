from fastapi import APIRouter, WebSocket, WebSocketDisconnect
import json
import logging

router = APIRouter()
logger = logging.getLogger(__name__)

@router.websocket("/ws/session")
async def websocket_session(websocket: WebSocket):
    await websocket.accept()
    logger.info("WebSocket connection established on /ws/session")
    
    try:
        # TODO: Initialize session and send first artifact
        # artifact = await engine.run_turn()
        # await websocket.send_json({"type": "artifact", "data": artifact})
        
        while True:
            # Wait for user response
            data = await websocket.receive_json()
            logger.info(f"Received data: {json.dumps(data)}")
            
            # TODO: Process response and generate feedback/next turn
            
    except WebSocketDisconnect:
        logger.info("WebSocket disconnected")
    except Exception as e:
        logger.error(f"Error in websocket connection: {e}")
        await websocket.close()
