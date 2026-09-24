import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/features/course_shell/widgets/course_svg_icon.dart';
import 'package:micro_teaching_studio/images_urls/assets.dart';

class OpeningHeroCard extends StatelessWidget {
  const OpeningHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppPadding.p20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: ColorManager.gradientCourse,
        ),
        borderRadius: BorderRadius.circular(AppRadius.r24.r),
        boxShadow: [
          BoxShadow(
            color: ColorManager.navyGlow,
            blurRadius: AppPadding.p16.r,
            offset: Offset(0, AppPadding.p8.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppSize.s56.w,
            height: AppSize.s56.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ColorManager.onDarkFill,
              shape: BoxShape.circle,
              border: Border.all(color: ColorManager.onDarkStroke),
            ),
            child: CourseSvgIcon(
              asset: Assets.assetsIconsLogo,
              size: AppSize.s32.w,
            ),
          ),
          SizedBox(height: AppPadding.p16.h),
          Text(
            AppStrings.courseLabel.tr(),
            style: getBoldStyle(
              fontSize: FontSize.s10.sp,
              color: ColorManager.onNavyMuted,
            ).copyWith(letterSpacing: AppLetterSpacing.label),
          ),
          SizedBox(height: AppPadding.p8.h),
          Text(
            AppStrings.courseTitle.tr(),
            style: getExtraBoldStyle(
              fontSize: FontSize.s22.sp,
              color: ColorManager.white,
            ).copyWith(letterSpacing: AppLetterSpacing.tight),
          ),
          SizedBox(height: AppPadding.p8.h),
          Text(
            AppStrings.courseYearFaculty.tr(
              namedArgs: {
                'year': AppStrings.courseAcademicYear.tr(),
                'faculty': AppStrings.facultyName.tr(),
              },
            ),
            style: getRegularStyle(
              fontSize: FontSize.s12.sp,
              color: ColorManager.onNavyBody,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
