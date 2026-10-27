import 'package:flutter_test/flutter_test.dart';
import 'package:micro_teaching_studio/features/presentation/presentation_script.dart';

void main() {
  test('quiz passes only on option c', () {
    expect(PresentationScript.matchesQuiz([2]), isTrue);
    expect(PresentationScript.matchesQuiz([0]), isFalse);
    expect(PresentationScript.matchesQuiz([1]), isFalse);
  });
}
