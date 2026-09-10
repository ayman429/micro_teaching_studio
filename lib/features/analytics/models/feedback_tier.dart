class FeedbackTier {
  static const String excellent = 'excellent';
  static const String wellDone = 'well_done';
  static const String goodEffort = 'good_effort';
  static const String dontGiveUp = 'dont_give_up';
  static const String noResponse = 'no_response';

  static const String labelExcellent = 'Excellent';
  static const String labelWellDone = 'Well done';
  static const String labelGoodEffort = 'Good effort';
  static const String labelDontGiveUp = "Don't give up";
  static const String labelNoResponse = 'No response';

  static const String colorGreen = 'Green';
  static const String colorAmber = 'Amber';
  static const String colorRed = 'Red';
  static const String colorGrey = 'Grey';

  static String fromOverall({
    required bool scored,
    double? pronScore,
    String? recognitionStatus,
  }) {
    if (!scored) return noResponse;
    final status = (recognitionStatus ?? '').trim().toLowerCase();
    if (status.isNotEmpty &&
        status != 'success' &&
        (pronScore == null || pronScore <= 0)) {
      return noResponse;
    }
    final value = pronScore ?? 0;
    if (value >= 80) return excellent;
    if (value >= 60) return wellDone;
    if (value >= 40) return goodEffort;
    return dontGiveUp;
  }

  static String labelOf(String tier) {
    switch (tier) {
      case excellent:
        return labelExcellent;
      case wellDone:
        return labelWellDone;
      case goodEffort:
        return labelGoodEffort;
      case dontGiveUp:
        return labelDontGiveUp;
      default:
        return labelNoResponse;
    }
  }

  static String wordColor(String band) {
    switch (band) {
      case 'excellent':
        return colorGreen;
      case 'needs_improv':
        return colorAmber;
      case 'incorrect':
        return colorRed;
      default:
        return colorGrey;
    }
  }
}
