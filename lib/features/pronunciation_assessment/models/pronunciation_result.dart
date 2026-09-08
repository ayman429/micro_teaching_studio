enum PronunciationBand { excellent, needsImprov, incorrect }

class PronunciationPhonemeScore {
  const PronunciationPhonemeScore({
    required this.phoneme,
    required this.accuracy,
    this.heardPhoneme,
  });

  final String phoneme;
  final double? accuracy;
  final String? heardPhoneme;

  PronunciationBand get band => PronunciationResult.bandFromScore(accuracy);

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
  });

  final String word;
  final double? accuracy;
  final String errorType;
  final List<PronunciationPhonemeScore> phonemes;

  bool get isInsertion => errorType.toLowerCase() == 'insertion';
  bool get isOmission => errorType.toLowerCase() == 'omission';

  PronunciationBand get band {
    if (isOmission || isInsertion) return PronunciationBand.incorrect;
    return PronunciationResult.bandFromScore(accuracy);
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

  List<PronunciationWordScore> get alignedWords =>
      words.where((word) => !word.isInsertion).toList();

  static PronunciationBand bandFromScore(double? score) {
    final value = score ?? 0;
    if (value >= 80) return PronunciationBand.excellent;
    if (value >= 60) return PronunciationBand.needsImprov;
    return PronunciationBand.incorrect;
  }
}
