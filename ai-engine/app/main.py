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
import urllib.parse # <-- Add this to the top of main.py


@app.get("/recommendations/{user_id}")
def get_recommendations(user_id: str):
    # Foundational Full Courses & Bootcamps
    courses = [
        {
            "title": "Machine Learning Full Course for Beginners",
            "category": "AI/ML",
            "tutor": "Andrew Ng",
            "rating": 4.9,
            "level": "Beginner",
            "duration": "10 Hours"
        },
        {
            "title": "Complete Frontend Web Development Bootcamp",
            "category": "Web Dev",
            "tutor": "Dr. Angela Yu",
            "rating": 4.8,
            "level": "All Levels",
            "duration": "15 Hours"
        },
        {
            "title": "Data Structures and Algorithms in Python",
            "category": "Computer Science",
            "tutor": "FreeCodeCamp",
            "rating": 4.9,
            "level": "Intermediate",
            "duration": "12 Hours"
        },
        {
            "title": "Internet of Things (IoT) Fundamentals",
            "category": "Hardware",
            "tutor": "NetworkChuck",
            "rating": 4.7,
            "level": "Beginner",
            "duration": "5 Hours"
        },
        {
            "title": "Quantum Computing for Computer Scientists",
            "category": "Quantum",
            "tutor": "IBM Quantum",
            "rating": 4.8,
            "level": "Advanced",
            "duration": "8 Hours"
        }
    ]

    # Dynamically generate safe YouTube search URLs for full courses
    for course in courses:
        query = urllib.parse.quote(f"{course['title']} {course['tutor']} full course")
        course["youtube_url"] = f"https://www.youtube.com/results?search_query={query}"

    return courses

    # Dynamically generate YouTube search URLs
    for course in courses:
        query = urllib.parse.quote(f"{course['title']} {course['tutor']} full course")
        course["youtube_url"] = f"https://www.youtube.com/results?search_query={query}"

    return courses

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