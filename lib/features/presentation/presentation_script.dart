import 'package:micro_teaching_studio/common/resources/assets_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/features/analytics/analytics_constants.dart';
import 'package:micro_teaching_studio/features/classroom/classroom_script.dart';
import 'package:micro_teaching_studio/features/greetings/greetings_script.dart';
import 'package:micro_teaching_studio/features/home/models/course_progress.dart';
import 'package:micro_teaching_studio/features/quiz/quiz_script.dart';

class PresentationScript {
  static const String quizPromptText =
      'What do you think of the following action?';
  static const String quizQuestionText =
      'A student teacher starts his grammar lesson about the present continuous by writing examples on the board, and asking students to copy them in their notebooks, and this is the whole thing. The teacher believes that students have understood everything.';
  static const String quizCorrectText =
      "Excellent! That's correct. Teaching grammar effectively requires more than copying examples. The teacher should use engaging activities and provide opportunities for students to practice and demonstrate their understanding.";
  static const String quizWrongText =
      'Not quite. Think about whether simply copying examples is enough to help students understand and use the present continuous. Try again.';
  static const String quizReviewText =
      'Good try! Think about what else the teacher should do to make sure students understand and can use the present continuous. Try again.';

  static final SpokenLessonPlan plan = SpokenLessonPlan(
    introKey: AppStrings.presentationVoice1,
    introAsset: AudioAssets.presentationVoice(1),
    videoAsset: AudioAssets.presentationVideo(),
    reflectionKey: AppStrings.presentationVoice8,
    reflectionAsset: AudioAssets.presentationVoice(8),
    retryKey: AppStrings.greetingsFeedbackRetry,
    retryAsset: AudioAssets.presentationTryAgain(),
    retryText: GreetingsScript.retryText,
    exhaustedKey: AppStrings.greetingsFeedbackExhausted,
    exhaustedAsset: AudioAssets.presentationIncorrect(),
    exhaustedText: GreetingsScript.exhaustedText,
    noResponseText: GreetingsScript.noResponseText,
    questions: [
      GreetingsQuestion(
        partId: CourseProgressIds.presentStart,
        promptKey: AppStrings.presentationVoice2,
        voiceAsset: AudioAssets.presentationVoice(2),
        referenceText:
            'He started the lesson by motivating students saying "today, we are going to do something very exciting but first look at me."',
        successKey: AppStrings.greetingsFeedbackExcellent,
        successAsset: AudioAssets.presentationExcellent(),
        successText: 'Excellent.',
        redWords: [
          'today',
          'we',
          'are',
          'going',
          'to',
          'do',
          'something',
          'very',
          'exciting',
          'but',
          'first',
          'look',
          'at',
          'me',
        ],
      ),
      GreetingsQuestion(
        partId: CourseProgressIds.presentTechnique,
        promptKey: AppStrings.presentationVoice3,
        voiceAsset: AudioAssets.presentationVoice(3),
        referenceText:
            'He used TPR when he asked the students to look at him drinking water and he asked Moaz "what am I doing right now?"',
        successKey: AppStrings.greetingsFeedbackExcellent,
        successAsset: AudioAssets.presentationExcellent(),
        successText: 'Excellent.',
        redWords: [
          'he',
          'used',
          'tpr',
          'drinking',
          'water',
          'what',
          'am',
          'i',
          'doing',
        ],
      ),
      GreetingsQuestion(
        partId: CourseProgressIds.presentPraise,
        promptKey: AppStrings.presentationVoice4,
        voiceAsset: AudioAssets.presentationVoice(4),
        referenceText:
            'He said "excellent" to reinforce Farida\'s right answer, and encouraged Moaz by saying "keep up the good work."',
        successKey: AppStrings.greetingsFeedbackExcellent,
        successAsset: AudioAssets.presentationExcellent(),
        successText: 'Excellent.',
        redWords: [
          'excellent',
          'farida',
          'answer',
          'moaz',
          'keep',
          'up',
          'the',
          'good',
          'work',
        ],
      ),
      GreetingsQuestion(
        partId: CourseProgressIds.presentMoaz,
        promptKey: AppStrings.presentationVoice5,
        voiceAsset: AudioAssets.presentationVoice(5),
        referenceText:
            'Yes, he used the suitable technique because he used acting, so students can see the action by themselves and understand the meaning of an action happening right now.',
        successKey: AppStrings.greetingsFeedbackExcellent,
        successAsset: AudioAssets.presentationExcellent(),
        successText: 'Excellent.',
        redWords: [
          'yes',
          'he',
          'used',
          'the',
          'suitable',
          'technique',
          'acting',
          'see',
          'the',
          'action',
          'understand',
          'the',
          'meaning',
          'action',
          'happening',
          'now',
        ],
      ),
      GreetingsQuestion(
        partId: CourseProgressIds.presentCorrection,
        promptKey: AppStrings.presentationVoice6,
        voiceAsset: AudioAssets.presentationVoice(6),
        referenceText:
            'Yes, it\'s effective because he used indirect teacher correction, by repeating the students\' answer in a correct way. When the students said "he write, writing notebook teacher", he repeated it correctly.',
        successKey: AppStrings.greetingsFeedbackExcellent,
        successAsset: AudioAssets.presentationExcellent(),
        successText: 'Excellent.',
        redWords: [
          'yes',
          "it's",
          'effective',
          'because',
          'he',
          'used',
          'indirect',
          'teacher',
          'correction',
          'repeating',
          'the',
          'students',
          'answer',
          'in',
          'a',
          'correct',
          'way',
          'the',
          'students',
          'said',
          'he',
          'write',
          'writing',
          'notebook',
          'teacher',
          'he',
          'repeated',
          'it',
          'correctly',
        ],
      ),
      GreetingsQuestion(
        partId: CourseProgressIds.presentPictures,
        promptKey: AppStrings.presentationVoice7,
        voiceAsset: AudioAssets.presentationVoice(7),
        referenceText:
            'The teacher showed students some pictures on the board and asked them what is the person in the picture doing and they wrote sentences on the board.',
        successKey: AppStrings.greetingsFeedbackExcellent,
        successAsset: AudioAssets.presentationExcellent(),
        successText: 'Excellent.',
        redWords: [
          'pictures',
          'on',
          'the',
          'board',
          'and',
          'asked',
          'what',
          'is',
          'the',
          'person',
          'in',
          'the',
          'picture',
          'doing',
          'and',
          'they',
          'wrote',
          'sentences',
          'on',
          'the',
          'board',
        ],
      ),
    ],
  );

  static const List<ClassroomQuizItem> quizItems = [
    ClassroomQuizItem(
      textKey: AppStrings.presentationQuizQuestion,
      text: quizQuestionText,
      expectedIndex: 2,
      choices: [
        ClassroomChoice(
          textKey: AppStrings.presentationQuizA,
          text:
              'This is the perfect action to teach students the present continuous.',
        ),
        ClassroomChoice(
          textKey: AppStrings.presentationQuizB,
          text:
              'This would be the perfect action, if the teacher asks students to do activities from the textbook.',
        ),
        ClassroomChoice(
          textKey: AppStrings.presentationQuizC,
          text:
              'This is not suitable, and the teacher should have followed different steps.',
        ),
      ],
    ),
  ];

  static List<String> introAssets() => [AudioAssets.presentationQuizPrompt()];

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
        feedbackKey: AppStrings.presentationQuizCorrect,
        feedbackText: quizCorrectText,
        settles: true,
      );
    }
    if (nextAttempt <= 1) {
      return const QuizGrade(
        outcome: AnalyticsConstants.contentRetry,
        tone: QuizTone.wrong,
        feedbackKey: AppStrings.presentationQuizWrong,
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
      feedbackKey: AppStrings.presentationQuizRetry,
      feedbackText: quizReviewText,
      settles: last,
    );
  }

  static String audioFor(QuizTone tone) {
    switch (tone) {
      case QuizTone.correct:
        return AudioAssets.presentationQuizCorrect();
      case QuizTone.wrong:
        return AudioAssets.presentationQuizTryAgain();
      case QuizTone.review:
        return AudioAssets.presentationQuizReview();
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
          'expectedText':
              quizItems[index].choices[quizItems[index].expectedIndex].text,
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
