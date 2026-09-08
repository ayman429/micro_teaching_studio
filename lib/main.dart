// import 'package:device_preview/device_preview.dart';
// import 'package:device_preview/device_preview.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'app/app.dart';
import 'app/imports.dart';
import 'common/network/dio_helper.dart';
import 'common/observer/bloc_observer.dart';
import 'common/resources/language_manager.dart';
import 'common/resources/theme_manager.dart';
import 'firebase_options.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  await Future.wait([
    DioHelper.init(),
    initAppModule(),
  ]);
  Bloc.observer = MyBlocObserver();

  //  Lock orientation
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(ThemeManager.overlayStyle);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

 
  // ⚡ إنشاء قناة المكالمات قبل تشغيل التطبيق
  const AndroidNotificationChannel callChannel = AndroidNotificationChannel(
    'call_channel', // نفس الاسم في body عند إرسال FCM
    'Incoming Calls',
    description: 'Channel for incoming calls',
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound(
        'ringtone'), // ضع ملف ringtone.mp3 في res/raw
  );

  // تسجيل القناة مع NotificationPlugin
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(callChannel);

  runApp(
    EasyLocalization(
      supportedLocales: const [ENGLISH_LOCALE],//ARABIC_LOCALE
      path: ASSET_PASS_LANGUAGE,
      fallbackLocale: const Locale('en'),
      useOnlyLangCode: true,
      useFallbackTranslations: true,
      saveLocale: true,
      child: MyApp(),
      // child: DevicePreview(enabled: true, builder: (context) => MyApp()),
    ),
  );
}
