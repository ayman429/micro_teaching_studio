import 'package:flutter_test/flutter_test.dart';
import 'package:micro_teaching_studio/features/analytics/analytics_constants.dart';
import 'package:micro_teaching_studio/features/quiz/quiz_script.dart';

void main() {
  test('quiz passes only when every statement matches', () {
    expect(QuizScript.matches(const [false, true, false]), isTrue);
    expect(QuizScript.matches(const [true, true, false]), isFalse);
    expect(QuizScript.matches(const [false, true, null]), isFalse);
  });

  test('first miss can be retried and the third miss is incorrect', () {
    final first = QuizScript.grade(matched: false, nextAttempt: 1);
    final second = QuizScript.grade(matched: false, nextAttempt: 2);
    final third = QuizScript.grade(matched: false, nextAttempt: 3);
    final correct = QuizScript.grade(matched: true, nextAttempt: 1);

    expect(first.outcome, AnalyticsConstants.contentRetry);
    expect(first.tone, QuizTone.wrong);
    expect(first.settles, isFalse);

    expect(second.outcome, AnalyticsConstants.contentRetry);
    expect(second.tone, QuizTone.review);
    expect(second.settles, isFalse);

    expect(third.outcome, AnalyticsConstants.contentIncorrect);
    expect(third.tone, QuizTone.review);
    expect(third.settles, isTrue);

    expect(correct.outcome, AnalyticsConstants.contentCorrect);
    expect(correct.settles, isTrue);
  });

  test('saved statements restore the chosen answers', () {
    final restored = QuizScript.selectionsFrom([
      {'index': 1, 'answered': true, 'selected': false},
      {'index': 2, 'answered': false, 'selected': true},
      {'index': 3, 'answered': true, 'selected': true},
    ]);
    expect(restored, [false, null, true]);
  });
}
