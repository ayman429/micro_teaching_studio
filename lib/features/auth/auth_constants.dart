class AuthConstants {
  static const String emailDomain = 'microteaching.app';
  static const String usersCollection = 'users';
  static const int minPasswordLength = 6;
  static const int minUserNameLength = 3;
  static const int maxUserNameLength = 32;
  static const Duration firebaseTimeout = Duration(seconds: 8);
  static const Duration authTimeout = Duration(seconds: 20);

  static final RegExp userNamePattern = RegExp(r'^[a-zA-Z0-9._-]+$');

  static String normalizeUserName(String userName) =>
      userName.trim().toLowerCase();

  static String emailFromUserName(String userName) =>
      '${normalizeUserName(userName)}@$emailDomain';

  static String userNameFromEmail(String email) {
    final at = email.indexOf('@');
    if (at <= 0) return email;
    return email.substring(0, at);
  }
}
