import 'package:micro_teaching_studio/common/resources/assets_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/features/greetings/greetings_script.dart';
import 'package:micro_teaching_studio/features/home/models/course_progress.dart';

class VocabTurn {
  const VocabTurn({
    required this.partId,
    required this.promptKey,
    required this.voiceAsset,
    required this.referenceText,
    required this.pronunciation,
    required this.maxAttempts,
    required this.successKey,
    required this.successAsset,
    required this.successText,
    this.matches,
  });

  final String partId;
  final String promptKey;
  final String voiceAsset;
  final String referenceText;
  final bool pronunciation;
  final int maxAttempts;
  final String successKey;
  final String successAsset;
  final String successText;
  final bool Function(String heard)? matches;
}

class VocabScript {
  static const int wordAttempts = 5;
  static const int questionAttempts = 3;
  static const String wordSuccessText =
      'Excellent! You successfully practiced the target word.';
  static const String questionSuccessText = 'Excellent.';
  static const String retryText = 'Please try again';
  static const String exhaustedText =
      "Good effort! You've used all three attempts. Review the lesson and try again when you're ready.";
  static const String noResponseText = 'No response';
  static const String quizReference = 'magnificent monuments heritage';
  static const String quizCorrectText =
      "Excellent! Well done. You've correctly identified the vocabulary and pronounced the words accurately.";
  static const String quizWrongText =
      'Not quite. Review the meaning of the words carefully and try again.';
  static const String quizReviewText =
      'Good try! Think about the meaning of each word and pronounce it carefully. You can do it!';

  static final List<VocabTurn> words = [
    VocabTurn(
      partId: CourseProgressIds.vocabCivilization,
      promptKey: AppStrings.vocabVoice1,
      voiceAsset: AudioAssets.vocabVoice(1),
      referenceText: 'Civilization',
      pronunciation: true,
      maxAttempts: wordAttempts,
      successKey: AppStrings.vocabWordExcellent,
      successAsset: AudioAssets.vocabFeed(),
      successText: wordSuccessText,
    ),
    VocabTurn(
      partId: CourseProgressIds.vocabMagnificent,
      promptKey: AppStrings.vocabVoice2,
      voiceAsset: AudioAssets.vocabVoice(2),
      referenceText: 'Magnificent',
      pronunciation: true,
      maxAttempts: wordAttempts,
      successKey: AppStrings.vocabWordExcellent,
      successAsset: AudioAssets.vocabFeed(),
      successText: wordSuccessText,
    ),
    VocabTurn(
      partId: CourseProgressIds.vocabMonuments,
      promptKey: AppStrings.vocabVoice3,
      voiceAsset: AudioAssets.vocabVoice(3),
      referenceText: 'monuments',
      pronunciation: true,
      maxAttempts: wordAttempts,
      successKey: AppStrings.vocabWordExcellent,
      successAsset: AudioAssets.vocabFeed(),
      successText: wordSuccessText,
    ),
    VocabTurn(
      partId: CourseProgressIds.vocabHeritage,
      promptKey: AppStrings.vocabVoice4,
      voiceAsset: AudioAssets.vocabVoice(4),
      referenceText: 'Heritage',
      pronunciation: true,
      maxAttempts: wordAttempts,
      successKey: AppStrings.vocabWordExcellent,
      successAsset: AudioAssets.vocabFeed(),
      successText: wordSuccessText,
    ),
  ];

  static final List<VocabTurn> questions = [
    VocabTurn(
      partId: CourseProgressIds.vocabStages,
      promptKey: AppStrings.vocabVoice6,
      voiceAsset: AudioAssets.vocabVoice(6),
      referenceText:
          'There are three stages for teaching a word: explaining meaning, giving the definition, and concept check.',
      pronunciation: false,
      maxAttempts: questionAttempts,
      successKey: AppStrings.greetingsFeedbackExcellent,
      successAsset: AudioAssets.vocabExcellent(),
      successText: questionSuccessText,
      matches: matchesTeachingStages,
    ),
    VocabTurn(
      partId: CourseProgressIds.vocabMonumentMeaning,
      promptKey: AppStrings.vocabVoice7,
      voiceAsset: AudioAssets.vocabVoice(7),
      referenceText:
          'He asked students to look at the picture, and he explained the meaning of the word as huge special structures built in ancient Egyptian history. A building or statue with special historical importance is a monument.',
      pronunciation: false,
      maxAttempts: questionAttempts,
      successKey: AppStrings.greetingsFeedbackExcellent,
      successAsset: AudioAssets.vocabExcellent(),
      successText: questionSuccessText,
      matches: matchesMonumentExplanation,
    ),
    VocabTurn(
      partId: CourseProgressIds.vocabStudentQuestion,
      promptKey: AppStrings.vocabVoice8,
      voiceAsset: AudioAssets.vocabVoice(8),
      referenceText:
          "The student asked: is the new shopping mall next to my house a monument? It's very big and built out of stone.",
      pronunciation: false,
      maxAttempts: questionAttempts,
      successKey: AppStrings.greetingsFeedbackExcellent,
      successAsset: AudioAssets.vocabExcellent(),
      successText: questionSuccessText,
      matches: matchesStudentMallQuestion,
    ),
    VocabTurn(
      partId: CourseProgressIds.vocabTeacherReply,
      promptKey: AppStrings.vocabVoice9,
      voiceAsset: AudioAssets.vocabVoice(9),
      referenceText:
          "The teacher thanked the student and pointed out the difference: the mall is big and beautiful, but is it a very old building built by the pharaohs to show our history, like the pyramids?",
      pronunciation: false,
      maxAttempts: questionAttempts,
      successKey: AppStrings.greetingsFeedbackExcellent,
      successAsset: AudioAssets.vocabExcellent(),
      successText: questionSuccessText,
      matches: matchesTeacherReply,
    ),
    VocabTurn(
      partId: CourseProgressIds.vocabMagnificentMeaning,
      promptKey: AppStrings.vocabVoice10,
      voiceAsset: AudioAssets.vocabVoice(10),
      referenceText:
          'The teacher defined the word as magnificent means very beautiful and grand, and then he drew a small stick figure on the board and asked if it is magnificent.',
      pronunciation: false,
      maxAttempts: questionAttempts,
      successKey: AppStrings.greetingsFeedbackExcellent,
      successAsset: AudioAssets.vocabExcellent(),
      successText: questionSuccessText,
      matches: matchesMagnificentExplanation,
    ),
    VocabTurn(
      partId: CourseProgressIds.vocabMask,
      promptKey: AppStrings.vocabVoice11,
      voiceAsset: AudioAssets.vocabVoice(11),
      referenceText:
          "What about the golden mask of Tutankhamun, is it magnificent? Students answered yes, because it's beautiful and shiny.",
      pronunciation: false,
      maxAttempts: questionAttempts,
      successKey: AppStrings.greetingsFeedbackExcellent,
      successAsset: AudioAssets.vocabExcellent(),
      successText: questionSuccessText,
      matches: matchesMaskQuestion,
    ),
  ];
}

bool matchesTeachingStages(String heard) {
  final text = normalizeSpoken(heard);
  final check = text.contains('concept') ||
      (text.contains('check') && text.contains('understand'));
  return text.contains('meaning') && text.contains('definition') && check;
}

bool matchesMonumentExplanation(String heard) {
  final text = normalizeSpoken(heard);
  final historic = text.contains('ancient') ||
      text.contains('egypt') ||
      text.contains('history') ||
      text.contains('huge') ||
      text.contains('special');
  final built = text.contains('structure') ||
      text.contains('building') ||
      text.contains('statue');
  return text.contains('picture') &&
      text.contains('monument') &&
      historic &&
      built;
}

bool matchesStudentMallQuestion(String heard) {
  final text = normalizeSpoken(heard);
  final place = text.contains('mall') || text.contains('shopping');
  final size = text.contains('big') || text.contains('huge') || text.contains('stone');
  return place && text.contains('monument') && size;
}

bool matchesTeacherReply(String heard) {
  final text = normalizeSpoken(heard);
  final thanks = text.contains('thank');
  final old = text.contains('pyramid') ||
      text.contains('pharaoh') ||
      text.contains('pharo');
  return thanks && old;
}

bool matchesMagnificentExplanation(String heard) {
  final text = normalizeSpoken(heard);
  final drawing = text.contains('board') ||
      text.contains('stick') ||
      text.contains('figure') ||
      text.contains('drew') ||
      text.contains('draw');
  return text.contains('magnificent') &&
      text.contains('beautiful') &&
      text.contains('grand') &&
      drawing;
}

bool matchesMaskQuestion(String heard) {
  final text = normalizeSpoken(heard);
  final object = text.contains('mask') ||
      text.contains('tut') ||
      text.contains('golden');
  final praise = text.contains('beautiful') ||
      text.contains('shiny') ||
      text.contains('magnificent');
  return object && praise;
}

bool matchesMagnificentBlank(String input) {
  return normalizeSpoken(input).split(' ').contains('magnificent');
}

bool matchesMonumentBlank(String input) {
  final words = normalizeSpoken(input).split(' ');
  return words.contains('monument') || words.contains('monuments');
}
