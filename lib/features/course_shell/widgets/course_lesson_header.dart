import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/theme_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/features/course_shell/widgets/course_svg_icon.dart';
import 'package:micro_teaching_studio/images_urls/assets.dart';

class CourseLessonHeader extends StatelessWidget {
  const CourseLessonHeader({
    super.key,
    required this.title,
    this.titleAr,
    this.onClose,
    this.onHelp,
    this.onSkip,
    this.showSkip = true,
    this.closeAsset,
  });

  final String title;
  final String? titleAr;
  final VoidCallback? onClose;
  final VoidCallback? onHelp;
  final VoidCallback? onSkip;
  final bool showSkip;
  final String? closeAsset;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: ThemeManager.overlayStyle,
      child: Directionality(
        textDirection: ui.TextDirection.ltr,
        child: Container(
          decoration: BoxDecoration(
            color: ColorManager.surfaceMuted,
            border: Border(
              bottom: BorderSide(
                color: ColorManager.slate100,
                width: 1.5.w,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: AppSize.headerHeight.h,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppPadding.p16.w),
                child: Row(
                  children: [
                    CourseCircleIconButton(
                      asset: closeAsset ?? Assets.assetsIconsCourseClose,
                      size: AppSize.s32.w,
                      iconSize: AppSize.s16.w,
                      backgroundColor: ColorManager.slate100,
                      onPressed: onClose,
                    ),
                    SizedBox(width: AppPadding.p8.w),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: getExtraBoldStyle(
                              fontSize: FontSize.s11.sp,
                              color: ColorManager.navy,
                            ).copyWith(letterSpacing: AppLetterSpacing.title),
                          ),
                          if (titleAr != null)
                            Text(
                              titleAr!,
                              style: getSemiBoldStyle(
                                fontSize: FontSize.s9.sp,
                                color: ColorManager.slate,
                              ),
                            ),
                        ],
                      ),
                    ),
                    CourseCircleIconButton(
                      asset: Assets.assetsIconsCourseHelp,
                      size: AppSize.s32.w,
                      iconSize: AppSize.s16.w,
                      borderColor: ColorManager.slate200,
                      onPressed: onHelp,
                    ),
                    if (showSkip) ...[
                      SizedBox(width: AppPadding.p8.w),
                      Material(
                        color: ColorManager.slate900,
                        borderRadius:
                            BorderRadius.circular(AppRadius.rCapsule.r),
                        child: InkWell(
                          onTap: onSkip,
                          borderRadius:
                              BorderRadius.circular(AppRadius.rCapsule.r),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppPadding.p12.w,
                              vertical: AppPadding.p8.h,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  AppStrings.skip.tr(),
                                  style: getBoldStyle(
                                    fontSize: FontSize.s10.sp,
                                    color: ColorManager.white,
                                  ).copyWith(
                                      letterSpacing: AppLetterSpacing.label),
                                ),
                                SizedBox(width: AppPadding.p4.w),
                                CourseSvgIcon(
                                  asset: Assets.assetsIconsCourseSkip,
                                  size: AppSize.s12.w,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
