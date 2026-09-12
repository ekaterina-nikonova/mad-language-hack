import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mad_language_frontend/models/artifact.dart';
import 'package:mad_language_frontend/models/content_block.dart';
import 'package:mad_language_frontend/models/input_block.dart';
import 'package:mad_language_frontend/models/feedback_model.dart';
import 'package:mad_language_frontend/utils/widget_registry.dart';
import 'package:mad_language_frontend/utils/response_collector.dart';
import 'package:mad_language_frontend/services/mock_data.dart';
import 'package:mad_language_frontend/widgets/artifact_renderer.dart';
import 'package:mad_language_frontend/widgets/feedback/root_cause_card.dart';

void main() {
  group('1. Model & Schema Validation', () {
    test('All MockDataService artifacts parse properly', () {
      expect(MockDataService.mockArtifactSequence.length, equals(7));
      for (final artifact in MockDataService.mockArtifactSequence) {
        expect(artifact.artifactId, isNotEmpty);
        expect(artifact.sessionId, isNotEmpty);
        expect(artifact.skill, isNotEmpty);
        expect(artifact.level, isNotEmpty);
      }
    });

    test('Root cause model parsing and deep drill detection', () {
      final json = {
        "category": "grammar_rule",
        "severity": "deep",
        "explanation": "Overgeneralized regular past tense to irregular verb",
        "underlying_concept": "Irregular verb preteritum",
        "will_drill": true
      };
      final rootCause = RootCause.fromJson(json);
      expect(rootCause.category, equals('grammar_rule'));
      expect(rootCause.severity, equals('deep'));
      expect(rootCause.isDeep, isTrue);
      expect(rootCause.willDrill, isTrue);
    });

    test('ResponseCollector gathers inputs and creates envelope', () {
      final collector = ResponseCollector(
        sessionId: 'test-sess',
        artifactId: 'test-art',
        turnNumber: 2,
        requiredInputs: {'input_1', 'input_2'},
      );

      expect(collector.isComplete, isFalse);

      collector.setResponse('input_1', 'multiple_choice', 'opt_b');
      expect(collector.isComplete, isFalse);

      collector.setResponse('input_2', 'free_text', 'Jeg gikk til butikken.');
      expect(collector.isComplete, isTrue);

      final envelope = collector.buildUserResponse();
      expect(envelope.sessionId, equals('test-sess'));
      expect(envelope.turnNumber, equals(2));
      expect(envelope.responses.length, equals(2));
      expect(envelope.responses[0].value, equals('opt_b'));
    });
  });

  group('2. Widget Registry & Rendering', () {
    testWidgets('Builds TextBlock and MultipleChoice block', (tester) async {
      final textBlock = TextContentBlock(
        id: 't1',
        text: 'Les denne teksten',
        style: 'instruction',
      );

      final inputBlock = MultipleChoiceInputBlock(
        id: 'mc1',
        question: 'Velg riktig svar:',
        options: const [
          MultipleChoiceOption(id: 'a', text: 'Option A', label: 'A'),
          MultipleChoiceOption(id: 'b', text: 'Option B', label: 'B'),
        ],
      );

      final collector = ResponseCollector(
        sessionId: 'sess',
        artifactId: 'art',
        turnNumber: 1,
        requiredInputs: {'mc1'},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                WidgetRegistry.buildContent(textBlock),
                WidgetRegistry.buildInput(inputBlock, collector),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Les denne teksten'), findsOneWidget);
      expect(find.text('Velg riktig svar:'), findsOneWidget);
      expect(find.text('Option A'), findsOneWidget);
      expect(find.text('Option B'), findsOneWidget);

      // Tap Option B
      await tester.tap(find.text('Option B'));
      await tester.pumpAndSettle();

      expect(collector.getResponse('mc1'), equals('b'));
      expect(collector.isComplete, isTrue);
    });

    testWidgets('Renders RootCauseCard with diagnosis details', (tester) async {
      const rootCause = RootCause(
        category: 'grammar_rule',
        severity: 'deep',
        explanation: 'Feil verbbøying i preteritum',
        underlyingConcept: 'Sterke verb med vokalskifte',
        willDrill: true,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RootCauseCard(rootCause: rootCause),
          ),
        ),
      );

      expect(find.text('ROOT CAUSE DIAGNOSIS'), findsOneWidget);
      expect(find.text('GRAMMAR RULE'), findsOneWidget);
      expect(find.text('Feil verbbøying i preteritum'), findsOneWidget);
      expect(find.text('Sterke verb med vokalskifte'), findsOneWidget);
      expect(find.text('The agent prepared a targeted drill exercise next.'), findsOneWidget);
    });

    testWidgets('Renders full ArtifactRenderer with content and submission', (tester) async {
      final artifact = MockDataService.mockArtifactSequence[0];
      final collector = ResponseCollector(
        sessionId: artifact.sessionId,
        artifactId: artifact.artifactId,
        turnNumber: artifact.turnNumber,
        requiredInputs: artifact.inputs.map((i) => i.id).toSet(),
      );

      bool submitted = false;

      tester.view.physicalSize = const Size(1280, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArtifactRenderer(
              artifact: artifact,
              responseCollector: collector,
              onSubmit: () {
                submitted = true;
              },
            ),
          ),
        ),
      );

      // Verify content rendered
      expect(find.text('På Kafeen i Oslo'), findsOneWidget);
      expect(find.text('Hva bestiller Sofie på kafeen?'), findsOneWidget);

      // Select option
      await tester.tap(find.text('Kaffe og kanelbolle'));
      await tester.pumpAndSettle();

      // Tap true
      await tester.scrollUntilVisible(find.text('Riktig (True)'), 100);
      await tester.tap(find.text('Riktig (True)'));
      await tester.pumpAndSettle();

      expect(collector.isComplete, isTrue);

      // Scroll to and click submit
      await tester.scrollUntilVisible(find.text('Submit Response'), 100);
      await tester.tap(find.text('Submit Response'));
      await tester.pumpAndSettle();

      expect(submitted, isTrue);
    });
  });
}
