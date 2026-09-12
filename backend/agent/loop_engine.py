from agent.generator import generator
from agent.evaluator import evaluator
from agent.root_cause_analyzer import root_cause_analyzer
from models.session import Session
from models.user_response import UserResponse
from models.artifact import FeedbackModel

class LoopEngine:
    """
    Main controller for the Loop Agent turn cycle.
    """
    def __init__(self):
        self.generator = generator
        self.evaluator = evaluator
        self.root_cause_analyzer = root_cause_analyzer

    async def run_turn(self, session: Session):
        """Step 1-3: Assess, Plan, Generate"""
        # For this version, we use the existing generator to create the artifact
        skills = ["reading", "writing", "listening", "speaking"]
        next_skill = skills[session.current_turn % len(skills)]
        artifact = await self.generator.generate(session, skill=next_skill)
        session.current_artifact = artifact.model_dump()
        return artifact

    async def process_response(self, session: Session, response: UserResponse):
        """Step 7-12: Evaluate, Root Cause, Feedback, Update"""
        
        # 1. Evaluate
        eval_result = await self.evaluator.evaluate(session.current_artifact, response, session.learner)
        
        # 2. Root Cause Analysis (if incorrect)
        feedback_explanation = eval_result.explanation
        is_correct = eval_result.is_correct
        
        if not is_correct:
            rca_result = await self.root_cause_analyzer.analyze(
                session.current_artifact, response, session.learner, eval_result.explanation
            )
            feedback_explanation = rca_result.explanation
            # Could update learner profile with root cause info here
            
        mock_feedback = dict(session.current_artifact)
        mock_feedback["mode"] = "feedback"
        
        feedback_data = {
            "overall": "correct" if is_correct else "incorrect",
            "message": feedback_explanation,
            "score": 1.0 if is_correct else 0.0
        }
        
        if not is_correct and rca_result:
            feedback_data["root_cause"] = {
                "category": rca_result.root_cause_category,
                "severity": rca_result.root_cause_severity,
                "explanation": rca_result.explanation,
                "underlying_concept": "",
                "will_drill": rca_result.root_cause_severity == "deep"
            }
            
        mock_feedback["feedback"] = feedback_data
        
        return mock_feedback

loop_engine = LoopEngine()
