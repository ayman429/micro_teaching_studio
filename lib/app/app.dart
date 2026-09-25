import 'package:micro_teaching_studio/app/app_prefs.dart';
import 'package:micro_teaching_studio/common/resources/theme_manager.dart';
import 'package:micro_teaching_studio/features/auth/cubit/auth_cubit.dart';
import 'package:micro_teaching_studio/features/auth/cubit/auth_state.dart';
import 'package:micro_teaching_studio/features/home/cubit/course_progress_cubit.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../common/resources/app_router.dart';
import 'imports.dart';

String userTypeValue = '';

class MyApp extends StatefulWidget {
  const MyApp._internal();

  static const _instance = MyApp._internal();

  factory MyApp() => _instance;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppPreferences _appPreferences = instance<AppPreferences>();

  @override
  void initState() {
    userTypeValue = _appPreferences.getUserType();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _appPreferences.getLocale().then((locale) {
      if (!mounted) return;
      if (context.supportedLocales.contains(locale)) {
        context.setLocale(locale);
      }
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: instance<AuthCubit>()),
        BlocProvider.value(value: instance<CourseProgressCubit>()),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          context.read<CourseProgressCubit>().reload();
        },
        child: ScreenUtilInit(
          designSize: Size(MediaQuery.sizeOf(context).width,
              MediaQuery.sizeOf(context).height),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return SafeArea(
              bottom: true,
              top: false,
              child: AnnotatedRegion<SystemUiOverlayStyle>(
                value: ThemeManager.overlayStyle,
                child: MaterialApp.router(
                  // navigatorKey: navigatorKey,
                  title: "Micro Teaching Studio",
                  scaffoldMessengerKey: scaffoldMessengerKey,
                  localizationsDelegates: context.localizationDelegates,
                  supportedLocales: context.supportedLocales,
                  locale: context.locale,
                  debugShowCheckedModeBanner: false,
                  theme: ThemeManager.getTheme(),
                  routerConfig: AppRouters.router,
                  builder: (context, child) {
                    // final scale = MediaQuery.of(context).textScaler.clamp(
                    //       minScaleFactor: 0.9,
                    //       maxScaleFactor: 1.05,
                    //     );
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        textScaler:
                            const TextScaler.linear(1.0), // Flutter 3.10+
                        // أو textScaleFactor: 1.0 لو نسخة أقدم
                      ),
                      child: GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus(); //  يقفل الكيبورد
                        },
                        child: child!,
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

final navigatorKey = GlobalKey<NavigatorState>(
    debugLabel: 'navigatorKey ${DateTime.now().millisecondsSinceEpoch}');
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
