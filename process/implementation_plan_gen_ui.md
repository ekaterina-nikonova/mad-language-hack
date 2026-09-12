# Generative UI — Flutter Frontend Implementation Plan

> **Goal**: Build a Flutter frontend that renders any learning exercise the AI agent designs, by interpreting a JSON artifact contract. The frontend is a **pure renderer** — it never decides *what* to teach, only *how to display* what the backend sends.

---

## 1. Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    FLUTTER APP                          │
│                                                         │
│  ┌───────────┐    ┌──────────────┐    ┌──────────────┐  │
│  │  Session   │───▶│  JSON Parser  │───▶│  Widget      │  │
│  │  Manager   │    │  & Validator  │    │  Registry     │  │
│  │ (WebSocket)│    └──────────────┘    └──────┬───────┘  │
│  └─────┬─────┘                               │          │
│        │           ┌──────────────┐           │          │
│        │           │  Artifact     │◀──────────┘          │
│        └──────────▶│  Renderer     │                     │
│                    │  (Main Stage) │                     │
│                    └──────┬───────┘                      │
│                           │                              │
│                    ┌──────▼───────┐                      │
│                    │  Response     │                     │
│                    │  Collector    │──── JSON ──▶ Backend │
│                    └──────────────┘                      │
└─────────────────────────────────────────────────────────┘
```

### Core Principle: **Artifact-Driven Rendering**

The backend (loop agent) sends a **UI Artifact** — a JSON object describing:
1. What to **show** the user (content blocks)
2. How the user should **respond** (input blocks)
3. **Metadata** (skill being tested, difficulty, timing, etc.)

The Flutter app has a **Widget Registry** that maps each JSON `type` field to a concrete Flutter widget. The app never hardcodes exercise flows — it only knows how to render component types.

---

## 2. JSON Artifact Schema (Contract Between Frontend & Backend)

> **IMPORTANT**: This schema is the single source of truth that both frontend and backend must agree on. Changes here must be coordinated.

### 2.1 Top-Level Artifact Envelope

```json
{
  "artifact_id": "uuid-v4",
  "turn_number": 3,
  "session_id": "uuid-v4",
  "skill": "listening",
  "level": "B1",
  "target_language": "no",
  "base_language": "en",
  "topic": "Matprodukter",
  "grammar_focus": "past_tense",
  "mode": "exercise",
  "content": [],
  "inputs": [],
  "feedback": {},
  "metadata": {
    "time_limit_seconds": null,
    "max_attempts": 1,
    "hint_available": true,
    "progress": {
      "current": 3,
      "total": 10
    }
  }
}
```

**Field Reference:**

| Field | Type | Values |
|-------|------|--------|
| `skill` | string | `reading`, `writing`, `listening`, `speaking` |
| `level` | string | `A1`, `A2`, `B1`, `B2`, `C1`, `C2` |
| `mode` | string | `exercise`, `feedback`, `summary`, `onboarding` |
| `target_language` | string | ISO 639-1 code |
| `base_language` | string | ISO 639-1 code |

### 2.2 Content Block Types

Each content block describes a **deliverable** the agent produced.

#### TEXT BLOCK — reading passages, instructions, grammar explanations

```json
{
  "type": "text",
  "id": "content_1",
  "text": "Les teksten og svar på spørsmålene.",
  "style": "instruction",
  "language": "no"
}
```

Style values: `instruction` | `passage` | `heading` | `hint` | `explanation`

#### RICH TEXT BLOCK — formatted text with highlights and blanks

```json
{
  "type": "rich_text",
  "id": "content_2",
  "segments": [
    { "text": "Jeg ", "style": "normal" },
    { "text": "___", "style": "blank", "blank_id": "blank_1" },
    { "text": " til butikken i går.", "style": "normal" }
  ],
  "language": "no"
}
```

#### AUDIO BLOCK — listening exercises, pronunciation demos

```json
{
  "type": "audio",
  "id": "content_3",
  "url": "https://storage.example.com/audio/exercise_42.mp3",
  "duration_seconds": 15,
  "playback_speed_options": [0.75, 1.0, 1.25],
  "max_plays": 3,
  "transcript_hidden": true,
  "transcript": "Jeg gikk til butikken i går."
}
```

#### IMAGE BLOCK — visual context, vocabulary cards

```json
{
  "type": "image",
  "id": "content_4",
  "url": "https://storage.example.com/images/grocery_store.jpg",
  "alt_text": "A grocery store in Norway",
  "caption": "Matbutikk"
}
```

#### VOCABULARY GRID — word lists with translations

```json
{
  "type": "vocabulary_grid",
  "id": "content_5",
  "words": [
    { "word": "melk", "translation": "milk", "phonetic": "/melk/", "image_url": "..." },
    { "word": "brød", "translation": "bread", "phonetic": "/brø/", "image_url": "..." }
  ]
}
```

#### DIALOGUE BLOCK — conversational exercises

```json
{
  "type": "dialogue",
  "id": "content_6",
  "speakers": [
    { "id": "A", "name": "Anna", "avatar": "female_1" },
    { "id": "B", "name": "Erik", "avatar": "male_1" }
  ],
  "lines": [
    { "speaker": "A", "text": "Hei! Har du vært i butikken?", "audio_url": "..." },
    { "speaker": "B", "text": "___", "is_blank": true, "blank_id": "dialogue_blank_1" }
  ]
}
```

#### CONJUGATION TABLE — grammar exercises

```json
{
  "type": "conjugation_table",
  "id": "content_7",
  "verb": "aa gaa",
  "tense": "preteritum",
  "rows": [
    { "pronoun": "jeg", "form": "gikk", "revealed": true },
    { "pronoun": "du", "form": "___", "revealed": false, "blank_id": "conj_1" }
  ]
}
```

### 2.3 Input Block Types

Each input block describes **how the user should respond**.

#### MULTIPLE CHOICE

```json
{
  "type": "multiple_choice",
  "id": "input_1",
  "question": "Hva betyr 'gikk'?",
  "options": [
    { "id": "a", "text": "walked", "label": "A" },
    { "id": "b", "text": "walks", "label": "B" },
    { "id": "c", "text": "will walk", "label": "C" },
    { "id": "d", "text": "is walking", "label": "D" }
  ],
  "allow_multiple": false
}
```

#### FREE TEXT — open-ended writing

```json
{
  "type": "free_text",
  "id": "input_2",
  "placeholder": "Skriv svaret ditt her...",
  "max_length": 500,
  "min_length": 10,
  "language": "no",
  "lines": 5
}
```

#### FILL IN THE BLANKS — connects to blank_ids in content

```json
{
  "type": "fill_blanks",
  "id": "input_3",
  "blanks": [
    { "blank_id": "blank_1", "hint": "past tense of 'aa gaa'", "max_length": 20 }
  ]
}
```

#### AUDIO RECORDER — speaking exercises

```json
{
  "type": "audio_recorder",
  "id": "input_4",
  "prompt": "Les setningen hoeyt:",
  "reference_text": "Jeg gikk til butikken i gaar.",
  "max_duration_seconds": 30,
  "allow_replay": true
}
```

#### DROPDOWN SELECT — grammar exercises

```json
{
  "type": "dropdown",
  "id": "input_5",
  "label": "Velg riktig form:",
  "options": [
    { "id": "opt1", "text": "gikk" },
    { "id": "opt2", "text": "gaar" },
    { "id": "opt3", "text": "gaatt" }
  ]
}
```

#### SLIDER — self-assessment or confidence rating

```json
{
  "type": "slider",
  "id": "input_6",
  "label": "Hvor sikker er du?",
  "min": 1,
  "max": 5,
  "step": 1,
  "labels": ["Usikker", "Litt sikker", "Middels", "Ganske sikker", "Helt sikker"],
  "default_value": 3
}
```

#### REORDER — sentence construction (drag and drop)

```json
{
  "type": "reorder",
  "id": "input_7",
  "instruction": "Sett ordene i riktig rekkefoelge:",
  "items": [
    { "id": "w1", "text": "Jeg" },
    { "id": "w2", "text": "til" },
    { "id": "w3", "text": "butikken" },
    { "id": "w4", "text": "gikk" },
    { "id": "w5", "text": "i gaar" }
  ]
}
```

#### MATCHING — pairing exercises

```json
{
  "type": "matching",
  "id": "input_8",
  "instruction": "Match the Norwegian words with their English translations:",
  "left_items": [
    { "id": "l1", "text": "melk" },
    { "id": "l2", "text": "broed" },
    { "id": "l3", "text": "ost" }
  ],
  "right_items": [
    { "id": "r1", "text": "cheese" },
    { "id": "r2", "text": "milk" },
    { "id": "r3", "text": "bread" }
  ]
}
```

#### BOOLEAN — true/false

```json
{
  "type": "boolean",
  "id": "input_9",
  "statement": "The word 'gikk' is in the present tense.",
  "labels": ["True", "False"]
}
```

### 2.4 Feedback Block (from agent after evaluation)

```json
{
  "feedback": {
    "overall": "correct",
    "score": 0.85,
    "message": "Bra jobba! Du fikk 5 av 6 riktig.",
    "corrections": [
      {
        "input_id": "input_3",
        "blank_id": "blank_1",
        "user_answer": "gaat",
        "correct_answer": "gikk",
        "explanation": "'Aa gaa' is irregular. The past tense is 'gikk', not 'gaat'."
      }
    ],
    "root_cause": {
      "category": "grammar_rule",
      "severity": "deep",
      "explanation": "You applied regular past tense formation (-et/-te) to an irregular verb.",
      "underlying_concept": "Irregular verb conjugation in preteritum",
      "will_drill": true
    },
    "encouragement": "Du er nesten der! Proev en gang til.",
    "level_assessment": {
      "current": "A2",
      "trend": "improving",
      "ready_for_next": false
    }
  }
}
```

| Field | Values |
|-------|--------|
| `overall` | `correct`, `partial`, `incorrect` |
| `trend` | `improving`, `stable`, `declining` |
| `root_cause.category` | `surface_typo`, `grammar_rule`, `vocabulary_gap`, `comprehension`, `pattern_confusion`, `pronunciation` |
| `root_cause.severity` | `surface` (just feedback), `deep` (drill exercise follows) |

### 2.5 User Response Envelope (Frontend to Backend)

```json
{
  "session_id": "uuid-v4",
  "artifact_id": "uuid-v4",
  "turn_number": 3,
  "timestamp": "2026-09-12T12:00:00Z",
  "responses": [
    {
      "input_id": "input_1",
      "type": "multiple_choice",
      "value": "a"
    },
    {
      "input_id": "input_2",
      "type": "free_text",
      "value": "Jeg gikk til butikken og kjoepte melk."
    },
    {
      "input_id": "input_4",
      "type": "audio_recorder",
      "audio_url": "http://localhost:8000/media/session_id/recording_turn_3.webm",
      "duration_seconds": 5.2
    },
    {
      "input_id": "input_7",
      "type": "reorder",
      "value": ["w1", "w4", "w2", "w3", "w5"]
    }
  ],
  "client_metadata": {
    "time_taken_seconds": 45,
    "hint_used": false,
    "audio_plays": 2
  }
}
```

---

## 3. Flutter Project Structure

```
lib/
├── main.dart
├── app.dart
│
├── config/
│   ├── theme.dart                  # Design tokens, colors, typography
│   ├── constants.dart              # App-wide constants
│   └── routes.dart                 # Route definitions
│
├── models/
│   ├── artifact.dart               # Top-level Artifact model
│   ├── content_block.dart          # Content block models (sealed class)
│   ├── input_block.dart            # Input block models (sealed class)
│   ├── feedback_model.dart         # Feedback model
│   ├── user_response.dart          # User response envelope
│   └── session.dart                # Session state model
│
├── services/
│   ├── api_service.dart            # HTTP/WebSocket communication
│   ├── session_service.dart        # Session lifecycle management
│   ├── audio_service.dart          # Audio playback and recording
│   ├── media_service.dart          # Local media caching and serving
│   └── websocket_service.dart      # WebSocket message/binary frame handling
│
├── providers/
│   ├── session_provider.dart       # Session state (Riverpod)
│   ├── artifact_provider.dart      # Current artifact state
│   ├── response_provider.dart      # Collected user responses
│   └── theme_provider.dart         # Theme state
│
├── widgets/
│   ├── artifact_renderer.dart      # MAIN: reads artifact, renders blocks
│   │
│   ├── content/                    # Content block widgets
│   │   ├── text_block_widget.dart
│   │   ├── rich_text_block_widget.dart
│   │   ├── audio_block_widget.dart
│   │   ├── image_block_widget.dart
│   │   ├── vocabulary_grid_widget.dart
│   │   ├── dialogue_block_widget.dart
│   │   └── conjugation_table_widget.dart
│   │
│   ├── input/                      # Input block widgets
│   │   ├── multiple_choice_widget.dart
│   │   ├── free_text_widget.dart
│   │   ├── fill_blanks_widget.dart
│   │   ├── audio_recorder_widget.dart
│   │   ├── dropdown_widget.dart
│   │   ├── slider_widget.dart
│   │   ├── reorder_widget.dart
│   │   ├── matching_widget.dart
│   │   └── boolean_widget.dart
│   │
│   ├── feedback/                   # Feedback display widgets
│   │   ├── feedback_card.dart
│   │   ├── correction_item.dart
│   │   ├── root_cause_card.dart        # Shows WHY the user got it wrong
│   │   └── level_badge.dart
│   │
│   └── shared/                     # Reusable UI components
│       ├── loading_shimmer.dart
│       ├── progress_bar.dart
│       ├── submit_button.dart
│       ├── hint_button.dart
│       ├── language_chip.dart
│       └── animated_card.dart
│
├── screens/
│   ├── onboarding_screen.dart
│   ├── session_screen.dart         # Main exercise screen
│   ├── summary_screen.dart         # Session summary
│   └── settings_screen.dart
│
└── utils/
    ├── json_parser.dart            # JSON to Model parsing with validation
    ├── widget_registry.dart        # Type string to Widget factory map
    └── response_collector.dart     # Gathers responses from input widgets
```

---

## 4. Key Components — Implementation Details

### 4.1 Widget Registry (`widget_registry.dart`)

The registry maps each JSON `type` string to a widget builder. This is the core of the generative UI pattern.

```dart
class WidgetRegistry {
  static final Map<String, Widget Function(Map<String, dynamic>)> _contentBuilders = {
    'text': (data) => TextBlockWidget.fromJson(data),
    'rich_text': (data) => RichTextBlockWidget.fromJson(data),
    'audio': (data) => AudioBlockWidget.fromJson(data),
    'image': (data) => ImageBlockWidget.fromJson(data),
    'vocabulary_grid': (data) => VocabularyGridWidget.fromJson(data),
    'dialogue': (data) => DialogueBlockWidget.fromJson(data),
    'conjugation_table': (data) => ConjugationTableWidget.fromJson(data),
  };

  static final Map<String, Widget Function(Map<String, dynamic>, ResponseCollector)> _inputBuilders = {
    'multiple_choice': (data, c) => MultipleChoiceWidget.fromJson(data, collector: c),
    'free_text': (data, c) => FreeTextWidget.fromJson(data, collector: c),
    'fill_blanks': (data, c) => FillBlanksWidget.fromJson(data, collector: c),
    'audio_recorder': (data, c) => AudioRecorderWidget.fromJson(data, collector: c),
    'dropdown': (data, c) => DropdownWidget.fromJson(data, collector: c),
    'slider': (data, c) => SliderWidget.fromJson(data, collector: c),
    'reorder': (data, c) => ReorderWidget.fromJson(data, collector: c),
    'matching': (data, c) => MatchingWidget.fromJson(data, collector: c),
    'boolean': (data, c) => BooleanWidget.fromJson(data, collector: c),
  };

  static Widget buildContent(Map<String, dynamic> block) { ... }
  static Widget buildInput(Map<String, dynamic> block, ResponseCollector c) { ... }
}
```

### 4.2 Artifact Renderer (`artifact_renderer.dart`)

The main stage widget — takes a parsed artifact and lays out all blocks:

```dart
/// Flow:
/// 1. Parse JSON into Artifact model
/// 2. If feedback exists, show feedback card first
/// 3. Render content blocks in order via WidgetRegistry
/// 4. Render input blocks in order via WidgetRegistry
/// 5. Show submit button at bottom
/// 6. On submit, collect all responses and send to backend
class ArtifactRenderer extends ConsumerWidget {
  final Artifact artifact;
  final ResponseCollector responseCollector;
  // Renders: FeedbackCard? -> Content[] -> Input[] -> SubmitButton
}
```

### 4.3 Response Collector (`response_collector.dart`)

```dart
/// Centralized response accumulator. Each input widget registers
/// its response here via [setResponse]. On submit, [toJson] packages
/// everything into the User Response Envelope.
class ResponseCollector extends ChangeNotifier {
  final Map<String, dynamic> _responses = {};
  final String sessionId;
  final String artifactId;
  final int turnNumber;
  final Stopwatch _timer = Stopwatch();

  void setResponse(String inputId, String type, dynamic value);
  bool get isComplete;
  Map<String, dynamic> toJson();
}
```

### 4.4 Session Manager (`session_service.dart`)

```dart
/// Manages the turn-based communication loop:
/// 1. Connect to backend (WebSocket preferred, HTTP fallback)
/// 2. Receive artifact JSON, parse, update state
/// 3. User interacts, submit response JSON
/// 4. Receive next artifact (feedback or next exercise)
/// 5. Repeat until session ends
class SessionService {
  Future<void> startSession(SessionConfig config);
  Stream<Artifact> get artifactStream;
  Future<void> submitResponse(UserResponse response);
  Future<void> endSession();
}
```

---

## 5. Design System — Minimalist Language Learning Theme

### 5.1 Design Tokens

Inspired by the UNIX card UI and meditation app references — clean, high contrast, generous whitespace.

```dart
// Color palette — dark mode primary, light mode available
static const Color background = Color(0xFF0F0F14);        // near-black
static const Color surface = Color(0xFF1A1A24);            // card surface
static const Color surfaceElevated = Color(0xFF252533);    // elevated card
static const Color primary = Color(0xFFE8E0D4);            // warm off-white (text)
static const Color secondary = Color(0xFF8B8680);           // muted warm gray
static const Color accent = Color(0xFFC4A97D);              // warm gold accent
static const Color correct = Color(0xFF4CAF7D);             // success green
static const Color incorrect = Color(0xFFE57373);           // error red
static const Color border = Color(0xFF2A2A38);              // subtle borders

// Typography
static const String fontFamily = 'Inter';
static const double headingSize = 24.0;
static const double bodySize = 16.0;
static const double captionSize = 13.0;

// Spacing
static const double spacingXS = 4.0;
static const double spacingSM = 8.0;
static const double spacingMD = 16.0;
static const double spacingLG = 24.0;
static const double spacingXL = 32.0;

// Border radius
static const double radiusSM = 8.0;
static const double radiusMD = 12.0;
static const double radiusLG = 16.0;
static const double radiusXL = 24.0;
```

### 5.2 Key Visual Components

| Component | Style |
|-----------|-------|
| Exercise card | `surface` bg, `radiusLG` corners, subtle shadow |
| Audio player | Waveform visualization, minimal controls (play/pause/speed) |
| MCQ options | Outlined chips, highlight on select with `accent` color |
| Text input | Borderless with underline, monospaced for language input |
| Progress bar | Thin line at top of screen, `accent` color fill |
| Submit button | Full-width, `accent` background, rounded |
| Feedback card | Animated slide-in, green/red left border |

### 5.3 Animations

- **Artifact transition**: Fade + slide up (300ms ease-out) when new artifact arrives
- **Feedback reveal**: Slide in from bottom with slight bounce
- **Option select**: Scale pulse (1.0 to 1.05 to 1.0, 200ms)
- **Progress increment**: Smooth width animation
- **Audio waveform**: Animated bars during playback

---

## 6. Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.0        # State management
  freezed_annotation: ^2.4.0       # Immutable models
  json_annotation: ^4.9.0          # JSON serialization
  web_socket_channel: ^3.0.0       # WebSocket communication
  http: ^1.2.0                     # HTTP fallback
  just_audio: ^0.9.0               # Audio playback
  record: ^5.1.0                   # Audio recording
  cached_network_image: ^3.4.0     # Image loading and caching
  shimmer: ^3.0.0                  # Loading placeholders
  google_fonts: ^6.2.0             # Typography
  uuid: ^4.4.0                     # ID generation

dev_dependencies:
  freezed: ^2.5.0
  json_serializable: ^6.8.0
  build_runner: ^2.4.0
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.0
```

---

## 7. Implementation Phases

### Phase 1: Foundation (Day 1 morning)
- [ ] Create Flutter project scaffold
- [ ] Set up theme, design tokens, and typography
- [ ] Define all data models (Artifact, ContentBlock, InputBlock, UserResponse)
- [ ] Implement JSON parser with validation
- [ ] Build WidgetRegistry skeleton

### Phase 2: Content Widgets (Day 1 afternoon)
- [ ] TextBlockWidget — text display with style variants
- [ ] RichTextBlockWidget — segmented text with blanks
- [ ] AudioBlockWidget — audio player with waveform, speed control, play count
- [ ] ImageBlockWidget — cached image with caption
- [ ] VocabularyGridWidget — grid of word cards
- [ ] DialogueBlockWidget — chat-bubble style dialogue
- [ ] ConjugationTableWidget — verb conjugation table

### Phase 3: Input Widgets (Day 1 evening)
- [ ] MultipleChoiceWidget — selectable option chips
- [ ] FreeTextWidget — text area with character count
- [ ] FillBlanksWidget — inline text fields
- [ ] AudioRecorderWidget — record button with timer
- [ ] DropdownWidget — styled dropdown selector
- [ ] SliderWidget — labeled slider
- [ ] ReorderWidget — drag-and-drop word ordering
- [ ] MatchingWidget — draw-lines or drag matching
- [ ] BooleanWidget — true/false toggle

### Phase 4: Core Engine (Day 2 morning)
- [ ] ArtifactRenderer — main layout engine
- [ ] ResponseCollector — gather and validate responses
- [ ] SessionService — WebSocket/HTTP communication
- [ ] SessionScreen — full exercise flow screen
- [ ] Feedback display (animated card, corrections list)

### Phase 5: Polish and Integration (Day 2 afternoon)
- [ ] Animations and transitions
- [ ] Loading states (shimmer)
- [ ] Error handling and offline fallback
- [ ] Onboarding screen
- [ ] Session summary screen
- [ ] End-to-end test with mock backend

---

## 8. Communication Protocol

### 8.1 WebSocket Flow (with Root Cause Drills)

```
CLIENT                          SERVER (localhost:8000)
  |                               |
  |-- POST /session/start ------->|  (returns session_id + ws_url)
  |                               |
  |<====== WebSocket Connect =====|
  |                               |
  |<-- {type:artifact} exercise 1 |
  |                               |
  |--- user_response #1 -------->|
  |                               |
  |<-- {type:feedback} + root_cause
  |                               |
  |   [IF root_cause.severity == "deep"]
  |<-- {type:artifact} drill exercise  <-- targeted mini-exercise
  |--- drill_response ---------->|
  |<-- {type:feedback} drill feedback
  |   [END IF]
  |                               |
  |<-- {type:artifact} exercise 2 |
  |                               |
  |--- user_response #2 -------->|
  |         ...                   |
  |                               |
  |<-- {type:summary} session end |
  |====== WebSocket Close ========|
```

**Message envelope**: All WebSocket messages are JSON with a `type` field:
- `{"type": "artifact", "data": {...}}` — exercise to render
- `{"type": "feedback", "data": {...}}` — feedback with root cause
- `{"type": "summary", "data": {...}}` — session summary

**Media**: Audio/images are served as static files from `http://localhost:8000/media/...`
Artifact URLs point to localhost (e.g., `"url": "http://localhost:8000/media/{session_id}/audio.mp3"`).

### 8.2 HTTP Fallback Flow

```
POST /api/session/start         -> { session_id, first_artifact }
POST /api/session/{id}/respond  -> { feedback_artifact, root_cause_exercise?, next_artifact }
POST /api/session/{id}/end      -> { summary }
```

---

## 9. Testing Strategy

| Test Type | What to Test |
|-----------|-------------|
| **Unit** | JSON parsing, model serialization, response collector logic |
| **Widget** | Each content/input widget renders correctly from JSON |
| **Integration** | Full artifact, render, collect response, submit flow |
| **Golden** | Visual snapshot tests for each widget variant |
| **Mock Backend** | Local JSON files simulating full exercise sessions |

### Mock Data

Create a `test/fixtures/` directory with sample JSON artifacts for each skill type:
- `reading_exercise.json` — text passage + MCQ
- `writing_exercise.json` — prompt + free text
- `listening_exercise.json` — audio + fill blanks
- `speaking_exercise.json` — reference text + audio recorder

---

## 10. Resolved Decisions

| Question | Decision |
|----------|----------|
| **Audio delivery** | URLs pointing to `http://localhost:8000/media/...` (static file serving from local filesystem) |
| **Audio recording** | Record locally on device, send binary over WebSocket, backend saves to local `./media/` folder |
| **TTS** | Gemini API for text-to-speech (backend generates audio, saves locally, sends URL in artifact) |
| **STT** | Gemini API for speech-to-text (backend transcribes recordings for evaluation) |
| **Deployment** | Localhost only — Flutter connects to `localhost:8000` |
| **Media types** | Audio (MP3/WAV), images (PNG/JPG), short video (MP4) — all served from local static files |
| **Gemini model** | `gemini-3.6-flash` or `gemini-3.8-flash` for generation; `gemini-3.1` for subjective evaluation |

**Widget extensibility**: The registry pattern means adding new exercise types only requires: (1) add JSON type to schema, (2) create widget, (3) register in registry. No changes to core engine needed.
