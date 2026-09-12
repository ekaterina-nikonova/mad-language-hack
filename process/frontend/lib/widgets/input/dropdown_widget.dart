import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/input_block.dart';
import '../../utils/response_collector.dart';

class DropdownWidget extends StatefulWidget {
  final DropdownInputBlock block;
  final ResponseCollector collector;

  const DropdownWidget({
    super.key,
    required this.block,
    required this.collector,
  });

  factory DropdownWidget.fromJson(
    Map<String, dynamic> json, {
    required ResponseCollector collector,
  }) {
    return DropdownWidget(
      block: DropdownInputBlock.fromJson(json),
      collector: collector,
    );
  }

  @override
  State<DropdownWidget> createState() => _DropdownWidgetState();
}

class _DropdownWidgetState extends State<DropdownWidget> {
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    final existing = widget.collector.getResponse(widget.block.id);
    if (existing != null) {
      _selectedValue = existing.toString();
    }
  }

  void _onChanged(String? val) {
    if (val == null) return;
    setState(() {
      _selectedValue = val;
    });
    widget.collector.setResponse(
      widget.block.id,
      'dropdown',
      val,
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
          if (widget.block.label != null && widget.block.label!.isNotEmpty) ...[
            Text(
              widget.block.label!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
            ),
            const SizedBox(height: AppTheme.spacingMD),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMD),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              border: Border.all(
                color: _selectedValue != null ? AppTheme.accent : AppTheme.border,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedValue,
                hint: const Text(
                  'Select an option...',
                  style: TextStyle(color: AppTheme.secondary),
                ),
                dropdownColor: AppTheme.surfaceElevated,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down_rounded, color: AppTheme.accent, size: 28),
                items: widget.block.options.map((opt) {
                  return DropdownMenuItem<String>(
                    value: opt.id,
                    child: Text(
                      opt.text,
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 15,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: _onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
