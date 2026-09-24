import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/common/resources/assets_manager.dart';
import 'package:micro_teaching_studio/common/widgets/default_button_widget.dart';
import 'package:micro_teaching_studio/features/course_audio/widgets/course_listen_control.dart';
import 'package:micro_teaching_studio/features/course_shell/widgets/course_svg_icon.dart';
import 'package:micro_teaching_studio/images_urls/assets.dart';

class FluencyInstructionsCard extends StatelessWidget {
  const FluencyInstructionsCard({
    super.key,
    required this.onStartPractice,
  });

  final VoidCallback onStartPractice;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppPadding.p20.w),
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(AppRadius.r24.r),
        border: Border.all(color: ColorManager.slate100),
        boxShadow: [
          BoxShadow(
            color: ColorManager.black.withValues(alpha: 0.05),
            blurRadius: AppPadding.p4.r,
            offset: Offset(0, 1.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: AppSize.s32.w,
                height: AppSize.s32.w,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: ColorManager.onNavyBody,
                  shape: BoxShape.circle,
                ),
                child: CourseSvgIcon(
                  asset: Assets.assetsIconsSessionTarget,
                  size: AppSize.s16.w,
                ),
              ),
              SizedBox(width: AppPadding.p8.w),
              Expanded(
                child: Text(
                  AppStrings.moduleSessionTitle.tr(
                    namedArgs: {
                      'module': '1',
                      'session': '1',
                      'name': AppStrings.fluencyEnglishTitle.tr(),
                    },
                  ),
                  style: getBoldStyle(
                    fontSize: FontSize.s14.sp,
                    color: ColorManager.slate800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppPadding.p16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  AppStrings.fluencyOutcomeLead.tr(),
                  style: getBoldStyle(
                    fontSize: FontSize.s12.sp,
                    color: ColorManager.navy,
                    height: 1.6,
                  ),
                ),
              ),
              CourseListenControl(
                asset: AudioAssets.fluencyObjectives(),
                color: ColorManager.navy,
                compact: true,
              ),
            ],
          ),
          Text(
            AppStrings.fluencyOutcomeBody.tr(),
            style: getRegularStyle(
              fontSize: FontSize.s12.sp,
              color: ColorManager.slate700,
              height: 1.6,
            ),
          ),
          SizedBox(height: AppPadding.p16.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppPadding.p12.w),
            decoration: BoxDecoration(
              color: ColorManager.iceBlue,
              borderRadius: BorderRadius.circular(AppRadius.r16.r),
              border: Border.all(color: ColorManager.onNavyBody),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppStrings.howToApply.tr(),
                        style: getBoldStyle(
                          fontSize: FontSize.s10.sp,
                          color: ColorManager.royalBlue,
                        ).copyWith(letterSpacing: AppLetterSpacing.label),
                      ),
                    ),
                    CourseListenControl(
                      asset: AudioAssets.fluencyHowToApply(),
                      color: ColorManager.navy,
                      compact: true,
                    ),
                  ],
                ),
                SizedBox(height: AppPadding.p8.h),
                Text(
                  AppStrings.fluencyHowToApplyBody.tr(),
                  style: getRegularStyle(
                    fontSize: FontSize.s12.sp,
                    color: ColorManager.slate700,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppPadding.p16.h),
          SizedBox(
            height: AppSize.inputHeight.h,
            width: double.infinity,
            child: DefaultButtonWidget(
              onPressed: onStartPractice,
              color: ColorManager.navy,
              radius: AppRadius.r16.r,
              elevation: 0,
              child: Text(
                AppStrings.startReadingPractice.tr(),
                textAlign: TextAlign.center,
                style: getBoldStyle(
                  fontSize: FontSize.s16.sp,
                  color: ColorManager.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
