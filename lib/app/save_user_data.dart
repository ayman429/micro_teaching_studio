import 'app_prefs.dart';
import 'imports.dart';

Future<void> saveUserData(
    {String? token,
    String? role,
    int? id,
    String? name,
    String? image,
    String? code,
    String? grade}) async {
  final AppPreferences appPreferences = instance<AppPreferences>();

  if (token != null) {
    await appPreferences.saveToken(token);
  }
  if (role != null) {
    await appPreferences.saveUserType(role);
  }
  if (id != null) {
    await appPreferences.saveUserId(id);
  }
  if (name != null) {
    await appPreferences.saveUserName(name);
  }
  if (image != null) {
    await appPreferences.saveUserImage(image);
  }
  if (code != null) {
    await appPreferences.saveUserCode(code);
  }
  if (grade != null) {
    await appPreferences.saveUserGrade(grade);
  }
}
