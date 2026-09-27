import 'package:flutter_test/flutter_test.dart';
import 'package:micro_teaching_studio/features/analytics/analytics_constants.dart';
import 'package:micro_teaching_studio/features/analytics/export/course_aims.dart';
import 'package:micro_teaching_studio/features/analytics/export/course_performance.dart';
import 'package:micro_teaching_studio/features/analytics/export/course_report.dart';
import 'package:micro_teaching_studio/features/analytics/export/course_report_workbook.dart';
import 'package:micro_teaching_studio/features/home/models/course_progress.dart';

void main() {
  test('an aim is achieved only when every mapped part succeeds', () {
    final parts = {
      for (final id in CourseAims.catalog[1].partIds)
        id: {
          'partType': AnalyticsConstants.phonicsWord,
          'bestBand': AnalyticsConstants.bandExcellent,
          'attemptCount': 1,
        },
    };
    parts[CourseAims.catalog[1].partIds.first] = {
      'partType': AnalyticsConstants.phonicsWord,
      'bestBand': AnalyticsConstants.bandNeedsImprov,
      'attemptCount': 2,
    };

    expect(
      CourseAims.statusFor(CourseAims.catalog[1], parts),
      AimStatus.attempted,
    );

    parts[CourseAims.catalog[1].partIds.first] = {
      'partType': AnalyticsConstants.phonicsWord,
      'bestBand': AnalyticsConstants.bandExcellent,
      'attemptCount': 1,
    };
    expect(
      CourseAims.statusFor(CourseAims.catalog[1], parts),
      AimStatus.achieved,
    );
    expect(
      CourseAims.statusFor(CourseAims.catalog.first, const {}),
      AimStatus.notStarted,
    );
  });

  test('performance uses pronunciation quality and settled quizzes', () {
    final score = CoursePerformance.fromParts({
      CourseProgressIds.fluencyPassage: {
        'partType': AnalyticsConstants.fluencyPassage,
        'bestPronScore': 80,
        'bestBand': AnalyticsConstants.bandNeedsImprov,
      },
      CourseProgressIds.vocabCivilization: {
        'partType': AnalyticsConstants.targetWord,
        'bestPronScore': 100,
        'bestBand': AnalyticsConstants.bandExcellent,
      },
      CourseProgressIds.sessionQuiz: {
        'partType': AnalyticsConstants.trueFalseQuiz,
        'contentOutcome': AnalyticsConstants.contentCorrect,
      },
      CourseProgressIds.classroomQuiz: {
        'partType': AnalyticsConstants.trueFalseQuiz,
        'contentOutcome': AnalyticsConstants.contentIncorrect,
      },
      CourseProgressIds.vocabQuiz: {
        'partType': AnalyticsConstants.trueFalseQuiz,
        'contentOutcome': AnalyticsConstants.contentRetry,
      },
    });

    expect(score.pronunciationAverage, 90);
    expect(score.quizAccuracy, 50);
    expect(score.performancePercent, 70);
  });

  test('the workbook lists students, aims, attempts, and cohort rates', () {
    final report = CourseReport.fromDocuments(
      userProgress: const [
        {'uid': 's1', 'fullName': 'Sara Ahmed', 'userName': 'sara'},
      ],
      partProgress: [
        {
          'uid': 's1',
          'fullName': 'Sara Ahmed',
          'userName': 'sara',
          'partId': CourseProgressIds.fluencyPassage,
          'partType': AnalyticsConstants.fluencyPassage,
          'partLabel': 'passage',
          'bestBand': AnalyticsConstants.bandExcellent,
          'bestPronScore': 96,
          'locked': true,
          'status': AnalyticsConstants.statusCompleted,
          'attemptCount': 1,
        },
      ],
      attempts: const [
        {
          'uid': 's1',
          'fullName': 'Sara Ahmed',
          'userName': 'sara',
          'moduleNumber': 1,
          'sessionNumber': 1,
          'partId': CourseProgressIds.fluencyPassage,
          'partLabel': 'passage',
          'attemptNumber': 1,
          'heardText': 'Marwa',
          'pronScore': 96,
          'band': AnalyticsConstants.bandExcellent,
          'contentOutcome': '',
          'lessonFeedback': 'Excellent',
          'startedAt': '2026-09-27T10:00:00.000',
          'endedAt': '2026-09-27T10:01:00.000',
        },
      ],
    );

    expect(report.students.single.aimsAchieved, 1);
    expect(report.students.single.performance.pronunciationAverage, 96);
    expect(report.cohort.studentCount, 1);
    expect(report.cohort.bandCounts[AnalyticsConstants.bandExcellent], 1);
    expect(report.cohort.partRates.first.successPercent, 100);

    final bytes = CourseReportWorkbook.encode(report);
    expect(bytes.length, greaterThan(100));
  });
}
