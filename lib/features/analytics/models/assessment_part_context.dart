import 'package:easy_localization/easy_localization.dart';
import 'package:micro_teaching_studio/features/analytics/analytics_constants.dart';
import 'package:micro_teaching_studio/features/home/models/course_progress.dart';
import 'package:micro_teaching_studio/features/home/models/home_module.dart';
import 'package:micro_teaching_studio/features/phonics/models/phonics_word.dart';

class AssessmentPartContext {
  const AssessmentPartContext({
    required this.partId,
    required this.partType,
    required this.moduleNumber,
    required this.sessionNumber,
    required this.moduleTitle,
    required this.sessionTitle,
    required this.partLabel,
    required this.referenceText,
    this.referenceIpa,
  });

  final String partId;
  final String partType;
  final int moduleNumber;
  final int sessionNumber;
  final String moduleTitle;
  final String sessionTitle;
  final String partLabel;
  final String referenceText;
  final String? referenceIpa;

  bool get isPhonics => partType == AnalyticsConstants.phonicsWord;

  String get itemKind {
    if (partType == AnalyticsConstants.fluencyPassage) {
      return AnalyticsConstants.itemParagraph;
    }
    if (partType == AnalyticsConstants.phonicsWord ||
        partType == AnalyticsConstants.targetWord) {
      return AnalyticsConstants.itemWord;
    }
    if (partType == AnalyticsConstants.spokenResponse) {
      return AnalyticsConstants.itemSpoken;
    }
    if (partType == AnalyticsConstants.trueFalseQuiz) {
      return AnalyticsConstants.itemQuiz;
    }
    return AnalyticsConstants.itemSession;
  }

  String get itemName {
    if (partType == AnalyticsConstants.fluencyPassage) {
      return AnalyticsConstants.fluencyItemName;
    }
    return partLabel;
  }

  factory AssessmentPartContext.fluency({required String referenceText}) {
    return AssessmentPartContext.fromPartId(
      CourseProgressIds.fluencyPassage,
      referenceText: referenceText,
    );
  }

  factory AssessmentPartContext.phonics({
    required PhonicsWord word,
    required String referenceText,
    required String referenceIpa,
  }) {
    return AssessmentPartContext.fromPartId(
      CourseProgressIds.phonicsWord(word.wordKey),
      referenceText: referenceText,
      referenceIpa: referenceIpa,
    );
  }

  factory AssessmentPartContext.fromPartId(
    String partId, {
    String? referenceText,
    String? referenceIpa,
  }) {
    final parsed = _parsePartId(partId);
    final module = HomeModule.catalog.firstWhere(
      (item) => item.number == parsed.moduleNumber,
      orElse: () => HomeModule.catalog.first,
    );
    final session = module.sessions.firstWhere(
      (item) => item.number == parsed.sessionNumber,
      orElse: () => module.sessions.first,
    );
    return AssessmentPartContext(
      partId: partId,
      partType: parsed.partType,
      moduleNumber: parsed.moduleNumber,
      sessionNumber: parsed.sessionNumber,
      moduleTitle: module.titleKey.tr(),
      sessionTitle: session.labelKey.tr(),
      partLabel: parsed.partLabel,
      referenceText: referenceText ?? parsed.partLabel,
      referenceIpa: referenceIpa,
    );
  }

  static _ParsedPart _parsePartId(String partId) {
    final segments = partId.split('-');
    final moduleNumber =
        segments.isNotEmpty ? int.tryParse(segments[0]) ?? 0 : 0;
    final sessionNumber =
        segments.length > 1 ? int.tryParse(segments[1]) ?? 0 : 0;
    final key = segments.length > 2 ? segments.sublist(2).join('-') : partId;
    if (partId == CourseProgressIds.fluencyPassage ||
        key == AnalyticsConstants.passageLabel) {
      return _ParsedPart(
        moduleNumber: moduleNumber,
        sessionNumber: sessionNumber,
        partType: AnalyticsConstants.fluencyPassage,
        partLabel: AnalyticsConstants.passageLabel,
      );
    }
    if (key == AnalyticsConstants.sessionKey) {
      return _ParsedPart(
        moduleNumber: moduleNumber,
        sessionNumber: sessionNumber,
        partType: AnalyticsConstants.sessionUnit,
        partLabel: AnalyticsConstants.sessionKey,
      );
    }
    final targetWord = _targetWord(moduleNumber, sessionNumber, key);
    if (targetWord != null) {
      return _ParsedPart(
        moduleNumber: moduleNumber,
        sessionNumber: sessionNumber,
        partType: AnalyticsConstants.targetWord,
        partLabel: targetWord,
      );
    }
    final spokenLabel = _spokenLabel(moduleNumber, sessionNumber, key);
    if (spokenLabel != null) {
      return _ParsedPart(
        moduleNumber: moduleNumber,
        sessionNumber: sessionNumber,
        partType: AnalyticsConstants.spokenResponse,
        partLabel: spokenLabel,
      );
    }
    if (key == 'quiz') {
      return _ParsedPart(
        moduleNumber: moduleNumber,
        sessionNumber: sessionNumber,
        partType: AnalyticsConstants.trueFalseQuiz,
        partLabel: 'Quiz',
      );
    }
    return _ParsedPart(
      moduleNumber: moduleNumber,
      sessionNumber: sessionNumber,
      partType: AnalyticsConstants.phonicsWord,
      partLabel: key.tr(),
    );
  }
}

String? _spokenLabel(int module, int session, String key) {
  if (module == 2 && session == 1) {
    return const {
      'q1': 'Classroom noise',
      'q2': 'TPR',
      'q3': 'Classroom expressions',
    }[key];
  }
  if (module == 2 && session == 2) {
    return const {
      'q1': 'Noise again',
      'q2': 'Teacher response',
      'q3': 'Attention expressions',
    }[key];
  }
  if (module == 3 && session == 1) {
    return const {
      'q1': 'Teaching stages',
      'q2': 'Monument explanation',
      'q3': 'Student question',
      'q4': 'Teacher response',
      'q5': 'Magnificent explanation',
      'q6': 'Mask question',
    }[key];
  }
  if (module == 3 && session == 2) {
    return const {
      'q1': 'Movement warm-up',
      'q2': 'Jump and say',
      'q3': 'Mistake reaction',
      'q4': 'Eating picture',
      'q5': 'Eating correction',
    }[key];
  }
  if (module == 3 && session == 3) {
    return const {
      'q1': 'Lesson start',
      'q2': 'TPR drinking',
      'q3': 'Positive reinforcement',
      'q4': 'Moaz technique',
      'q5': 'Mistake correction',
      'q6': 'Picture practice',
    }[key];
  }
  return null;
}

String? _targetWord(int module, int session, String key) {
  if (module == 3 && session == 1) {
    return const {
      'w1': 'Civilization',
      'w2': 'Magnificent',
      'w3': 'monuments',
      'w4': 'Heritage',
    }[key];
  }
  return null;
}

class _ParsedPart {
  const _ParsedPart({
    required this.moduleNumber,
    required this.sessionNumber,
    required this.partType,
    required this.partLabel,
  });

  final int moduleNumber;
  final int sessionNumber;
  final String partType;
  final String partLabel;
}
