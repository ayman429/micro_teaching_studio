import 'package:micro_teaching_studio/features/analytics/analytics_constants.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/pronunciation_constants.dart';

class GreetingsPartSnapshot {
  const GreetingsPartSnapshot({
    required this.reached,
    required this.attemptCount,
    required this.locked,
    required this.contentOutcome,
  });

  final bool reached;
  final int attemptCount;
  final bool locked;
  final String contentOutcome;

  bool get settled {
    if (!reached) return false;
    if (contentOutcome == AnalyticsConstants.contentCorrect ||
        contentOutcome == AnalyticsConstants.contentIncorrect) {
      return true;
    }
    if (locked) return true;
    return attemptCount >= PronunciationConstants.maxAttempts;
  }

  bool get answeredCorrectly {
    if (contentOutcome == AnalyticsConstants.contentCorrect) return true;
    if (contentOutcome == AnalyticsConstants.contentIncorrect) return false;
    return locked &&
        attemptCount > 0 &&
        attemptCount < PronunciationConstants.maxAttempts;
  }
}

class GreetingsResumePlan {
  /// `-1` when the lesson has not passed the video.
  /// `parts.length` when every question is settled.
  static int resumeIndex(List<GreetingsPartSnapshot> parts) {
    if (parts.isEmpty || parts.every((part) => !part.reached)) return -1;
    for (var index = 0; index < parts.length; index++) {
      if (!parts[index].settled) return index;
    }
    return parts.length;
  }
}
