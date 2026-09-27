import 'package:micro_teaching_studio/features/analytics/analytics_constants.dart';
import 'package:micro_teaching_studio/features/analytics/export/course_aims.dart';
import 'package:micro_teaching_studio/features/home/models/course_progress.dart';

class PerformanceScore {
  const PerformanceScore({
    required this.pronunciationAverage,
    required this.quizAccuracy,
    required this.performancePercent,
  });

  final double? pronunciationAverage;
  final double? quizAccuracy;
  final double? performancePercent;

  static const empty = PerformanceScore(
    pronunciationAverage: null,
    quizAccuracy: null,
    performancePercent: null,
  );
}

class CoursePerformance {
  static const List<String> quizPartIds = [
    CourseProgressIds.sessionQuiz,
    CourseProgressIds.classroomQuiz,
    CourseProgressIds.vocabQuiz,
    CourseProgressIds.grammarQuiz,
    CourseProgressIds.presentQuiz,
  ];

  static PerformanceScore fromParts(
    Map<String, Map<String, dynamic>> parts,
  ) {
    final scores = <double>[];
    for (final part in parts.values) {
      final type = (part['partType'] as String?)?.trim() ?? '';
      if (!_countsTowardPronunciation(type)) continue;
      final score = _asDouble(part['bestPronScore']);
      if (score == null) continue;
      scores.add(score);
    }
    final settled = <bool>[];
    for (final id in quizPartIds) {
      final part = parts[id];
      final outcome = (part?['contentOutcome'] as String?)?.trim() ?? '';
      if (outcome == AnalyticsConstants.contentCorrect) {
        settled.add(true);
      } else if (outcome == AnalyticsConstants.contentIncorrect) {
        settled.add(false);
      }
    }
    final pronunciation = scores.isEmpty ? null : _mean(scores);
    final quiz = settled.isEmpty
        ? null
        : settled.where((item) => item).length / settled.length * 100;
    final components = [
      if (pronunciation != null) pronunciation,
      if (quiz != null) quiz,
    ];
    return PerformanceScore(
      pronunciationAverage: pronunciation,
      quizAccuracy: quiz,
      performancePercent: components.isEmpty ? null : _mean(components),
    );
  }

  static double completionPercent(Map<String, Map<String, dynamic>> parts) {
    final ids = CourseProgressIds.all();
    if (ids.isEmpty) return 0;
    final done = ids.where((id) {
      final part = parts[id];
      if (part == null) return false;
      return part['locked'] == true ||
          part['status'] == AnalyticsConstants.statusCompleted;
    }).length;
    return done / ids.length * 100;
  }

  static bool _countsTowardPronunciation(String type) {
    return CourseAims.pronunciationPart(type) ||
        type == AnalyticsConstants.spokenResponse;
  }

  static double _mean(List<double> values) {
    var sum = 0.0;
    for (final value in values) {
      sum += value;
    }
    return sum / values.length;
  }

  static double? _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    return null;
  }
}
