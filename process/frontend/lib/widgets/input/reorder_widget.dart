import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/input_block.dart';
import '../../utils/response_collector.dart';

class ReorderWidget extends StatefulWidget {
  final ReorderInputBlock block;
  final ResponseCollector collector;

  const ReorderWidget({
    super.key,
    required this.block,
    required this.collector,
  });

  factory ReorderWidget.fromJson(
    Map<String, dynamic> json, {
    required ResponseCollector collector,
  }) {
    return ReorderWidget(
      block: ReorderInputBlock.fromJson(json),
      collector: collector,
    );
  }

  @override
  State<ReorderWidget> createState() => _ReorderWidgetState();
}

class _ReorderWidgetState extends State<ReorderWidget> {
  late List<ReorderItem> _currentItems;

  @override
  void initState() {
    super.initState();
    _currentItems = List.from(widget.block.items);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _saveResponse();
    });
  }

  void _saveResponse() {
    widget.collector.setResponse(
      widget.block.id,
      'reorder',
      _currentItems.map((item) => item.id).toList(),
    );
  }

  void _moveItem(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = _currentItems.removeAt(oldIndex);
      _currentItems.insert(newIndex, item);
      _saveResponse();
    });
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
              const Icon(Icons.swap_vert_rounded, size: 16, color: AppTheme.accent),
              const SizedBox(width: 6),
              Text(
                'ORDER THE WORDS',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.accent,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          if (widget.block.instruction != null) ...[
            const SizedBox(height: AppTheme.spacingSM),
            Text(
              widget.block.instruction!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
          const SizedBox(height: AppTheme.spacingMD),
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            onReorder: _moveItem,
            proxyDecorator: (child, index, animation) {
              return Material(
                color: Colors.transparent,
                elevation: 6,
                shadowColor: AppTheme.background,
                child: child,
              );
            },
            children: _currentItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;

              return Container(
                key: ValueKey(item.id),
                margin: const EdgeInsets.only(bottom: AppTheme.spacingSM),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMD,
                  vertical: AppTheme.spacingSM + 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.secondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingMD),
                    Expanded(
                      child: Text(
                        item.text,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                    const Icon(Icons.drag_indicator_rounded, color: AppTheme.secondary, size: 20),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
