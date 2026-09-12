# Backend & Frontend JSON Integration Guide

This directory contains the **JSON contracts** exchanged between the **Python FastAPI Loop Agent (Backend)** and the **Flutter Generative UI (Frontend)**.

---

## 1. Connection Architecture (Localhost MVP)

Both services run locally on your machine:
- **Frontend (Flutter)**: Runs in browser on `http://localhost:8080` (or `http://localhost:8085`)
- **Backend (FastAPI)**: Runs on `http://localhost:8000`
- **WebSocket Protocol**: `ws://localhost:8000/ws/session`
- **Static Media Files**: Served from `http://localhost:8000/media/...` (audio recordings, speech audio, images)

```
┌─────────────────────────┐               WebSocket (ws://localhost:8000/ws/session)               ┌────────────────────────┐
│      FLUTTER APP        │ ◀════════════════════════════════════════════════════════════════════▶ │   FASTAPI LOOP AGENT   │
│  (Generative UI Engine) │      1. Backend pushes UI Artifact JSON                                │     (Gemini 3.8 Flash) │
│                         │      2. User answers -> Frontend sends Response JSON                   │                        │
│                         │      3. Backend evaluates -> pushes Feedback + Root Cause JSON        │                        │
└─────────────────────────┘                                                                        └────────────────────────┘
```

---

## 2. WebSocket Message Wrapper

All WebSocket messages exchanged are wrapped in a simple JSON envelope:

### A. From Backend to Frontend:
```json
{
  "type": "artifact",
  "data": { ... Artifact JSON ... }
}
```
*(or `"type": "feedback"` / `"type": "summary"`)*

### B. From Frontend to Backend:
```json
{
  "type": "response",
  "data": { ... User Response JSON ... }
}
```

---

## 3. JSON Contract Files in this Directory

| File | Description |
|------|-------------|
| [`01_free_form_exercise.json`](file:///c:/Users/dariorf/Documents/hackaton/mad-language-hack/process/backend_json_contracts/01_free_form_exercise.json) | Free-form text writing exercise with AI chatbot message, vocabulary cards, and text input |
| [`02_audio_listening_exercise.json`](file:///c:/Users/dariorf/Documents/hackaton/mad-language-hack/process/backend_json_contracts/02_audio_listening_exercise.json) | Audio reproduction exercise with waveform player, speed selector, and comprehension question |
| [`03_audio_speaking_exercise.json`](file:///c:/Users/dariorf/Documents/hackaton/mad-language-hack/process/backend_json_contracts/03_audio_speaking_exercise.json) | Speaking exercise with live microphone audio recorder and reference text |
| [`04_conversational_chat_exercise.json`](file:///c:/Users/dariorf/Documents/hackaton/mad-language-hack/process/backend_json_contracts/04_conversational_chat_exercise.json) | Roleplay conversational dialogue with hotel receptionist + freeform answer |
| [`05_feedback_with_root_cause.json`](file:///c:/Users/dariorf/Documents/hackaton/mad-language-hack/process/backend_json_contracts/05_feedback_with_root_cause.json) | Feedback JSON containing score, corrections, and Root Cause Analysis diagnosis |
| [`06_user_response_envelope.json`](file:///c:/Users/dariorf/Documents/hackaton/mad-language-hack/process/backend_json_contracts/06_user_response_envelope.json) | The exact response payload Flutter sends back to the backend |

---

## 4. How the Frontend Connects
In [`lib/services/websocket_service.dart`](file:///c:/Users/dariorf/Documents/hackaton/mad-language-hack/process/frontend/lib/services/websocket_service.dart):
```dart
sessionService.connect(url: 'ws://localhost:8000/ws/session');
```
If the backend is not running yet, the frontend automatically falls back to the built-in generative simulation so you can test all UI components offline without server errors.
