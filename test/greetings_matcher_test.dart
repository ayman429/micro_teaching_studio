import 'package:flutter_test/flutter_test.dart';
import 'package:micro_teaching_studio/features/analytics/analytics_constants.dart';
import 'package:micro_teaching_studio/features/greetings/greetings_resume.dart';
import 'package:micro_teaching_studio/features/greetings/greetings_script.dart';

void main() {
  test('noise answer accepts the expected idea', () {
    expect(
      matchesNoise('Yes, students are making a lot of noise?'),
      isTrue,
    );
    expect(matchesNoise('Yes, the students make noise'), isTrue);
    expect(matchesNoise('Yes, students are not making noise'), isFalse);
    expect(matchesNoise('The class is quiet'), isFalse);
  });

  test('TPR answer needs the method and the name', () {
    expect(
      matchesTpr(
        "Yes, the teacher could manage the students' behaviours by asking them to respond to physical actions. This is called TPR (Total Physical Response).",
      ),
      isTrue,
    );
    expect(matchesTpr('The teacher used TPR'), isFalse);
  });

  test('expressions answer needs most of the classroom lines', () {
    expect(
      matchesExpressions(
        'Clap once if you can hear me. Clap twice if you can hear me. Good morning my students. Everyone hands up, hands down and sit down please. Eyes on me. Books out class. Open page twenty-four. Finger on line one. Show me your fingers.',
      ),
      isTrue,
    );
    expect(
      matchesExpressions('Clap once. Good morning. Hands up.'),
      isFalse,
    );
  });

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
      GreetingsResumePlan.resumeIndex(const [settled, settled, settled]),
      3,
    );
  });
}
