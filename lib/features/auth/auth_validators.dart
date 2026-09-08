import 'package:easy_localization/easy_localization.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/features/auth/auth_constants.dart';

String? authRequiredField(String? value) {
  if (value == null || value.trim().isEmpty) {
    return AppStrings.textFieldError.tr();
  }
  return null;
}

String? authUserNameField(String? value) {
  final requiredError = authRequiredField(value);
  if (requiredError != null) return requiredError;
  final userName = AuthConstants.normalizeUserName(value!);
  if (userName.length < AuthConstants.minUserNameLength ||
      userName.length > AuthConstants.maxUserNameLength ||
      !AuthConstants.userNamePattern.hasMatch(userName)) {
    return AppStrings.authInvalidUserName.tr();
  }
  return null;
}

String? authPasswordField(String? value) {
  final requiredError = authRequiredField(value);
  if (requiredError != null) return requiredError;
  if (value!.trim().length < AuthConstants.minPasswordLength) {
    return AppStrings.authWeakPassword.tr();
  }
  return null;
}
