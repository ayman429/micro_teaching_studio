import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/font_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ThemeManager {
  static const SystemUiOverlayStyle overlayStyle = SystemUiOverlayStyle(
    statusBarColor: ColorManager.surfaceMuted,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: ColorManager.white,
    systemNavigationBarIconBrightness: Brightness.dark,
    systemNavigationBarDividerColor: ColorManager.transparent,
  );

  static const SystemUiOverlayStyle overlayStyleOnNavy = SystemUiOverlayStyle(
    statusBarColor: ColorManager.navy,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: ColorManager.navy,
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarDividerColor: ColorManager.transparent,
  );

  static ThemeData getTheme() {
    return ThemeData(
      fontFamily: FontConstants.fontFamily,
      colorScheme: ColorScheme.fromSeed(seedColor: ColorManager.primary),
      scaffoldBackgroundColor: ColorManager.surfaceMuted,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        surfaceTintColor: ColorManager.white,
        systemOverlayStyle: overlayStyle,
        scrolledUnderElevation: 1,
        shadowColor: ColorManager.greyBorder,
        backgroundColor: ColorManager.white,
      ),
      elevatedButtonTheme: const ElevatedButtonThemeData(
          style: ButtonStyle(
        minimumSize: WidgetStatePropertyAll(Size.zero),
      )),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: getRegularStyle(color: ColorManager.grey, fontSize: 12.sp),
        labelStyle:
            getMediumStyle(color: ColorManager.textColor, fontSize: 14.sp),
        fillColor: ColorManager.white,
        filled: true,
        contentPadding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 10.h),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: ColorManager.green),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: ColorManager.green),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: ColorManager.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: ColorManager.red),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: ColorManager.grey),
        ),
      ),
    );
  }
}
