import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/input_block.dart';
import '../../utils/response_collector.dart';

class SliderWidget extends StatefulWidget {
  final SliderInputBlock block;
  final ResponseCollector collector;

  const SliderWidget({
    super.key,
    required this.block,
    required this.collector,
  });

  factory SliderWidget.fromJson(
    Map<String, dynamic> json, {
    required ResponseCollector collector,
  }) {
    return SliderWidget(
      block: SliderInputBlock.fromJson(json),
      collector: collector,
    );
  }

  @override
  State<SliderWidget> createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    final existing = widget.collector.getResponse(widget.block.id);
    _currentValue = (existing as num?)?.toDouble() ?? widget.block.defaultValue;

    // Pre-seed response collector with default value
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.collector.setResponse(
        widget.block.id,
        'slider',
        _currentValue,
      );
    });
  }

  void _onChanged(double val) {
    setState(() {
      _currentValue = val;
    });
    widget.collector.setResponse(
      widget.block.id,
      'slider',
      val,
    );
  }

  @override
  Widget build(BuildContext context) {
    final divisions = ((widget.block.max - widget.block.min) / widget.block.step).round();
    final labelIndex = (_currentValue - widget.block.min).round();
    final currentLabel = (widget.block.labels.isNotEmpty && labelIndex < widget.block.labels.length)
        ? widget.block.labels[labelIndex]
        : _currentValue.toStringAsFixed(0);

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
              Text(
                widget.block.label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentSubtle,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  border: Border.all(color: AppTheme.accent),
                ),
                child: Text(
                  currentLabel,
                  style: const TextStyle(
                    color: AppTheme.accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingLG),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.accent,
              inactiveTrackColor: AppTheme.surfaceElevated,
              thumbColor: AppTheme.accent,
              overlayColor: AppTheme.accentSubtle,
              trackHeight: 4.0,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
            ),
            child: Slider(
              value: _currentValue,
              min: widget.block.min,
              max: widget.block.max,
              divisions: divisions > 0 ? divisions : 1,
              onChanged: _onChanged,
            ),
          ),
          if (widget.block.labels.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.block.labels.first,
                    style: const TextStyle(fontSize: 12, color: AppTheme.secondary),
                  ),
                  Text(
                    widget.block.labels.last,
                    style: const TextStyle(fontSize: 12, color: AppTheme.secondary),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
