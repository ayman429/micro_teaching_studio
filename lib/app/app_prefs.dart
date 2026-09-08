import 'dart:developer';

import 'package:micro_teaching_studio/app/app.dart';
import 'package:micro_teaching_studio/common/resources/language_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String langKey = 'lang_key';
const String prefsKeyOnBoardingScreenViewed =
    "PREFS_KEY_ON_BOARDING_SCREEN_VIEWED";
const String prefsKeySaveToken = "PREFS_KEY_SAVE_TOKEN";
const String prefsKeySaveFcmToken = "PREFS_KEY_SAVE_FCM_TOKEN";
const String prefsKeySaveUserType = "PREFS_KEY_SAVE_UserType";
const String prefsKeySaveUserName = "PREFS_KEY_SAVE_Name";
const String prefsKeySaveFullName = "PREFS_KEY_SAVE_FULL_Name";
const String prefsKeySaveUid = "PREFS_KEY_SAVE_UID";
const String prefsKeySaveUserId = "PREFS_KEY_SAVE_Id";
const String prefsKeySaveUserImage = "PREFS_KEY_SAVE_UserImage";
const String prefsKeySaveUserCode = "PREFS_KEY_SAVE_UserCode";
const String prefsKeySaveUserGrade = "PREFS_KEY_SAVE_Grade";
const String prefsKeySaveUserEmail = "PREFS_KEY_SAVE_Email";
const String prefsKeySaveStudentId = "PREFS_KEY_SAVE_Student_Id";
const String prefsKeyUserMobile = "PREFS_KEY_USER_mobile";

class AppPreferences {
  final SharedPreferences _sharedPreferences;
  BuildContext? globalContext = navigatorKey.currentContext;

  AppPreferences(this._sharedPreferences);
  String getAppLanguage() {
    String? language = _sharedPreferences.getString(langKey);
    if (language?.isNotEmpty ?? false) {
      return language!;
    } else {
      globalContext?.resetLocale();
      log(globalContext?.deviceLocale.toString() ?? "");
      return globalContext?.deviceLocale.toString().contains("en") ?? false
          ? LanguageType.ENGLISH.getValue()
          : LanguageType.ARABIC.getValue();
    }
  }

  Future<void> changeAppLanguage() async {
    String currentLanguage = getAppLanguage();
    if (currentLanguage == LanguageType.ENGLISH.getValue()) {
      _sharedPreferences.setString(langKey, LanguageType.ARABIC.getValue());
    } else {
      _sharedPreferences.setString(langKey, LanguageType.ENGLISH.getValue());
    }
  }

  Future<Locale> getLocale() async {
    String currentLanguage = getAppLanguage();
    if (currentLanguage == LanguageType.ENGLISH.getValue()) {
      return ENGLISH_LOCALE;
    } else {
      return ARABIC_LOCALE;
    }
  }

  Future<void> setGestMode(bool isGest) async {
    _sharedPreferences.setBool(prefsKeyOnBoardingScreenViewed, isGest);
  }

  bool isGestMode() {
    return _sharedPreferences.getBool(prefsKeyOnBoardingScreenViewed) ?? true;
  }

  Future<void> saveToken(String token) async {
    await _sharedPreferences.setString(prefsKeySaveToken, token);
  }

  String getToken() {
    return _sharedPreferences.getString(prefsKeySaveToken) ?? '';
  }

  Future<void> saveFcmToken(String fcmToken) async {
    await _sharedPreferences.setString(prefsKeySaveFcmToken, fcmToken);
  }

  String getFcmToken() {
    return _sharedPreferences.getString(prefsKeySaveFcmToken) ?? '';
  }

  String getUserType() {
    return _sharedPreferences.getString(prefsKeySaveUserType) ?? '';
  }

  String getUserName() {
    return _sharedPreferences.getString(prefsKeySaveUserName) ??
        AppStrings.guest.tr();
  }

  String getFullName() {
    return _sharedPreferences.getString(prefsKeySaveFullName) ?? '';
  }

  String getUid() {
    return _sharedPreferences.getString(prefsKeySaveUid) ?? '';
  }

  Future<void> setMobile(String mobile) async {
    _sharedPreferences.setString(prefsKeyUserMobile, mobile);
  }

  String getMobile() {
    return _sharedPreferences.getString(prefsKeyUserMobile) ?? '';
  }

  // prefsKeySaveUserId
  int getUserId() {
    return _sharedPreferences.getInt(prefsKeySaveUserId) ?? 0;
  }

  int getStudentId() {
    return _sharedPreferences.getInt(prefsKeySaveStudentId) ?? 0;
  }

  String getUserCode() {
    return _sharedPreferences.getString(prefsKeySaveUserCode) ?? '';
  }

  String getUserImage() {
    return _sharedPreferences.getString(prefsKeySaveUserImage) ?? '';
  }

  String getUserGrade() {
    return _sharedPreferences.getString(prefsKeySaveUserGrade) ?? '';
  }

  String getUserEmail() {
    return _sharedPreferences.getString(prefsKeySaveUserEmail) ?? '';
  }

  Future<void> saveUserType(String type) async {
    await _sharedPreferences.setString(prefsKeySaveUserType, type);
  }

  Future<void> saveUserId(int id) async {
    await _sharedPreferences.setInt(prefsKeySaveUserId, id);
  }

  Future<void> saveStudentId(int id) async {
    await _sharedPreferences.setInt(prefsKeySaveStudentId, id);
  }

  Future<void> saveUserName(String name) async {
    await _sharedPreferences.setString(prefsKeySaveUserName, name);
  }

  Future<void> saveFullName(String name) async {
    await _sharedPreferences.setString(prefsKeySaveFullName, name);
  }

  Future<void> saveUid(String uid) async {
    await _sharedPreferences.setString(prefsKeySaveUid, uid);
  }

  Future<void> saveUserCode(String code) async {
    await _sharedPreferences.setString(prefsKeySaveUserCode, code);
  }

  Future<void> saveUserImage(String image) async {
    await _sharedPreferences.setString(prefsKeySaveUserImage, image);
  }

  Future<void> saveUserGrade(String grade) async {
    await _sharedPreferences.setString(prefsKeySaveUserGrade, grade);
  }

  Future<void> saveUserEmail(String email) async {
    await _sharedPreferences.setString(prefsKeySaveUserEmail, email);
  }

  Future<void> logout() async {
    await Future.wait([
      _sharedPreferences.remove(prefsKeySaveToken),
      _sharedPreferences.remove(prefsKeySaveUserType),
      _sharedPreferences.remove(prefsKeyOnBoardingScreenViewed),
      _sharedPreferences.remove(prefsKeySaveFcmToken),
      _sharedPreferences.remove(prefsKeySaveUserId),
      _sharedPreferences.remove(prefsKeySaveUserImage),
      _sharedPreferences.remove(prefsKeySaveUserEmail),
      _sharedPreferences.remove(prefsKeySaveUserCode),
      _sharedPreferences.remove(prefsKeySaveUserGrade),
      _sharedPreferences.remove(prefsKeySaveStudentId),
      _sharedPreferences.remove(prefsKeySaveUserName),
      _sharedPreferences.remove(prefsKeySaveFullName),
      _sharedPreferences.remove(prefsKeySaveUid),
      _sharedPreferences.remove(prefsKeyUserMobile),
    ]);
  }
}
