/// Envelope sent from Frontend to Backend containing collected user responses.
class InputResponse {
  final String inputId;
  final String type;
  final dynamic value;
  final String? audioUrl;
  final double? durationSeconds;

  const InputResponse({
    required this.inputId,
    required this.type,
    this.value,
    this.audioUrl,
    this.durationSeconds,
  });

  Map<String, dynamic> toJson() => {
    'input_id': inputId,
    'type': type,
    if (value != null) 'value': value,
    if (audioUrl != null) 'audio_url': audioUrl,
    if (durationSeconds != null) 'duration_seconds': durationSeconds,
  };
}

class UserResponse {
  final String sessionId;
  final String artifactId;
  final int turnNumber;
  final String timestamp;
  final List<InputResponse> responses;
  final Map<String, dynamic> clientMetadata;

  const UserResponse({
    required this.sessionId,
    required this.artifactId,
    required this.turnNumber,
    required this.timestamp,
    required this.responses,
    this.clientMetadata = const {},
  });

  Map<String, dynamic> toJson() => {
    'session_id': sessionId,
    'artifact_id': artifactId,
    'turn_number': turnNumber,
    'timestamp': timestamp,
    'responses': responses.map((r) => r.toJson()).toList(),
    'client_metadata': clientMetadata,
  };
}
