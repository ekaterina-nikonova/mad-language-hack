# MVP Specifications

## About the application

The Mad Language Hack application, or **MLH**, is a GenAI-driven application for learning foreign languages. It is based on Agent Loops creating structured data in the process of a dialogue with the user.

## The main workflow

The main page of MLH collects the following input from the user:
- **Language**: The language the user wants to learn.
- **Topic**: The topic the user wants to learn about or practice (i.e., "Norwegian food traditions").
- **Grammar**: The grammar rules the user wants to focus on during the current session (i.e., "past tense verbs").

In response, the agent generates a **deliverable**: a structured data object conforming both to a formal schema and a set of content criteria.

### Deliverables

- **Text** is a short (about 100 words) piece of reading content in the target language on the specified topic and focused on the specified grammar rules. The text is generated for an **assumed** CEFR-aligned language level: the starting level is B1, and the level value is adjusted for the user in the process of interaction with the agent.

- **A multiple-choice question** (MCQ) is generated based on the text and has 4 answer options, one of which is correct. The length of the answer options must be approximately equal (a formal requirement), and the question must be answerable based on the text, adhere to the user's grammar focus, and be appropriate for the user's CEFR-aligned language level.

- **A free-form question** (FFQ) is generated based on the text and serves as a writing exercise. The answer may contain additional facts not present in the text.

- **An audio question or a prompt to a dialogue** is based on the text and takes into account the previous inputs given by the user. The audio question is generated in the target language and is appropriate for the user's CEFR-aligned language level.

After each deliverable, the user's response is collected and analyzed for correctness and appropriateness. The **Root Cause Evaluator** (RCE) asks the user to jusify the answer, gives the feedback on whether the answer was correct or incorrect, and what could have been improved.

Based on the user's answer and its justification, the CEFR estimate for this user is updated, and the subsequent deliverable generation is conducted according to the new CEFR level.

This interaction (deliverable – answer – root cause evaluation – feedback – updated CEFR level) continues until the user expresses the desire to finish the session as part of (or instead of) the answer or simply presses the "Finish" button.

## Memory

The information about the user persists in the application as structured data containing the current estimate of the CEFR level (updated after every answer submission), coverage of topics, and coverage of grammatic themes (updated after a session completes).
