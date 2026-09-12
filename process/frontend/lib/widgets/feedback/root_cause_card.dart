import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/feedback_model.dart';

class RootCauseCard extends StatelessWidget {
  final RootCause rootCause;

  const RootCauseCard({super.key, required this.rootCause});

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'surface_typo':
        return Icons.spellcheck_rounded;
      case 'grammar_rule':
        return Icons.auto_stories_rounded;
      case 'vocabulary_gap':
        return Icons.translate_rounded;
      case 'comprehension':
        return Icons.psychology_rounded;
      case 'pattern_confusion':
        return Icons.alt_route_rounded;
      case 'pronunciation':
        return Icons.record_voice_over_rounded;
      default:
        return Icons.lightbulb_outline_rounded;
    }
  }

  String _formatCategory(String category) {
    return category.replaceAll('_', ' ').toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isDeep = rootCause.isDeep;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: AppTheme.spacingMD),
      padding: const EdgeInsets.all(AppTheme.spacingLG),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        border: Border.all(
          color: isDeep ? AppTheme.warning : AppTheme.border,
          width: isDeep ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    _getCategoryIcon(rootCause.category),
                    color: isDeep ? AppTheme.warning : AppTheme.accent,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ROOT CAUSE DIAGNOSIS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: isDeep ? AppTheme.warning : AppTheme.accent,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDeep ? AppTheme.warningSubtle : AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  border: Border.all(
                    color: isDeep ? AppTheme.warning.withOpacity(0.5) : AppTheme.border,
                  ),
                ),
                child: Text(
                  _formatCategory(rootCause.category),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDeep ? AppTheme.warning : AppTheme.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMD),
          Text(
            rootCause.explanation,
            style: const TextStyle(
              fontSize: 15,
              color: AppTheme.primary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMD),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMD),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.hub_outlined, size: 18, color: AppTheme.secondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Underlying Concept',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        rootCause.underlyingConcept,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (rootCause.willDrill) ...[
            const SizedBox(height: AppTheme.spacingMD),
            Row(
              children: [
                const Icon(Icons.bolt_rounded, size: 16, color: AppTheme.warning),
                const SizedBox(width: 6),
                Text(
                  'The agent prepared a targeted drill exercise next.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.warning.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
