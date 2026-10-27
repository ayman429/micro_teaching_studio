import 'package:flutter_test/flutter_test.dart';
import 'package:micro_teaching_studio/features/analytics/analytics_constants.dart';
import 'package:micro_teaching_studio/features/greetings/greetings_resume.dart';

void main() {
  test('resume stays on the open question and skips settled ones', () {
    const open = GreetingsPartSnapshot(
      reached: true,
      attemptCount: 1,
      locked: false,
      contentOutcome: AnalyticsConstants.contentRetry,
    );
    const settled = GreetingsPartSnapshot(
      reached: true,
      attemptCount: 3,
      locked: true,
      contentOutcome: AnalyticsConstants.contentIncorrect,
    );
    const improved = GreetingsPartSnapshot(
      reached: true,
      attemptCount: 1,
      locked: true,
      contentOutcome: AnalyticsConstants.contentNeedsImprovement,
    );
    const untouched = GreetingsPartSnapshot(
      reached: false,
      attemptCount: 0,
      locked: false,
      contentOutcome: '',
    );
    expect(
      GreetingsResumePlan.resumeIndex(const [untouched, untouched, untouched]),
      -1,
    );
    expect(
        GreetingsResumePlan.resumeIndex(const [open, untouched, untouched]), 0);
    expect(
      GreetingsResumePlan.resumeIndex(const [settled, open, untouched]),
      1,
    );
    expect(
      GreetingsResumePlan.resumeIndex(const [improved, settled, settled]),
      3,
    );
    expect(improved.answeredCorrectly, isTrue);
  });
}
