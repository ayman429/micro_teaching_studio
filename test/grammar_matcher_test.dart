import 'package:flutter_test/flutter_test.dart';
import 'package:micro_teaching_studio/features/grammar/grammar_script.dart';

void main() {
  test('quiz passes on option c then option b', () {
    expect(GrammarScript.matchesQuiz([2, 1]), isTrue);
    expect(GrammarScript.matchesQuiz([2, 2]), isFalse);
    expect(GrammarScript.matchesQuiz([0, 1]), isFalse);
  });
}
