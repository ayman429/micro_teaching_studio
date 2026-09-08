import 'package:micro_teaching_studio/common/stateless/gaps.dart';
import 'package:micro_teaching_studio/common/stateless/label.dart';
import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/app_functions.dart';
import '../resources/theme_manager.dart';

extension ContextExtensions on BuildContext {
  double get screenHeight => MediaQuery.of(this).size.height;

  double get screenWidth => MediaQuery.of(this).size.width;

  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => Theme.of(this).textTheme;

  bool get isKeyboardVisible => MediaQuery.of(this).viewInsets.bottom != 0;

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  bool get isArabic => Localizations.localeOf(this).languageCode == 'ar';
  bool get isEnglish => Localizations.localeOf(this).languageCode == 'en';
  bool get isRussion => Localizations.localeOf(this).languageCode == 'ru';

  TextDirection get textDirection =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;

  TextDirection get reversedTextDirection =>
      !isArabic ? TextDirection.rtl : TextDirection.ltr;

  FocusScopeNode get foucsScopeNode => FocusScope.of(this);

  void goWithNoReturn(Widget widget) =>
      AppFunctions.navigateToAndFinish(this, widget);

  // void go(Widget widget) => AppFunctions.navigateTo(this, widget);

  void goWithReplacement(Widget widget, {Object? result}) =>
      AppFunctions.navigateToAndReplacement(this, widget);

  void pop([Object? object]) => navigatorKey.currentState?.pop(object);

  bool canPop() => navigatorKey.currentState?.canPop() ?? false;

  void popUntil(int count, [bool Function(Route<dynamic>)? predicate]) =>
      navigatorKey.currentState?.popUntil(
          (route) => route.isFirst || (predicate != null && predicate(route)));

  void showErrorMessage(String message) {
    scaffoldMessengerKey.currentState?.clearSnackBars();
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                message,
                style: ThemeManager.getTheme()
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.error,
              color: Colors.red,
            ),
          ],
        ),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        margin: const EdgeInsets.only(bottom: 25, right: 20, left: 20),
      ),
    );
  }

  void showSuccessMessage(
    String message, {
    Color color = Colors.green,
    IconData icon = Icons.check_circle,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: LocalizedLabel(
                  text: message,
                  style: ThemeManager.getTheme()
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 10),
              Icon(icon, color: color),
            ],
          ),
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          margin: const EdgeInsets.only(bottom: 25, right: 20, left: 20),
        ),
      );
    });
  }

  void showTapAgainToExit({
    String message = 'اضغط مرة اخرى للخروج',
    Color color = Colors.grey,
    IconData icon = Icons.logout,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  message,
                  style: ThemeManager.getTheme()
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 10),
              Icon(icon, color: color),
            ],
          ),
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          margin: const EdgeInsets.only(bottom: 25, right: 20, left: 20),
        ),
      );
    });
  }

  void showSuccessDialog(String text) {
    showDialog(
      context: this,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        content: Text(
          text,
          style: ThemeManager.getTheme()
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.black),
          textAlign: TextAlign.center,
        ),
        contentPadding: const EdgeInsets.all(20).copyWith(bottom: 40),
      ),
    );
  }

  void showLoadingDialog({
    String? message,
    bool canPop = false,
    bool barrierDismissible = false,
  }) {
    showDialog(
      context: this,
      barrierDismissible: barrierDismissible,
      builder: (_) => PopScope(
        canPop: canPop,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator.adaptive(),
              Gaps.v18(),
              Text(
                message ?? '...تحميل البيانات',
                style: theme.textTheme.titleLarge!,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          contentPadding: const EdgeInsets.all(20).copyWith(bottom: 40),
        ),
      ),
    );
  }

  void showTopSnackBar({
    required Widget child,
    required Color backgroundColor,
    IconData icon = Icons.error,
    Duration duration = const Duration(seconds: 2),
  }) {
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: 16,
        right: 16,
        top: MediaQuery.of(context).padding.top + 10,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(this).insert(overlayEntry);

    Future.delayed(duration, () {
      overlayEntry.remove();
    });
  }

  void showToast({Color color = Colors.red, required String text}) {
    AppFunctions.showsToast(text, color, this);
  }

  ///TODO location  inquiry
  // Future<bool> promptToEnableLocation({
  //   String? title,
  //   String? message,
  //   String? cancelText,
  //   String? openSettingsText,
  //   bool barrierDismissible = false,
  // }) async {
  //   final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (serviceEnabled) return true;
  //
  //   final bool? result = await showDialog<bool>(
  //     context: navigatorKey.currentContext!,
  //     barrierDismissible: barrierDismissible,
  //     builder: (context) => AlertDialog(
  //       title: Text(
  //         title ?? (isArabic ? 'يجب تفعيل الموقع' : 'Location must be enabled'),
  //         style: const TextStyle(
  //           fontSize: 20,
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //       content: Text(
  //         message ?? (isArabic ? 'يرجى فتح الموقع في الإعدادات' : 'Please turn on location in settings'),
  //         style: const TextStyle(fontSize: 18),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context, false),
  //           child: Text(
  //             cancelText ?? (isArabic ? 'إلغاء' : 'Cancel'),
  //             style: const TextStyle(
  //               fontSize: 18,
  //               color: Colors.blue,
  //             ),
  //           ),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             Navigator.pop(context, true);
  //             Geolocator.openLocationSettings();
  //           },
  //           child: Text(
  //             openSettingsText ?? (isArabic ? 'فتح' : 'Open'),
  //             style: const TextStyle(
  //               fontSize: 18,
  //               color: Colors.blue,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  //
  //   return result ?? false;
  // }
}
