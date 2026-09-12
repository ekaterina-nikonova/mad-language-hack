import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/content_block.dart';

class DialogueBlockWidget extends StatelessWidget {
  final DialogueContentBlock block;

  const DialogueBlockWidget({super.key, required this.block});

  factory DialogueBlockWidget.fromJson(Map<String, dynamic> json) {
    return DialogueBlockWidget(block: DialogueContentBlock.fromJson(json));
  }

  @override
  Widget build(BuildContext context) {
    final speakerMap = {for (var s in block.speakers) s.id: s};

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMD),
      padding: const EdgeInsets.all(AppTheme.spacingLG),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingMD),
            child: Row(
              children: [
                const Icon(Icons.forum_outlined, size: 16, color: AppTheme.accent),
                const SizedBox(width: 6),
                Text(
                  'DIALOGUE',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.accent,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          ...block.lines.map((line) {
            final speaker = speakerMap[line.speaker];
            final speakerName = speaker?.name ?? line.speaker;
            final isSpeakerA = block.speakers.isNotEmpty && block.speakers.first.id == line.speaker;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacingMD),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment:
                    isSpeakerA ? MainAxisAlignment.start : MainAxisAlignment.end,
                children: [
                  if (isSpeakerA) ...[
                    _buildAvatar(speakerName),
                    const SizedBox(width: AppTheme.spacingSM),
                  ],
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingMD,
                        vertical: AppTheme.spacingSM + 2,
                      ),
                      decoration: BoxDecoration(
                        color: isSpeakerA ? AppTheme.surfaceElevated : AppTheme.accentSubtle,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(AppTheme.radiusMD),
                          topRight: const Radius.circular(AppTheme.radiusMD),
                          bottomLeft: isSpeakerA
                              ? const Radius.circular(2)
                              : const Radius.circular(AppTheme.radiusMD),
                          bottomRight: isSpeakerA
                              ? const Radius.circular(AppTheme.radiusMD)
                              : const Radius.circular(2),
                        ),
                        border: Border.all(
                          color: isSpeakerA ? AppTheme.border : AppTheme.accent.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: isSpeakerA
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.end,
                        children: [
                          Text(
                            speakerName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isSpeakerA ? AppTheme.secondary : AppTheme.accent,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (line.isBlank)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.surface,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppTheme.accent, width: 1.5),
                              ),
                              child: const Text(
                                '____',
                                style: TextStyle(
                                  color: AppTheme.accent,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            )
                          else
                            Text(
                              line.text,
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontSize: 15,
                                height: 1.4,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (!isSpeakerA) ...[
                    const SizedBox(width: AppTheme.spacingSM),
                    _buildAvatar(speakerName),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAvatar(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.borderHover),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: AppTheme.primary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
