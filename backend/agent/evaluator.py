from models.gemini_feedback_schema import GeminiFeedbackResult
from models.learner import LearnerProfile
from models.user_response import UserResponse
from pydantic import BaseModel
from services.llm_service import llm_service

class ObjectiveEvalResult(BaseModel):
    is_correct: bool
    explanation: str

class Evaluator:
    """
    Evaluates the user's response.
    First tries objective matching, then uses Gemini for subjective evaluation.
    """
    async def evaluate(self, artifact: dict, response: UserResponse, learner: LearnerProfile) -> ObjectiveEvalResult:
        # 1. Extract correct answers from artifact metadata
        correct_answers = artifact.get("metadata", {}).get("correct_answers", {})
        
        # 2. Match with user inputs
        inputs = {}
        for r in response.responses:
            inputs[r.input_id] = r.value

        all_correct = True
        explanations = []

        for input_block in artifact.get("inputs", []):
            input_id = input_block.get("id")
            user_answer_id = inputs.get(input_id)
            correct_answer_text = correct_answers.get(input_id)

            # Map user_answer_id back to text if it's a multiple choice option
            user_answer_text = str(user_answer_id)
            if user_answer_text.startswith("opt_"):
                options = input_block.get("options", [])
                for opt in options:
                    if opt.get("id") == user_answer_id:
                        user_answer_text = opt.get("text", user_answer_text)
                        break

            if correct_answer_text is not None:
                # Objective comparison
                if str(user_answer_text).strip().lower() == str(correct_answer_text).strip().lower():
                    explanations.append(f"Correct for {input_id}.")
                else:
                    all_correct = False
                    explanations.append(f"Incorrect for {input_id}. User selected '{user_answer_text}', expected '{correct_answer_text}'.")
            else:
                # Subjective (use Gemini)
                prompt = (
                    f"Evaluate this response in {learner.target_language}.\n"
                    f"Learner level: {learner.overall_level}\n"
                    f"Question ID: {input_id}\n"
                    f"User Answer: {user_answer_text}\n"
                    f"Context: {artifact}\n"
                )
                eval_result = await llm_service.generate_structured(
                    prompt=prompt,
                    response_schema=ObjectiveEvalResult,
                    system_instruction=f"You are a strict but fair language evaluator. Determine if the answer is correct. IMPORTANT: Write your explanation in the user's native language ({learner.base_language})."
                )
                if not eval_result.is_correct:
                    all_correct = False
                explanations.append(eval_result.explanation)

        return ObjectiveEvalResult(
            is_correct=all_correct,
            explanation="\n".join(explanations)
        )

evaluator = Evaluator()
