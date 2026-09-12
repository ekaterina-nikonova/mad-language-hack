import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/content_block.dart';

class RichTextBlockWidget extends StatelessWidget {
  final RichTextContentBlock block;

  const RichTextBlockWidget({super.key, required this.block});

  factory RichTextBlockWidget.fromJson(Map<String, dynamic> json) {
    return RichTextBlockWidget(block: RichTextContentBlock.fromJson(json));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMD),
      padding: const EdgeInsets.all(AppTheme.spacingLG),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        border: Border.all(color: AppTheme.border),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: block.segments.map((segment) {
          if (segment.style == 'blank') {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                border: Border.all(color: AppTheme.accent, width: 1.5),
              ),
              child: Text(
                segment.text.isEmpty ? '____' : segment.text,
                style: const TextStyle(
                  color: AppTheme.accent,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.0,
                ),
              ),
            );
          } else if (segment.style == 'highlight') {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.0),
              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.0),
              decoration: BoxDecoration(
                color: AppTheme.accentSubtle,
                borderRadius: BorderRadius.circular(AppTheme.radiusSM),
              ),
              child: Text(
                segment.text,
                style: const TextStyle(
                  color: AppTheme.accent,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.0,
                ),
              ),
            );
          } else if (segment.style == 'bold') {
            return Text(
              segment.text,
              style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w700,
                fontSize: 16.0,
              ),
            );
          } else {
            return Text(
              segment.text,
              style: const TextStyle(
                color: AppTheme.primary,
                fontSize: 16.0,
                height: 1.6,
              ),
            );
          }
        }).toList(),
      ),
    );
  }
}
