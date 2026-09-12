import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/content_block.dart';

class TextBlockWidget extends StatelessWidget {
  final TextContentBlock block;

  const TextBlockWidget({super.key, required this.block});

  factory TextBlockWidget.fromJson(Map<String, dynamic> json) {
    return TextBlockWidget(block: TextContentBlock.fromJson(json));
  }

  @override
  Widget build(BuildContext context) {
    switch (block.style) {
      case 'heading':
        return Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spacingMD),
          child: Text(
            block.text,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
          ),
        );

      case 'passage':
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: AppTheme.spacingMD),
          padding: const EdgeInsets.all(AppTheme.spacingLG),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusLG),
            border: Border.all(color: AppTheme.border),
          ),
          child: Text(
            block.text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                  color: AppTheme.primary,
                ),
          ),
        );

      case 'hint':
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: AppTheme.spacingMD),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMD,
            vertical: AppTheme.spacingSM,
          ),
          decoration: BoxDecoration(
            color: AppTheme.warningSubtle,
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            border: Border.all(color: AppTheme.warning.withOpacity(0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lightbulb_outline, color: AppTheme.warning, size: 20),
              const SizedBox(width: AppTheme.spacingSM),
              Expanded(
                child: Text(
                  block.text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.warning,
                      ),
                ),
              ),
            ],
          ),
        );

      case 'explanation':
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: AppTheme.spacingMD),
          padding: const EdgeInsets.all(AppTheme.spacingMD),
          decoration: BoxDecoration(
            color: AppTheme.surfaceElevated,
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            border: const Border(
              left: BorderSide(color: AppTheme.accent, width: 3),
            ),
          ),
          child: Text(
            block.text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primary,
                ),
          ),
        );

      case 'instruction':
      default:
        return Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spacingMD),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 3),
                width: 6,
                height: 18,
                decoration: BoxDecoration(
                  color: AppTheme.accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: AppTheme.spacingSM),
              Expanded(
                child: Text(
                  block.text,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        );
    }
  }
}
