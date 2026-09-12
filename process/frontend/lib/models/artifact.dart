import 'content_block.dart';
import 'input_block.dart';
import 'feedback_model.dart';

/// The top-level UI Artifact received from the Gemini loop agent.
class Artifact {
  final String artifactId;
  final int turnNumber;
  final String sessionId;
  final String skill; // reading, writing, listening, speaking
  final String level; // A1, A2, B1, B2, C1, C2
  final String targetLanguage;
  final String baseLanguage;
  final String topic;
  final String? grammarFocus;
  final String mode; // exercise, feedback, summary, onboarding
  final String? agentMessage; // Conversational chatbot tutor message
  final List<ContentBlock> content;
  final List<InputBlock> inputs;
  final FeedbackModel? feedback;
  final Map<String, dynamic> metadata;

  const Artifact({
    required this.artifactId,
    required this.turnNumber,
    required this.sessionId,
    required this.skill,
    required this.level,
    required this.targetLanguage,
    required this.baseLanguage,
    required this.topic,
    this.grammarFocus,
    this.mode = 'exercise',
    this.agentMessage,
    this.content = const [],
    this.inputs = const [],
    this.feedback,
    this.metadata = const {},
  });

  factory Artifact.fromJson(Map<String, dynamic> json) {
    final rawContent = json['content'] as List<dynamic>? ?? [];
    final rawInputs = json['inputs'] as List<dynamic>? ?? [];

    return Artifact(
      artifactId: json['artifact_id'] as String? ?? 'art_${DateTime.now().millisecondsSinceEpoch}',
      turnNumber: json['turn_number'] as int? ?? 1,
      sessionId: json['session_id'] as String? ?? 'sess_default',
      skill: json['skill'] as String? ?? 'reading',
      level: json['level'] as String? ?? 'A1',
      targetLanguage: json['target_language'] as String? ?? 'no',
      baseLanguage: json['base_language'] as String? ?? 'en',
      topic: json['topic'] as String? ?? 'General',
      grammarFocus: json['grammar_focus'] as String?,
      mode: json['mode'] as String? ?? 'exercise',
      agentMessage: json['agent_message'] as String? ?? json['tutor_message'] as String?,
      content: rawContent
          .map((c) => ContentBlock.fromJson(c as Map<String, dynamic>))
          .toList(),
      inputs: rawInputs
          .map((i) => InputBlock.fromJson(i as Map<String, dynamic>))
          .toList(),
      feedback: json['feedback'] != null && (json['feedback'] as Map).isNotEmpty
          ? FeedbackModel.fromJson(json['feedback'] as Map<String, dynamic>)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() => {
    'artifact_id': artifactId,
    'turn_number': turnNumber,
    'session_id': sessionId,
    'skill': skill,
    'level': level,
    'target_language': targetLanguage,
    'base_language': baseLanguage,
    'topic': topic,
    if (grammarFocus != null) 'grammar_focus': grammarFocus,
    'mode': mode,
    if (agentMessage != null) 'agent_message': agentMessage,
    'content': content.map((c) => c.toJson()).toList(),
    'inputs': inputs.map((i) => i.toJson()).toList(),
    if (feedback != null) 'feedback': feedback!.toJson(),
    'metadata': metadata,
  };

  int get currentProgress => (metadata['progress']?['current'] as int?) ?? turnNumber;
  int get totalProgress => (metadata['progress']?['total'] as int?) ?? 10;
  bool get isDrill => (metadata['is_drill'] as bool?) ?? false;
}
