import 'package:micro_teaching_studio/features/pronunciation_assessment/pronunciation_constants.dart';

enum PronunciationBand { excellent, needsImprov, incorrect }

class PronunciationPhonemeCandidate {
  const PronunciationPhonemeCandidate({
    required this.phoneme,
    this.accuracy,
  });

  final String phoneme;
  final double? accuracy;
}

class PronunciationPhonemeScore {
  const PronunciationPhonemeScore({
    required this.phoneme,
    required this.accuracy,
    this.heardPhoneme,
    this.nBest = const [],
    this.phonics = false,
  });

  final String phoneme;
  final double? accuracy;
  final String? heardPhoneme;
  final List<PronunciationPhonemeCandidate> nBest;
  final bool phonics;

  PronunciationBand get band =>
      PronunciationResult.bandFromScore(accuracy, phonics: phonics);

  bool get hasWrongSound {
    final heard = heardPhoneme?.trim() ?? '';
    return heard.isNotEmpty && heard != phoneme;
  }
}

class PronunciationWordScore {
  const PronunciationWordScore({
    required this.word,
    required this.accuracy,
    required this.errorType,
    this.phonemes = const [],
    this.phonics = false,
    this.heardWord,
    this.wrongWord = false,
  });

  final String word;
  final double? accuracy;
  final String errorType;
  final List<PronunciationPhonemeScore> phonemes;
  final bool phonics;
  final String? heardWord;
  final bool wrongWord;

  bool get isInsertion => errorType.toLowerCase() == 'insertion';
  bool get isOmission => errorType.toLowerCase() == 'omission';

  PronunciationBand get band {
    if (isOmission || isInsertion || wrongWord) {
      return PronunciationBand.incorrect;
    }
    return PronunciationResult.bandFromScore(accuracy, phonics: phonics);
  }

  PronunciationPhonemeScore? get weakestPhoneme {
    PronunciationPhonemeScore? weakest;
    for (final phoneme in phonemes) {
      if (phoneme.phoneme.isEmpty) continue;
      if (weakest == null ||
          (phoneme.accuracy ?? 100) < (weakest.accuracy ?? 100)) {
        weakest = phoneme;
      }
    }
    return weakest;
  }
}

class PronunciationResult {
  const PronunciationResult({
    required this.raw,
    required this.pronScore,
    required this.accuracyScore,
    required this.fluencyScore,
    required this.completenessScore,
    required this.prosodyScore,
    required this.words,
    required this.band,
    required this.heardText,
    required this.recognitionStatus,
    required this.httpStatus,
    required this.weakestWord,
    this.weakestPhoneme,
    this.heardPhoneme,
    this.phonics = false,
  });

  final Map<String, dynamic> raw;
  final double? pronScore;
  final double? accuracyScore;
  final double? fluencyScore;
  final double? completenessScore;
  final double? prosodyScore;
  final List<PronunciationWordScore> words;
  final PronunciationBand band;
  final String? heardText;
  final String? recognitionStatus;
  final int httpStatus;
  final String? weakestWord;
  final String? weakestPhoneme;
  final String? heardPhoneme;
  final bool phonics;

  List<PronunciationWordScore> get alignedWords =>
      words.where((word) => !word.isInsertion).toList();

  static String normalizeWord(String? value) {
    return (value ?? '').toLowerCase().replaceAll(RegExp(r"[^a-z']"), '');
  }

  static String? spokenWord(String? value) {
    final tokens = (value ?? '')
        .split(RegExp(r"[^A-Za-z']+"))
        .where((token) => token.trim().isNotEmpty);
    if (tokens.isEmpty) return null;
    return tokens.first;
  }

  static bool phonicsWordMismatch(String? heard, String expected) {
    final expectedNorm = normalizeWord(expected);
    if (expectedNorm.isEmpty) return false;
    final spoken = spokenWord(heard);
    return normalizeWord(spoken ?? heard) != expectedNorm;
  }

  static double capPhonicsWrongWordScore(double? score) {
    final cap = PronunciationConstants.needsImprovMin - 1;
    final value = score ?? 0;
    return value > cap ? cap : value;
  }

  static PronunciationBand bandFromScore(
    double? score, {
    bool phonics = false,
  }) {
    final value = score ?? 0;
    final excellentMin = phonics
        ? PronunciationConstants.phonicsExcellentMin
        : PronunciationConstants.excellentMin;
    if (value >= excellentMin) {
      return PronunciationBand.excellent;
    }
    if (value >= PronunciationConstants.needsImprovMin) {
      return PronunciationBand.needsImprov;
    }
    return PronunciationBand.incorrect;
  }

  static PronunciationBand bandFromName(String? name) {
    switch (name) {
      case 'excellent':
        return PronunciationBand.excellent;
      case 'needs_improv':
        return PronunciationBand.needsImprov;
      default:
        return PronunciationBand.incorrect;
    }
  }
}
