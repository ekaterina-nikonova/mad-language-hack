import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/input_block.dart';
import '../../utils/response_collector.dart';

class MultipleChoiceWidget extends StatefulWidget {
  final MultipleChoiceInputBlock block;
  final ResponseCollector collector;

  const MultipleChoiceWidget({
    super.key,
    required this.block,
    required this.collector,
  });

  factory MultipleChoiceWidget.fromJson(
    Map<String, dynamic> json, {
    required ResponseCollector collector,
  }) {
    return MultipleChoiceWidget(
      block: MultipleChoiceInputBlock.fromJson(json),
      collector: collector,
    );
  }

  @override
  State<MultipleChoiceWidget> createState() => _MultipleChoiceWidgetState();
}

class _MultipleChoiceWidgetState extends State<MultipleChoiceWidget> {
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    final existing = widget.collector.getResponse(widget.block.id);
    if (existing != null) {
      if (existing is List) {
        _selectedIds.addAll(existing.map((e) => e.toString()));
      } else {
        _selectedIds.add(existing.toString());
      }
    }
  }

  void _handleSelect(String optionId) {
    setState(() {
      if (widget.block.allowMultiple) {
        if (_selectedIds.contains(optionId)) {
          _selectedIds.remove(optionId);
        } else {
          _selectedIds.add(optionId);
        }
        widget.collector.setResponse(
          widget.block.id,
          'multiple_choice',
          _selectedIds.toList(),
        );
      } else {
        _selectedIds.clear();
        _selectedIds.add(optionId);
        widget.collector.setResponse(
          widget.block.id,
          'multiple_choice',
          optionId,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.block.question != null && widget.block.question!.isNotEmpty) ...[
            Text(
              widget.block.question!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
            ),
            const SizedBox(height: AppTheme.spacingMD),
          ],
          ...widget.block.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isSelected = _selectedIds.contains(option.id);
            final displayLabel = option.label ?? '${index + 1}'; // 1, 2, 3...

            return Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacingSM),
              child: InkWell(
                onTap: () => _handleSelect(option.id),
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMD,
                    vertical: AppTheme.spacingMD,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.accentSubtle : AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    border: Border.all(
                      color: isSelected ? AppTheme.accent : AppTheme.border,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.accent : AppTheme.surfaceElevated,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppTheme.accent : AppTheme.border,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            displayLabel,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? AppTheme.background : AppTheme.secondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingMD),
                      Expanded(
                        child: Text(
                          option.text,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? AppTheme.primary : AppTheme.primary.withOpacity(0.85),
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle_rounded, color: AppTheme.accent, size: 20),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
