import 'package:micro_teaching_studio/common/resources/assets_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/features/analytics/analytics_constants.dart';

enum QuizTone { none, correct, wrong, review }

class QuizStatement {
  const QuizStatement({
    required this.textKey,
    required this.text,
    required this.expected,
  });

  final String textKey;
  final String text;
  final bool expected;
}

class QuizGrade {
  const QuizGrade({
    required this.outcome,
    required this.tone,
    required this.feedbackKey,
    required this.feedbackText,
    required this.settles,
  });

  final String outcome;
  final QuizTone tone;
  final String feedbackKey;
  final String feedbackText;
  final bool settles;
}

class QuizScript {
  static const String promptText =
      'Decide whether the following statements are true or false.';
  static const String correctText =
      "Correct! Well done. You understand the appropriate techniques for managing students' behavior and gaining their attention.";
  static const String wrongText =
      "Not quite. Think about the most effective way to gain students' attention without increasing the noise or relying on inappropriate techniques. Try again.";
  static const String reviewText =
      "Good try! Review the statements carefully and think about which techniques help you gain students' attention calmly and effectively.";

  static const List<QuizStatement> statements = [
    QuizStatement(
      textKey: AppStrings.quizStatement1,
      text:
          'When the class is noisy and students are not paying attention, the teacher gives them instructions in Arabic to control the situation.',
      expected: false,
    ),
    QuizStatement(
      textKey: AppStrings.quizStatement2,
      text:
          "Rewarding students is a suitable technique to manage students' behaviors and get their attention to your lesson.",
      expected: true,
    ),
    QuizStatement(
      textKey: AppStrings.quizStatement3,
      text:
          'Speaking loudly is the best choice to break the noise inside the class.',
      expected: false,
    ),
  ];

  static bool matches(List<bool?> selections) {
    if (selections.length != statements.length) return false;
    for (var index = 0; index < statements.length; index++) {
      if (selections[index] != statements[index].expected) return false;
    }
    return true;
  }

  static QuizGrade grade({
    required bool matched,
    required int nextAttempt,
  }) {
    if (matched) {
      return const QuizGrade(
        outcome: AnalyticsConstants.contentCorrect,
        tone: QuizTone.correct,
        feedbackKey: AppStrings.quizFeedbackCorrect,
        feedbackText: correctText,
        settles: true,
      );
    }
    if (nextAttempt <= 1) {
      return const QuizGrade(
        outcome: AnalyticsConstants.contentRetry,
        tone: QuizTone.wrong,
        feedbackKey: AppStrings.quizFeedbackWrong,
        feedbackText: wrongText,
        settles: false,
      );
    }
    final last = nextAttempt >= 3;
    return QuizGrade(
      outcome: last
          ? AnalyticsConstants.contentIncorrect
          : AnalyticsConstants.contentRetry,
      tone: QuizTone.review,
      feedbackKey: AppStrings.quizFeedbackRetry,
      feedbackText: reviewText,
      settles: last,
    );
  }

  static String audioFor(QuizTone tone) {
    switch (tone) {
      case QuizTone.correct:
        return AudioAssets.quizCorrect();
      case QuizTone.wrong:
        return AudioAssets.quizTryAgain();
      case QuizTone.review:
        return AudioAssets.quizReview();
      case QuizTone.none:
        return '';
    }
  }

  static List<Map<String, dynamic>> records(
    List<bool?> selections, {
    required bool graded,
  }) {
    return [
      for (var index = 0; index < statements.length; index++)
        {
          'index': index + 1,
          'text': statements[index].text,
          'answered': selections[index] != null,
          'selected': selections[index] ?? false,
          'expected': statements[index].expected,
          'matched': graded && selections[index] == statements[index].expected,
        },
    ];
  }

  static List<bool?> selectionsFrom(Object? raw) {
    final selections = List<bool?>.filled(statements.length, null);
    if (raw is! List) return selections;
    for (final item in raw) {
      if (item is! Map) continue;
      final index = (item['index'] as num?)?.toInt() ?? 0;
      if (index < 1 || index > statements.length) continue;
      if (item['answered'] == true) {
        selections[index - 1] = item['selected'] == true;
      }
    }
    return selections;
  }

  static QuizTone toneFor({
    required String outcome,
    required int attemptCount,
  }) {
    if (outcome == AnalyticsConstants.contentCorrect) return QuizTone.correct;
    if (outcome == AnalyticsConstants.contentIncorrect) return QuizTone.review;
    if (outcome == AnalyticsConstants.contentRetry) {
      return attemptCount <= 1 ? QuizTone.wrong : QuizTone.review;
    }
    return QuizTone.none;
  }
}
