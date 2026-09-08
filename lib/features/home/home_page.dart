import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_teaching_studio/app/app_prefs.dart';
import 'package:micro_teaching_studio/app/imports.dart';
import 'package:micro_teaching_studio/common/resources/app_router.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/features/auth/cubit/auth_cubit.dart';
import 'package:micro_teaching_studio/features/auth/cubit/auth_state.dart';
import 'package:micro_teaching_studio/features/auth/models/student_avatar.dart';
import 'package:micro_teaching_studio/features/course_shell/course_constants.dart';
import 'package:micro_teaching_studio/features/course_shell/widgets/course_scaffold.dart';
import 'package:micro_teaching_studio/features/home/models/home_module.dart';
import 'package:micro_teaching_studio/features/home/models/home_session.dart';
import 'package:micro_teaching_studio/features/home/widgets/home_module_card.dart';
import 'package:micro_teaching_studio/features/home/widgets/home_profile_card.dart';
import 'package:micro_teaching_studio/features/home/widgets/logout_confirm_dialog.dart';
import 'package:micro_teaching_studio/images_urls/assets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return CourseScaffold(
          voiceCode: CourseConstants.homeVoiceCode,
          title: AppStrings.homeEnglishTitle.tr(),
          currentIndex: CourseConstants.homeStepIndex,
          closeAsset: Assets.assetsIconsLogout,
          onClose: () => _confirmLogout(context),
          onHelp: () => _popIfPossible(context),
          onSkip: () => _popIfPossible(context),
          onBack: () => _popIfPossible(context),
          body: Directionality(
            textDirection: ui.TextDirection.ltr,
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                AppPadding.p16.w,
                AppPadding.p16.h,
                AppPadding.p16.w,
                AppPadding.p16.h,
              ),
              children: [
                HomeProfileCard(
                  fullName: state.user?.fullName ??
                      instance<AppPreferences>().getFullName(),
                  userName: state.user?.userName ??
                      instance<AppPreferences>().getUserName(),
                  avatar: state.user?.avatar ??
                      StudentAvatar.fromName(
                        instance<AppPreferences>().getUserImage(),
                      ),
                ),
                SizedBox(height: AppPadding.p16.h),
                Text(
                  AppStrings.aimsOfTheProgram.tr(),
                  style: getExtraBoldStyle(
                    fontSize: FontSize.s18.sp,
                    color: ColorManager.navy,
                  ),
                ),
                SizedBox(height: AppPadding.p4.h),
                Text(
                  AppStrings.aimsOfTheProgramSubtitle.tr(),
                  style: getRegularStyle(
                    fontSize: FontSize.s11.sp,
                    color: ColorManager.slate,
                  ),
                ),
                SizedBox(height: AppPadding.p20.h),
                ...HomeModule.catalog.map((module) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: AppPadding.p16.h),
                    child: HomeModuleCard(
                      module: module,
                      onSessionTap: (session) =>
                          _openSession(context, module, session),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openSession(
    BuildContext context,
    HomeModule module,
    HomeSession session,
  ) {
    if (module.number == 1 && session.number == 1) {
      context.push(AppRouters.fluencyView);
    } else if (module.number == 1 && session.number == 2) {
      context.push(AppRouters.phonicsView);
    }
  }

  void _popIfPossible(BuildContext context) {
    if (context.canPop()) context.pop();
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await LogoutConfirmDialog.show(context);
    if (confirmed && context.mounted) {
      final cubit = context.read<AuthCubit>();
      await cubit.signOut();
      if (!context.mounted) return;
      if (cubit.state.status == AuthStatus.unauthenticated) {
        context.go(AppRouters.signInView);
      }
    }
  }
}

class HomeView extends HomePage {
  const HomeView({super.key});
}
