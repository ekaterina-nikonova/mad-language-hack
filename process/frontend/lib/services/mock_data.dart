import '../models/artifact.dart';

class MockDataService {
  static final List<Artifact> mockArtifactSequence = [
    // ----------------------------------------------------
    // 1. MOCKUP: Free Form Writing Exercise
    // ----------------------------------------------------
    Artifact.fromJson({
      "artifact_id": "mockup-free-form",
      "turn_number": 1,
      "session_id": "sess-mad-hackathon",
      "skill": "writing",
      "level": "B1",
      "target_language": "no",
      "base_language": "en",
      "topic": "Min Daglige Rutine (Free Form)",
      "grammar_focus": "sentence_structure",
      "mode": "exercise",
      "agent_message":
          "Hei Dario! I dag skal vi trene på skriftlig formuleringsevne. Beskriv hva du pleier å gjøre om morgenen. Prøv å bruke minst to tidsuttrykk som «først», «deretter» eller «etterpå».",
      "metadata": {
        "progress": {"current": 1, "total": 4},
        "hint_available": true
      },
      "content": [
        {
          "type": "text",
          "id": "ff_heading",
          "text": "Åpen skriveoppgave: Morgenrutine",
          "style": "heading",
          "language": "no"
        },
        {
          "type": "text",
          "id": "ff_instruction",
          "text": "Skriv en sammenhengende tekst (minimum 25 tegn). Bruk gjerne ordene fra listen nedenfor:",
          "style": "instruction",
          "language": "no"
        },
        {
          "type": "vocabulary_grid",
          "id": "ff_vocab",
          "words": [
            {"word": "å våkne", "translation": "to wake up", "phonetic": "/voːknə/"},
            {"word": "frokost", "translation": "breakfast", "phonetic": "/fruːkust/"},
            {"word": "å pusse tenner", "translation": "to brush teeth", "phonetic": "/pusə tenːər/"},
            {"word": "deretter", "translation": "afterwards", "phonetic": "/dɛrɛtːər/"}
          ]
        }
      ],
      "inputs": [
        {
          "type": "free_text",
          "id": "q_freeform_answer",
          "placeholder": "Skriv svaret ditt her på norsk (f.eks. «Hver morgen våkner jeg klokken sju. Først drikker jeg kaffe, deretter spiser jeg frokost...»)",
          "min_length": 25,
          "max_length": 600,
          "lines": 5,
          "language": "no"
        },
        {
          "type": "slider",
          "id": "q_confidence_slider",
          "label": "Hvor fornøyd er du med teksten din?",
          "min": 1,
          "max": 5,
          "step": 1,
          "labels": ["Må øve mer", "Litt usikker", "Helt greit", "Bra", "Superfornøyd!"],
          "default_value": 4
        }
      ]
    }),

    // ----------------------------------------------------
    // 2. MOCKUP: Audio Listening Comprehension
    // ----------------------------------------------------
    Artifact.fromJson({
      "artifact_id": "mockup-audio-listening",
      "turn_number": 2,
      "session_id": "sess-mad-hackathon",
      "skill": "listening",
      "level": "B1",
      "target_language": "no",
      "base_language": "en",
      "topic": "På Flyplassen i Oslo (Listening)",
      "grammar_focus": "listening_comprehension",
      "mode": "exercise",
      "agent_message":
          "Lytt nøye til høyttalermeldingen fra Oslo lufthavn Gardermoen. Legg merke til hvilken gate flyet til Bergen har flyttet til, og svar på spørsmålene.",
      "metadata": {
        "progress": {"current": 2, "total": 4}
      },
      "content": [
        {
          "type": "text",
          "id": "listen_heading",
          "text": "Lytteøvelse: Melding over høyttaleren",
          "style": "heading",
          "language": "no"
        },
        {
          "type": "text",
          "id": "listen_inst",
          "text": "Trykk på play for å høre opptaket. Du kan justere farten (0.75x, 1.0x, 1.25x) eller åpne transkripsjonen:",
          "style": "instruction",
          "language": "no"
        },
        {
          "type": "audio",
          "id": "listen_audio_track",
          "url": "http://localhost:8000/media/announcement_gardermoen.mp3",
          "duration_seconds": 14,
          "playback_speed_options": [0.75, 1.0, 1.25],
          "max_plays": 3,
          "transcript_hidden": true,
          "transcript":
              "Oppmerksomhet, passasjerer til Bergen med rute SK284. På grunn av teknisk vedlikehold er avgangen flyttet fra gate B12 til gate A19. Ombordstigning starter om ti minutter."
        }
      ],
      "inputs": [
        {
          "type": "multiple_choice",
          "id": "q_listen_gate",
          "question": "Hvilken gate skal passasjerene gå til nå?",
          "options": [
            {"id": "a", "text": "Gate B12", "label": "A"},
            {"id": "b", "text": "Gate A19", "label": "B"},
            {"id": "c", "text": "Gate C4", "label": "C"},
            {"id": "d", "text": "Gate D8", "label": "D"}
          ]
        },
        {
          "type": "boolean",
          "id": "q_listen_boarding",
          "statement": "Ombordstigningen starter med en gang (akkurat nå).",
          "labels": ["Riktig (True)", "Galt (False - om 10 min)"]
        }
      ]
    }),

    // ----------------------------------------------------
    // 3. MOCKUP: Audio Speaking & Voice Recording
    // ----------------------------------------------------
    Artifact.fromJson({
      "artifact_id": "mockup-audio-speaking",
      "turn_number": 3,
      "session_id": "sess-mad-hackathon",
      "skill": "speaking",
      "level": "A2",
      "target_language": "no",
      "base_language": "en",
      "topic": "Muntlig Øvelse: Bestille på Restaurant",
      "grammar_focus": "pronunciation_intonation",
      "mode": "exercise",
      "agent_message":
          "Nå skal vi øve på uttale og setningsmelodi! Les setningen høyt inn i mikrofonen. Når du er ferdig kan du høre opptaket ditt før du sender.",
      "metadata": {
        "progress": {"current": 3, "total": 4}
      },
      "content": [
        {
          "type": "text",
          "id": "spk_heading",
          "text": "Muntlig taleoppgave",
          "style": "heading",
          "language": "no"
        },
        {
          "type": "text",
          "id": "spk_inst",
          "text": "Trykk på den runde mikrofonknappen nedenfor for å starte innspillingen:",
          "style": "instruction",
          "language": "no"
        }
      ],
      "inputs": [
        {
          "type": "audio_recorder",
          "id": "q_speech_record",
          "prompt": "Les denne høflige bestillingen høyt og tydelig:",
          "reference_text": "Unnskyld, kan jeg få se menyen og bestille et glass vann?",
          "max_duration_seconds": 25,
          "allow_replay": true
        }
      ]
    }),

    // ----------------------------------------------------
    // 4. MOCKUP: Conversational Chatbot (Dialogue + Freeform + Feedback)
    // ----------------------------------------------------
    Artifact.fromJson({
      "artifact_id": "mockup-conversational-combo",
      "turn_number": 4,
      "session_id": "sess-mad-hackathon",
      "skill": "speaking_and_writing",
      "level": "B1",
      "target_language": "no",
      "base_language": "en",
      "topic": "Samtale: Innsjekking på Hotell",
      "grammar_focus": "polite_requests",
      "mode": "exercise",
      "agent_message":
          "Rollespill: Du ankommer hotellet i Tromsø klokken 22:00. Resepsjonisten henvender seg til deg. Svar høflig på spørsmålet i tekstfeltet.",
      "metadata": {
        "progress": {"current": 4, "total": 4}
      },
      "content": [
        {
          "type": "text",
          "id": "chat_heading",
          "text": "Rollespill: Resepsjonen",
          "style": "heading",
          "language": "no"
        },
        {
          "type": "dialogue",
          "id": "chat_dialogue_flow",
          "speakers": [
            {"id": "A", "name": "Resepsjonist (Kari)"},
            {"id": "B", "name": "Deg (Dario)"}
          ],
          "lines": [
            {
              "speaker": "A",
              "text": "God kveld og velkommen til Tromsø! Har du en reservasjon hos oss i kveld?",
              "isBlank": false
            },
            {
              "speaker": "B",
              "text": "Ja, jeg har bestilt et rom...",
              "isBlank": true
            }
          ]
        }
      ],
      "inputs": [
        {
          "type": "free_text",
          "id": "q_hotel_reply",
          "placeholder": "Skriv svaret ditt til resepsjonisten (f.eks. «Ja, jeg heter Dario og har bestilt et enkeltrom for tre netter.»)",
          "min_length": 15,
          "max_length": 300,
          "lines": 3
        },
        {
          "type": "dropdown",
          "id": "q_breakfast_pref",
          "label": "Velg frokostønske:",
          "options": [
            {"id": "opt_early", "text": "Tidlig frokost (kl. 06:30)"},
            {"id": "opt_regular", "text": "Vanlig frokost (kl. 08:00)"},
            {"id": "opt_takeaway", "text": "Frokostpose for fjelltur (Takeaway)"}
          ]
        }
      ]
    }),

    // ----------------------------------------------------
    // 5. BONUS TURN: Root Cause Diagnosis & Feedback Card Showcase
    // ----------------------------------------------------
    Artifact.fromJson({
      "artifact_id": "art-feedback-turn-rootcause",
      "turn_number": 5,
      "session_id": "sess-mad-hackathon",
      "skill": "writing",
      "level": "A2",
      "target_language": "no",
      "base_language": "en",
      "topic": "Root Cause Diagnosis: Irregular Verbs",
      "grammar_focus": "past_tense_irregular",
      "mode": "feedback",
      "agent_message":
          "Flott innsats! Du gjorde en feil med verbbøyingen, men her er den nøyaktige årsaken (Root Cause Diagnosis) og forklaringen:",
      "metadata": {
        "progress": {"current": 3, "total": 5},
        "is_drill_next": true
      },
      "feedback": {
        "overall": "partial",
        "score": 0.70,
        "message": "Nesten helt riktig! God setningsstruktur, men verbet krever oppmerksomhet.",
        "corrections": [
          {
            "input_id": "q2_blank",
            "blank_id": "blank_verb_gaa",
            "user_answer": "gådde",
            "correct_answer": "gikk",
            "explanation": "«Å gå» er et sterkt uregelmessig verb. Preteritumsformen er «gikk», ikke «gådde»."
          }
        ],
        "root_cause": {
          "category": "grammar_rule",
          "severity": "deep",
          "explanation":
              "Du overgeneraliserte den svake regelmessige endelsen (-de) på et sterkt verb med rotvokalskifte (Ablaut).",
          "underlying_concept": "Sterke verb med vokalskifte i preteritum (å gå -> gikk)",
          "will_drill": true
        },
        "encouragement": "Dette er veldig vanlig! La oss ta en rask drill for å automatisere formen.",
        "level_assessment": {
          "current": "A2",
          "trend": "improving",
          "ready_for_next": false
        }
      },
      "content": [
        {
          "type": "conjugation_table",
          "id": "drill_table",
          "verb": "å gå",
          "tense": "preteritum",
          "rows": [
            {"pronoun": "Infinitiv", "form": "å gå", "revealed": true},
            {"pronoun": "Presens", "form": "går", "revealed": true},
            {"pronoun": "Preteritum", "form": "gikk", "revealed": true},
            {"pronoun": "Perfektum", "form": "har gått", "revealed": true}
          ]
        }
      ],
      "inputs": []
    }),

    // ----------------------------------------------------
    // 6. BONUS TURN: Reorder & Matching Interactive Showcase
    // ----------------------------------------------------
    Artifact.fromJson({
      "artifact_id": "art-turn-reorder-matching",
      "turn_number": 6,
      "session_id": "sess-mad-hackathon",
      "skill": "grammar_and_vocab",
      "level": "A1",
      "target_language": "no",
      "base_language": "en",
      "topic": "V2-regelen og Ordparing",
      "grammar_focus": "word_order",
      "mode": "exercise",
      "agent_message":
          "Dra og slipp ordene for å sette setningen i riktig rekkefølge etter V2-regelen, og kobl sammen de norske og engelske ordene.",
      "metadata": {
        "progress": {"current": 4, "total": 4}
      },
      "content": [
        {
          "type": "text",
          "id": "reorder_heading",
          "text": "Ordrekkefølge og Ordforråd",
          "style": "heading",
          "language": "no"
        }
      ],
      "inputs": [
        {
          "type": "reorder",
          "id": "q_reorder_sentence",
          "instruction": "Sett ordene i riktig rekkefølge (V2-regelen: verbet må stå på andreplass):",
          "items": [
            {"id": "w1", "text": "I dag"},
            {"id": "w2", "text": "kjøper"},
            {"id": "w3", "text": "jeg"},
            {"id": "w4", "text": "ferskt brød"}
          ]
        },
        {
          "type": "matching",
          "id": "q_matching_words",
          "instruction": "Koble sammen ordene:",
          "left_items": [
            {"id": "l1", "text": "melk"},
            {"id": "l2", "text": "ost"},
            {"id": "l3", "text": "kaffe"}
          ],
          "right_items": [
            {"id": "r1", "text": "coffee"},
            {"id": "r2", "text": "cheese"},
            {"id": "r3", "text": "milk"}
          ]
        }
      ]
    })
  ];
}
