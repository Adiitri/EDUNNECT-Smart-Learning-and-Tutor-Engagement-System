# EDUNNECT - Smart Learning and Tutor Engagement System

EDUNNECT is a multi-module tutoring platform with:

- A Flutter app for Students, Tutors, and Admins
- A Node.js backend API for auth, tutor matching, bookings, and real-time chat
- A Python FastAPI AI engine for AI tutor Q&A and course recommendations

## Architecture

- `mobile-app` -> Flutter frontend
- `backend-api` -> Express + MongoDB + Socket.IO
- `ai-engine` -> FastAPI + Gemini API integration

## Core Features

- Role-based authentication (Student / Tutor / Admin)
- Profile completion with address + geolocation support
- Nearby tutor discovery using geospatial queries
- Session booking and tutor approval flow
- Real-time chat with Socket.IO
- File/image sharing in chat
- AI Tutor chat (Gemini)
- AI-based course recommendations

## Project Structure

```text
EDUNNECT-Smart-Learning-and-Tutor-Engagement-System/
├── mobile-app/          # Flutter app
├── backend-api/         # Node.js + Express API + Socket.IO
└── ai-engine/           # FastAPI AI services
```
