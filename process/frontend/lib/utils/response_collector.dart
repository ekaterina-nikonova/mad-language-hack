import 'package:flutter/foundation.dart';
import '../models/user_response.dart';

/// Centralized response accumulator.
/// Each input widget registers its response here via [setResponse].
/// On submit, [buildUserResponse] packages everything into the User Response Envelope.
class ResponseCollector extends ChangeNotifier {
  final String sessionId;
  final String artifactId;
  final int turnNumber;
  final Set<String> requiredInputIds;
  final Stopwatch _stopwatch = Stopwatch();

  final Map<String, InputResponse> _responses = {};
  bool _hintUsed = false;
  int _audioPlays = 0;

  ResponseCollector({
    required this.sessionId,
    required this.artifactId,
    required this.turnNumber,
    required Set<String> requiredInputs,
  }) : requiredInputIds = Set.from(requiredInputs) {
    _stopwatch.start();
  }

  void setResponse(
    String inputId,
    String type,
    dynamic value, {
    String? audioUrl,
    double? durationSeconds,
  }) {
    _responses[inputId] = InputResponse(
      inputId: inputId,
      type: type,
      value: value,
      audioUrl: audioUrl,
      durationSeconds: durationSeconds,
    );
    notifyListeners();
  }

  dynamic getResponse(String inputId) {
    return _responses[inputId]?.value;
  }

  void markHintUsed() {
    _hintUsed = true;
    notifyListeners();
  }

  void incrementAudioPlays() {
    _audioPlays++;
    notifyListeners();
  }

  bool get hintUsed => _hintUsed;
  int get audioPlays => _audioPlays;

  bool get isComplete {
    if (requiredInputIds.isEmpty) return true;
    for (final id in requiredInputIds) {
      final resp = _responses[id];
      if (resp == null) return false;
      if (resp.value == null && resp.audioUrl == null) return false;
      if (resp.value is String && (resp.value as String).trim().isEmpty) return false;
      if (resp.value is List && (resp.value as List).isEmpty) return false;
      if (resp.value is Map && (resp.value as Map).isEmpty) return false;
    }
    return true;
  }

  UserResponse buildUserResponse() {
    _stopwatch.stop();
    return UserResponse(
      sessionId: sessionId,
      artifactId: artifactId,
      turnNumber: turnNumber,
      timestamp: DateTime.now().toUtc().toIso8601String(),
      responses: _responses.values.toList(),
      clientMetadata: {
        'time_taken_seconds': _stopwatch.elapsed.inSeconds,
        'hint_used': _hintUsed,
        'audio_plays': _audioPlays,
      },
    );
  }
}
