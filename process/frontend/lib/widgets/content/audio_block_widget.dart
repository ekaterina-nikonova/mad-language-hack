import 'dart:async';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/content_block.dart';
import '../../utils/response_collector.dart';

class AudioBlockWidget extends StatefulWidget {
  final AudioContentBlock block;
  final ResponseCollector? collector;

  const AudioBlockWidget({
    super.key,
    required this.block,
    this.collector,
  });

  factory AudioBlockWidget.fromJson(
    Map<String, dynamic> json, {
    ResponseCollector? collector,
  }) {
    return AudioBlockWidget(
      block: AudioContentBlock.fromJson(json),
      collector: collector,
    );
  }

  @override
  State<AudioBlockWidget> createState() => _AudioBlockWidgetState();
}

class _AudioBlockWidgetState extends State<AudioBlockWidget>
    with SingleTickerProviderStateMixin {
  bool _isPlaying = false;
  int _playsCount = 0;
  double _currentSpeed = 1.0;
  bool _showTranscript = false;
  double _progress = 0.0;
  Timer? _playbackTimer;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _showTranscript = !widget.block.transcriptHidden;
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    _waveController.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_isPlaying) {
      _stopPlayback();
    } else {
      if (_playsCount >= widget.block.maxPlays) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Maximum plays (${widget.block.maxPlays}) reached for this exercise'),
            backgroundColor: AppTheme.surfaceElevated,
          ),
        );
        return;
      }
      _startPlayback();
    }
  }

  void _startPlayback() {
    setState(() {
      _isPlaying = true;
      _playsCount++;
      _progress = 0.0;
    });
    widget.collector?.incrementAudioPlays();

    const stepDurationMs = 100;
    final totalSteps = (widget.block.durationSeconds * 1000 / _currentSpeed) / stepDurationMs;

    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(Duration(milliseconds: stepDurationMs), (timer) {
      if (!mounted) return;
      setState(() {
        _progress += 1.0 / totalSteps;
        if (_progress >= 1.0) {
          _progress = 1.0;
          _stopPlayback();
        }
      });
    });
  }

  void _stopPlayback() {
    _playbackTimer?.cancel();
    setState(() {
      _isPlaying = false;
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
              // Play/Pause button
              GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _isPlaying ? AppTheme.accent : AppTheme.surfaceElevated,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.accent,
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: _isPlaying ? AppTheme.background : AppTheme.accent,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingMD),

              // Animated Waveform
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 36,
                      child: AnimatedBuilder(
                        animation: _waveController,
                        builder: (context, _) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(24, (index) {
                              final waveOffset = (index * 0.15);
                              final heightFactor = _isPlaying
                                  ? (0.2 + 0.8 * ((_waveController.value + waveOffset) % 1.0))
                                  : 0.25;
                              final isPlayed = (index / 24) <= _progress;

                              return Container(
                                width: 3,
                                height: 32 * heightFactor,
                                decoration: BoxDecoration(
                                  color: isPlayed ? AppTheme.accent : AppTheme.border,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              );
                            }),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingXS),
                    LinearProgressIndicator(
                      value: _progress,
                      backgroundColor: AppTheme.surfaceElevated,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
                      minHeight: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingMD),

          // Controls and metadata row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Play count badge
              Row(
                children: [
                  const Icon(Icons.headphones_outlined, size: 16, color: AppTheme.secondary),
                  const SizedBox(width: 4),
                  Text(
                    'Plays: $_playsCount / ${widget.block.maxPlays}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.secondary,
                          fontSize: 12,
                        ),
                  ),
                ],
              ),

              // Speed selector chips
              Row(
                children: widget.block.playbackSpeedOptions.map((speed) {
                  final isSelected = (_currentSpeed - speed).abs() < 0.01;
                  return Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _currentSpeed = speed;
                        });
                      },
                      borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.accentSubtle : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                          border: Border.all(
                            color: isSelected ? AppTheme.accent : AppTheme.border,
                          ),
                        ),
                        child: Text(
                          '${speed}x',
                          style: TextStyle(
                            color: isSelected ? AppTheme.accent : AppTheme.secondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              // Transcript toggle button (if transcript exists)
              if (widget.block.transcript != null)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showTranscript = !_showTranscript;
                    });
                  },
                  icon: Icon(
                    _showTranscript ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 14,
                    color: AppTheme.secondary,
                  ),
                  label: Text(
                    _showTranscript ? 'Hide' : 'Transcript',
                    style: const TextStyle(fontSize: 12, color: AppTheme.secondary),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                  ),
                ),
            ],
          ),

          // Revealed transcript
          if (_showTranscript && widget.block.transcript != null) ...[
            const SizedBox(height: AppTheme.spacingMD),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacingMD),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TRANSCRIPT',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.0,
                      color: AppTheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.block.transcript!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.primary,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
