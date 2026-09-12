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

    async def propose_plan(self, session: Session, send_event=None, retry=False):
        skills = ["reading", "writing", "listening", "speaking"]
        current_skill = skills[session.current_turn % len(skills)]
        
        if retry:
            import random
            available_skills = [s for s in skills if s != current_skill]
            next_skill = random.choice(available_skills)
        else:
            next_skill = current_skill
        
        if send_event:
            import asyncio
            await send_event("agent_thought", "Analyzing learner profile...")
            await asyncio.sleep(1)
            await send_event("agent_thought", f"Current turn: {session.current_turn}, Performance is stable.")
            await asyncio.sleep(1)
            await send_event("agent_thought", f"Determining optimal next skill: {next_skill.capitalize()}")
            await asyncio.sleep(1)
            
            plan_text = f"For the next turn, I propose we focus on **{next_skill.capitalize()}**."
            await send_event("plan_proposal", {"plan": plan_text, "skill": next_skill})
        return next_skill

    async def run_turn(self, session: Session, skill: str = None):
        """Step 1-3: Assess, Plan, Generate"""
        if not skill:
            skills = ["reading", "writing", "listening", "speaking"]
            skill = skills[session.current_turn % len(skills)]
            
        artifact = await self.generator.generate(session, skill=skill)
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
            session.learner.consecutive_incorrect += 1
            session.learner.consecutive_correct = 0
            if session.learner.consecutive_incorrect >= 2:
                levels = ["A1", "A2", "B1", "B2", "C1", "C2"]
                try:
                    idx = levels.index(session.learner.overall_level)
                    if idx > 0:
                        session.learner.overall_level = levels[idx - 1]
                        session.learner.consecutive_incorrect = 0
                except ValueError:
                    pass

            rca_result = await self.root_cause_analyzer.analyze(
                session.current_artifact, response, session.learner, eval_result.explanation
            )
            feedback_explanation = rca_result.explanation
            # Could update learner profile with root cause info here
        else:
            session.learner.consecutive_correct += 1
            session.learner.consecutive_incorrect = 0
            if session.learner.consecutive_correct >= 2:
                levels = ["A1", "A2", "B1", "B2", "C1", "C2"]
                try:
                    idx = levels.index(session.learner.overall_level)
                    if idx < len(levels) - 1:
                        session.learner.overall_level = levels[idx + 1]
                        session.learner.consecutive_correct = 0
                except ValueError:
                    pass
            rca_result = None
            
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
