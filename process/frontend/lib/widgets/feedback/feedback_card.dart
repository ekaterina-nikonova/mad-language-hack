import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/feedback_model.dart';
import 'root_cause_card.dart';

class FeedbackCard extends StatelessWidget {
  final FeedbackModel feedback;
  final VoidCallback? onContinue;

  const FeedbackCard({
    super.key,
    required this.feedback,
    this.onContinue,
  });

  Color _getStatusColor() {
    if (feedback.isCorrect) return AppTheme.correct;
    if (feedback.isPartial) return AppTheme.warning;
    return AppTheme.incorrect;
  }

  IconData _getStatusIcon() {
    if (feedback.isCorrect) return Icons.check_circle_rounded;
    if (feedback.isPartial) return Icons.published_with_changes_rounded;
    return Icons.error_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final statusIcon = _getStatusIcon();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppTheme.spacingLG),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        border: Border.all(color: statusColor.withOpacity(0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingLG),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTheme.radiusLG - 1),
                topRight: Radius.circular(AppTheme.radiusLG - 1),
              ),
            ),
            child: Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 28),
                const SizedBox(width: AppTheme.spacingMD),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feedback.overall.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        feedback.message,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  ),
                  child: Text(
                    '${(feedback.score * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingLG),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Corrections list
                if (feedback.corrections.isNotEmpty) ...[
                  Text(
                    'CORRECTIONS',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.secondary,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppTheme.spacingSM),
                  ...feedback.corrections.map((corr) {
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: AppTheme.spacingSM),
                      padding: const EdgeInsets.all(AppTheme.spacingMD),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (corr.userAnswer != null) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.incorrectSubtle,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'You: ${corr.userAnswer}',
                                    style: const TextStyle(
                                      color: AppTheme.incorrect,
                                      fontSize: 13,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward_rounded,
                                    size: 14, color: AppTheme.secondary),
                                const SizedBox(width: 8),
                              ],
                              if (corr.correctAnswer != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.correctSubtle,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Correct: ${corr.correctAnswer}',
                                    style: const TextStyle(
                                      color: AppTheme.correct,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            corr.explanation,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.primary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],

                // Root Cause Analysis Card
                if (feedback.rootCause != null)
                  RootCauseCard(rootCause: feedback.rootCause!),

                // Encouragement & Level Assessment
                if (feedback.encouragement != null || feedback.levelAssessment != null) ...[
                  const SizedBox(height: AppTheme.spacingMD),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (feedback.encouragement != null)
                        Expanded(
                          child: Text(
                            feedback.encouragement!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: AppTheme.secondary,
                            ),
                          ),
                        ),
                      if (feedback.levelAssessment != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceElevated,
                            borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Level ${feedback.levelAssessment!.current}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.accent,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                feedback.levelAssessment!.trend == 'improving'
                                    ? Icons.trending_up_rounded
                                    : Icons.trending_flat_rounded,
                                size: 14,
                                color: feedback.levelAssessment!.trend == 'improving'
                                    ? AppTheme.correct
                                    : AppTheme.secondary,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],

                // Continue Button
                if (onContinue != null) ...[
                  const SizedBox(height: AppTheme.spacingLG),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        foregroundColor: AppTheme.background,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                        ),
                      ),
                      child: Text(
                        feedback.rootCause?.willDrill == true
                            ? 'Start Targeted Drill'
                            : 'Continue to Next Exercise',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
