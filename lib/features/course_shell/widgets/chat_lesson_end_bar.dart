import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/common/widgets/default_button_widget.dart';
import 'package:micro_teaching_studio/features/course_shell/course_flow.dart';
import 'package:micro_teaching_studio/features/course_shell/course_sessions.dart';
import 'package:micro_teaching_studio/features/course_shell/widgets/lesson_continue_bar.dart';
import 'package:micro_teaching_studio/features/home/cubit/course_progress_cubit.dart';
import 'package:micro_teaching_studio/features/home/cubit/course_progress_state.dart';

/// End of a spoken chat. A missed spoken question offers one restudy and a
/// way back to the main menu. Passing every spoken question keeps Continue.
class ChatLessonEndBar extends StatelessWidget {
  const ChatLessonEndBar({
    super.key,
    required this.module,
    required this.session,
    required this.onContinue,
    required this.onRestudy,
  });

  final int module;
  final int session;
  final VoidCallback onContinue;
  final VoidCallback onRestudy;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseProgressCubit, CourseProgressState>(
      buildWhen: (previous, current) =>
          previous.pointIds != current.pointIds ||
          previous.restudiedSessions != current.restudiedSessions,
      builder: (context, state) {
        final missed = CourseSessions.hasMissedSpokenTask(
          state.pointIds,
          module,
          session,
        );
        final offer = missed &&
            !state.restudiedSessions.contains(
              CourseSessions.key(module, session),
            );
        if (!offer) return LessonContinueBar(onPressed: onContinue);
        return Material(
          color: ColorManager.white,
          elevation: 8,
          shadowColor: ColorManager.navyGlow,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppPadding.p16.w,
                AppPadding.p12.h,
                AppPadding.p16.w,
                AppPadding.p12.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _button(
                    label: AppStrings.studyAgain.tr(),
                    filled: false,
                    onPressed: onRestudy,
                  ),
                  SizedBox(height: AppPadding.p8.h),
                  _button(
                    label: AppStrings.next.tr(),
                    filled: true,
                    onPressed: onContinue,
                  ),
                  SizedBox(height: AppPadding.p8.h),
                  _button(
                    label: AppStrings.mainMenuAction.tr(),
                    filled: false,
                    onPressed: () => CourseFlow.goHome(context),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _button({
    required String label,
    required bool filled,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: AppSize.s48.h,
      child: DefaultButtonWidget(
        onPressed: onPressed,
        text: label,
        color: filled ? ColorManager.navy : ColorManager.white,
        textColor: filled ? ColorManager.white : ColorManager.navy,
        withBorder: !filled,
        borderColor: ColorManager.navy,
        radius: AppRadius.rCapsule.r,
        elevation: 0,
        verticalPadding: 0,
        fontSize: FontSize.s13.sp,
      ),
    );
  }
}
