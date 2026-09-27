import 'package:excel/excel.dart';
import 'package:micro_teaching_studio/features/analytics/analytics_constants.dart';
import 'package:micro_teaching_studio/features/analytics/export/course_aims.dart';
import 'package:micro_teaching_studio/features/analytics/export/course_report.dart';

class CourseReportWorkbook {
  static List<int> encode(CourseReport report) {
    final excel = Excel.createExcel();
    const students = 'Students';
    const aims = 'Aims';
    const attempts = 'Attempts';
    const cohort = 'Cohort';
    excel.rename('Sheet1', students);
    _students(excel[students], report);
    _aims(excel[aims], report);
    _attempts(excel[attempts], report);
    _cohort(excel[cohort], report);
    final bytes = excel.encode();
    if (bytes == null || bytes.isEmpty) {
      throw StateError('grades workbook was empty');
    }
    return bytes;
  }

  static void _students(Sheet sheet, CourseReport report) {
    sheet.appendRow([
      TextCellValue('Full name'),
      TextCellValue('User name'),
      TextCellValue('Completion %'),
      TextCellValue('Pronunciation average'),
      TextCellValue('Quiz accuracy %'),
      TextCellValue('Performance %'),
      TextCellValue('Aims achieved'),
    ]);
    for (final student in report.students) {
      sheet.appendRow([
        TextCellValue(student.fullName),
        TextCellValue(student.userName),
        DoubleCellValue(student.completionPercent),
        _number(student.performance.pronunciationAverage),
        _number(student.performance.quizAccuracy),
        _number(student.performance.performancePercent),
        IntCellValue(student.aimsAchieved),
      ]);
    }
  }

  static void _aims(Sheet sheet, CourseReport report) {
    sheet.appendRow([
      TextCellValue('Aim'),
      TextCellValue('Objective'),
      for (final student in report.students)
        TextCellValue(
          student.fullName.isEmpty ? student.userName : student.fullName,
        ),
    ]);
    for (var index = 0; index < CourseAims.catalog.length; index++) {
      final aim = CourseAims.catalog[index];
      sheet.appendRow([
        IntCellValue(aim.number),
        TextCellValue(aim.text),
        for (final student in report.students)
          TextCellValue(CourseAims.labelOf(student.aimStatuses[index])),
      ]);
    }
  }

  static void _attempts(Sheet sheet, CourseReport report) {
    sheet.appendRow([
      TextCellValue('Full name'),
      TextCellValue('User name'),
      TextCellValue('Module'),
      TextCellValue('Session'),
      TextCellValue('Part'),
      TextCellValue('Part label'),
      TextCellValue('Attempt'),
      TextCellValue('Heard text'),
      TextCellValue('Pronunciation'),
      TextCellValue('Accuracy'),
      TextCellValue('Fluency'),
      TextCellValue('Completeness'),
      TextCellValue('Prosody'),
      TextCellValue('Band'),
      TextCellValue('Content outcome'),
      TextCellValue('Feedback'),
      TextCellValue('Started'),
      TextCellValue('Ended'),
    ]);
    for (final attempt in report.attempts) {
      sheet.appendRow([
        TextCellValue(attempt.fullName),
        TextCellValue(attempt.userName),
        IntCellValue(attempt.moduleNumber),
        IntCellValue(attempt.sessionNumber),
        TextCellValue(attempt.partId),
        TextCellValue(attempt.partLabel),
        IntCellValue(attempt.attemptNumber),
        TextCellValue(attempt.heardText),
        _number(attempt.pronScore),
        _number(attempt.accuracyScore),
        _number(attempt.fluencyScore),
        _number(attempt.completenessScore),
        _number(attempt.prosodyScore),
        TextCellValue(attempt.band),
        TextCellValue(attempt.contentOutcome),
        TextCellValue(attempt.lessonFeedback),
        TextCellValue(attempt.startedAt),
        TextCellValue(attempt.endedAt),
      ]);
    }
  }

  static void _cohort(Sheet sheet, CourseReport report) {
    final cohort = report.cohort;
    sheet.appendRow([
      TextCellValue('Students'),
      IntCellValue(cohort.studentCount),
    ]);
    sheet.appendRow([
      TextCellValue('Average completion %'),
      _number(cohort.averageCompletion),
    ]);
    sheet.appendRow([
      TextCellValue('Average performance %'),
      _number(cohort.averagePerformance),
    ]);
    sheet.appendRow([TextCellValue('')]);
    sheet.appendRow([
      TextCellValue('Part'),
      TextCellValue('Label'),
      TextCellValue('Success %'),
    ]);
    for (final rate in cohort.partRates) {
      sheet.appendRow([
        TextCellValue(rate.partId),
        TextCellValue(rate.partLabel),
        DoubleCellValue(rate.successPercent),
      ]);
    }
    sheet.appendRow([TextCellValue('')]);
    sheet.appendRow([
      TextCellValue('Band'),
      TextCellValue('Attempts'),
    ]);
    for (final band in [
      AnalyticsConstants.bandExcellent,
      AnalyticsConstants.bandNeedsImprov,
      AnalyticsConstants.bandIncorrect,
    ]) {
      sheet.appendRow([
        TextCellValue(band),
        IntCellValue(cohort.bandCounts[band] ?? 0),
      ]);
    }
  }

  static CellValue _number(double? value) {
    if (value == null) return TextCellValue('');
    return DoubleCellValue(value);
  }
}
