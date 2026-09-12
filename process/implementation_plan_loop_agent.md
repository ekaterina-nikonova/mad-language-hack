# Loop Agent — Backend Implementation Plan

> **Goal**: Build a Gemini-powered loop agent that runs a continuous teaching cycle: assess the learner, plan the next exercise, generate a UI artifact, send it, wait for the response, evaluate, give feedback, update the learner model, and repeat. The agent is the **brain** — it decides *what* to teach and *how* to test it.

---

## 1. Architecture Overview

```
┌──────────────────────────────────────────────────────────────────┐
│                        LOOP AGENT SERVER                         │
│                                                                  │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐   │
│  │  Session  │    │  Learner │    │  Turn    │    │  Gemini  │   │
│  │  Manager  │───▶│  Model   │───▶│  Engine  │───▶│  Client  │   │
│  └──────────┘    └──────────┘    └──────────┘    └──────────┘   │
│       │               │               │               │         │
│       │               │               ▼               │         │
│       │               │         ┌──────────┐          │         │
│       │               │         │ Artifact │          │         │
│       │               │         │ Builder  │◀─────────┘         │
│       │               │         └──────────┘                    │
│       │               │               │                         │
│       │               │               ▼                         │
│       │               │         ┌──────────┐                    │
│       │               │         │ Evaluator│                    │
│       │               └────────▶│          │                    │
│       │                         └──────────┘                    │
│       │                               │                         │
│       ▼                               ▼                         │
│  ┌──────────┐                  ┌──────────┐                    │
│  │ WebSocket│◀────────────────▶│ Response │                    │
│  │ Handler  │                  │ Processor│                    │
│  └──────────┘                  └──────────┘                    │
└──────────────────────────────────────────────────────────────────┘
```

### Core Principle: **Turn-Based Loop Agent**

Each **turn** in the loop follows this exact sequence:

```
┌──────────────────────────────────────────────────────────────┐
│                    SINGLE TURN CYCLE                         │
│                                                              │
│  1. ASSESS        → What does the learner know/need?         │
│  2. PLAN          → What skill/topic/grammar to exercise?    │
│  3. GENERATE      → Create UI artifact (JSON) via Gemini    │
│  4. VALIDATE      → Check artifact is well-formed           │
│  5. SEND          → Push artifact to frontend via WebSocket │
│  6. WAIT          → Block until user response arrives       │
│  7. EVALUATE      → Score the user's response via Gemini    │
│  8. ROOT CAUSE    → WHY did the user get it wrong?          │
│  9. DECIDE PATH   → New question OR root cause exercise?    │
│  10. FEEDBACK     → Generate feedback artifact               │
│  11. UPDATE       → Update learner model (level, history)   │
│  12. DECIDE       → Continue loop or end session?           │
│                                                              │
│  └──▶ REPEAT from step 1                                    │
└──────────────────────────────────────────────────────────────┘
```

#### The Root Cause Analysis Branch (Steps 8-9)

After evaluation, the agent doesn't just give feedback — it performs **root cause analysis** to understand *why* the learner made a mistake. This determines the next action:

```
                    EVALUATE
                       │
                       ▼
               ROOT CAUSE ANALYSIS
              "Why did they get it wrong?"
                       │
            ┌──────────┼──────────┐
            ▼                     ▼
     SURFACE ERROR          DEEP MISCONCEPTION
  (typo, careless,         (wrong grammar rule,
   understood concept)      missing vocabulary,
            │               wrong mental model)
            ▼                     ▼
    FEEDBACK +              ROOT CAUSE EXERCISE
    NEW QUESTION            (targeted mini-exercise
    (advance normally)       that drills the root cause
                             before moving on)
```

**Root cause categories:**

| Category | Example | Agent Action |
|----------|---------|-------------|
| `surface_typo` | Wrote "gik" instead of "gikk" | Feedback only, advance |
| `grammar_rule` | Used present tense instead of past | Root cause exercise on that rule |
| `vocabulary_gap` | Didn't know the word at all | Vocabulary drill exercise |
| `comprehension` | Misunderstood the passage/audio | Simpler version of same content |
| `pattern_confusion` | Confused similar grammar patterns | Contrastive exercise |
| `pronunciation` | Mispronounced systematically | Pronunciation drill with model audio |

---

## 2. Technology Stack

| Component | Technology | Rationale |
|-----------|-----------|-----------|
| Runtime | Python 3.12+ | Fast prototyping, excellent Gemini SDK support |
| Web Framework | FastAPI | Async-first, WebSocket support, auto-docs |
| AI (Generation) | Gemini API — `gemini-3.6-flash` or `gemini-3.8-flash` | Structured output, fast, multimodal |
| AI (Evaluation) | Gemini API — `gemini-3.1` (optional for subjective) | More nuanced assessment for writing/speaking |
| TTS | Gemini API (text-to-speech) | Audio generation for listening exercises |
| STT | Gemini API (speech-to-text) | Transcribe user recordings for evaluation |
| WebSocket | FastAPI WebSocket | Native support, bidirectional, binary frames |
| State | In-memory (dict) | Hackathon-scope, no DB needed |
| Media Storage | Local filesystem (`./media/`) | All audio, images, video stored locally |
| Schema Validation | Pydantic v2 | Type-safe models, JSON serialization |

> **Note**: The entire MVP runs on **localhost** — both the FastAPI backend and the Flutter frontend connect locally. No cloud services needed beyond the Gemini API key.

---

## 3. Project Structure

```
backend/
├── main.py                         # FastAPI app entry point
├── requirements.txt                # Python dependencies
│
├── config/
│   ├── settings.py                 # Environment vars, API keys, config
│   └── prompts.py                  # All Gemini prompt templates
│
├── models/
│   ├── artifact.py                 # Artifact schema (Pydantic)
│   ├── content_blocks.py           # Content block schemas
│   ├── input_blocks.py             # Input block schemas
│   ├── feedback.py                 # Feedback schema
│   ├── user_response.py            # User response schema
│   ├── session.py                  # Session state model
│   └── learner.py                  # Learner profile model
│
├── agent/
│   ├── loop_engine.py              # The main turn loop controller
│   ├── assessor.py                 # Step 1: Assess learner state
│   ├── planner.py                  # Step 2: Plan next exercise
│   ├── generator.py                # Step 3: Generate artifact via Gemini
│   ├── validator.py                # Step 4: Validate artifact structure
│   ├── evaluator.py                # Step 7: Evaluate user response
│   ├── root_cause_analyzer.py      # Step 8: Root cause analysis of errors
│   ├── feedback_builder.py         # Step 10: Build feedback artifact
│   └── level_tracker.py            # Step 11: Update learner level
│
├── services/
│   ├── gemini_client.py            # Gemini API wrapper (generation + TTS + STT)
│   ├── session_manager.py          # Session lifecycle (create, get, end)
│   ├── media_service.py            # Local media storage (audio, images, video)
│   └── websocket_manager.py        # WebSocket connection pool (JSON + binary)
│
├── api/
│   ├── routes.py                   # HTTP endpoints
│   └── ws.py                       # WebSocket endpoint
│
└── tests/
    ├── test_loop_engine.py
    ├── test_generator.py
    ├── test_evaluator.py
    ├── fixtures/
    │   ├── sample_artifacts.json
    │   └── sample_responses.json
    └── conftest.py
```

---

## 4. The Loop Engine — Core Implementation

### 4.1 Loop Engine (`loop_engine.py`)

```python
class LoopEngine:
    """
    The heart of the agent. Runs the turn-based teaching loop.
    Each method corresponds to one step in the cycle.
    """

    def __init__(self, session: Session, gemini: GeminiClient):
        self.session = session
        self.gemini = gemini
        self.assessor = Assessor()
        self.planner = Planner()
        self.generator = ArtifactGenerator(gemini)
        self.validator = ArtifactValidator()
        self.evaluator = ResponseEvaluator(gemini)
        self.root_cause_analyzer = RootCauseAnalyzer(gemini)
        self.feedback_builder = FeedbackBuilder(gemini)
        self.level_tracker = LevelTracker()

    async def run_turn(self) -> Artifact:
        """Execute one complete turn of the loop."""

        # Step 1: ASSESS — analyze learner's current state
        assessment = self.assessor.assess(self.session.learner)

        # Step 2: PLAN — decide what to exercise next
        plan = self.planner.plan(
            assessment=assessment,
            session_history=self.session.history,
            target_language=self.session.target_language,
        )

        # Step 3: GENERATE — create UI artifact via Gemini
        artifact = await self.generator.generate(plan)

        # Step 4: VALIDATE — ensure artifact is well-formed
        validated_artifact = self.validator.validate(artifact)

        # Step 5: SEND — handled by caller (WebSocket handler)
        return validated_artifact

    async def process_response(self, response: UserResponse) -> tuple[Artifact, Artifact | None]:
        """Process user response, analyze root cause, generate feedback."""

        # Step 7: EVALUATE — score the response
        evaluation = await self.evaluator.evaluate(
            artifact=self.session.current_artifact,
            response=response,
            learner=self.session.learner,
        )

        # Step 8: ROOT CAUSE ANALYSIS — why did the user get it wrong?
        root_cause = None
        root_cause_exercise = None
        if evaluation.overall_status != "correct":
            root_cause = await self.root_cause_analyzer.analyze(
                artifact=self.session.current_artifact,
                response=response,
                evaluation=evaluation,
                learner=self.session.learner,
            )

            # Step 9: DECIDE PATH — new question or root cause drill?
            if root_cause.severity == "deep":
                # Generate a targeted mini-exercise to address the root cause
                root_cause_exercise = await self.generator.generate_root_cause_drill(
                    root_cause=root_cause,
                    learner=self.session.learner,
                )

        # Step 10: FEEDBACK — generate feedback artifact (includes root cause explanation)
        feedback_artifact = await self.feedback_builder.build(
            evaluation=evaluation,
            original_artifact=self.session.current_artifact,
            response=response,
            root_cause=root_cause,  # Now includes WHY they got it wrong
        )

        # Step 11: UPDATE — update learner model
        self.level_tracker.update(
            learner=self.session.learner,
            evaluation=evaluation,
            root_cause=root_cause,
        )

        # Step 12: DECIDE — continue or end?
        self.session.record_turn(response, evaluation, root_cause)

        return feedback_artifact, root_cause_exercise
```

### 4.2 Assessor (`assessor.py`)

```python
class Assessor:
    """
    Analyzes the learner's current state to determine:
    - Which skills are weakest (reading/writing/listening/speaking)
    - What level they're at for each skill
    - Which topics/grammar points need reinforcement
    - Whether to introduce new material or review
    """

    def assess(self, learner: LearnerProfile) -> Assessment:
        # Calculate skill gaps
        skill_scores = learner.get_skill_scores()
        weakest_skill = min(skill_scores, key=skill_scores.get)

        # Check if recent performance warrants level change
        recent_accuracy = learner.get_recent_accuracy(last_n=5)

        # Determine if we should review or advance
        mode = "review" if recent_accuracy < 0.6 else "advance"

        return Assessment(
            weakest_skill=weakest_skill,
            skill_scores=skill_scores,
            current_level=learner.level,
            recent_accuracy=recent_accuracy,
            mode=mode,
            topics_needing_review=learner.get_weak_topics(),
            suggested_grammar=learner.get_next_grammar_point(),
        )
```

### 4.3 Planner (`planner.py`)

```python
class Planner:
    """
    Takes an Assessment and decides exactly what the next exercise should be:
    - Which skill to test (reading/writing/listening/speaking)
    - What topic and grammar focus
    - What type of exercise (MCQ, fill-blank, free text, etc.)
    - Difficulty calibration
    """

    def plan(self, assessment: Assessment, session_history: list, target_language: str) -> ExercisePlan:
        # Rotate skills to maintain variety, but weight toward weakest
        skill = self._select_skill(assessment, session_history)

        # Select topic based on assessment
        topic = self._select_topic(assessment)

        # Choose exercise types appropriate for the skill
        input_types = self._select_input_types(skill, assessment.current_level)

        # Choose content types appropriate for the skill
        content_types = self._select_content_types(skill)

        return ExercisePlan(
            skill=skill,
            level=assessment.current_level,
            topic=topic,
            grammar_focus=assessment.suggested_grammar,
            target_language=target_language,
            content_types=content_types,
            input_types=input_types,
            difficulty=self._calibrate_difficulty(assessment),
        )
```

### 4.4 Artifact Generator (`generator.py`)

```python
class ArtifactGenerator:
    """
    Uses Gemini to generate the UI artifact JSON based on the exercise plan.
    This is where the AI creativity happens — the agent decides the exact
    content, questions, options, audio prompts, etc.
    """

    def __init__(self, gemini: GeminiClient):
        self.gemini = gemini

    async def generate(self, plan: ExercisePlan) -> dict:
        prompt = self._build_prompt(plan)

        # Use Gemini structured output to guarantee valid JSON
        response = await self.gemini.generate_structured(
            prompt=prompt,
            response_schema=ARTIFACT_SCHEMA,
            system_instruction=SYSTEM_PROMPT_GENERATOR,
        )

        return response
```

### 4.5 Response Evaluator (`evaluator.py`)

```python
class ResponseEvaluator:
    """
    Uses Gemini to evaluate the user's response against the expected answers.
    For objective answers (MCQ, fill-blank), does direct comparison.
    For subjective answers (free text, audio), uses Gemini to assess.
    """

    async def evaluate(self, artifact: Artifact, response: UserResponse, learner: LearnerProfile) -> Evaluation:
        # Separate objective vs subjective inputs
        objective_results = self._evaluate_objective(artifact, response)
        subjective_results = await self._evaluate_subjective(artifact, response)

        # Combine results
        all_results = {**objective_results, **subjective_results}

        # Calculate overall score
        score = sum(r.score for r in all_results.values()) / len(all_results)

        return Evaluation(
            results=all_results,
            overall_score=score,
            overall_status=self._classify_score(score),
        )

    def _evaluate_objective(self, artifact, response) -> dict:
        """Direct comparison for MCQ, boolean, reorder, matching, dropdown."""
        # Compare user answers to correct answers embedded in artifact
        ...

    async def _evaluate_subjective(self, artifact, response) -> dict:
        """Use Gemini for free text and audio evaluation."""
        # Send user's free text to Gemini for grammar/content evaluation
        # Send audio transcription to Gemini for pronunciation feedback
        ...
```

### 4.6 Root Cause Analyzer (`root_cause_analyzer.py`)

```python
class RootCauseAnalyzer:
    """
    When the user gets something wrong, this module uses Gemini to
    diagnose WHY — not just WHAT was wrong.

    Root cause categories:
    - surface_typo: Minor spelling/typo, user understood the concept
    - grammar_rule: Applied wrong grammar rule (e.g., wrong tense formation)
    - vocabulary_gap: Didn't know the word/phrase
    - comprehension: Misunderstood the passage/audio content
    - pattern_confusion: Confused similar grammar patterns
    - pronunciation: Systematic pronunciation error (speaking exercises)
    """

    def __init__(self, gemini: GeminiClient):
        self.gemini = gemini

    async def analyze(
        self,
        artifact: Artifact,
        response: UserResponse,
        evaluation: Evaluation,
        learner: LearnerProfile,
    ) -> RootCause:
        """Analyze WHY the learner made mistakes."""

        prompt = self._build_analysis_prompt(
            artifact=artifact,
            response=response,
            evaluation=evaluation,
            learner_level=learner.overall_level,
        )

        analysis = await self.gemini.generate_structured(
            prompt=prompt,
            response_schema=ROOT_CAUSE_SCHEMA,
            system_instruction=SYSTEM_PROMPT_ROOT_CAUSE,
        )

        return RootCause(
            category=analysis["category"],
            severity=analysis["severity"],       # "surface" | "deep"
            explanation=analysis["explanation"],
            underlying_concept=analysis["underlying_concept"],
            suggested_drill_type=analysis["suggested_drill_type"],
            related_errors=analysis.get("related_errors", []),
        )


class RootCause(BaseModel):
    """Result of root cause analysis."""
    category: str           # surface_typo | grammar_rule | vocabulary_gap | ...
    severity: str           # "surface" (just give feedback) | "deep" (drill needed)
    explanation: str        # Human-readable explanation of the root cause
    underlying_concept: str # The grammar rule / vocab item / concept that's weak
    suggested_drill_type: str  # What kind of exercise would help
    related_errors: list[str] = []  # Past errors that share this root cause
```

---

## 5. Gemini Integration

### 5.1 Gemini Client (`gemini_client.py`)

```python
class GeminiClient:
    """
    Wrapper around the Google Generative AI SDK.
    Supports structured output, TTS, and STT via the Gemini API.

    Model selection:
    - gemini-3.6-flash / gemini-3.8-flash: Fast generation (artifacts, feedback)
    - gemini-3.1: Deeper evaluation (subjective writing/speaking assessment)
    """

    def __init__(self, api_key: str, model: str = "gemini-3.6-flash"):
        self.client = genai.Client(api_key=api_key)
        self.model = model
        self.eval_model = "gemini-3.1"  # For subjective evaluation

    async def generate_structured(
        self,
        prompt: str,
        response_schema: dict,
        system_instruction: str = None,
        use_eval_model: bool = False,
    ) -> dict:
        """Generate content with guaranteed JSON structure."""
        model = self.eval_model if use_eval_model else self.model
        response = await self.client.aio.models.generate_content(
            model=model,
            contents=prompt,
            config=genai.types.GenerateContentConfig(
                system_instruction=system_instruction,
                response_mime_type="application/json",
                response_schema=response_schema,
                temperature=0.7,
            ),
        )
        return json.loads(response.text)

    async def generate_text(self, prompt: str, system_instruction: str = None) -> str:
        """Generate free-form text (for feedback messages, explanations)."""
        ...

    async def text_to_speech(self, text: str, language: str) -> bytes:
        """Generate audio from text using Gemini TTS API.
        Returns raw audio bytes (WAV/MP3) to be saved locally."""
        response = await self.client.aio.models.generate_content(
            model="gemini-3.6-flash",  # TTS-capable model
            contents=f"Read this aloud in {language}: {text}",
            config=genai.types.GenerateContentConfig(
                response_modalities=["AUDIO"],
            ),
        )
        # Extract audio bytes from response
        return response.candidates[0].content.parts[0].inline_data.data

    async def speech_to_text(self, audio_bytes: bytes, language: str) -> str:
        """Transcribe audio using Gemini STT.
        Accepts raw audio bytes, returns transcription text."""
        response = await self.client.aio.models.generate_content(
            model="gemini-3.6-flash",
            contents=[
                genai.types.Part.from_bytes(data=audio_bytes, mime_type="audio/webm"),
                f"Transcribe this audio. The language is {language}. Return only the transcription.",
            ],
        )
        return response.text
```

### 5.2 Media Service (`media_service.py`)

```python
class MediaService:
    """
    Handles local file storage for all media (audio, images, video).
    The MVP runs entirely on localhost — no cloud storage needed.

    Media flow:
    1. Backend generates/receives media -> saves to ./media/{session_id}/
    2. Media served via FastAPI static files or sent as binary WebSocket frames
    3. Frontend can fetch media via HTTP GET or receive inline via WebSocket
    """

    MEDIA_DIR = Path("./media")

    def __init__(self):
        self.MEDIA_DIR.mkdir(exist_ok=True)

    def save_audio(self, session_id: str, audio_bytes: bytes, filename: str) -> str:
        """Save audio file locally, return local URL path."""
        session_dir = self.MEDIA_DIR / session_id
        session_dir.mkdir(exist_ok=True)
        filepath = session_dir / filename
        filepath.write_bytes(audio_bytes)
        return f"/media/{session_id}/{filename}"

    def save_image(self, session_id: str, image_bytes: bytes, filename: str) -> str:
        """Save image file locally, return local URL path."""
        session_dir = self.MEDIA_DIR / session_id
        session_dir.mkdir(exist_ok=True)
        filepath = session_dir / filename
        filepath.write_bytes(image_bytes)
        return f"/media/{session_id}/{filename}"

    def get_media_path(self, session_id: str, filename: str) -> Path:
        """Get filesystem path for a media file."""
        return self.MEDIA_DIR / session_id / filename

    def read_media(self, session_id: str, filename: str) -> bytes:
        """Read media file bytes for WebSocket binary transmission."""
        return (self.MEDIA_DIR / session_id / filename).read_bytes()
```

### 5.3 WebSocket Binary Media Protocol

The WebSocket carries both JSON messages and binary media frames. We use a simple envelope protocol:

```python
# JSON messages (text frames) — artifacts, responses, feedback
await websocket.send_json({"type": "artifact", "data": artifact_dict})

# Binary messages (binary frames) — audio, images, video
# Preceded by a JSON header message describing the binary payload
await websocket.send_json({
    "type": "media_header",
    "media_id": "audio_content_3",
    "mime_type": "audio/mp3",
    "filename": "exercise_42.mp3",
    "size_bytes": 45032,
})
await websocket.send_bytes(audio_bytes)

# Frontend receives: header (JSON) then payload (binary)
# Frontend saves binary locally and maps media_id to local file path
```

**Alternative (simpler for MVP):** Serve media via FastAPI static files on localhost:

```python
# In main.py
from fastapi.staticfiles import StaticFiles
app.mount("/media", StaticFiles(directory="media"), name="media")

# Artifact references local URLs:
# "url": "http://localhost:8000/media/{session_id}/exercise_42.mp3"
```

### 5.4 System Prompts (`prompts.py`)

```python
SYSTEM_PROMPT_GENERATOR = """
You are an expert language teacher AI that creates interactive exercises.
You generate JSON artifacts that a Flutter frontend renders into interactive UI.

Your job is to create engaging, pedagogically sound exercises for language learners.
You MUST follow the exact JSON schema provided.

Key principles:
- Match content difficulty to the learner's CEFR level (A1-C2)
- Use authentic, natural language in the target language
- Create exercises that test the specified skill (reading/writing/listening/speaking)
- Include clear instructions in the base language
- Vary exercise types to maintain engagement
- For grammar exercises, focus on the specified grammar point
- Use culturally relevant topics and scenarios

You will receive an ExercisePlan with:
- skill: which of the 4 skills to test
- level: CEFR level (A1-C2)
- topic: the thematic domain
- grammar_focus: specific grammar point
- content_types: which content blocks to use
- input_types: which input blocks to use
- difficulty: calibrated difficulty (0.0-1.0)
"""

SYSTEM_PROMPT_EVALUATOR = """
You are an expert language assessment AI. You evaluate student responses
to language exercises with accuracy and constructive feedback.

For each response:
1. Check correctness (grammar, vocabulary, meaning)
2. Identify specific errors
3. Provide the correct answer
4. Explain WHY the answer is correct/incorrect
5. Give encouragement appropriate to the learner's level
6. Assess whether the response suggests the learner is ready to advance

Be precise in your corrections but encouraging in your tone.
"""

SYSTEM_PROMPT_ROOT_CAUSE = """
You are a language learning diagnostician. When a student makes an error,
you analyze the ROOT CAUSE — not just what was wrong, but WHY.

Your analysis must categorize the error:
- surface_typo: Minor spelling mistake, the student understands the concept
- grammar_rule: Student applied the wrong grammar rule (e.g., wrong tense formation)
- vocabulary_gap: Student doesn't know the word or phrase
- comprehension: Student misunderstood the passage or audio content
- pattern_confusion: Student confused similar grammar patterns (e.g., preteritum vs perfektum)
- pronunciation: Systematic pronunciation error in speaking exercises

For each error, determine:
1. The severity: "surface" (just feedback) or "deep" (needs targeted drill)
2. The underlying concept that needs reinforcement
3. What type of drill exercise would best address this gap

Be diagnostic, not punitive. The goal is to understand the learner's mental model.
"""

SYSTEM_PROMPT_FEEDBACK = """
You generate structured feedback artifacts for language learners.
Your feedback should be:
- Specific and actionable
- Encouraging but honest
- Include correct answers with explanations
- Written partly in the target language (appropriate to level)
- Include root cause explanation when errors are found
- Include a level assessment with trend
"""
```

---

## 6. Data Models

### 6.1 Learner Profile (`learner.py`)

```python
class LearnerProfile(BaseModel):
    """Tracks everything about the learner across sessions."""

    user_id: str
    target_language: str                  # ISO 639-1
    base_language: str = "en"             # ISO 639-1
    overall_level: str = "A1"             # CEFR level

    skill_levels: dict[str, str] = {
        "reading": "A1",
        "writing": "A1",
        "listening": "A1",
        "speaking": "A1",
    }

    # Performance tracking
    turn_history: list[TurnRecord] = []   # Last N turns with scores
    topic_scores: dict[str, float] = {}   # topic -> average score
    grammar_scores: dict[str, float] = {} # grammar point -> average score

    # Adaptive difficulty
    consecutive_correct: int = 0
    consecutive_incorrect: int = 0

    def get_skill_scores(self) -> dict[str, float]:
        """Return average recent scores per skill."""
        ...

    def get_recent_accuracy(self, last_n: int = 5) -> float:
        """Return accuracy over last N turns."""
        ...

    def get_weak_topics(self) -> list[str]:
        """Return topics scoring below threshold."""
        ...

    def get_next_grammar_point(self) -> str:
        """Return the next grammar point to teach/review."""
        ...
```

### 6.2 Session Model (`session.py`)

```python
class Session(BaseModel):
    """Represents an active learning session."""

    session_id: str
    learner: LearnerProfile
    target_language: str
    base_language: str = "en"
    topic: str = None                     # Optional topic focus

    # Turn tracking
    current_turn: int = 0
    max_turns: int = 10                   # Default session length
    history: list[TurnRecord] = []

    # Current state
    current_artifact: dict = None         # The artifact currently displayed
    current_plan: ExercisePlan = None     # The plan for current exercise

    # Session config
    skills_to_practice: list[str] = ["reading", "writing", "listening", "speaking"]
    difficulty_preference: str = "adaptive"  # adaptive | easy | medium | hard


class TurnRecord(BaseModel):
    """Record of a single turn in the session."""

    turn_number: int
    skill: str
    topic: str
    grammar_focus: str = None
    artifact_id: str
    response: dict = None
    evaluation: dict = None
    score: float
    timestamp: datetime
```

---

## 7. API Endpoints

### 7.1 HTTP Routes (`routes.py`)

```python
# POST /api/session/start
# Body: { target_language, base_language, topic?, skills?, level? }
# Returns: { session_id, ws_url, first_artifact }

# POST /api/session/{session_id}/respond
# Body: UserResponse (JSON)
# Returns: { feedback_artifact, next_artifact? }

# POST /api/session/{session_id}/end
# Returns: { summary, stats, recommendations }

# GET /api/session/{session_id}/status
# Returns: { current_turn, total_turns, learner_level }
```

### 7.2 WebSocket Endpoint (`ws.py`)

```python
@app.websocket("/ws/session/{session_id}")
async def websocket_session(websocket: WebSocket, session_id: str):
    await websocket.accept()
    session = session_manager.get(session_id)
    engine = LoopEngine(session, gemini_client)
    media = MediaService()

    try:
        # Send first exercise
        artifact = await engine.run_turn()
        session.current_artifact = artifact
        await send_artifact_with_media(websocket, artifact, session.session_id, media)

        # Enter the loop
        while session.current_turn < session.max_turns:
            # Step 6: WAIT for user response
            data = await websocket.receive_json()
            response = UserResponse(**data)

            # Handle any uploaded media (audio recordings)
            if response.has_audio():
                audio_data = await websocket.receive_bytes()
                audio_url = media.save_audio(
                    session.session_id, audio_data,
                    f"recording_turn_{session.current_turn}.webm"
                )
                response.set_audio_url(audio_url)

            # Process response (evaluate + root cause + feedback)
            feedback_artifact, root_cause_exercise = await engine.process_response(response)

            # Send feedback
            await websocket.send_json({"type": "feedback", "data": feedback_artifact})

            # If root cause analysis found a deep issue, send a drill exercise first
            if root_cause_exercise:
                await send_artifact_with_media(
                    websocket, root_cause_exercise, session.session_id, media
                )
                # Wait for drill response
                drill_data = await websocket.receive_json()
                drill_response = UserResponse(**drill_data)
                # Evaluate drill (lighter evaluation, just checking improvement)
                drill_feedback, _ = await engine.process_response(drill_response)
                await websocket.send_json({"type": "feedback", "data": drill_feedback})

            # Generate and send next exercise
            next_artifact = await engine.run_turn()
            session.current_artifact = next_artifact
            await send_artifact_with_media(websocket, next_artifact, session.session_id, media)

        # Session complete
        summary = engine.generate_summary()
        await websocket.send_json({"type": "summary", "data": summary})

    except WebSocketDisconnect:
        session_manager.pause(session_id)
    finally:
        await websocket.close()


async def send_artifact_with_media(
    websocket: WebSocket, artifact: dict, session_id: str, media: MediaService
):
    """
    Send an artifact over WebSocket. If it contains audio/image content blocks
    that need TTS generation, generate and save the media first, then update
    the artifact URLs to point to localhost media server.
    """
    for block in artifact.get("content", []):
        if block["type"] == "audio" and "tts_text" in block:
            # Generate audio via Gemini TTS
            audio_bytes = await gemini_client.text_to_speech(
                text=block["tts_text"], language=artifact["target_language"]
            )
            url = media.save_audio(session_id, audio_bytes, f"{block['id']}.mp3")
            block["url"] = f"http://localhost:8000{url}"
            del block["tts_text"]  # Remove internal field before sending

    await websocket.send_json({"type": "artifact", "data": artifact})
```

---

## 8. Skill-Specific Exercise Generation

The agent needs to know which content+input combinations work for each skill:

### 8.1 Reading Exercises

| Content Blocks | Input Blocks | Exercise Type |
|---------------|-------------|---------------|
| text (passage) | multiple_choice | Comprehension questions |
| rich_text | fill_blanks | Grammar in context |
| vocabulary_grid | matching | Vocabulary matching |
| dialogue | boolean | True/false about dialogue |

### 8.2 Writing Exercises

| Content Blocks | Input Blocks | Exercise Type |
|---------------|-------------|---------------|
| text (instruction) | free_text | Guided writing |
| image | free_text | Picture description |
| rich_text | fill_blanks | Sentence completion |
| conjugation_table | fill_blanks | Verb conjugation |
| text (instruction) | reorder | Sentence construction |

### 8.3 Listening Exercises

| Content Blocks | Input Blocks | Exercise Type |
|---------------|-------------|---------------|
| audio | multiple_choice | Listen and choose |
| audio | fill_blanks | Listen and complete |
| audio + dialogue | boolean | True/false about audio |
| audio | free_text | Transcription |
| audio | reorder | Reorder heard words |

### 8.4 Speaking Exercises

| Content Blocks | Input Blocks | Exercise Type |
|---------------|-------------|---------------|
| text (passage) | audio_recorder | Read aloud |
| image | audio_recorder | Describe the image |
| dialogue | audio_recorder | Role-play response |
| audio | audio_recorder | Repeat after |
| text (instruction) | audio_recorder + slider | Speak + self-assess |

---

## 9. Level Tracking Algorithm

```python
class LevelTracker:
    """
    Adaptive level tracking based on performance patterns.
    Uses a sliding window of recent turns to determine level changes.
    """

    LEVEL_ORDER = ["A1", "A2", "B1", "B2", "C1", "C2"]
    ADVANCE_THRESHOLD = 0.85      # Score needed to consider advancing
    DECLINE_THRESHOLD = 0.40      # Score that triggers level reconsideration
    WINDOW_SIZE = 5               # Number of turns to consider

    def update(self, learner: LearnerProfile, evaluation: Evaluation):
        # Update per-skill tracking
        skill = evaluation.skill
        learner.skill_levels[skill] = self._recalculate_skill_level(
            learner, skill, evaluation.overall_score
        )

        # Update consecutive counters
        if evaluation.overall_score >= self.ADVANCE_THRESHOLD:
            learner.consecutive_correct += 1
            learner.consecutive_incorrect = 0
        elif evaluation.overall_score <= self.DECLINE_THRESHOLD:
            learner.consecutive_incorrect += 1
            learner.consecutive_correct = 0
        else:
            learner.consecutive_correct = 0
            learner.consecutive_incorrect = 0

        # Check for level change
        if learner.consecutive_correct >= 3:
            self._advance_level(learner, skill)
        elif learner.consecutive_incorrect >= 3:
            self._decline_level(learner, skill)

        # Update overall level (median of skill levels)
        learner.overall_level = self._calculate_overall_level(learner)
```

---

## 10. Implementation Phases

### Phase 1: Foundation (Day 1 morning)
- [ ] Set up FastAPI project with project structure
- [ ] Configure Gemini API client
- [ ] Define all Pydantic models (Artifact, Blocks, Response, Learner)
- [ ] Build the artifact JSON schema for Gemini structured output
- [ ] Create WebSocket endpoint skeleton

### Phase 2: Generator + Validator (Day 1 afternoon)
- [ ] Build prompt templates for artifact generation
- [ ] Implement ArtifactGenerator with Gemini structured output
- [ ] Implement ArtifactValidator (schema checking)
- [ ] Test: generate artifacts for each skill type
- [ ] Verify generated JSON matches the contract schema

### Phase 3: Evaluator + Feedback (Day 1 evening)
- [ ] Implement objective evaluation (MCQ, boolean, reorder, matching)
- [ ] Implement subjective evaluation via Gemini (free text, audio)
- [ ] Build FeedbackBuilder with Gemini
- [ ] Test: evaluate sample responses for each input type

### Phase 4: Loop Engine + Session (Day 2 morning)
- [ ] Implement Assessor (learner state analysis)
- [ ] Implement Planner (exercise selection logic)
- [ ] Implement LevelTracker (adaptive leveling)
- [ ] Wire up the full LoopEngine turn cycle
- [ ] Implement SessionManager (in-memory state)
- [ ] Complete WebSocket endpoint with full loop

### Phase 5: Integration + Media (Day 2 afternoon)
- [ ] Add local media storage service (audio, images, video)
- [ ] Gemini TTS integration for listening exercise audio generation
- [ ] Gemini STT integration for speaking exercise evaluation
- [ ] Root cause analyzer implementation
- [ ] Root cause drill exercise generation
- [ ] WebSocket binary media protocol (or static file serving)
- [ ] End-to-end test with Flutter frontend on localhost
- [ ] Session summary generation
- [ ] Error handling and graceful degradation

---

## 11. Dependencies (requirements.txt)

```
fastapi>=0.115.0
uvicorn[standard]>=0.30.0
websockets>=12.0
google-genai>=1.0.0
pydantic>=2.9.0
python-dotenv>=1.0.0
httpx>=0.27.0
python-multipart>=0.0.9
```

---

## 12. Environment Configuration

```env
# .env
GEMINI_API_KEY=your-api-key-here
GEMINI_MODEL_FAST=gemini-3.6-flash
GEMINI_MODEL_EVAL=gemini-3.1
SERVER_HOST=localhost
SERVER_PORT=8000
CORS_ORIGINS=http://localhost:*
MEDIA_DIR=./media
MAX_SESSION_TURNS=20
DEFAULT_LEVEL=A1
```

---

## 13. Resolved Decisions

| Question | Decision |
|----------|----------|
| **Gemini model** | `gemini-3.6-flash` or `gemini-3.8-flash` for generation; `gemini-3.1` available for deeper subjective evaluation |
| **TTS** | Gemini API for text-to-speech (no Google Cloud TTS needed) |
| **STT** | Gemini API for speech-to-text transcription of user recordings |
| **Media storage** | Local filesystem (`./media/`) — no cloud storage for MVP |
| **Media delivery** | Static file serving via FastAPI on localhost OR binary WebSocket frames |
| **Deployment** | Localhost only — both backend (FastAPI) and frontend (Flutter) run locally |
| **Offline support** | Not applicable — localhost is always reachable |

## 14. Remaining Open Questions

**Conversation history in Gemini context**: Should we pass the full session history to Gemini on each turn for better context, or summarize it? Full history = better coherence but higher token cost. Recommendation: pass a summary + last 3 turns.

**Correct answers in artifacts**: Should the artifact JSON include correct answers (for objective questions) so the frontend can do instant validation, or should all evaluation go through the backend? Backend-only is more secure but slower. Recommendation: backend-only for the loop to work correctly; the agent must see responses.

**Root cause drill depth**: How many root cause drills should the agent insert before advancing? Recommendation: max 1 drill per error, then advance regardless — don't get stuck in a loop.
