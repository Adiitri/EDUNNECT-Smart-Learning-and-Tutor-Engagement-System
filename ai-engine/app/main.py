from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import os
import uvicorn
from dotenv import load_dotenv

# Import the brain safely
try:
    from app.core import chatbot 
except ModuleNotFoundError:
    # This acts as a fallback if the path is still tricky
    import sys
    sys.path.append(os.getcwd())
    from app.core import chatbot

# Load Environment Variables
load_dotenv()

app = FastAPI()

# --- CORS MIDDLEWARE ---
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Data Model for Chat
class QuestionRequest(BaseModel):
    question: str
    history: list = []

@app.get("/")
def read_root():
    return {"message": "Edunnect AI Engine is Running 🤖"}

# --- NEW: RECOMMENDATION ROUTE ---
# This matches your Flutter "RecommendationService.getRecommendations('user123')" call
@app.get("/recommendations/{user_id}")
def get_recommendations(user_id: str):
    return [
        {
            "title": "Introduction to AI",
            "category": "Computer Science",
            "tutor": "Dr. Aris",
            "rating": 4.9
        },
        {
            "title": "Flutter UI Mastery",
            "category": "Mobile Dev",
            "tutor": "Dev Sam",
            "rating": 4.7
        },
        {
            "title": "Node.js Backend Pro",
            "category": "Web Dev",
            "tutor": "Mandal Sir",
            "rating": 4.8
        }
    ]

# AI Chat Route
@app.post("/ask")
def ask_ai(request: QuestionRequest):
    try:
        ai_reply = chatbot.get_ai_response(request.question)
        return {"answer": ai_reply, "status": "success"}
    except Exception as e:
        return {"answer": f"Error: {str(e)}", "status": "error"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)