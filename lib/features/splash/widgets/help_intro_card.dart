import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/features/course_shell/widgets/course_svg_icon.dart';
import 'package:micro_teaching_studio/images_urls/assets.dart';

class HelpIntroCard extends StatelessWidget {
  const HelpIntroCard({super.key});

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
            color: ColorManager.black.withValues(alpha: 0.06),
            blurRadius: AppPadding.p16.r,
            offset: Offset(0, AppPadding.p8.h),
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
                  color: ColorManager.amberSoft,
                  shape: BoxShape.circle,
                ),
                child: CourseSvgIcon(
                  asset: Assets.assetsIconsHelpLightbulb,
                  size: AppSize.s16.w,
                ),
              ),
              SizedBox(width: AppPadding.p8.w),
              Expanded(
                child: Text(
                  AppStrings.howToUseThisApp.tr(),
                  style: getBoldStyle(
                    fontSize: FontSize.s15.sp,
                    color: ColorManager.slate800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppPadding.p16.h),
          Text(
            AppStrings.howToUseThisAppBody.tr(),
            style: getRegularStyle(
              fontSize: FontSize.s13.sp,
              color: ColorManager.slate600,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
