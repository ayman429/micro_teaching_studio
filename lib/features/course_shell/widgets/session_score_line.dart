import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/features/course_shell/course_sessions.dart';
import 'package:micro_teaching_studio/features/home/cubit/course_progress_cubit.dart';
import 'package:micro_teaching_studio/features/home/cubit/course_progress_state.dart';

class SessionScoreLine extends StatelessWidget {
  const SessionScoreLine({
    super.key,
    required this.module,
    required this.session,
  });

  final int module;
  final int session;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseProgressCubit, CourseProgressState>(
      buildWhen: (previous, current) => previous.pointIds != current.pointIds,
      builder: (context, state) {
        final total = CourseSessions.taskIds(module, session).length;
        final points = CourseSessions.earned(state.pointIds, module, session);
        return Padding(
          padding: EdgeInsets.only(bottom: AppPadding.p12.h),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppPadding.p12.w,
                vertical: AppPadding.p8.h,
              ),
              decoration: BoxDecoration(
                color: ColorManager.white,
                borderRadius: BorderRadius.circular(AppRadius.rCapsule.r),
                border: Border.all(color: ColorManager.slate200),
              ),
              child: Text(
                AppStrings.sessionScore.tr(
                  namedArgs: {
                    'points': '$points',
                    'total': '$total',
                  },
                ),
                style: getBoldStyle(
                  fontSize: FontSize.s12.sp,
                  color: ColorManager.navy,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
