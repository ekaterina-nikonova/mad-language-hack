from models.gemini_feedback_schema import GeminiFeedbackResult
from models.user_response import UserResponse
from models.learner import LearnerProfile
from services.llm_service import llm_service

class RootCauseAnalyzer:
    """
    Diagnoses WHY the user got a question wrong using Gemini.
    """
    async def analyze(self, artifact: dict, response: UserResponse, learner: LearnerProfile, evaluator_explanation: str = "") -> GeminiFeedbackResult:
        prompt = (
            f"Analyze the learner's response for root causes of any errors.\n"
            f"Target Language: {learner.target_language}\n"
            f"Learner Level: {learner.overall_level}\n"
            f"Evaluator Findings: {evaluator_explanation}\n"
            f"Artifact context: {artifact}\n"
            f"User response: {response.model_dump()}\n"
        )
        
        system_instruction = (
            f"You are a language learning diagnostician. Evaluate the user's response. "
            f"If correct, set is_correct to true. If incorrect, diagnose the root cause: "
            f"surface_typo, grammar_rule, vocabulary_gap, comprehension, pattern_confusion, or pronunciation. "
            f"Also set severity to 'surface' or 'deep'. 'deep' means a drill is needed. "
            f"IMPORTANT: You MUST write your explanation in the user's native language ({learner.base_language}). "
            f"The content being learned is in {learner.target_language}, but feedback MUST be in {learner.base_language}."
        )

        return await llm_service.generate_structured(
            prompt=prompt,
            response_schema=GeminiFeedbackResult,
            system_instruction=system_instruction
        )

root_cause_analyzer = RootCauseAnalyzer()
