import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/common/resources/assets_manager.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/features/course_audio/widgets/course_listen_control.dart';
import 'package:micro_teaching_studio/images_urls/assets.dart';

class AimsHeroCard extends StatelessWidget {
  const AimsHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppPadding.p16.w),
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(AppRadius.r24.r),
        border: Border.all(color: ColorManager.slate100),
        boxShadow: [
          BoxShadow(
            color: ColorManager.black.withValues(alpha: 0.05),
            blurRadius: AppSize.s4.r,
            offset: Offset(0, 1.h),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            Assets.assetsImagesAiTwinFull,
            width: AppSize.s84.w,
            height: AppSize.s80.h + AppSize.s80.h + AppSize.s40.h,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
          ),
          SizedBox(width: AppPadding.p12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppStrings.aiTwinTitle.tr(),
                        style: getExtraBoldStyle(
                          fontSize: FontSize.s13.sp,
                          color: ColorManager.navy,
                        ),
                      ),
                    ),
                    CourseListenControl(
                      asset: AudioAssets.aimsTwinIntro(),
                      color: ColorManager.navy,
                      compact: true,
                    ),
                  ],
                ),
                SizedBox(height: AppPadding.p4.h),
                Text(
                  AppStrings.yourTeachingPartner.tr(),
                  style: getRegularStyle(
                    fontSize: FontSize.s11.sp,
                    color: ColorManager.slate,
                  ),
                ),
                SizedBox(height: AppPadding.p12.h),
                Text(
                  AppStrings.aimsTwinIntro.tr(),
                  style: getRegularStyle(
                    fontSize: FontSize.s13.sp,
                    color: ColorManager.slate700,
                    height: 1.6,
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
