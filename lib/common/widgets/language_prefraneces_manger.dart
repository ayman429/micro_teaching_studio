// ignore_for_file: use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_prefs.dart';
import '../../app/imports.dart';
import '../resources/app_router.dart';
import '../resources/language_manager.dart';

class LanguagePreferenceManager {
  bool isArabic = false;
  bool isEnglish = false;

  void updateLanguageState(BuildContext context) {
    isArabic = context.locale.languageCode == ARABIC;
    isEnglish = context.locale.languageCode == ENGLISH;
  }

  Future<void> changeLanguage(BuildContext context,
      {required bool isArabic}) async {
    await instance<AppPreferences>().changeAppLanguage();
    context.go(AppRouters.root);
    updateLanguageState(context);
  }
}
