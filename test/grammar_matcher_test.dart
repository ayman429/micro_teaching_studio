import 'package:flutter_test/flutter_test.dart';
import 'package:micro_teaching_studio/features/grammar/grammar_script.dart';

void main() {
  test('warm-up needs standing, jumping, and the model sentence', () {
    expect(
      matchesWarmupMovement(
        'He told students to stand up and look at him jumping, and he asked what am I doing. Look at me, I am jumping.',
      ),
      isTrue,
    );
    expect(
      matchesWarmupMovement('He told them to stand up and jump'),
      isFalse,
    );
  });

  test('jump command needs students saying I am jumping', () {
    expect(
      matchesJumpCommand('He asked the students to jump and say I am jumping'),
      isTrue,
    );
    expect(matchesJumpCommand('He asked them to sit down'), isFalse);
  });

  test('mistake reaction needs an incorrect answer and a repair', () {
    expect(
      matchesJumpingMistake(
        'The students did not respond correctly. The teacher asked them to listen to I am jumping and repeat it.',
      ),
      isTrue,
    );
    expect(
      matchesJumpingMistake(
        'The students responded correctly and said I am jumping',
      ),
      isFalse,
    );
  });

  test('eating picture needs the picture and the question', () {
    expect(
      matchesEatingPicture(
        'He showed a picture of a girl eating and asked what is she doing',
      ),
      isTrue,
    );
    expect(matchesEatingPicture('A girl is eating'), isFalse);
  });

  test('eating correction needs the mistake, eating, and a repeat', () {
    expect(
      matchesEatingCorrection(
        'The students answered incorrectly, and the teacher said she is eating and asked them to repeat it.',
      ),
      isTrue,
    );
    expect(matchesEatingCorrection('She is eating'), isFalse);
  });

  test('quiz passes on option c then option b', () {
    expect(GrammarScript.matchesQuiz([2, 1]), isTrue);
    expect(GrammarScript.matchesQuiz([2, 2]), isFalse);
    expect(GrammarScript.matchesQuiz([0, 1]), isFalse);
  });
}
