import 'dart:async';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/input_block.dart';
import '../../utils/response_collector.dart';

class AudioRecorderWidget extends StatefulWidget {
  final AudioRecorderInputBlock block;
  final ResponseCollector collector;

  const AudioRecorderWidget({
    super.key,
    required this.block,
    required this.collector,
  });

  factory AudioRecorderWidget.fromJson(
    Map<String, dynamic> json, {
    required ResponseCollector collector,
  }) {
    return AudioRecorderWidget(
      block: AudioRecorderInputBlock.fromJson(json),
      collector: collector,
    );
  }

  @override
  State<AudioRecorderWidget> createState() => _AudioRecorderWidgetState();
}

class _AudioRecorderWidgetState extends State<AudioRecorderWidget>
    with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  bool _hasRecorded = false;
  bool _isPlayingBack = false;
  int _secondsRecorded = 0;
  Timer? _timer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleRecord() {
    if (_isRecording) {
      _stopRecording();
    } else {
      _startRecording();
    }
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _secondsRecorded = 0;
      _hasRecorded = false;
      _isPlayingBack = false;
    });
    _pulseController.repeat(reverse: true);

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _secondsRecorded++;
        if (_secondsRecorded >= widget.block.maxDurationSeconds) {
          _stopRecording();
        }
      });
    });
  }

  void _stopRecording() {
    _timer?.cancel();
    _pulseController.stop();
    _pulseController.reset();

    setState(() {
      _isRecording = false;
      _hasRecorded = true;
    });

    final audioUrl =
        'http://localhost:8000/media/${widget.collector.sessionId}/recording_turn_${widget.collector.turnNumber}.webm';

    widget.collector.setResponse(
      widget.block.id,
      'audio_recorder',
      audioUrl,
      audioUrl: audioUrl,
      durationSeconds: _secondsRecorded.toDouble(),
    );
  }

  void _togglePlayback() {
    if (!_hasRecorded) return;

    if (_isPlayingBack) {
      setState(() => _isPlayingBack = false);
    } else {
      setState(() => _isPlayingBack = true);
      Future.delayed(Duration(seconds: _secondsRecorded > 0 ? _secondsRecorded : 3), () {
        if (mounted) {
          setState(() => _isPlayingBack = false);
        }
      });
    }
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            widget.block.prompt,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
            textAlign: TextAlign.center,
          ),
          if (widget.block.referenceText != null) ...[
            const SizedBox(height: AppTheme.spacingMD),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingLG,
                vertical: AppTheme.spacingMD,
              ),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
              ),
              child: Text(
                '“${widget.block.referenceText!}”',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.accent,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          const SizedBox(height: AppTheme.spacingXL),

          // Pulsing mic button
          GestureDetector(
            onTap: _toggleRecord,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = _isRecording ? (1.0 + 0.12 * _pulseController.value) : 1.0;
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: _isRecording ? AppTheme.incorrect : AppTheme.accent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_isRecording ? AppTheme.incorrect : AppTheme.accent)
                              .withOpacity(0.4),
                          blurRadius: _isRecording ? 18 : 8,
                          spreadRadius: _isRecording ? 4 : 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                      color: AppTheme.background,
                      size: 38,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppTheme.spacingMD),

          // Timer & Status
          Text(
            _isRecording
                ? 'Recording: 00:${_secondsRecorded.toString().padLeft(2, '0')} / 00:${widget.block.maxDurationSeconds.toString().padLeft(2, '0')}'
                : _hasRecorded
                    ? 'Recording saved (00:${_secondsRecorded.toString().padLeft(2, '0')})'
                    : 'Tap microphone to start speaking',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _isRecording
                  ? AppTheme.incorrect
                  : _hasRecorded
                      ? AppTheme.correct
                      : AppTheme.secondary,
            ),
          ),

          if (_hasRecorded && widget.block.allowReplay) ...[
            const SizedBox(height: AppTheme.spacingMD),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: _togglePlayback,
                  icon: Icon(
                    _isPlayingBack ? Icons.stop_rounded : Icons.play_arrow_rounded,
                    size: 18,
                    color: AppTheme.primary,
                  ),
                  label: Text(
                    _isPlayingBack ? 'Stop' : 'Play back',
                    style: const TextStyle(color: AppTheme.primary),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSM),
                TextButton.icon(
                  onPressed: _startRecording,
                  icon: const Icon(Icons.refresh_rounded, size: 16, color: AppTheme.secondary),
                  label: const Text('Re-record', style: TextStyle(color: AppTheme.secondary)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
