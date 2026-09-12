/// Sealed class hierarchy for Input Blocks rendered on the interactive stage.
abstract class InputBlock {
  final String type;
  final String id;

  const InputBlock({required this.type, required this.id});

  factory InputBlock.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? 'multiple_choice';
    final id = json['id'] as String? ?? 'input_${DateTime.now().millisecondsSinceEpoch}';

    switch (type) {
      case 'multiple_choice':
        return MultipleChoiceInputBlock.fromJson(json);
      case 'free_text':
        return FreeTextInputBlock.fromJson(json);
      case 'fill_blanks':
        return FillBlanksInputBlock.fromJson(json);
      case 'audio_recorder':
        return AudioRecorderInputBlock.fromJson(json);
      case 'dropdown':
        return DropdownInputBlock.fromJson(json);
      case 'slider':
        return SliderInputBlock.fromJson(json);
      case 'reorder':
        return ReorderInputBlock.fromJson(json);
      case 'matching':
        return MatchingInputBlock.fromJson(json);
      case 'boolean':
        return BooleanInputBlock.fromJson(json);
      default:
        return FreeTextInputBlock(
          id: id,
          placeholder: 'Provide your response...',
        );
    }
  }

  Map<String, dynamic> toJson();
}

class MultipleChoiceOption {
  final String id;
  final String text;
  final String? label; // e.g. "A", "B", "C"

  const MultipleChoiceOption({
    required this.id,
    required this.text,
    this.label,
  });

  factory MultipleChoiceOption.fromJson(Map<String, dynamic> json) {
    return MultipleChoiceOption(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      label: json['label'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    if (label != null) 'label': label,
  };
}

class MultipleChoiceInputBlock extends InputBlock {
  final String? question;
  final List<MultipleChoiceOption> options;
  final bool allowMultiple;

  const MultipleChoiceInputBlock({
    required super.id,
    this.question,
    required this.options,
    this.allowMultiple = false,
  }) : super(type: 'multiple_choice');

  factory MultipleChoiceInputBlock.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'] as List<dynamic>? ?? [];
    return MultipleChoiceInputBlock(
      id: json['id'] as String? ?? '',
      question: json['question'] as String?,
      options: rawOptions
          .map((o) => MultipleChoiceOption.fromJson(o as Map<String, dynamic>))
          .toList(),
      allowMultiple: json['allow_multiple'] as bool? ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    if (question != null) 'question': question,
    'options': options.map((o) => o.toJson()).toList(),
    'allow_multiple': allowMultiple,
  };
}

class FreeTextInputBlock extends InputBlock {
  final String? placeholder;
  final int maxLength;
  final int minLength;
  final String? language;
  final int lines;

  const FreeTextInputBlock({
    required super.id,
    this.placeholder,
    this.maxLength = 500,
    this.minLength = 0,
    this.language,
    this.lines = 3,
  }) : super(type: 'free_text');

  factory FreeTextInputBlock.fromJson(Map<String, dynamic> json) {
    return FreeTextInputBlock(
      id: json['id'] as String? ?? '',
      placeholder: json['placeholder'] as String?,
      maxLength: json['max_length'] as int? ?? 500,
      minLength: json['min_length'] as int? ?? 0,
      language: json['language'] as String?,
      lines: json['lines'] as int? ?? 3,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    if (placeholder != null) 'placeholder': placeholder,
    'max_length': maxLength,
    'min_length': minLength,
    if (language != null) 'language': language,
    'lines': lines,
  };
}

class BlankItem {
  final String blankId;
  final String? hint;
  final int maxLength;

  const BlankItem({
    required this.blankId,
    this.hint,
    this.maxLength = 20,
  });

  factory BlankItem.fromJson(Map<String, dynamic> json) {
    return BlankItem(
      blankId: json['blank_id'] as String? ?? '',
      hint: json['hint'] as String?,
      maxLength: json['max_length'] as int? ?? 20,
    );
  }

  Map<String, dynamic> toJson() => {
    'blank_id': blankId,
    if (hint != null) 'hint': hint,
    'max_length': maxLength,
  };
}

class FillBlanksInputBlock extends InputBlock {
  final List<BlankItem> blanks;

  const FillBlanksInputBlock({
    required super.id,
    required this.blanks,
  }) : super(type: 'fill_blanks');

  factory FillBlanksInputBlock.fromJson(Map<String, dynamic> json) {
    final rawBlanks = json['blanks'] as List<dynamic>? ?? [];
    return FillBlanksInputBlock(
      id: json['id'] as String? ?? '',
      blanks: rawBlanks
          .map((b) => BlankItem.fromJson(b as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'blanks': blanks.map((b) => b.toJson()).toList(),
  };
}

class AudioRecorderInputBlock extends InputBlock {
  final String prompt;
  final String? referenceText;
  final int maxDurationSeconds;
  final bool allowReplay;

  const AudioRecorderInputBlock({
    required super.id,
    required this.prompt,
    this.referenceText,
    this.maxDurationSeconds = 30,
    this.allowReplay = true,
  }) : super(type: 'audio_recorder');

  factory AudioRecorderInputBlock.fromJson(Map<String, dynamic> json) {
    return AudioRecorderInputBlock(
      id: json['id'] as String? ?? '',
      prompt: json['prompt'] as String? ?? 'Record your voice:',
      referenceText: json['reference_text'] as String?,
      maxDurationSeconds: json['max_duration_seconds'] as int? ?? 30,
      allowReplay: json['allow_replay'] as bool? ?? true,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'prompt': prompt,
    if (referenceText != null) 'reference_text': referenceText,
    'max_duration_seconds': maxDurationSeconds,
    'allow_replay': allowReplay,
  };
}

class DropdownOption {
  final String id;
  final String text;

  const DropdownOption({required this.id, required this.text});

  factory DropdownOption.fromJson(Map<String, dynamic> json) {
    return DropdownOption(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'text': text};
}

class DropdownInputBlock extends InputBlock {
  final String? label;
  final List<DropdownOption> options;

  const DropdownInputBlock({
    required super.id,
    this.label,
    required this.options,
  }) : super(type: 'dropdown');

  factory DropdownInputBlock.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'] as List<dynamic>? ?? [];
    return DropdownInputBlock(
      id: json['id'] as String? ?? '',
      label: json['label'] as String?,
      options: rawOptions
          .map((o) => DropdownOption.fromJson(o as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    if (label != null) 'label': label,
    'options': options.map((o) => o.toJson()).toList(),
  };
}

class SliderInputBlock extends InputBlock {
  final String label;
  final double min;
  final double max;
  final double step;
  final List<String> labels;
  final double defaultValue;

  const SliderInputBlock({
    required super.id,
    required this.label,
    this.min = 1.0,
    this.max = 5.0,
    this.step = 1.0,
    this.labels = const [],
    this.defaultValue = 3.0,
  }) : super(type: 'slider');

  factory SliderInputBlock.fromJson(Map<String, dynamic> json) {
    final rawLabels = (json['labels'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [];
    return SliderInputBlock(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      min: (json['min'] as num?)?.toDouble() ?? 1.0,
      max: (json['max'] as num?)?.toDouble() ?? 5.0,
      step: (json['step'] as num?)?.toDouble() ?? 1.0,
      labels: rawLabels,
      defaultValue: (json['default_value'] as num?)?.toDouble() ?? 3.0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'label': label,
    'min': min,
    'max': max,
    'step': step,
    'labels': labels,
    'default_value': defaultValue,
  };
}

class ReorderItem {
  final String id;
  final String text;

  const ReorderItem({required this.id, required this.text});

  factory ReorderItem.fromJson(Map<String, dynamic> json) {
    return ReorderItem(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'text': text};
}

class ReorderInputBlock extends InputBlock {
  final String? instruction;
  final List<ReorderItem> items;

  const ReorderInputBlock({
    required super.id,
    this.instruction,
    required this.items,
  }) : super(type: 'reorder');

  factory ReorderInputBlock.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return ReorderInputBlock(
      id: json['id'] as String? ?? '',
      instruction: json['instruction'] as String?,
      items: rawItems
          .map((i) => ReorderItem.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    if (instruction != null) 'instruction': instruction,
    'items': items.map((i) => i.toJson()).toList(),
  };
}

class MatchingItem {
  final String id;
  final String text;

  const MatchingItem({required this.id, required this.text});

  factory MatchingItem.fromJson(Map<String, dynamic> json) {
    return MatchingItem(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'text': text};
}

class MatchingInputBlock extends InputBlock {
  final String? instruction;
  final List<MatchingItem> leftItems;
  final List<MatchingItem> rightItems;

  const MatchingInputBlock({
    required super.id,
    this.instruction,
    required this.leftItems,
    required this.rightItems,
  }) : super(type: 'matching');

  factory MatchingInputBlock.fromJson(Map<String, dynamic> json) {
    final rawLeft = json['left_items'] as List<dynamic>? ?? [];
    final rawRight = json['right_items'] as List<dynamic>? ?? [];
    return MatchingInputBlock(
      id: json['id'] as String? ?? '',
      instruction: json['instruction'] as String?,
      leftItems: rawLeft
          .map((i) => MatchingItem.fromJson(i as Map<String, dynamic>))
          .toList(),
      rightItems: rawRight
          .map((i) => MatchingItem.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    if (instruction != null) 'instruction': instruction,
    'left_items': leftItems.map((i) => i.toJson()).toList(),
    'right_items': rightItems.map((i) => i.toJson()).toList(),
  };
}

class BooleanInputBlock extends InputBlock {
  final String statement;
  final List<String> labels;

  const BooleanInputBlock({
    required super.id,
    required this.statement,
    this.labels = const ['True', 'False'],
  }) : super(type: 'boolean');

  factory BooleanInputBlock.fromJson(Map<String, dynamic> json) {
    final rawLabels = (json['labels'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        ['True', 'False'];
    return BooleanInputBlock(
      id: json['id'] as String? ?? '',
      statement: json['statement'] as String? ?? '',
      labels: rawLabels,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'statement': statement,
    'labels': labels,
  };
}
