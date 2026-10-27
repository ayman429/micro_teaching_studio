import 'package:flutter_test/flutter_test.dart';
import 'package:micro_teaching_studio/features/analytics/analytics_constants.dart';
import 'package:micro_teaching_studio/features/classroom/classroom_script.dart';
import 'package:micro_teaching_studio/features/quiz/quiz_script.dart';

void main() {
  test('quiz passes on option b then option c', () {
    expect(ClassroomScript.matchesQuiz(const [1, 2]), isTrue);
    expect(ClassroomScript.matchesQuiz(const [2, 2]), isFalse);
    final first = ClassroomScript.gradeQuiz(matched: false, nextAttempt: 1);
    final third = ClassroomScript.gradeQuiz(matched: false, nextAttempt: 3);
    expect(first.tone, QuizTone.wrong);
    expect(first.settles, isFalse);
    expect(third.outcome, AnalyticsConstants.contentIncorrect);
    expect(third.settles, isTrue);
  });
}
