import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_teaching_studio/app/app.dart';
import 'package:micro_teaching_studio/app/app_prefs.dart';
import 'package:micro_teaching_studio/app/imports.dart';
import 'package:micro_teaching_studio/common/resources/app_router.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/common/resources/theme_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/features/auth/cubit/auth_cubit.dart';
import 'package:micro_teaching_studio/features/auth/cubit/auth_state.dart';
import 'package:micro_teaching_studio/features/course_shell/widgets/course_svg_icon.dart';
import 'package:micro_teaching_studio/images_urls/assets.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  final AppPreferences _appPreferences = instance<AppPreferences>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _goNext());
  }

  Future<void> _goNext() async {
    log("======userTypeValue: $userTypeValue");
    log("======isGestMode: ${_appPreferences.isGestMode()}");
    final cubit = context.read<AuthCubit>();
    await Future.wait([
      Future<void>.delayed(AppDuration.splash),
      cubit.restoreSession(),
    ]);
    if (!mounted) return;
    final isLoggedIn = cubit.state.status == AuthStatus.authenticated;
    context.go(isLoggedIn ? AppRouters.homeView : AppRouters.helpView);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _appPreferences.getLocale().then((locale) {
      if (!mounted) return;
      if (context.supportedLocales.contains(locale)) {
        context.setLocale(locale);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: ThemeManager.overlayStyleOnNavy,
      child: Scaffold(
        backgroundColor: ColorManager.navy,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CourseSvgIcon(
                asset: Assets.assetsIconsLogo,
                size: AppSize.s80.w,
              ),
              SizedBox(height: AppPadding.p16.h),
              Text(
                AppStrings.appName.tr(),
                textAlign: TextAlign.center,
                style: getExtraBoldStyle(
                  fontSize: FontSize.s22.sp,
                  color: ColorManager.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
