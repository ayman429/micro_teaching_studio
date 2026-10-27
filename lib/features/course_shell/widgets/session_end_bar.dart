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
import 'package:micro_teaching_studio/features/home/cubit/course_progress_cubit.dart';
import 'package:micro_teaching_studio/features/home/cubit/course_progress_state.dart';

class SessionEndBar extends StatefulWidget {
  const SessionEndBar({
    super.key,
    required this.module,
    required this.session,
    required this.onRestudy,
  });

  final int module;
  final int session;
  final VoidCallback onRestudy;

  @override
  State<SessionEndBar> createState() => _SessionEndBarState();
}

class _SessionEndBarState extends State<SessionEndBar> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CourseProgressCubit>().finishSession(
            widget.module,
            widget.session,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseProgressCubit, CourseProgressState>(
      builder: (context, state) {
        final sessionKey = CourseSessions.key(widget.module, widget.session);
        final missed = CourseSessions.hasMissedTask(
          state.pointIds,
          widget.module,
          widget.session,
        );
        final offerRestudy =
            missed && !state.restudiedSessions.contains(sessionKey);
        return Column(
          children: [
            if (offerRestudy) ...[
              SizedBox(height: AppPadding.p12.h),
              _button(
                label: AppStrings.studyAgain.tr(),
                filled: false,
                onPressed: widget.onRestudy,
              ),
            ],
            SizedBox(height: AppPadding.p12.h),
            _button(
              label: AppStrings.nextLesson.tr(),
              filled: true,
              onPressed: () => CourseFlow.openAfterSession(
                context,
                widget.module,
                widget.session,
              ),
            ),
            SizedBox(height: AppPadding.p8.h),
            _button(
              label: AppStrings.mainMenuAction.tr(),
              filled: false,
              onPressed: () => CourseFlow.goHome(context),
            ),
          ],
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
