/// Sealed class hierarchy for Content Blocks rendered on the main stage.
abstract class ContentBlock {
  final String type;
  final String id;

  const ContentBlock({required this.type, required this.id});

  factory ContentBlock.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? 'text';
    final id = json['id'] as String? ?? 'content_${DateTime.now().millisecondsSinceEpoch}';

    switch (type) {
      case 'text':
        return TextContentBlock.fromJson(json);
      case 'rich_text':
        return RichTextContentBlock.fromJson(json);
      case 'audio':
        return AudioContentBlock.fromJson(json);
      case 'image':
        return ImageContentBlock.fromJson(json);
      case 'vocabulary_grid':
        return VocabularyGridContentBlock.fromJson(json);
      case 'dialogue':
        return DialogueContentBlock.fromJson(json);
      case 'conjugation_table':
        return ConjugationTableContentBlock.fromJson(json);
      default:
        return TextContentBlock(
          id: id,
          text: json['text'] as String? ?? json.toString(),
          style: 'instruction',
        );
    }
  }

  Map<String, dynamic> toJson();
}

class TextContentBlock extends ContentBlock {
  final String text;
  final String style; // 'instruction' | 'passage' | 'heading' | 'hint' | 'explanation'
  final String? language;

  const TextContentBlock({
    required super.id,
    required this.text,
    this.style = 'instruction',
    this.language,
  }) : super(type: 'text');

  factory TextContentBlock.fromJson(Map<String, dynamic> json) {
    return TextContentBlock(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      style: json['style'] as String? ?? 'instruction',
      language: json['language'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'text': text,
    'style': style,
    if (language != null) 'language': language,
  };
}

class RichTextSegment {
  final String text;
  final String style; // 'normal' | 'blank' | 'highlight' | 'bold'
  final String? blankId;

  const RichTextSegment({
    required this.text,
    this.style = 'normal',
    this.blankId,
  });

  factory RichTextSegment.fromJson(Map<String, dynamic> json) {
    return RichTextSegment(
      text: json['text'] as String? ?? '',
      style: json['style'] as String? ?? 'normal',
      blankId: json['blank_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'text': text,
    'style': style,
    if (blankId != null) 'blank_id': blankId,
  };
}

class RichTextContentBlock extends ContentBlock {
  final List<RichTextSegment> segments;
  final String? language;

  const RichTextContentBlock({
    required super.id,
    required this.segments,
    this.language,
  }) : super(type: 'rich_text');

  factory RichTextContentBlock.fromJson(Map<String, dynamic> json) {
    final rawSegments = json['segments'] as List<dynamic>? ?? [];
    return RichTextContentBlock(
      id: json['id'] as String? ?? '',
      segments: rawSegments
          .map((s) => RichTextSegment.fromJson(s as Map<String, dynamic>))
          .toList(),
      language: json['language'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'segments': segments.map((s) => s.toJson()).toList(),
    if (language != null) 'language': language,
  };
}

class AudioContentBlock extends ContentBlock {
  final String url;
  final int durationSeconds;
  final List<double> playbackSpeedOptions;
  final int maxPlays;
  final bool transcriptHidden;
  final String? transcript;

  const AudioContentBlock({
    required super.id,
    required this.url,
    this.durationSeconds = 15,
    this.playbackSpeedOptions = const [0.75, 1.0, 1.25],
    this.maxPlays = 3,
    this.transcriptHidden = true,
    this.transcript,
  }) : super(type: 'audio');

  factory AudioContentBlock.fromJson(Map<String, dynamic> json) {
    final speeds = (json['playback_speed_options'] as List<dynamic>?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        [0.75, 1.0, 1.25];

    return AudioContentBlock(
      id: json['id'] as String? ?? '',
      url: json['url'] as String? ?? '',
      durationSeconds: json['duration_seconds'] as int? ?? 15,
      playbackSpeedOptions: speeds,
      maxPlays: json['max_plays'] as int? ?? 3,
      transcriptHidden: json['transcript_hidden'] as bool? ?? true,
      transcript: json['transcript'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'url': url,
    'duration_seconds': durationSeconds,
    'playback_speed_options': playbackSpeedOptions,
    'max_plays': maxPlays,
    'transcript_hidden': transcriptHidden,
    if (transcript != null) 'transcript': transcript,
  };
}

class ImageContentBlock extends ContentBlock {
  final String url;
  final String? altText;
  final String? caption;

  const ImageContentBlock({
    required super.id,
    required this.url,
    this.altText,
    this.caption,
  }) : super(type: 'image');

  factory ImageContentBlock.fromJson(Map<String, dynamic> json) {
    return ImageContentBlock(
      id: json['id'] as String? ?? '',
      url: json['url'] as String? ?? '',
      altText: json['alt_text'] as String?,
      caption: json['caption'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'url': url,
    if (altText != null) 'alt_text': altText,
    if (caption != null) 'caption': caption,
  };
}

class VocabularyWord {
  final String word;
  final String translation;
  final String? phonetic;
  final String? imageUrl;

  const VocabularyWord({
    required this.word,
    required this.translation,
    this.phonetic,
    this.imageUrl,
  });

  factory VocabularyWord.fromJson(Map<String, dynamic> json) {
    return VocabularyWord(
      word: json['word'] as String? ?? '',
      translation: json['translation'] as String? ?? '',
      phonetic: json['phonetic'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'word': word,
    'translation': translation,
    if (phonetic != null) 'phonetic': phonetic,
    if (imageUrl != null) 'image_url': imageUrl,
  };
}

class VocabularyGridContentBlock extends ContentBlock {
  final List<VocabularyWord> words;

  const VocabularyGridContentBlock({
    required super.id,
    required this.words,
  }) : super(type: 'vocabulary_grid');

  factory VocabularyGridContentBlock.fromJson(Map<String, dynamic> json) {
    final rawWords = json['words'] as List<dynamic>? ?? [];
    return VocabularyGridContentBlock(
      id: json['id'] as String? ?? '',
      words: rawWords
          .map((w) => VocabularyWord.fromJson(w as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'words': words.map((w) => w.toJson()).toList(),
  };
}

class DialogueSpeaker {
  final String id;
  final String name;
  final String? avatar;

  const DialogueSpeaker({
    required this.id,
    required this.name,
    this.avatar,
  });

  factory DialogueSpeaker.fromJson(Map<String, dynamic> json) {
    return DialogueSpeaker(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      avatar: json['avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (avatar != null) 'avatar': avatar,
  };
}

class DialogueLine {
  final String speaker;
  final String text;
  final bool isBlank;
  final String? blankId;
  final String? audioUrl;

  const DialogueLine({
    required this.speaker,
    required this.text,
    this.isBlank = false,
    this.blankId,
    this.audioUrl,
  });

  factory DialogueLine.fromJson(Map<String, dynamic> json) {
    return DialogueLine(
      speaker: json['speaker'] as String? ?? '',
      text: json['text'] as String? ?? '',
      isBlank: json['is_blank'] as bool? ?? false,
      blankId: json['blank_id'] as String?,
      audioUrl: json['audio_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'speaker': speaker,
    'text': text,
    'is_blank': isBlank,
    if (blankId != null) 'blank_id': blankId,
    if (audioUrl != null) 'audio_url': audioUrl,
  };
}

class DialogueContentBlock extends ContentBlock {
  final List<DialogueSpeaker> speakers;
  final List<DialogueLine> lines;

  const DialogueContentBlock({
    required super.id,
    required this.speakers,
    required this.lines,
  }) : super(type: 'dialogue');

  factory DialogueContentBlock.fromJson(Map<String, dynamic> json) {
    final rawSpeakers = json['speakers'] as List<dynamic>? ?? [];
    final rawLines = json['lines'] as List<dynamic>? ?? [];

    return DialogueContentBlock(
      id: json['id'] as String? ?? '',
      speakers: rawSpeakers
          .map((s) => DialogueSpeaker.fromJson(s as Map<String, dynamic>))
          .toList(),
      lines: rawLines
          .map((l) => DialogueLine.fromJson(l as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'speakers': speakers.map((s) => s.toJson()).toList(),
    'lines': lines.map((l) => l.toJson()).toList(),
  };
}

class ConjugationRow {
  final String pronoun;
  final String form;
  final bool revealed;
  final String? blankId;

  const ConjugationRow({
    required this.pronoun,
    required this.form,
    this.revealed = true,
    this.blankId,
  });

  factory ConjugationRow.fromJson(Map<String, dynamic> json) {
    return ConjugationRow(
      pronoun: json['pronoun'] as String? ?? '',
      form: json['form'] as String? ?? '',
      revealed: json['revealed'] as bool? ?? true,
      blankId: json['blank_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'pronoun': pronoun,
    'form': form,
    'revealed': revealed,
    if (blankId != null) 'blank_id': blankId,
  };
}

class ConjugationTableContentBlock extends ContentBlock {
  final String verb;
  final String tense;
  final List<ConjugationRow> rows;

  const ConjugationTableContentBlock({
    required super.id,
    required this.verb,
    required this.tense,
    required this.rows,
  }) : super(type: 'conjugation_table');

  factory ConjugationTableContentBlock.fromJson(Map<String, dynamic> json) {
    final rawRows = json['rows'] as List<dynamic>? ?? [];
    return ConjugationTableContentBlock(
      id: json['id'] as String? ?? '',
      verb: json['verb'] as String? ?? '',
      tense: json['tense'] as String? ?? '',
      rows: rawRows
          .map((r) => ConjugationRow.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'verb': verb,
    'tense': tense,
    'rows': rows.map((r) => r.toJson()).toList(),
  };
}
