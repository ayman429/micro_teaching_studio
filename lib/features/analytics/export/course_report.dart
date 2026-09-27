import 'package:micro_teaching_studio/features/analytics/analytics_constants.dart';
import 'package:micro_teaching_studio/features/analytics/export/course_aims.dart';
import 'package:micro_teaching_studio/features/analytics/export/course_performance.dart';
import 'package:micro_teaching_studio/features/home/models/course_progress.dart';

class AttemptRow {
  const AttemptRow({
    required this.uid,
    required this.fullName,
    required this.userName,
    required this.moduleNumber,
    required this.sessionNumber,
    required this.partId,
    required this.partLabel,
    required this.attemptNumber,
    required this.heardText,
    required this.pronScore,
    required this.accuracyScore,
    required this.fluencyScore,
    required this.completenessScore,
    required this.prosodyScore,
    required this.band,
    required this.contentOutcome,
    required this.lessonFeedback,
    required this.startedAt,
    required this.endedAt,
  });

  final String uid;
  final String fullName;
  final String userName;
  final int moduleNumber;
  final int sessionNumber;
  final String partId;
  final String partLabel;
  final int attemptNumber;
  final String heardText;
  final double? pronScore;
  final double? accuracyScore;
  final double? fluencyScore;
  final double? completenessScore;
  final double? prosodyScore;
  final String band;
  final String contentOutcome;
  final String lessonFeedback;
  final String startedAt;
  final String endedAt;
}

class StudentReport {
  const StudentReport({
    required this.uid,
    required this.fullName,
    required this.userName,
    required this.completionPercent,
    required this.performance,
    required this.aimStatuses,
  });

  final String uid;
  final String fullName;
  final String userName;
  final double completionPercent;
  final PerformanceScore performance;
  final List<AimStatus> aimStatuses;

  int get aimsAchieved =>
      aimStatuses.where((status) => status == AimStatus.achieved).length;
}

class PartCohortRate {
  const PartCohortRate({
    required this.partId,
    required this.partLabel,
    required this.successPercent,
  });

  final String partId;
  final String partLabel;
  final double successPercent;
}

class CohortSummary {
  const CohortSummary({
    required this.studentCount,
    required this.averageCompletion,
    required this.averagePerformance,
    required this.partRates,
    required this.bandCounts,
  });

  final int studentCount;
  final double? averageCompletion;
  final double? averagePerformance;
  final List<PartCohortRate> partRates;
  final Map<String, int> bandCounts;
}

class CourseReport {
  const CourseReport({
    required this.students,
    required this.attempts,
    required this.cohort,
  });

  final List<StudentReport> students;
  final List<AttemptRow> attempts;
  final CohortSummary cohort;

  factory CourseReport.fromDocuments({
    required List<Map<String, dynamic>> userProgress,
    required List<Map<String, dynamic>> partProgress,
    required List<Map<String, dynamic>> attempts,
  }) {
    final names = <String, ({String fullName, String userName})>{};
    for (final doc in userProgress) {
      final uid = _text(doc['uid']);
      if (uid.isEmpty) continue;
      names[uid] =
          (fullName: _text(doc['fullName']), userName: _text(doc['userName']));
    }
    final partsByUid = <String, Map<String, Map<String, dynamic>>>{};
    for (final doc in partProgress) {
      final uid = _text(doc['uid']);
      final partId = _text(doc['partId']);
      if (uid.isEmpty || partId.isEmpty) continue;
      partsByUid.putIfAbsent(uid, () => {})[partId] = doc;
      names.putIfAbsent(
        uid,
        () => (
          fullName: _text(doc['fullName']),
          userName: _text(doc['userName'])
        ),
      );
    }
    final attemptRows = <AttemptRow>[];
    for (final doc in attempts) {
      final uid = _text(doc['uid']);
      if (uid.isEmpty) continue;
      final name = names[uid];
      names.putIfAbsent(
        uid,
        () => (
          fullName: _text(doc['fullName']),
          userName: _text(doc['userName'])
        ),
      );
      attemptRows.add(
        AttemptRow(
          uid: uid,
          fullName: name?.fullName ?? _text(doc['fullName']),
          userName: name?.userName ?? _text(doc['userName']),
          moduleNumber: _int(doc['moduleNumber']),
          sessionNumber: _int(doc['sessionNumber']),
          partId: _text(doc['partId']),
          partLabel: _text(doc['partLabel']),
          attemptNumber: _int(doc['attemptNumber']),
          heardText: _text(doc['heardText']),
          pronScore: _double(doc['pronScore']),
          accuracyScore: _double(doc['accuracyScore']),
          fluencyScore: _double(doc['fluencyScore']),
          completenessScore: _double(doc['completenessScore']),
          prosodyScore: _double(doc['prosodyScore']),
          band: _text(doc['band']),
          contentOutcome: _text(doc['contentOutcome']),
          lessonFeedback: _text(doc['lessonFeedback']),
          startedAt: _text(doc['startedAt']),
          endedAt: _text(doc['endedAt']),
        ),
      );
    }
    attemptRows.sort((left, right) {
      final byName = left.fullName.compareTo(right.fullName);
      if (byName != 0) return byName;
      final byPart = left.partId.compareTo(right.partId);
      if (byPart != 0) return byPart;
      return left.attemptNumber.compareTo(right.attemptNumber);
    });
    final students = [
      for (final uid in names.keys)
        _student(uid, names[uid]!, partsByUid[uid] ?? const {}),
    ]..sort((left, right) => left.fullName.compareTo(right.fullName));
    return CourseReport(
      students: students,
      attempts: attemptRows,
      cohort: _cohort(students, partsByUid, attemptRows),
    );
  }

  static StudentReport _student(
    String uid,
    ({String fullName, String userName}) name,
    Map<String, Map<String, dynamic>> parts,
  ) {
    return StudentReport(
      uid: uid,
      fullName: name.fullName,
      userName: name.userName,
      completionPercent: CoursePerformance.completionPercent(parts),
      performance: CoursePerformance.fromParts(parts),
      aimStatuses: [
        for (final aim in CourseAims.catalog) CourseAims.statusFor(aim, parts),
      ],
    );
  }

  static CohortSummary _cohort(
    List<StudentReport> students,
    Map<String, Map<String, Map<String, dynamic>>> partsByUid,
    List<AttemptRow> attempts,
  ) {
    final count = students.length;
    final completionValues = [
      for (final student in students) student.completionPercent
    ];
    final performanceValues = [
      for (final student in students)
        if (student.performance.performancePercent != null)
          student.performance.performancePercent!,
    ];
    final rates = <PartCohortRate>[];
    for (final partId in CourseProgressIds.all()) {
      var succeeded = 0;
      var label = partId;
      for (final parts in partsByUid.values) {
        final part = parts[partId];
        final storedLabel = _text(part?['partLabel']);
        if (storedLabel.isNotEmpty) label = storedLabel;
        if (CourseAims.succeeded(part)) succeeded++;
      }
      rates.add(
        PartCohortRate(
          partId: partId,
          partLabel: label,
          successPercent: count == 0 ? 0 : succeeded / count * 100,
        ),
      );
    }
    return CohortSummary(
      studentCount: count,
      averageCompletion: count == 0 ? null : _mean(completionValues),
      averagePerformance:
          performanceValues.isEmpty ? null : _mean(performanceValues),
      partRates: rates,
      bandCounts: bandCountsFor(attempts),
    );
  }
}

Map<String, int> bandCountsFor(List<AttemptRow> attempts) {
  final counts = <String, int>{
    AnalyticsConstants.bandExcellent: 0,
    AnalyticsConstants.bandNeedsImprov: 0,
    AnalyticsConstants.bandIncorrect: 0,
    '': 0,
  };
  for (final attempt in attempts) {
    final band = attempt.band.trim();
    counts[band] = (counts[band] ?? 0) + 1;
  }
  return counts;
}

double _mean(List<double> values) {
  var sum = 0.0;
  for (final value in values) {
    sum += value;
  }
  return sum / values.length;
}

String _text(Object? value) => value is String ? value.trim() : '';

int _int(Object? value) => value is num ? value.toInt() : 0;

double? _double(Object? value) => value is num ? value.toDouble() : null;
