import 'package:micro_teaching_studio/features/analytics/analytics_constants.dart';

class LessonAnalytics {
  const LessonAnalytics({
    required this.contentOutcome,
    required this.contentMatched,
    required this.lessonFeedback,
    this.statements = const [],
  });

  final String contentOutcome;
  final bool contentMatched;
  final String lessonFeedback;
  final List<Map<String, dynamic>> statements;

  bool get settles =>
      contentOutcome == AnalyticsConstants.contentCorrect ||
      contentOutcome == AnalyticsConstants.contentIncorrect;

  bool get noResponse => contentOutcome == AnalyticsConstants.contentNoResponse;
}
