import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/input_block.dart';
import '../../utils/response_collector.dart';

class FillBlanksWidget extends StatefulWidget {
  final FillBlanksInputBlock block;
  final ResponseCollector collector;

  const FillBlanksWidget({
    super.key,
    required this.block,
    required this.collector,
  });

  factory FillBlanksWidget.fromJson(
    Map<String, dynamic> json, {
    required ResponseCollector collector,
  }) {
    return FillBlanksWidget(
      block: FillBlanksInputBlock.fromJson(json),
      collector: collector,
    );
  }

  @override
  State<FillBlanksWidget> createState() => _FillBlanksWidgetState();
}

class _FillBlanksWidgetState extends State<FillBlanksWidget> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    final existing = widget.collector.getResponse(widget.block.id) as Map<String, dynamic>? ?? {};

    for (final blank in widget.block.blanks) {
      final initialVal = existing[blank.blankId]?.toString() ?? '';
      _controllers[blank.blankId] = TextEditingController(text: initialVal);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onBlankChanged() {
    final values = <String, String>{};
    for (final entry in _controllers.entries) {
      values[entry.key] = entry.value.text.trim();
    }
    widget.collector.setResponse(
      widget.block.id,
      'fill_blanks',
      values,
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
            children: [
              const Icon(Icons.edit_note_rounded, size: 16, color: AppTheme.accent),
              const SizedBox(width: 6),
              Text(
                'FILL IN THE BLANKS',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.accent,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMD),
          ...widget.block.blanks.asMap().entries.map((entry) {
            final index = entry.key;
            final blank = entry.value;
            final controller = _controllers[blank.blankId]!;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacingMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceElevated,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Blank #${index + 1}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (blank.hint != null) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Hint: ${blank.hint!}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.secondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: controller,
                    maxLength: blank.maxLength,
                    onChanged: (_) => _onBlankChanged(),
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Type answer...',
                      hintStyle: const TextStyle(color: AppTheme.secondary),
                      counterText: '',
                      filled: true,
                      fillColor: AppTheme.surfaceElevated,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingMD,
                        vertical: AppTheme.spacingSM + 2,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                        borderSide: const BorderSide(color: AppTheme.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                        borderSide: const BorderSide(color: AppTheme.accent, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
