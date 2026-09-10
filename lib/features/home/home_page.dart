import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_teaching_studio/app/app_functions.dart';
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
import 'package:micro_teaching_studio/features/course_shell/course_flow.dart';
import 'package:micro_teaching_studio/features/course_shell/widgets/course_loading_dialog.dart';
import 'package:micro_teaching_studio/features/course_shell/widgets/course_scaffold.dart';
import 'package:micro_teaching_studio/features/home/cubit/course_progress_cubit.dart';
import 'package:micro_teaching_studio/features/home/cubit/course_progress_state.dart';
import 'package:micro_teaching_studio/features/home/models/home_module.dart';
import 'package:micro_teaching_studio/features/home/models/home_session.dart';
import 'package:micro_teaching_studio/features/home/widgets/home_module_card.dart';
import 'package:micro_teaching_studio/features/home/widgets/home_profile_card.dart';
import 'package:micro_teaching_studio/features/home/widgets/logout_confirm_dialog.dart';
import 'package:micro_teaching_studio/images_urls/assets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _opening = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return BlocBuilder<CourseProgressCubit, CourseProgressState>(
          builder: (context, progressState) {
            final progress = progressState.snapshot;
            return CourseScaffold(
          voiceCode: CourseConstants.homeVoiceCode,
          title: AppStrings.homeEnglishTitle.tr(),
          currentIndex: CourseConstants.homeStepIndex,
          closeAsset: Assets.assetsIconsLogout,
          onClose: () => _confirmLogout(context),
          onBack: null,
          onNext: () => CourseFlow.next(context),
          backEnabled: false,
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
                  overallProgress: progress.overallProgress,
                ),
                SizedBox(height: AppPadding.p16.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _openAims(context),
                        child: Text(
                          AppStrings.aimsOfTheProgram.tr(),
                          style: getExtraBoldStyle(
                            fontSize: FontSize.s18.sp,
                            color: ColorManager.navy,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _openAims(context),
                      child: Text(
                        AppStrings.viewAimsAction.tr(),
                        style: getBoldStyle(
                          fontSize: FontSize.s11.sp,
                          color: ColorManager.navy,
                        ),
                      ),
                    ),
                  ],
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
                      progress: progress.moduleProgress(module.number),
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
      },
    );
  }

  void _openAims(BuildContext context) {
    context.go(AppRouters.aimsView);
  }

  Future<void> _openSession(
    BuildContext context,
    HomeModule module,
    HomeSession session,
  ) async {
    if (_opening) return;
    _opening = true;
    final progress = context.read<CourseProgressCubit>();
    try {
      if (!progress.isHydrated) {
        await CourseLoadingDialog.run(
          context: context,
          task: progress.ensureHydrated,
        );
      } else {
        await progress.ensureHydrated();
      }
      if (!context.mounted) return;
      CourseFlow.openSession(context, module.number, session.number);
    } catch (error) {
      if (context.mounted) {
        AppFunctions.showsToast(
          AppStrings.noInternetError.tr(),
          ColorManager.red,
          context,
        );
      }
    } finally {
      _opening = false;
    }
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
