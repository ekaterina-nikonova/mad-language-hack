import 'package:flutter/material.dart';
import '../models/content_block.dart';
import '../models/input_block.dart';
import 'response_collector.dart';

// Content widgets
import '../widgets/content/text_block_widget.dart';
import '../widgets/content/rich_text_block_widget.dart';
import '../widgets/content/audio_block_widget.dart';
import '../widgets/content/image_block_widget.dart';
import '../widgets/content/vocabulary_grid_widget.dart';
import '../widgets/content/dialogue_block_widget.dart';
import '../widgets/content/conjugation_table_widget.dart';

// Input widgets
import '../widgets/input/multiple_choice_widget.dart';
import '../widgets/input/free_text_widget.dart';
import '../widgets/input/fill_blanks_widget.dart';
import '../widgets/input/audio_recorder_widget.dart';
import '../widgets/input/dropdown_widget.dart';
import '../widgets/input/slider_widget.dart';
import '../widgets/input/reorder_widget.dart';
import '../widgets/input/matching_widget.dart';
import '../widgets/input/boolean_widget.dart';

/// The core Generative UI Registry that maps JSON type identifiers
/// to concrete Flutter components.
class WidgetRegistry {
  static final Map<String, Widget Function(ContentBlock, ResponseCollector?)> _contentBuilders = {
    'text': (block, _) => TextBlockWidget(key: ValueKey(block.id), block: block as TextContentBlock),
    'rich_text': (block, _) => RichTextBlockWidget(key: ValueKey(block.id), block: block as RichTextContentBlock),
    'audio': (block, collector) => AudioBlockWidget(
          key: ValueKey(block.id),
          block: block as AudioContentBlock,
          collector: collector,
        ),
    'image': (block, _) => ImageBlockWidget(key: ValueKey(block.id), block: block as ImageContentBlock),
    'vocabulary_grid': (block, _) => VocabularyGridWidget(key: ValueKey(block.id), block: block as VocabularyGridContentBlock),
    'dialogue': (block, _) => DialogueBlockWidget(key: ValueKey(block.id), block: block as DialogueContentBlock),
    'conjugation_table': (block, _) => ConjugationTableWidget(key: ValueKey(block.id), block: block as ConjugationTableContentBlock),
  };

  static final Map<String, Widget Function(InputBlock, ResponseCollector)> _inputBuilders = {
    'multiple_choice': (block, collector) => MultipleChoiceWidget(
          key: ValueKey(block.id),
          block: block as MultipleChoiceInputBlock,
          collector: collector,
        ),
    'free_text': (block, collector) => FreeTextWidget(
          key: ValueKey(block.id),
          block: block as FreeTextInputBlock,
          collector: collector,
        ),
    'fill_blanks': (block, collector) => FillBlanksWidget(
          key: ValueKey(block.id),
          block: block as FillBlanksInputBlock,
          collector: collector,
        ),
    'audio_recorder': (block, collector) => AudioRecorderWidget(
          key: ValueKey(block.id),
          block: block as AudioRecorderInputBlock,
          collector: collector,
        ),
    'dropdown': (block, collector) => DropdownWidget(
          key: ValueKey(block.id),
          block: block as DropdownInputBlock,
          collector: collector,
        ),
    'slider': (block, collector) => SliderWidget(
          key: ValueKey(block.id),
          block: block as SliderInputBlock,
          collector: collector,
        ),
    'reorder': (block, collector) => ReorderWidget(
          key: ValueKey(block.id),
          block: block as ReorderInputBlock,
          collector: collector,
        ),
    'matching': (block, collector) => MatchingWidget(
          key: ValueKey(block.id),
          block: block as MatchingInputBlock,
          collector: collector,
        ),
    'boolean': (block, collector) => BooleanWidget(
          key: ValueKey(block.id),
          block: block as BooleanInputBlock,
          collector: collector,
        ),
  };

  static Widget buildContent(ContentBlock block, {ResponseCollector? collector}) {
    final builder = _contentBuilders[block.type];
    if (builder != null) {
      return builder(block, collector);
    }
    // Fallback: render text block with json dump
    return TextBlockWidget(
      block: TextContentBlock(
        id: block.id,
        text: 'Unknown content type: ${block.type}',
        style: 'explanation',
      ),
    );
  }

  static Widget buildInput(InputBlock block, ResponseCollector collector) {
    final builder = _inputBuilders[block.type];
    if (builder != null) {
      return builder(block, collector);
    }
    // Fallback: render free text block
    return FreeTextWidget(
      block: FreeTextInputBlock(
        id: block.id,
        placeholder: 'Response for ${block.type}...',
      ),
      collector: collector,
    );
  }
}
