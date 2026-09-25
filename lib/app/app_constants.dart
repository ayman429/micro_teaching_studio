class AppConstants {
  // Replace with the real backend URL, e.g. https://example.com/api
  static const String baseUrl = "****************************";
  static const Duration apiTimeOut = Duration(milliseconds: 60000);
  static const int splashDelay = 5;

  static String get dioBaseUrl {
    final uri = Uri.tryParse(baseUrl);
    final isValid = uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    return isValid ? baseUrl : 'https://localhost';
  }
}
