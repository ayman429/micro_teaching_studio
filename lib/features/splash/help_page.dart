import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/common/widgets/default_button_widget.dart';
import 'package:micro_teaching_studio/features/course_shell/course_constants.dart';
import 'package:micro_teaching_studio/features/course_shell/course_flow.dart';
import 'package:micro_teaching_studio/features/course_shell/widgets/course_scaffold.dart';
import 'package:micro_teaching_studio/features/course_shell/widgets/course_svg_icon.dart';
import 'package:micro_teaching_studio/features/splash/widgets/help_intro_card.dart';
import 'package:micro_teaching_studio/features/splash/widgets/help_video_card.dart';
import 'package:micro_teaching_studio/images_urls/assets.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CourseScaffold(
      voiceCode: CourseConstants.helpVoiceCode,
      title: AppStrings.helpEnglishTitle.tr(),
      currentIndex: CourseConstants.helpStepIndex,
      bodyGradient: ColorManager.gradientHelpSurface,
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
          const HelpIntroCard(),
          SizedBox(height: AppPadding.p16.h),
          const HelpVideoCard(),
          SizedBox(height: AppPadding.p16.h),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.r16.r),
              boxShadow: [
                BoxShadow(
                  color: ColorManager.navy.withValues(alpha: 0.25),
                  blurRadius: AppPadding.p16.r,
                  offset: Offset(0, AppPadding.p8.h),
                ),
              ],
            ),
            child: SizedBox(
              height: AppSize.s56.h,
              width: double.infinity,
              child: DefaultButtonWidget(
                onPressed: () => CourseFlow.next(context),
                color: ColorManager.navy,
                radius: AppRadius.r16.r,
                elevation: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.next.tr(),
                      style: getBoldStyle(
                        fontSize: FontSize.s16.sp,
                        color: ColorManager.white,
                      ).copyWith(letterSpacing: AppLetterSpacing.title),
                    ),
                    SizedBox(width: AppPadding.p8.w),
                    CourseSvgIcon(
                      asset: Assets.assetsIconsCourseNext,
                      size: AppSize.s18.w,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HelpView extends HelpPage {
  const HelpView({super.key});
}
