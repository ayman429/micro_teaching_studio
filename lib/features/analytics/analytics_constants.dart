class AnalyticsConstants {
  static const String userProgressCollection = 'user_progress';
  static const String partProgressCollection = 'part_progress';
  static const String attemptsCollection = 'attempts';
  static const String attemptWordsCollection = 'attempt_words';
  static const String attemptPhonemesCollection = 'attempt_phonemes';

  static const String fluencyPassage = 'fluency_passage';
  static const String phonicsWord = 'phonics_word';
  static const String sessionUnit = 'session_unit';

  static const String outcomeScored = 'scored';
  static const String outcomeFailed = 'failed';

  static const String statusNotStarted = 'not_started';
  static const String statusInProgress = 'in_progress';
  static const String statusCompleted = 'completed';

  static const String bandExcellent = 'excellent';
  static const String bandNeedsImprov = 'needs_improv';
  static const String bandIncorrect = 'incorrect';

  static const String engineAzureSpeech = 'azure_speech';
  static const String passageLabel = 'passage';
  static const String sessionKey = 'session';
  static const String fluencyItemName = 'Marwa paragraph';
  static const String itemParagraph = 'Paragraph';
  static const String itemWord = 'Word';
  static const String itemSession = 'Session';

  static const int batchLimit = 400;
  static const Duration writeTimeout = Duration(seconds: 30);
}
