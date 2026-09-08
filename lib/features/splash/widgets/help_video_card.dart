import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/features/course_shell/course_constants.dart';
import 'package:micro_teaching_studio/features/course_shell/widgets/course_svg_icon.dart';
import 'package:micro_teaching_studio/features/splash/widgets/help_volume_icon.dart';
import 'package:micro_teaching_studio/images_urls/assets.dart';

class HelpVideoCard extends StatelessWidget {
  const HelpVideoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppPadding.p8.w),
      decoration: BoxDecoration(
        color: ColorManager.slate900,
        borderRadius: BorderRadius.circular(AppRadius.r24.r),
        boxShadow: [
          BoxShadow(
            color: ColorManager.black.withValues(alpha: 0.1),
            blurRadius: AppPadding.p24.r,
            offset: Offset(0, AppPadding.p8.h),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.r18.r),
            child: SizedBox(
              height: AppSize.videoPlayerHeight.h,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: ColorManager.gradientVideoPlayer,
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(-0.4, -0.4),
                        radius: 0.9,
                        colors: [
                          ColorManager.actionBlue.withValues(alpha: 0.25),
                          ColorManager.transparent,
                        ],
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipOval(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: AppPadding.p4.r,
                            sigmaY: AppPadding.p4.r,
                          ),
                          child: Container(
                            width: AppSize.s64.w,
                            height: AppSize.s64.w,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: ColorManager.onDarkFill,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: ColorManager.onDarkStroke,
                              ),
                            ),
                            child: CourseSvgIcon(
                              asset: Assets.assetsIconsHelpPlay,
                              size: AppSize.s24.w,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: AppPadding.p12.h),
                      Text(
                        AppStrings.videoPlayerLabel.tr(),
                        style: getBoldStyle(
                          fontSize: FontSize.s11.sp,
                          color: ColorManager.onDarkSoft,
                        ).copyWith(letterSpacing: AppLetterSpacing.video),
                      ),
                    ],
                  ),
                  Positioned(
                    left: AppPadding.p12.w,
                    right: AppPadding.p12.w,
                    bottom: AppPadding.p12.h,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.rCapsule.r),
                      child: SizedBox(
                        height: AppSize.s4.h,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            const ColoredBox(color: ColorManager.onDarkFill),
                            FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: CourseConstants.helpVideoProgress,
                              child: const ColoredBox(
                                color: ColorManager.accentAmber,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppPadding.p12.w,
              AppPadding.p12.h,
              AppPadding.p12.w,
              AppPadding.p4.h,
            ),
            child: Row(
              children: [
                HelpVolumeIcon(size: AppSize.s12.w),
                SizedBox(width: AppPadding.p6.w),
                Expanded(
                  child: Text(
                    AppStrings.helpVideoIntro.tr(
                      namedArgs: {
                        'duration': CourseConstants.helpVideoDuration,
                      },
                    ),
                    style: getBoldStyle(
                      fontSize: FontSize.s11.sp,
                      color: ColorManager.onDarkMuted,
                    ).copyWith(letterSpacing: AppLetterSpacing.video),
                  ),
                ),
                Text(
                  AppStrings.helpVideoQuality.tr(),
                  style: getRegularStyle(
                    fontSize: FontSize.s10.sp,
                    color: ColorManager.onDarkFaint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
