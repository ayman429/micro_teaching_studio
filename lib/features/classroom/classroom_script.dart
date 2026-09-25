import 'package:micro_teaching_studio/common/resources/assets_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/features/analytics/analytics_constants.dart';
import 'package:micro_teaching_studio/features/greetings/greetings_script.dart';
import 'package:micro_teaching_studio/features/home/models/course_progress.dart';
import 'package:micro_teaching_studio/features/quiz/quiz_script.dart';

class ClassroomChoice {
  const ClassroomChoice({required this.textKey, required this.text});

  final String textKey;
  final String text;
}

class ClassroomQuizItem {
  const ClassroomQuizItem({
    required this.textKey,
    required this.text,
    required this.choices,
    required this.expectedIndex,
  });

  final String textKey;
  final String text;
  final List<ClassroomChoice> choices;
  final int expectedIndex;
}

class ClassroomScript {
  static const String responseText =
      "Excellent! You successfully gained the students' attention using clear and engaging call-and-response techniques. Your timing and delivery were effective, and the students responded as expected. Well done!";
  static const String quizPromptText =
      'Read the following and select the best answer.';
  static const String quizCorrectText =
      "Excellent! That's correct. You've understood how to use call-and-response and appropriate attention-getters to gain students' attention effectively.";
  static const String quizWrongText =
      "Not quite. Think about the purpose of call-and-response and how it can help you gain students' attention without shouting. Try again.";
  static const String quizReviewText =
      "Good try! Review the options carefully and think about which one best helps you gain students' attention in a calm and effective way.";

  static final SpokenLessonPlan plan = SpokenLessonPlan(
    introKey: AppStrings.classroomVoice1,
    introAsset: AudioAssets.classroomVoice(1),
    videoAsset: AudioAssets.classroomVideo(),
    reflectionKey: AppStrings.classroomVoice5,
    reflectionAsset: AudioAssets.classroomVoice(5),
    retryKey: AppStrings.greetingsFeedbackRetry,
    retryAsset: AudioAssets.classroomTryAgain(),
    retryText: GreetingsScript.retryText,
    exhaustedKey: AppStrings.greetingsFeedbackExhausted,
    exhaustedAsset: AudioAssets.classroomExhausted(),
    exhaustedText: GreetingsScript.exhaustedText,
    noResponseText: GreetingsScript.noResponseText,
    questions: [
      GreetingsQuestion(
        partId: CourseProgressIds.classroomNoise,
        promptKey: AppStrings.classroomVoice2,
        voiceAsset: AudioAssets.classroomVoice(2),
        referenceText: 'The students are making noise again.',
        successKey: AppStrings.classroomFeedbackExcellent,
        successAsset: AudioAssets.greetingsExcellent(),
        successText: 'Excellent!',
        matches: matchesNoiseAgain,
      ),
      GreetingsQuestion(
        partId: CourseProgressIds.classroomResponse,
        promptKey: AppStrings.classroomVoice3,
        voiceAsset: AudioAssets.classroomVoice(3),
        referenceText:
            'The teacher responded by doing physical actions and asking students to imitate him.',
        successKey: AppStrings.classroomFeedbackResponse,
        successAsset: AudioAssets.classroomTrue(),
        successText: responseText,
        matches: matchesTeacherResponse,
      ),
      GreetingsQuestion(
        partId: CourseProgressIds.classroomExpressions,
        promptKey: AppStrings.classroomVoice4,
        voiceAsset: AudioAssets.classroomVoice(4),
        referenceText:
            'The teacher said: clap, clap, clap. If you can hear my voice imitate me. If you can hear my voice copy me. Class, class, class. One, two, three, eyes on me and students say: one two eyes on you, then the teacher says: macaroni and cheese, and students respond everybody freeze. Everyone hands up, hands on shoulders, hands on lips. Lips are zipped.',
        successKey: AppStrings.classroomFeedbackExcellent,
        successAsset: AudioAssets.greetingsExcellent(),
        successText: 'Excellent!',
        matches: matchesAttentionExpressions,
      ),
    ],
  );

  static const List<ClassroomQuizItem> quizItems = [
    ClassroomQuizItem(
      textKey: AppStrings.classroomQuizQuestion1,
      text: 'A call-and-response technique means …….',
      expectedIndex: 1,
      choices: [
        ClassroomChoice(
          textKey: AppStrings.classroomQuiz1a,
          text: 'Being firm to the students to control over the class.',
        ),
        ClassroomChoice(
          textKey: AppStrings.classroomQuiz1b,
          text: 'Giving students physical commands and asking them to respond.',
        ),
        ClassroomChoice(
          textKey: AppStrings.classroomQuiz1c,
          text: 'Asking students to repeat things after the teacher.',
        ),
      ],
    ),
    ClassroomQuizItem(
      textKey: AppStrings.classroomQuizQuestion2,
      text:
          'Which of the following is a suitable classroom action when the class goes into mess?',
      expectedIndex: 2,
      choices: [
        ClassroomChoice(
          textKey: AppStrings.classroomQuiz2a,
          text:
              'Starting directly to explain the lesson and students will get quiet gradually.',
        ),
        ClassroomChoice(
          textKey: AppStrings.classroomQuiz2b,
          text:
              'Shouting at the students to get their attention and control the situation.',
        ),
        ClassroomChoice(
          textKey: AppStrings.classroomQuiz2c,
          text:
              'Using suitable attention getters and call-and-response techniques.',
        ),
      ],
    ),
  ];

  static List<String> introAssets() => [
        AudioAssets.classroomQuizFirst(),
        AudioAssets.classroomQuizSecond(),
      ];

  static bool matchesQuiz(List<int?> selections) {
    if (selections.length != quizItems.length) return false;
    for (var index = 0; index < quizItems.length; index++) {
      if (selections[index] != quizItems[index].expectedIndex) return false;
    }
    return true;
  }

  static QuizGrade gradeQuiz({
    required bool matched,
    required int nextAttempt,
  }) {
    if (matched) {
      return const QuizGrade(
        outcome: AnalyticsConstants.contentCorrect,
        tone: QuizTone.correct,
        feedbackKey: AppStrings.classroomQuizCorrect,
        feedbackText: quizCorrectText,
        settles: true,
      );
    }
    if (nextAttempt <= 1) {
      return const QuizGrade(
        outcome: AnalyticsConstants.contentRetry,
        tone: QuizTone.wrong,
        feedbackKey: AppStrings.classroomQuizWrong,
        feedbackText: quizWrongText,
        settles: false,
      );
    }
    final last = nextAttempt >= 3;
    return QuizGrade(
      outcome: last
          ? AnalyticsConstants.contentIncorrect
          : AnalyticsConstants.contentRetry,
      tone: QuizTone.review,
      feedbackKey: AppStrings.classroomQuizRetry,
      feedbackText: quizReviewText,
      settles: last,
    );
  }

  static String audioFor(QuizTone tone) {
    switch (tone) {
      case QuizTone.correct:
        return AudioAssets.classroomQuizCorrect();
      case QuizTone.wrong:
        return AudioAssets.classroomQuizTryAgain();
      case QuizTone.review:
        return AudioAssets.classroomQuizReview();
      case QuizTone.none:
        return '';
    }
  }

  static List<Map<String, dynamic>> records(
    List<int?> selections, {
    required bool graded,
  }) {
    return [
      for (var index = 0; index < quizItems.length; index++)
        {
          'index': index + 1,
          'text': quizItems[index].text,
          'answered': selections[index] != null,
          'selected': selections[index] ?? -1,
          'selectedText': _choiceText(index, selections[index]),
          'expected': quizItems[index].expectedIndex,
          'expectedText': quizItems[index]
              .choices[quizItems[index].expectedIndex]
              .text,
          'matched':
              graded && selections[index] == quizItems[index].expectedIndex,
        },
    ];
  }

  static String _choiceText(int question, int? choice) {
    if (choice == null) return '';
    final choices = quizItems[question].choices;
    if (choice < 0 || choice >= choices.length) return '';
    return choices[choice].text;
  }

  static List<int?> selectionsFrom(Object? raw) {
    final selections = List<int?>.filled(quizItems.length, null);
    if (raw is! List) return selections;
    for (final item in raw) {
      if (item is! Map) continue;
      final index = (item['index'] as num?)?.toInt() ?? 0;
      if (index < 1 || index > quizItems.length) continue;
      if (item['answered'] != true) continue;
      final selected = (item['selected'] as num?)?.toInt();
      if (selected == null || selected < 0) continue;
      selections[index - 1] = selected;
    }
    return selections;
  }
}

bool matchesNoiseAgain(String heard) {
  final text = normalizeSpoken(heard);
  final affirmed = text.contains('students') &&
      (text.contains('noise') || text.contains('noisy')) &&
      text.contains('again');
  final denied = text.contains('not') ||
      text.contains('no noise') ||
      text.contains('quiet') ||
      text.contains('arent') ||
      text.contains('dont');
  return affirmed && !denied;
}

bool matchesTeacherResponse(String heard) {
  final text = normalizeSpoken(heard);
  final physical = text.contains('physical') || text.contains('action');
  final imitate = text.contains('imitat') || text.contains('copy');
  return text.contains('teacher') && physical && imitate;
}

bool matchesAttentionExpressions(String heard) {
  final text = normalizeSpoken(heard);
  final checks = <bool>[
    text.contains('clap'),
    text.contains('imitate me') || text.contains('imitate'),
    text.contains('copy me') || text.contains('copy'),
    text.contains('class class'),
    text.contains('eyes on me'),
    text.contains('eyes on you'),
    text.contains('macaroni'),
    text.contains('freeze'),
    text.contains('hands up'),
    text.contains('shoulders'),
    text.contains('lips') || text.contains('zipped'),
  ];
  var hits = 0;
  for (final check in checks) {
    if (check) hits++;
  }
  return hits >= 7;
}
