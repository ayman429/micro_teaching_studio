import 'package:flutter_test/flutter_test.dart';
import 'package:micro_teaching_studio/features/analytics/analytics_constants.dart';
import 'package:micro_teaching_studio/features/classroom/classroom_script.dart';
import 'package:micro_teaching_studio/features/quiz/quiz_script.dart';

void main() {
  test('noise again needs students, noise, and again', () {
    expect(
      matchesNoiseAgain('The students are making noise again.'),
      isTrue,
    );
    expect(matchesNoiseAgain('The students are noisy again'), isTrue);
    expect(matchesNoiseAgain('The students are making noise'), isFalse);
    expect(matchesNoiseAgain('The students are not making noise again'), isFalse);
  });

  test('teacher response needs physical imitation', () {
    expect(
      matchesTeacherResponse(
        'The teacher responded by doing physical actions and asking students to imitate him.',
      ),
      isTrue,
    );
    expect(
      matchesTeacherResponse('The teacher copied the students'),
      isFalse,
    );
  });

  test('attention expressions need most of the classroom lines', () {
    expect(
      matchesAttentionExpressions(
        'Clap clap clap. If you can hear my voice imitate me. If you can hear my voice copy me. Class class class. One two three eyes on me. One two eyes on you. Macaroni and cheese. Everybody freeze. Hands up. Hands on shoulders. Hands on lips. Lips are zipped.',
      ),
      isTrue,
    );
    expect(matchesAttentionExpressions('Clap. Eyes on me. Freeze.'), isFalse);
  });

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
