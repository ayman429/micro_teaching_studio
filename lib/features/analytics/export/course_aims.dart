import 'package:micro_teaching_studio/features/analytics/analytics_constants.dart';
import 'package:micro_teaching_studio/features/home/models/course_progress.dart';
import 'package:micro_teaching_studio/features/phonics/models/phonics_word.dart';

enum AimStatus { achieved, attempted, notStarted }

class CourseAim {
  const CourseAim({
    required this.number,
    required this.text,
    required this.partIds,
  });

  final int number;
  final String text;
  final List<String> partIds;
}

class CourseAims {
  static const String achievedLabel = 'Achieved';
  static const String attemptedLabel = 'Attempted';
  static const String notStartedLabel = 'Not started';

  static final List<CourseAim> catalog = [
    CourseAim(
      number: 1,
      text: 'Enhance reading fluency by reading simple texts.',
      partIds: const [CourseProgressIds.fluencyPassage],
    ),
    CourseAim(
      number: 2,
      text:
          'Practice pronouncing words from sample lessons given from EFL textbooks.',
      partIds: [
        for (final word in PhonicsWord.catalog)
          CourseProgressIds.phonicsWord(word.wordKey),
      ],
    ),
    const CourseAim(
      number: 3,
      text:
          'Deliver simple greetings and giving common classroom commands confidently.',
      partIds: [
        CourseProgressIds.greetingsNoise,
        CourseProgressIds.greetingsTpr,
        CourseProgressIds.greetingsExpressions,
        CourseProgressIds.sessionQuiz,
      ],
    ),
    const CourseAim(
      number: 4,
      text:
          'Practice using simple sentences for controlling the class, and getting and maintaining attention.',
      partIds: [
        CourseProgressIds.classroomNoise,
        CourseProgressIds.classroomResponse,
        CourseProgressIds.classroomExpressions,
        CourseProgressIds.classroomQuiz,
      ],
    ),
    const CourseAim(
      number: 5,
      text: 'Pronounce target words correctly and fluently.',
      partIds: [
        CourseProgressIds.vocabCivilization,
        CourseProgressIds.vocabMagnificent,
        CourseProgressIds.vocabMonuments,
        CourseProgressIds.vocabHeritage,
      ],
    ),
    const CourseAim(
      number: 6,
      text: 'Convey the meaning of words to EFL young learners clearly.',
      partIds: [
        CourseProgressIds.vocabMonumentMeaning,
        CourseProgressIds.vocabMagnificentMeaning,
      ],
    ),
    const CourseAim(
      number: 7,
      text:
          'Use correct grammar and appropriate vocabulary while explaining the meaning of words to young learners.',
      partIds: [
        CourseProgressIds.vocabStages,
        CourseProgressIds.vocabTeacherReply,
      ],
    ),
    const CourseAim(
      number: 8,
      text:
          "Check for students' understanding of words using clear and correct English.",
      partIds: [
        CourseProgressIds.vocabStudentQuestion,
        CourseProgressIds.vocabMask,
        CourseProgressIds.vocabQuiz,
      ],
    ),
    const CourseAim(
      number: 9,
      text: 'Give clear instructions to a class in spoken English.',
      partIds: [
        CourseProgressIds.grammarWarmup,
        CourseProgressIds.grammarJump,
      ],
    ),
    const CourseAim(
      number: 10,
      text: 'Use language to start a grammar lesson clearly and fluently.',
      partIds: [
        CourseProgressIds.grammarWarmup,
        CourseProgressIds.grammarJump,
        CourseProgressIds.grammarQuiz,
      ],
    ),
    const CourseAim(
      number: 11,
      text: 'Present grammar points using clear and fluent English.',
      partIds: [
        CourseProgressIds.presentStart,
        CourseProgressIds.presentTechnique,
        CourseProgressIds.presentQuiz,
      ],
    ),
    const CourseAim(
      number: 12,
      text:
          "Answer students' clarification questions using clear and fluent language.",
      partIds: [
        CourseProgressIds.grammarMistake,
        CourseProgressIds.presentMoaz,
        CourseProgressIds.presentCorrection,
      ],
    ),
    const CourseAim(
      number: 13,
      text: 'Clarify ideas to students using clear and fluent English.',
      partIds: [
        CourseProgressIds.grammarPicture,
        CourseProgressIds.grammarEating,
        CourseProgressIds.presentPraise,
        CourseProgressIds.presentPictures,
      ],
    ),
  ];

  static bool pronunciationPart(String partType) {
    return partType == AnalyticsConstants.fluencyPassage ||
        partType == AnalyticsConstants.phonicsWord ||
        partType == AnalyticsConstants.targetWord;
  }

  static bool succeeded(Map<String, dynamic>? part) {
    if (part == null) return false;
    final type = (part['partType'] as String?)?.trim() ?? '';
    if (pronunciationPart(type) || type.isEmpty && _hasBand(part)) {
      return _band(part) == AnalyticsConstants.bandExcellent;
    }
    return (part['contentOutcome'] as String?)?.trim() ==
        AnalyticsConstants.contentCorrect;
  }

  static bool started(Map<String, dynamic>? part) {
    if (part == null) return false;
    if (succeeded(part)) return true;
    final attempts = (part['attemptCount'] as num?)?.toInt() ?? 0;
    if (attempts > 0) return true;
    final outcome = (part['contentOutcome'] as String?)?.trim() ?? '';
    if (outcome.isNotEmpty) return true;
    return _band(part).isNotEmpty;
  }

  static AimStatus statusFor(
    CourseAim aim,
    Map<String, Map<String, dynamic>> parts,
  ) {
    final docs = [for (final id in aim.partIds) parts[id]];
    if (docs.every(succeeded)) return AimStatus.achieved;
    if (docs.any(started)) return AimStatus.attempted;
    return AimStatus.notStarted;
  }

  static String labelOf(AimStatus status) {
    switch (status) {
      case AimStatus.achieved:
        return achievedLabel;
      case AimStatus.attempted:
        return attemptedLabel;
      case AimStatus.notStarted:
        return notStartedLabel;
    }
  }

  static String _band(Map<String, dynamic> part) {
    final best = (part['bestBand'] as String?)?.trim() ?? '';
    if (best.isNotEmpty) return best;
    return (part['latestBand'] as String?)?.trim() ?? '';
  }

  static bool _hasBand(Map<String, dynamic> part) => _band(part).isNotEmpty;
}
