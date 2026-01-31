from app.core import chatbot  # <-- Import the brain
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware # <-- NEW IMPORT
from pydantic import BaseModel
import os
from dotenv import load_dotenv

# Load Environment Variables
load_dotenv()

app = FastAPI()

# --- ADD THIS SECTION TO FIX THE ERROR ---
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins (Chrome, Phone, etc.)
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods (POST, GET, OPTIONS, etc.)
    allow_headers=["*"],
)
# -----------------------------------------

# Basic Data Model
class QuestionRequest(BaseModel):
    question: str
    history: list = []

@app.get("/")
def read_root():
    return {"message": "Edunnect AI Engine is Running 🤖"}

# AI Chat Route
@app.post("/ask")
def ask_ai(request: QuestionRequest):
    # 1. Get the real answer from Gemini
    ai_reply = chatbot.get_ai_response(request.question)
    
    # 2. Send it back to the mobile app
    return {"answer": ai_reply, "status": "success"}