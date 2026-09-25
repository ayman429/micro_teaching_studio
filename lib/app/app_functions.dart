// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:micro_teaching_studio/app/app.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/common/widgets/default_button_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

class AppFunctions {
  static const Duration _transitionDuration = Duration(milliseconds: 500);

  static PageRoute<T> _slideFromRight<T>(Widget screen) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => screen,
      transitionDuration: _transitionDuration,
      reverseTransitionDuration: _transitionDuration,
      transitionsBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        );
      },
    );
  }

  static PageRoute<T> _fade<T>(Widget screen) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => screen,
      transitionDuration: _transitionDuration,
      reverseTransitionDuration: _transitionDuration,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
  static String reverseString(String originalString) {
    List<String> charList = originalString.split('');
    List<String> reversedList = charList.reversed.toList();
    String reversedString = reversedList.join();

    debugPrint('Original String: $originalString');
    debugPrint('Reversed String: $reversedString');

    return reversedString;
  }

  static void showsToast(String text, Color color, BuildContext context,
      {int seconds = 5}) {
    showToast(text,
        context: context,
        textStyle: getBoldStyle(fontSize: 15.sp, color: ColorManager.white),
        backgroundColor: color,
        animation: StyledToastAnimation.slideFromTopFade,
        reverseAnimation: StyledToastAnimation.slideToTopFade,
        position: StyledToastPosition.top,
        animDuration: const Duration(seconds: 2),
        duration: Duration(seconds: seconds),
        curve: Curves.elasticOut,
        reverseCurve: Curves.easeInOutCirc,
        isIgnoring: false);
  }

  static String prettyTime(String timeString) {
    DateTime time = DateTime.parse("2023-01-01 $timeString");

    String formattedTime = DateFormat('h:mm a').format(time);

    return formattedTime;
  }

  static String prettyDate(String dateString) {
    DateTime date = DateTime.parse(dateString);

    String formattedTime = DateFormat('MM-dd-yyyy').format(date);

    return formattedTime;
  }

  static Future<void> navigateTo(BuildContext context, Widget screen) async {
    await (Platform.isIOS
        ? navigatorKey.currentState?.push(CupertinoPageRoute(
            builder: (context) => screen,
          ))
        : navigatorKey.currentState?.push(_slideFromRight(screen)));
  }

  static void navigateToAndReplacement(BuildContext context, Widget screen) {
    Platform.isIOS
        ? navigatorKey.currentState?.pushReplacement(CupertinoPageRoute(
            builder: (context) => screen,
          ))
        : navigatorKey.currentState?.pushReplacement(_slideFromRight(screen));
  }

  static void navigateToAndFinish(BuildContext context, Widget screen) {
    Platform.isIOS
        ? navigatorKey.currentState?.pushAndRemoveUntil(
            CupertinoPageRoute(
              builder: (context) => screen,
            ),
            (route) => false,
          )
        : navigatorKey.currentState?.pushAndRemoveUntil(
            _fade(screen),
            (route) => false,
          );
  }

  static void popThenNavigateTo(BuildContext context, Widget screen) {
    Navigator.pop(context);
    navigatorKey.currentState?.push(_slideFromRight(screen));
  }

  static String convertToArabic(int number) {
    List<String> arabicDigits = [
      '٠',
      '١',
      '٢',
      '٣',
      '٤',
      '٥',
      '٦',
      '٧',
      '٨',
      '٩'
    ];

    String result = '';
    String numberStr = number.toString();

    for (int i = 0; i < numberStr.length; i++) {
      int digit = int.parse(numberStr[i]);
      result += arabicDigits[digit];
    }

    return result;
  }

  static String getYoutubeVideoId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return url;

    if (uri.host.contains('youtube.com')) {
      return uri.queryParameters['v'] ?? url;
    } else if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : url;
    }
    return url;
  }

  static void showMyDialog(
    BuildContext context, {
    Function()? onConfirm,
    required String title,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          contentPadding:
              EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w),
          backgroundColor: ColorManager.white,
          children: [
            Text(
              title,
              style: getBoldStyle(fontSize: 17.sp, color: ColorManager.black),
            ),
            SizedBox(
              height: 20.h,
            ),
            Row(
              children: [
                Expanded(
                  child: DefaultButtonWidget(
                    onPressed: () {
                      Navigator.pop(context);
                      if (onConfirm != null) onConfirm.call();
                    },
                    color: ColorManager.primary,
                    textColor: ColorManager.white,
                    text: AppStrings.confirm.tr(),
                    radius: 5.r,
                  ),
                ),
                SizedBox(
                  width: 10.w,
                ),
                Expanded(
                  child: DefaultButtonWidget(
                    onPressed: () => Navigator.pop(context),
                    color: ColorManager.red,
                    textColor: ColorManager.white,
                    text: AppStrings.back.tr(),
                    radius: 5.r,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  static void copyText(
      {BuildContext? context, bool? mounted, required String text}) async {
    ClipboardData data = ClipboardData(text: text);
    await Clipboard.setData(data);
    if (context != null && mounted == true) {
      showsToast(
          AppStrings.textCopied.tr(), ColorManager.successGreen, context);
    }
  }
}
