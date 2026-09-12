import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/input_block.dart';
import '../../utils/response_collector.dart';

class MatchingWidget extends StatefulWidget {
  final MatchingInputBlock block;
  final ResponseCollector collector;

  const MatchingWidget({
    super.key,
    required this.block,
    required this.collector,
  });

  factory MatchingWidget.fromJson(
    Map<String, dynamic> json, {
    required ResponseCollector collector,
  }) {
    return MatchingWidget(
      block: MatchingInputBlock.fromJson(json),
      collector: collector,
    );
  }

  @override
  State<MatchingWidget> createState() => _MatchingWidgetState();
}

class _MatchingWidgetState extends State<MatchingWidget> {
  String? _selectedLeftId;
  final Map<String, String> _pairs = {}; // leftId -> rightId

  @override
  void initState() {
    super.initState();
    final existing = widget.collector.getResponse(widget.block.id);
    if (existing != null && existing is Map) {
      existing.forEach((k, v) {
        _pairs[k.toString()] = v.toString();
      });
    }
  }

  void _onLeftTap(String id) {
    setState(() {
      if (_selectedLeftId == id) {
        _selectedLeftId = null;
      } else {
        _selectedLeftId = id;
      }
    });
  }

  void _onRightTap(String rightId) {
    if (_selectedLeftId == null) {
      // Find if rightId is already paired, if so unpair
      final matchingLeft = _pairs.entries.firstWhere(
        (e) => e.value == rightId,
        orElse: () => const MapEntry('', ''),
      );
      if (matchingLeft.key.isNotEmpty) {
        setState(() {
          _pairs.remove(matchingLeft.key);
          _saveResponse();
        });
      }
      return;
    }

    setState(() {
      _pairs[_selectedLeftId!] = rightId;
      _selectedLeftId = null;
      _saveResponse();
    });
  }

  void _saveResponse() {
    widget.collector.setResponse(
      widget.block.id,
      'matching',
      _pairs,
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
                  const Icon(Icons.compare_arrows_rounded, size: 16, color: AppTheme.accent),
                  const SizedBox(width: 6),
                  Text(
                    'MATCH THE PAIRS',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.accent,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
              if (_pairs.isNotEmpty)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _pairs.clear();
                      _selectedLeftId = null;
                      _saveResponse();
                    });
                  },
                  child: const Text('Reset', style: TextStyle(fontSize: 12, color: AppTheme.secondary)),
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
          const SizedBox(height: AppTheme.spacingLG),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column
              Expanded(
                child: Column(
                  children: widget.block.leftItems.map((item) {
                    final isSelected = _selectedLeftId == item.id;
                    final isPaired = _pairs.containsKey(item.id);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppTheme.spacingSM),
                      child: InkWell(
                        onTap: () => _onLeftTap(item.id),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingMD,
                            vertical: AppTheme.spacingSM + 4,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.accentSubtle
                                : isPaired
                                    ? AppTheme.surfaceElevated
                                    : AppTheme.surface,
                            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.accent
                                  : isPaired
                                      ? AppTheme.correct.withOpacity(0.5)
                                      : AppTheme.border,
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item.text,
                                style: TextStyle(
                                  color: isSelected ? AppTheme.accent : AppTheme.primary,
                                  fontWeight: isSelected || isPaired
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                              if (isPaired)
                                const Icon(Icons.check_circle_outline,
                                    size: 16, color: AppTheme.correct),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: AppTheme.spacingMD),
              // Right Column
              Expanded(
                child: Column(
                  children: widget.block.rightItems.map((item) {
                    final isPaired = _pairs.containsValue(item.id);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppTheme.spacingSM),
                      child: InkWell(
                        onTap: () => _onRightTap(item.id),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingMD,
                            vertical: AppTheme.spacingSM + 4,
                          ),
                          decoration: BoxDecoration(
                            color: isPaired ? AppTheme.surfaceElevated : AppTheme.surface,
                            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                            border: Border.all(
                              color: isPaired
                                  ? AppTheme.correct.withOpacity(0.5)
                                  : AppTheme.border,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item.text,
                                style: TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: isPaired ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                              if (isPaired)
                                const Icon(Icons.link_rounded, size: 16, color: AppTheme.correct),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
