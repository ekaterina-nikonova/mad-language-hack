import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/content_block.dart';

class VocabularyGridWidget extends StatelessWidget {
  final VocabularyGridContentBlock block;

  const VocabularyGridWidget({super.key, required this.block});

  factory VocabularyGridWidget.fromJson(Map<String, dynamic> json) {
    return VocabularyGridWidget(block: VocabularyGridContentBlock.fromJson(json));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingSM),
            child: Row(
              children: [
                const Icon(Icons.menu_book_rounded, size: 16, color: AppTheme.accent),
                const SizedBox(width: 6),
                Text(
                  'VOCABULARY',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.accent,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 220,
              mainAxisExtent: 100,
              crossAxisSpacing: AppTheme.spacingSM,
              mainAxisSpacing: AppTheme.spacingSM,
            ),
            itemCount: block.words.length,
            itemBuilder: (context, index) {
              final word = block.words[index];
              return Container(
                padding: const EdgeInsets.all(AppTheme.spacingMD),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      word.word,
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      word.translation,
                      style: const TextStyle(
                        color: AppTheme.accent,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (word.phonetic != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        word.phonetic!,
                        style: const TextStyle(
                          color: AppTheme.secondary,
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
