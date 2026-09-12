import uvicorn
import os
from dotenv import load_dotenv
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# Load .env from the parent directory BEFORE importing app modules
load_dotenv(os.path.join(os.path.dirname(__file__), "..", ".env"))

from api.ws import router as ws_router

app = FastAPI(title="MLH Agent Loop API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(ws_router)

@app.get("/")
async def root():
    return {"message": "MAD Language Hack Agent Loop API is running"}

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
