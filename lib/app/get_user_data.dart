import 'app_prefs.dart';
import 'imports.dart';

class GetUserDataString {
  static const String getToken = "getToken";
  static const String getUserType = "getUserType";
  static const String getUserId = "getUserId";
  static const String getUserCode = "getUserCode";
  static const String getUserImage = "getUserImage";
  static const String getUserName = "getUserName";
  static const String getUserGrade = "getUserGrade";
  static const String getUserEmail = "getUserEmail";
}

Map<String, dynamic> getUserData() {
  final AppPreferences appPreferences = instance<AppPreferences>();

  return {
    GetUserDataString.getToken: appPreferences.getToken(),
    GetUserDataString.getUserType: appPreferences.getUserType(),
    GetUserDataString.getUserId: appPreferences.getUserId(),
    GetUserDataString.getUserCode: appPreferences.getUserCode(),
    GetUserDataString.getUserImage: appPreferences.getUserImage(),
    GetUserDataString.getUserName: appPreferences.getUserName(),
    GetUserDataString.getUserGrade: appPreferences.getUserGrade(),
    GetUserDataString.getUserEmail: appPreferences.getUserEmail(),
  };
}
