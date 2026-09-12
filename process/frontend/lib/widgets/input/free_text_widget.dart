import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/input_block.dart';
import '../../utils/response_collector.dart';

class FreeTextWidget extends StatefulWidget {
  final FreeTextInputBlock block;
  final ResponseCollector collector;

  const FreeTextWidget({
    super.key,
    required this.block,
    required this.collector,
  });

  factory FreeTextWidget.fromJson(
    Map<String, dynamic> json, {
    required ResponseCollector collector,
  }) {
    return FreeTextWidget(
      block: FreeTextInputBlock.fromJson(json),
      collector: collector,
    );
  }

  @override
  State<FreeTextWidget> createState() => _FreeTextWidgetState();
}

class _FreeTextWidgetState extends State<FreeTextWidget> {
  late final TextEditingController _controller;
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    final initialText = widget.collector.getResponse(widget.block.id) as String? ?? '';
    _controller = TextEditingController(text: initialText);
    _charCount = initialText.length;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() {
      _charCount = value.length;
    });
    widget.collector.setResponse(
      widget.block.id,
      'free_text',
      value,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUnderMin = widget.block.minLength > 0 && _charCount < widget.block.minLength;

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
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMD),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusLG),
              border: Border.all(
                color: isUnderMin && _charCount > 0 ? AppTheme.warning : AppTheme.border,
              ),
            ),
            child: TextField(
              controller: _controller,
              maxLines: widget.block.lines > 1 ? widget.block.lines : 1,
              maxLength: widget.block.maxLength,
              onChanged: _onChanged,
              style: const TextStyle(
                color: AppTheme.primary,
                fontSize: 15,
                height: 1.5,
              ),
              decoration: InputDecoration(
                hintText: widget.block.placeholder ?? 'Type your answer here...',
                hintStyle: const TextStyle(color: AppTheme.secondary),
                border: InputBorder.none,
                counterText: '', // custom counter below
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (widget.block.minLength > 0)
                Text(
                  isUnderMin
                      ? 'Minimum ${widget.block.minLength} characters (need ${widget.block.minLength - _charCount} more)'
                      : 'Minimum requirement met',
                  style: TextStyle(
                    fontSize: 12,
                    color: isUnderMin && _charCount > 0 ? AppTheme.warning : AppTheme.secondary,
                  ),
                )
              else
                const SizedBox.shrink(),
              Text(
                '$_charCount / ${widget.block.maxLength}',
                style: const TextStyle(fontSize: 12, color: AppTheme.secondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
