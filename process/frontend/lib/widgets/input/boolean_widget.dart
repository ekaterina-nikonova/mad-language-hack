import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/input_block.dart';
import '../../utils/response_collector.dart';

class BooleanWidget extends StatefulWidget {
  final BooleanInputBlock block;
  final ResponseCollector collector;

  const BooleanWidget({
    super.key,
    required this.block,
    required this.collector,
  });

  factory BooleanWidget.fromJson(
    Map<String, dynamic> json, {
    required ResponseCollector collector,
  }) {
    return BooleanWidget(
      block: BooleanInputBlock.fromJson(json),
      collector: collector,
    );
  }

  @override
  State<BooleanWidget> createState() => _BooleanWidgetState();
}

class _BooleanWidgetState extends State<BooleanWidget> {
  bool? _selected;

  @override
  void initState() {
    super.initState();
    final existing = widget.collector.getResponse(widget.block.id);
    if (existing != null && existing is bool) {
      _selected = existing;
    }
  }

  void _onSelect(bool val) {
    setState(() {
      _selected = val;
    });
    widget.collector.setResponse(
      widget.block.id,
      'boolean',
      val,
    );
  }

  @override
  Widget build(BuildContext context) {
    final trueLabel = widget.block.labels.isNotEmpty ? widget.block.labels[0] : 'True';
    final falseLabel = widget.block.labels.length > 1 ? widget.block.labels[1] : 'False';

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
          Text(
            widget.block.statement,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
          ),
          const SizedBox(height: AppTheme.spacingLG),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _onSelect(true),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMD),
                    decoration: BoxDecoration(
                      color: _selected == true ? AppTheme.accentSubtle : AppTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                      border: Border.all(
                        color: _selected == true ? AppTheme.accent : AppTheme.border,
                        width: _selected == true ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          size: 18,
                          color: _selected == true ? AppTheme.accent : AppTheme.secondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          trueLabel,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: _selected == true ? FontWeight.w700 : FontWeight.w500,
                            color: _selected == true ? AppTheme.accent : AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingMD),
              Expanded(
                child: InkWell(
                  onTap: () => _onSelect(false),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMD),
                    decoration: BoxDecoration(
                      color: _selected == false ? AppTheme.accentSubtle : AppTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                      border: Border.all(
                        color: _selected == false ? AppTheme.accent : AppTheme.border,
                        width: _selected == false ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cancel_outlined,
                          size: 18,
                          color: _selected == false ? AppTheme.accent : AppTheme.secondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          falseLabel,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: _selected == false ? FontWeight.w700 : FontWeight.w500,
                            color: _selected == false ? AppTheme.accent : AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
