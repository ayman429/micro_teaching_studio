import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/features/course_shell/course_flow.dart';
import 'package:micro_teaching_studio/features/course_shell/widgets/course_scaffold.dart';
import 'package:micro_teaching_studio/features/home/models/home_module.dart';

class UpcomingSessionPage extends StatelessWidget {
  const UpcomingSessionPage({
    super.key,
    required this.module,
    required this.session,
  });

  final int module;
  final int session;

  @override
  Widget build(BuildContext context) {
    final step = CourseFlow.stepForSession(module, session);
    final catalog = HomeModule.catalog.where((item) => item.number == module);
    final homeModule = catalog.isEmpty ? null : catalog.first;
    final sessions = homeModule?.sessions.where((item) => item.number == session);
    final labelKey = sessions == null || sessions.isEmpty
        ? AppStrings.moduleSessionTitle
        : sessions.first.labelKey;
    return CourseScaffold(
      voiceCode: step?.voiceCode ?? CourseFlow.steps.last.voiceCode,
      title: labelKey.tr(),
      currentIndex: step?.index ?? CourseFlow.steps.last.index,
      onBack: () => CourseFlow.back(context),
      onNext: () => CourseFlow.next(context),
      backEnabled: CourseFlow.hasPrevious(context),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          AppPadding.p16.w,
          AppPadding.p16.h,
          AppPadding.p16.w,
          AppPadding.p16.h,
        ),
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppPadding.p20.w),
            decoration: BoxDecoration(
              color: ColorManager.white,
              borderRadius: BorderRadius.circular(AppRadius.r24.r),
              border: Border.all(color: ColorManager.slate100),
            ),
            child: Text(
              AppStrings.moduleSessionTitle.tr(
                namedArgs: {
                  'module': '$module',
                  'session': '$session',
                  'name': labelKey.tr(),
                },
              ),
              style: getBoldStyle(
                fontSize: FontSize.s16.sp,
                color: ColorManager.navy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UpcomingSessionView extends UpcomingSessionPage {
  const UpcomingSessionView({
    super.key,
    required super.module,
    required super.session,
  });
}
