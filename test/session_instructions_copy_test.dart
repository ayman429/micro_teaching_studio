import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:micro_teaching_studio/common/resources/assets_manager.dart';
import 'package:micro_teaching_studio/features/session_instructions/session_instructions_copy.dart';

void main() {
  test('paragraph instructions keep the body and the how-to section', () {
    const raw = '''
Objective
Practice pronouncing words from sample lessons given from EFL textbooks.  students grade 4 to 6. 
How to apply
You practice pronouncing the following phonics words.
''';

    final copy = parseSessionInstructions(raw);

    expect(copy.objectivePoints, isEmpty);
    expect(
      copy.objectivesLead,
      'Practice pronouncing words from sample lessons given from EFL textbooks.  students grade 4 to 6.',
    );
    expect(
      copy.howToApply,
      'You practice pronouncing the following phonics words.',
    );
  });

  test('dash and bullet objectives split from an inline how-to heading', () {
    const dashed = '''
Objectives:
By the end of this session, you will be able to:
- Give greetings and simple welcoming sentences.
- Give common classroom commands confidently.

How to apply:
First, watch the video carefully.
''';
    const marked = '''
Objectives: by the end of this lesson, you will be able to
\uF0B7Pronounce target words correctly and fluently.
\uF0B7Check for students' understanding of words using clear and correct English.
How to apply: First, watch the video carefully and pay attention.
''';

    final dashes = parseSessionInstructions(dashed);
    final marks = parseSessionInstructions(marked);

    expect(
      dashes.objectivesLead,
      'By the end of this session, you will be able to:',
    );
    expect(dashes.objectivePoints, [
      'Give greetings and simple welcoming sentences.',
      'Give common classroom commands confidently.',
    ]);
    expect(dashes.howToApply, 'First, watch the video carefully.');
    expect(
      marks.objectivesLead,
      'by the end of this lesson, you will be able to',
    );
    expect(marks.objectivePoints, [
      'Pronounce target words correctly and fluently.',
      "Check for students' understanding of words using clear and correct English.",
    ]);
    expect(
      marks.howToApply,
      'First, watch the video carefully and pay attention.',
    );
  });

  test('each session instructions folder parses and matches its audio files',
      () {
    const sessions = [
      (1, 2),
      (2, 1),
      (2, 2),
      (3, 1),
      (3, 2),
      (3, 3),
    ];

    for (final (module, session) in sessions) {
      final textPath = AudioAssets.sessionInstructionsText(module, session);
      final objectivesPath =
          AudioAssets.sessionInstructionsObjectives(module, session);
      final howToPath =
          AudioAssets.sessionInstructionsHowToApply(module, session);
      final copy = parseSessionInstructions(File(textPath).readAsStringSync());

      expect(File(textPath).existsSync(), isTrue, reason: textPath);
      expect(File(objectivesPath).existsSync(), isTrue, reason: objectivesPath);
      expect(File(howToPath).existsSync(), isTrue, reason: howToPath);
      expect(copy.objectivesLead, isNotEmpty, reason: textPath);
      expect(copy.howToApply, isNotEmpty, reason: textPath);
    }
  });
}
