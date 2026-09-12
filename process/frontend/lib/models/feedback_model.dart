/// Feedback model returned by loop agent evaluator and root cause analyzer.
class CorrectionItem {
  final String inputId;
  final String? blankId;
  final dynamic userAnswer;
  final dynamic correctAnswer;
  final String explanation;

  const CorrectionItem({
    required this.inputId,
    this.blankId,
    this.userAnswer,
    this.correctAnswer,
    required this.explanation,
  });

  factory CorrectionItem.fromJson(Map<String, dynamic> json) {
    return CorrectionItem(
      inputId: json['input_id'] as String? ?? '',
      blankId: json['blank_id'] as String?,
      userAnswer: json['user_answer'],
      correctAnswer: json['correct_answer'],
      explanation: json['explanation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'input_id': inputId,
    if (blankId != null) 'blank_id': blankId,
    if (userAnswer != null) 'user_answer': userAnswer,
    if (correctAnswer != null) 'correct_answer': correctAnswer,
    'explanation': explanation,
  };
}

class RootCause {
  final String category; // surface_typo | grammar_rule | vocabulary_gap | comprehension | pattern_confusion | pronunciation
  final String severity; // 'surface' | 'deep'
  final String explanation;
  final String underlyingConcept;
  final bool willDrill;

  const RootCause({
    required this.category,
    required this.severity,
    required this.explanation,
    required this.underlyingConcept,
    this.willDrill = false,
  });

  factory RootCause.fromJson(Map<String, dynamic> json) {
    return RootCause(
      category: json['category'] as String? ?? 'grammar_rule',
      severity: json['severity'] as String? ?? 'surface',
      explanation: json['explanation'] as String? ?? '',
      underlyingConcept: json['underlying_concept'] as String? ?? '',
      willDrill: json['will_drill'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'category': category,
    'severity': severity,
    'explanation': explanation,
    'underlying_concept': underlyingConcept,
    'will_drill': willDrill,
  };

  bool get isDeep => severity == 'deep';
}

class LevelAssessment {
  final String current;
  final String trend; // 'improving' | 'stable' | 'declining'
  final bool readyForNext;

  const LevelAssessment({
    required this.current,
    this.trend = 'stable',
    this.readyForNext = false,
  });

  factory LevelAssessment.fromJson(Map<String, dynamic> json) {
    return LevelAssessment(
      current: json['current'] as String? ?? 'A1',
      trend: json['trend'] as String? ?? 'stable',
      readyForNext: json['ready_for_next'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'current': current,
    'trend': trend,
    'ready_for_next': readyForNext,
  };
}

class FeedbackModel {
  final String overall; // 'correct' | 'partial' | 'incorrect'
  final double score;
  final String message;
  final List<CorrectionItem> corrections;
  final RootCause? rootCause;
  final String? encouragement;
  final LevelAssessment? levelAssessment;

  const FeedbackModel({
    required this.overall,
    this.score = 0.0,
    required this.message,
    this.corrections = const [],
    this.rootCause,
    this.encouragement,
    this.levelAssessment,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    final rawCorrections = json['corrections'] as List<dynamic>? ?? [];
    return FeedbackModel(
      overall: json['overall'] as String? ?? 'correct',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      message: json['message'] as String? ?? '',
      corrections: rawCorrections
          .map((c) => CorrectionItem.fromJson(c as Map<String, dynamic>))
          .toList(),
      rootCause: json['root_cause'] != null
          ? RootCause.fromJson(json['root_cause'] as Map<String, dynamic>)
          : null,
      encouragement: json['encouragement'] as String?,
      levelAssessment: json['level_assessment'] != null
          ? LevelAssessment.fromJson(json['level_assessment'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'overall': overall,
    'score': score,
    'message': message,
    'corrections': corrections.map((c) => c.toJson()).toList(),
    if (rootCause != null) 'root_cause': rootCause!.toJson(),
    if (encouragement != null) 'encouragement': encouragement,
    if (levelAssessment != null) 'level_assessment': levelAssessment!.toJson(),
  };

  bool get isCorrect => overall == 'correct';
  bool get isPartial => overall == 'partial';
  bool get isIncorrect => overall == 'incorrect';
}
