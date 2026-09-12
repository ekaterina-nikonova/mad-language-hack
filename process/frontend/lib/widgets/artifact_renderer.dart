import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/artifact.dart';
import '../utils/response_collector.dart';
import '../utils/widget_registry.dart';
import 'feedback/feedback_card.dart';
import 'shared/agent_message_bubble.dart';

class ArtifactRenderer extends StatelessWidget {
  final Artifact artifact;
  final ResponseCollector responseCollector;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final VoidCallback? onContinueFromFeedback;

  const ArtifactRenderer({
    super.key,
    required this.artifact,
    required this.responseCollector,
    this.isSubmitting = false,
    required this.onSubmit,
    this.onContinueFromFeedback,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: responseCollector,
      builder: (context, _) {
        final hasFeedback = artifact.feedback != null;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingLG,
            vertical: AppTheme.spacingMD,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 0. AI Chatbot Message Bubble (Tutor presence)
              if (artifact.agentMessage != null && artifact.agentMessage!.isNotEmpty) ...[
                AgentMessageBubble(message: artifact.agentMessage!),
              ],
              // 1. Feedback Card (if turn returned feedback)
              if (hasFeedback) ...[
                FeedbackCard(
                  feedback: artifact.feedback!,
                  onContinue: onContinueFromFeedback,
                ),
                const SizedBox(height: AppTheme.spacingMD),
              ],

              // 2. Content Blocks
              ...artifact.content.map((contentBlock) {
                return WidgetRegistry.buildContent(
                  contentBlock,
                  collector: responseCollector,
                );
              }),

              // 3. Input Blocks (if in exercise mode and has inputs)
              if (artifact.inputs.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spacingMD),
                ...artifact.inputs.map((inputBlock) {
                  return WidgetRegistry.buildInput(
                    inputBlock,
                    responseCollector,
                  );
                }),
                const SizedBox(height: AppTheme.spacingLG),

                // 4. Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      foregroundColor: AppTheme.background,
                      disabledBackgroundColor: AppTheme.surfaceElevated,
                      disabledForegroundColor: AppTheme.secondary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                      ),
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppTheme.background,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Submit Response',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 20),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXL),
              ],
            ],
          ),
        );
      },
    );
  }
}
