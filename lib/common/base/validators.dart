import 'package:easy_localization/easy_localization.dart';

class Validators {
  static String? displayNameValidator(String? displayName) {
    if (displayName == null || displayName.isEmpty) {
      return "nameMustBeNotEmpty".tr();
    }
    if (displayName.length < 3 || displayName.length > 20) {
      return "invalidName".tr();
    }
    return null;
  }

  static String? usernameValidator(String? username) {
    if (username == null || username.isEmpty) {
      return null; // يسمح بأن يكون فارغًا
    }
    if (username.trim().isEmpty) {
      return "usernameCannotBeOnlySpaces"
          .tr(); // لا يمكن أن يحتوي على مسافات فقط
    }
    if (username.startsWith(' ')) {
      return "usernameCannotStartWithSpace".tr(); // لا يمكن أن يبدأ بمسافة
    }
    return null;
  }

  static String? editProfileNameValidator(String? displayName) {
    if (displayName!.length < 3 || displayName.length > 20) {
      return "invalidName".tr();
    }
    return null;
  }

  static String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "emailMustBeNotEmpty".tr();
    }
    if (!RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b')
        .hasMatch(value)) {
      return "enter_vaild_email".tr();
    }
    return null;
  }

  static String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "please_enter_password".tr();
    }
    if (value.length < 8) {
      return "password_length".tr();
    }
    return null;
  }

  // ignore: non_constant_identifier_names
  static String? repeatPasswordValidator({String? value, String? Password}) {
    if (value != Password) {
      return "password_not_match".tr();
    }
    return null;
  }

  static String? phoneNumberValidator(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return "phoneNumberEmpty";
    }
    if (phoneNumber.length != 11) {
      return "phoneNumberLength";
    }
    if (!RegExp(r'^01[0-2,5]\d{8}$').hasMatch(phoneNumber)) {
      return "invalidPhoneNumberFormat";
    }
    return null;
  }

  static String? locationValidator(String? location) {
    if (location == null || location.isEmpty) {
      return "locationEmpty";
    }
    return null;
  }

  static String? validateEmpty(String? text) {
    if (text == null || text.isEmpty) {
      return "fieldEmpty".tr();
    }
    return null;
  }

  static String? timeValidator(String? time) {
    if (time == null || time.isEmpty) {
      return "timeEmpty".tr();
    }
    if (!RegExp(r'^(?:[01]\d|2[0-3]):[0-5]\d:[0-5]\d$').hasMatch(time)) {
      return "invalidTime".tr();
    }
    return null;
  }

  static String? ageValidator(String? age) {
    if (age == null || age.isEmpty) {
      return null;
    }
    int? ageValue = int.tryParse(age);
    if (ageValue == null || ageValue < 18 || ageValue > 48) {
      return "invalidAge".tr();
    }
    return null;
  }

  static String? countryValidator(String? country) {
    if (country == null || country.isEmpty) {
      return "countryEmpty".tr();
    }
    return null;
  }

  static String? cityValidator(String? city) {
    if (city == null || city.isEmpty) {
      return "cityEmpty".tr();
    }
    return null;
  }
}
