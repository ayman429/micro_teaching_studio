import 'package:flutter_test/flutter_test.dart';
import 'package:micro_teaching_studio/features/course_shell/course_sessions.dart';

void main() {
  test('course complete waits until every session is finished', () {
    final finished = <String>{};
    expect(CourseSessions.allFinished(finished), isFalse);
    expect(CourseSessions.firstUnfinished(finished)?.key, '1-1');

    for (final session in CourseSessions.order) {
      if (session.key == '2-2') continue;
      finished.add(session.key);
    }
    expect(CourseSessions.allFinished(finished), isFalse);
    expect(CourseSessions.firstUnfinished(finished)?.key, '2-2');

    finished.add('2-2');
    expect(CourseSessions.allFinished(finished), isTrue);
    expect(CourseSessions.firstUnfinished(finished), isNull);
  });

  test('next lesson skips finished sessions in every order', () {
    final finished = {'3-1', '3-2', '3-3', '1-1', '1-2'};
    expect(CourseSessions.firstUnfinished(finished)?.key, '2-1');

    finished.add('2-1');
    expect(CourseSessions.firstUnfinished(finished)?.key, '2-2');
  });

  test('chat restudy ignores quiz questions that were not opened', () {
    final passedChat = {'2-1-q1', '2-1-q2', '2-1-q3'};
    expect(CourseSessions.hasMissedSpokenTask(passedChat, 2, 1), isFalse);
    expect(CourseSessions.hasMissedTask(passedChat, 2, 1), isTrue);

    final failedChat = {'2-1-q1'};
    expect(CourseSessions.hasMissedSpokenTask(failedChat, 2, 1), isTrue);
  });

  test('a missed quiz question reopens its part without clearing a point', () {
    final points = {'2-2-q1', '2-2-quiz#0'};
    expect(CourseSessions.hasMissedTask(points, 2, 2), isTrue);
    expect(
      CourseSessions.missedPartIds(points, 2, 2),
      containsAll(['2-2-q2', '2-2-q3', '2-2-quiz']),
    );
    expect(
      CourseSessions.missedPartIds(points, 2, 2),
      isNot(contains('2-2-q1')),
    );
  });
}
