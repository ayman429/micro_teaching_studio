import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/features/course_shell/widgets/course_svg_icon.dart';
import 'package:micro_teaching_studio/images_urls/assets.dart';

class CourseBottomNav extends StatelessWidget {
  const CourseBottomNav({
    super.key,
    required this.currentIndex,
    required this.totalSteps,
    this.onBack,
    this.onNext,
    this.backEnabled = true,
  });

  final int currentIndex;
  final int totalSteps;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final bool backEnabled;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Container(
        height: AppSize.bottomNavHeight.h,
        padding: EdgeInsets.symmetric(horizontal: AppPadding.p12.w),
        decoration: BoxDecoration(
          color: ColorManager.white,
          border: Border(
            top: BorderSide(
              color: ColorManager.slate100,
              width: 1.5.w,
            ),
          ),
        ),
        child: Row(
          children: [
            Opacity(
              opacity: backEnabled ? 1 : 0.3,
              child: CourseCircleIconButton(
                asset: Assets.assetsIconsCourseBack,
                size: AppSize.s40.w,
                iconSize: AppSize.s18.w,
                backgroundColor: ColorManager.slate100,
                onPressed: backEnabled ? onBack : null,
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(totalSteps, (index) {
                  final isCurrent = index == currentIndex;
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppPadding.p4.w),
                    child: AnimatedContainer(
                      duration: AppDuration.short,
                      width: isCurrent ? AppSize.stepPillWidth.w : AppSize.s6.w,
                      height: AppSize.s6.h,
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? ColorManager.navy
                            : ColorManager.slate300,
                        borderRadius:
                            BorderRadius.circular(AppRadius.rCapsule.r),
                      ),
                    ),
                  );
                }),
              ),
            ),
            CourseCircleIconButton(
              asset: Assets.assetsIconsCourseNext,
              size: AppSize.s40.w,
              iconSize: AppSize.s18.w,
              backgroundColor: ColorManager.navy,
              onPressed: onNext,
            ),
          ],
        ),
      ),
    );
  }
}
