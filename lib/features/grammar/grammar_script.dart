import 'package:micro_teaching_studio/common/resources/assets_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/features/analytics/analytics_constants.dart';
import 'package:micro_teaching_studio/features/classroom/classroom_script.dart';
import 'package:micro_teaching_studio/features/greetings/greetings_script.dart';
import 'package:micro_teaching_studio/features/home/models/course_progress.dart';
import 'package:micro_teaching_studio/features/quiz/quiz_script.dart';

class GrammarScript {
  static const String quizPromptText =
      'What will you do in the following situations? Select the best response.';
  static const String quizCorrectText =
      "Excellent! That's the best choice. You've selected an effective way to engage young learners and gain their attention. Well done!";
  static const String quizWrongText =
      "Not quite. Think about the learners' age and the purpose of the situation. Which response would be more engaging and effective? Try again.";
  static const String quizReviewText =
      "Good try! Take another look at the situation and think about the most engaging and appropriate response. You're close!";

  static final SpokenLessonPlan plan = SpokenLessonPlan(
    introKey: AppStrings.grammarVoice1,
    introAsset: AudioAssets.grammarVoice(1),
    videoAsset: AudioAssets.grammarVideo(),
    reflectionKey: AppStrings.grammarVoice7,
    reflectionAsset: AudioAssets.grammarVoice(7),
    retryKey: AppStrings.greetingsFeedbackRetry,
    retryAsset: AudioAssets.grammarTryAgain(),
    retryText: GreetingsScript.retryText,
    exhaustedKey: AppStrings.greetingsFeedbackExhausted,
    exhaustedAsset: AudioAssets.grammarIncorrect(),
    exhaustedText: GreetingsScript.exhaustedText,
    noResponseText: GreetingsScript.noResponseText,
    questions: [
      GreetingsQuestion(
        partId: CourseProgressIds.grammarWarmup,
        promptKey: AppStrings.grammarVoice2,
        voiceAsset: AudioAssets.grammarVoice(2),
        referenceText:
            'He told students to stand up and look at him jumping. He asked them "what am I doing?" Look at me, I\'m jumping.',
        successKey: AppStrings.greetingsFeedbackExcellent,
        successAsset: AudioAssets.grammarExcellent(),
        successText: 'Excellent.',
        matches: matchesWarmupMovement,
      ),
      GreetingsQuestion(
        partId: CourseProgressIds.grammarJump,
        promptKey: AppStrings.grammarVoice3,
        voiceAsset: AudioAssets.grammarVoice(3),
        referenceText:
            'He asked students to jump and say "I\'m jumping".',
        successKey: AppStrings.greetingsFeedbackExcellent,
        successAsset: AudioAssets.grammarExcellent(),
        successText: 'Excellent.',
        matches: matchesJumpCommand,
      ),
      GreetingsQuestion(
        partId: CourseProgressIds.grammarMistake,
        promptKey: AppStrings.grammarVoice4,
        voiceAsset: AudioAssets.grammarVoice(4),
        referenceText:
            'No, the students did not respond correctly. The teacher asked them to listen carefully to the correct answer "I\'m jumping", and asked a student to repeat it.',
        successKey: AppStrings.greetingsFeedbackExcellent,
        successAsset: AudioAssets.grammarExcellent(),
        successText: 'Excellent.',
        matches: matchesJumpingMistake,
      ),
      GreetingsQuestion(
        partId: CourseProgressIds.grammarPicture,
        promptKey: AppStrings.grammarVoice5,
        voiceAsset: AudioAssets.grammarVoice(5),
        referenceText:
            'He showed them a picture of a girl eating and asked them "what is she doing?"',
        successKey: AppStrings.greetingsFeedbackExcellent,
        successAsset: AudioAssets.grammarExcellent(),
        successText: 'Excellent.',
        matches: matchesEatingPicture,
      ),
      GreetingsQuestion(
        partId: CourseProgressIds.grammarEating,
        promptKey: AppStrings.grammarVoice6,
        voiceAsset: AudioAssets.grammarVoice(6),
        referenceText:
            'The students answered incorrectly "she is…", and the teacher corrected their mistake saying "she is eating" and asking students to repeat it.',
        successKey: AppStrings.greetingsFeedbackExcellent,
        successAsset: AudioAssets.grammarExcellent(),
        successText: 'Excellent.',
        matches: matchesEatingCorrection,
      ),
    ],
  );

  static const List<ClassroomQuizItem> quizItems = [
    ClassroomQuizItem(
      textKey: AppStrings.grammarQuizQuestion1,
      text:
          'You are teaching a grammar lesson about the present continuous to young learners. What is the best action to start the lesson?',
      expectedIndex: 2,
      choices: [
        ClassroomChoice(
          textKey: AppStrings.grammarQuiz1a,
          text:
              'To start by saying "today we are talking about the present continuous which tells about things happening right now."',
        ),
        ClassroomChoice(
          textKey: AppStrings.grammarQuiz1b,
          text:
              'To start by asking them "what do you know about the present continuous?"',
        ),
        ClassroomChoice(
          textKey: AppStrings.grammarQuiz1c,
          text:
              'To start by acting out an action, e.g., jumping and asking students "what am I doing?"',
        ),
      ],
    ),
    ClassroomQuizItem(
      textKey: AppStrings.grammarQuizQuestion2,
      text:
          'You have just entered an English class making a lot of noise, talking, and not giving you any attention.',
      expectedIndex: 1,
      choices: [
        ClassroomChoice(
          textKey: AppStrings.grammarQuiz2a,
          text: 'Shout loudly at the class asking them to stop talking.',
        ),
        ClassroomChoice(
          textKey: AppStrings.grammarQuiz2b,
          text:
              'Start with an attention getter activity like a total physical response.',
        ),
        ClassroomChoice(
          textKey: AppStrings.grammarQuiz2c,
          text:
              'Start explaining the lesson directly and gradually they will get calmer.',
        ),
      ],
    ),
  ];

  static List<String> introAssets() => [
        AudioAssets.grammarQuizClip(1),
        AudioAssets.grammarQuizClip(2),
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
        feedbackKey: AppStrings.grammarQuizCorrect,
        feedbackText: quizCorrectText,
        settles: true,
      );
    }
    if (nextAttempt <= 1) {
      return const QuizGrade(
        outcome: AnalyticsConstants.contentRetry,
        tone: QuizTone.wrong,
        feedbackKey: AppStrings.grammarQuizWrong,
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
      feedbackKey: AppStrings.grammarQuizRetry,
      feedbackText: quizReviewText,
      settles: last,
    );
  }

  static String audioFor(QuizTone tone) {
    switch (tone) {
      case QuizTone.correct:
        return AudioAssets.grammarQuizCorrect();
      case QuizTone.wrong:
        return AudioAssets.grammarQuizTryAgain();
      case QuizTone.review:
        return AudioAssets.grammarQuizReview();
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

bool matchesWarmupMovement(String heard) {
  final text = normalizeSpoken(heard);
  final stand = text.contains('stand');
  final jump = text.contains('jump');
  final model = text.contains('what am i doing') ||
      text.contains('i m jumping') ||
      text.contains('i am jumping') ||
      text.contains('look at me');
  return stand && jump && model;
}

bool matchesJumpCommand(String heard) {
  final text = normalizeSpoken(heard);
  final jumping =
      text.contains('i m jumping') || text.contains('i am jumping');
  return text.contains('student') && text.contains('jump') && jumping;
}

bool matchesJumpingMistake(String heard) {
  final text = normalizeSpoken(heard);
  final wrong = text.contains('incorrect') ||
      text.contains('wrong') ||
      text.contains('did not') ||
      text.contains('didn t') ||
      text.contains('not correct');
  final repair = text.contains('listen') || text.contains('repeat');
  return wrong && text.contains('jump') && repair;
}

bool matchesEatingPicture(String heard) {
  final text = normalizeSpoken(heard);
  final picture = text.contains('picture') ||
      text.contains('photo') ||
      text.contains('image');
  final girl = text.contains('girl') || text.contains('she');
  final asked = text.contains('what is she doing') ||
      text.contains('what she is doing');
  return picture && girl && text.contains('eat') && asked;
}

bool matchesEatingCorrection(String heard) {
  final text = normalizeSpoken(heard);
  final wrong = text.contains('incorrect') ||
      text.contains('wrong') ||
      text.contains('not');
  final eating = text.contains('eating');
  return wrong && eating && text.contains('repeat');
}
