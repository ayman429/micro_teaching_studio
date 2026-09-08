// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

enum LanguageType { ENGLISH, ARABIC }

String language = '';

const String ARABIC = "ar";
const String ENGLISH = "en";
const String ASSET_PASS_LANGUAGE = "assets/translations";
const Locale ARABIC_LOCALE = Locale("ar");
const Locale ENGLISH_LOCALE = Locale("en");

extension LanguageTypeExtension on LanguageType {
  String getValue() {
    switch (this) {
      case LanguageType.ENGLISH:
        return ENGLISH;
      case LanguageType.ARABIC:
        return ARABIC;
    }
  }
}
