import 'package:micro_teaching_studio/common/resources/assets_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/features/home/models/course_progress.dart';

class GreetingsQuestion {
  const GreetingsQuestion({
    required this.partId,
    required this.promptKey,
    required this.voiceAsset,
    required this.referenceText,
    required this.successKey,
    required this.successAsset,
    required this.successText,
    required this.matches,
  });

  final String partId;
  final String promptKey;
  final String voiceAsset;
  final String referenceText;
  final String successKey;
  final String successAsset;
  final String successText;
  final bool Function(String heard) matches;
}

class SpokenLessonPlan {
  const SpokenLessonPlan({
    required this.introKey,
    required this.introAsset,
    required this.videoAsset,
    required this.reflectionKey,
    required this.reflectionAsset,
    required this.retryKey,
    required this.retryAsset,
    required this.retryText,
    required this.exhaustedKey,
    required this.exhaustedAsset,
    required this.exhaustedText,
    required this.noResponseText,
    required this.questions,
  });

  final String introKey;
  final String introAsset;
  final String videoAsset;
  final String reflectionKey;
  final String reflectionAsset;
  final String retryKey;
  final String retryAsset;
  final String retryText;
  final String exhaustedKey;
  final String exhaustedAsset;
  final String exhaustedText;
  final String noResponseText;
  final List<GreetingsQuestion> questions;
}

class GreetingsScript {
  static const String noResponseText = 'No response';
  static const String retryText = 'Please try again';
  static const String exhaustedText =
      "Good effort! You've used all three attempts. Review the lesson and try again when you're ready.";

  static final SpokenLessonPlan plan = SpokenLessonPlan(
    introKey: AppStrings.greetingsVoice1,
    introAsset: AudioAssets.greetingsVoice(1),
    videoAsset: AudioAssets.greetingsVideo(),
    reflectionKey: AppStrings.greetingsVoice5,
    reflectionAsset: AudioAssets.greetingsVoice(5),
    retryKey: AppStrings.greetingsFeedbackRetry,
    retryAsset: AudioAssets.greetingsTryAgain(),
    retryText: retryText,
    exhaustedKey: AppStrings.greetingsFeedbackExhausted,
    exhaustedAsset: AudioAssets.greetingsExhausted(),
    exhaustedText: exhaustedText,
    noResponseText: noResponseText,
    questions: questions,
  );

  static final List<GreetingsQuestion> questions = [
    GreetingsQuestion(
      partId: CourseProgressIds.greetingsNoise,
      promptKey: AppStrings.greetingsVoice2,
      voiceAsset: AudioAssets.greetingsVoice(2),
      referenceText: 'Yes, students are making a lot of noise.',
      successKey: AppStrings.greetingsFeedbackExcellent,
      successAsset: AudioAssets.greetingsExcellent(),
      successText: 'Excellent.',
      matches: matchesNoise,
    ),
    GreetingsQuestion(
      partId: CourseProgressIds.greetingsTpr,
      promptKey: AppStrings.greetingsVoice3,
      voiceAsset: AudioAssets.greetingsVoice(3),
      referenceText:
          "Yes, the teacher could manage the students' behaviors by asking them to respond to physical actions. This is called TPR (Total Physical Response).",
      successKey: AppStrings.greetingsFeedbackExcellent,
      successAsset: AudioAssets.greetingsExcellent(),
      successText: 'Excellent.',
      matches: matchesTpr,
    ),
    GreetingsQuestion(
      partId: CourseProgressIds.greetingsExpressions,
      promptKey: AppStrings.greetingsVoice4,
      voiceAsset: AudioAssets.greetingsVoice(4),
      referenceText:
          'The teacher said the following expressions: Clap once if you can hear me. Clap twice if you can hear me. Good morning my students. Everyone hands up, hands down and sit down please. Eyes on me. Books out class. Open page twenty-four. Finger on line one. Show me your fingers.',
      successKey: AppStrings.greetingsFeedbackExcellentRules,
      successAsset: AudioAssets.greetingsExcellentRules(),
      successText:
          'Excellent! This is one of the golden rules we use to manage students and maintain control of the classroom: never speak over a crowd. Use call-and-response claps to break the noise barrier first.',
      matches: matchesExpressions,
    ),
  ];
}

String normalizeSpoken(String input) {
  var text = input.toLowerCase();
  text = text.replaceAll('behaviour', 'behavior');
  text = text.replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
  text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  return text;
}

bool matchesNoise(String heard) {
  final text = normalizeSpoken(heard);
  final affirmed = text.contains('yes') &&
      text.contains('students') &&
      text.contains('noise') &&
      (text.contains('make') || text.contains('lot'));
  final denied = text.contains('not') ||
      text.contains('no noise') ||
      text.contains('quiet') ||
      text.contains('arent') ||
      text.contains('dont');
  return affirmed && !denied;
}

bool matchesTpr(String heard) {
  final text = normalizeSpoken(heard);
  final hasTpr =
      text.contains('tpr') || text.contains('total physical response');
  final hasManage = text.contains('manage') || text.contains('behavior');
  return hasTpr && hasManage && text.contains('physical');
}

bool matchesExpressions(String heard) {
  final text = normalizeSpoken(heard);
  final checks = <bool>[
    text.contains('clap once'),
    text.contains('clap twice'),
    text.contains('good morning'),
    text.contains('hands up'),
    text.contains('hands down') || text.contains('sit down'),
    text.contains('eyes on me'),
    text.contains('books out') ||
        text.contains('page 24') ||
        text.contains('twenty four'),
    text.contains('finger on line') || text.contains('show me your fingers'),
  ];
  var hits = 0;
  for (final check in checks) {
    if (check) hits++;
  }
  return hits >= 7;
}
