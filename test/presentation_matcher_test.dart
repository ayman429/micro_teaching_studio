import 'package:flutter_test/flutter_test.dart';
import 'package:micro_teaching_studio/features/presentation/presentation_script.dart';

void main() {
  test('lesson start needs the motivating look-at-me opening', () {
    expect(
      matchesLessonStart(
        'He motivated them saying today we are going to do something very exciting but first look at me.',
      ),
      isTrue,
    );
    expect(matchesLessonStart('He wrote examples on the board'), isFalse);
  });

  test('drinking technique needs water and the question or TPR', () {
    expect(
      matchesDrinkingTechnique(
        'He used TPR and asked them to look at him drinking water. What am I doing right now?',
      ),
      isTrue,
    );
    expect(matchesDrinkingTechnique('He used a picture'), isFalse);
  });

  test('praise needs excellent and encouragement', () {
    expect(
      matchesPositiveReinforcement(
        'He said excellent to Farida and told Moaz to keep up the good work.',
      ),
      isTrue,
    );
    expect(matchesPositiveReinforcement('He said excellent'), isFalse);
  });

  test('Moaz technique agrees that acting shows an action happening now', () {
    expect(
      matchesMoazTechnique(
        'Yes, it was suitable because he used acting so students can see the action happening right now.',
      ),
      isTrue,
    );
    expect(
      matchesMoazTechnique('No, this technique is not suitable'),
      isFalse,
    );
  });

  test('correction agrees that repeating the answer correctly is effective', () {
    expect(
      matchesIndirectCorrection(
        'Yes, it is effective because he used indirect correction and repeated the answer correctly.',
      ),
      isTrue,
    );
    expect(
      matchesIndirectCorrection('No, it is not effective'),
      isFalse,
    );
  });

  test('picture practice needs pictures, the board, and sentences', () {
    expect(
      matchesPicturePractice(
        'He showed pictures on the board and they wrote sentences about what the person is doing.',
      ),
      isTrue,
    );
    expect(matchesPicturePractice('He showed a picture'), isFalse);
  });

  test('quiz passes only on option c', () {
    expect(PresentationScript.matchesQuiz([2]), isTrue);
    expect(PresentationScript.matchesQuiz([0]), isFalse);
    expect(PresentationScript.matchesQuiz([1]), isFalse);
  });
}
