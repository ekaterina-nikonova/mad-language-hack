import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/content_block.dart';

class ConjugationTableWidget extends StatelessWidget {
  final ConjugationTableContentBlock block;

  const ConjugationTableWidget({super.key, required this.block});

  factory ConjugationTableWidget.fromJson(Map<String, dynamic> json) {
    return ConjugationTableWidget(
      block: ConjugationTableContentBlock.fromJson(json),
    );
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.table_chart_outlined, size: 16, color: AppTheme.accent),
                  const SizedBox(width: 6),
                  Text(
                    'CONJUGATION',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.accent,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.accentSubtle,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                ),
                child: Text(
                  '${block.verb} (${block.tense})',
                  style: const TextStyle(
                    color: AppTheme.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMD),
          Table(
            border: TableBorder.all(color: AppTheme.border, width: 1),
            children: [
              const TableRow(
                decoration: BoxDecoration(color: AppTheme.surfaceElevated),
                children: [
                  Padding(
                    padding: EdgeInsets.all(AppTheme.spacingSM + 2),
                    child: Text(
                      'Pronoun',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.secondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(AppTheme.spacingSM + 2),
                    child: Text(
                      'Form',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.secondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              ...block.rows.map((row) {
                return TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingSM + 2),
                      child: Text(
                        row.pronoun,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingSM + 2),
                      child: row.revealed
                          ? Text(
                              row.form,
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.accentSubtle,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppTheme.accent),
                              ),
                              child: const Text(
                                '____',
                                style: TextStyle(
                                  color: AppTheme.accent,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}
