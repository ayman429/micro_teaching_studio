import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/features/aims/aims_metrics.dart';
import 'package:micro_teaching_studio/features/aims/widgets/aims_check_row.dart';

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
          SizedBox(
            width: AppSize.s84.w,
            child: Column(
              children: [
                Container(
                  width: AppSize.s84.w,
                  height: AppSize.s84.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.r20.r),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: ColorManager.gradientAvatarGirl,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: ColorManager.black.withValues(alpha: 0.1),
                        blurRadius: AppPadding.p16.r,
                        offset: Offset(0, AppPadding.p4.h),
                      ),
                    ],
                  ),
                  child: Text(
                    AimsMetrics.twinGlyph,
                    style: getRegularStyle(
                      fontSize: FontSize.s32.sp,
                      color: ColorManager.slate800,
                    ),
                  ),
                ),
                SizedBox(height: AppPadding.p8.h),
                Text(
                  AppStrings.aiTwinSara.tr(),
                  textAlign: TextAlign.center,
                  style: getExtraBoldStyle(
                    fontSize: FontSize.s11.sp,
                    color: ColorManager.slate800,
                  ),
                ),
                SizedBox(height: AppPadding.p4.h),
                Text(
                  AppStrings.yourTeachingPartner.tr(),
                  textAlign: TextAlign.center,
                  style: getRegularStyle(
                    fontSize: FontSize.s9.sp,
                    color: ColorManager.slate,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppPadding.p16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.aimsProgramHeading.tr(),
                  style: getExtraBoldStyle(
                    fontSize: FontSize.s15.sp,
                    color: ColorManager.navy,
                  ),
                ),
                SizedBox(height: AppPadding.p4.h),
                Text(
                  AppStrings.aimsProgramHeadingAr.tr(),
                  style: getRegularStyle(
                    fontSize: FontSize.s10.sp,
                    color: ColorManager.slate,
                  ),
                ),
                SizedBox(height: AppPadding.p8.h),
                ...AimsMetrics.itemKeys.asMap().entries.map((entry) {
                  final isLast = entry.key == AimsMetrics.itemKeys.length - 1;
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: isLast ? 0 : AppPadding.p8.h,
                    ),
                    child: AimsCheckRow(labelKey: entry.value),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
