import 'package:firebase_auth/firebase_auth.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';

class AuthErrorMapper {
  static String message(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return AppStrings.authUserNameTaken;
      case 'weak-password':
        return AppStrings.authWeakPassword;
      case 'invalid-email':
        return AppStrings.authInvalidUserName;
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
      case 'user-disabled':
        return AppStrings.authWrongCredentials;
      case 'too-many-requests':
        return AppStrings.authTooManyRequests;
      case 'network-request-failed':
        return AppStrings.noInternetError;
      default:
        return AppStrings.unKnownError;
    }
  }
}
