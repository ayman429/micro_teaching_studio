class SpeechConfig {
  const SpeechConfig({
    required this.speechKey,
    required this.region,
    required this.language,
  });

  final String speechKey;
  final String region;
  final String language;
}

class PronunciationConstants {
  static const String configCollection = 'app_config';
  static const String speechDocument = 'speech';
  static const String speechKeyField = 'speechKey';
  static const String regionField = 'region';
  static const String languageField = 'language';
  static const String defaultRegion = 'switzerlandnorth';
  static const String defaultLanguage = 'en-US';
  static const Duration requestTimeout = Duration(seconds: 30);
  static const int configRetryCount = 3;
  static const Duration configRetryDelay = Duration(milliseconds: 500);
}
