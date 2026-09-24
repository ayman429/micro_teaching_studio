import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/common/resources/assets_manager.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/features/aims/aims_metrics.dart';
import 'package:micro_teaching_studio/features/aims/widgets/aims_check_row.dart';
import 'package:micro_teaching_studio/features/course_audio/widgets/course_listen_control.dart';

class AimsObjectivesCard extends StatelessWidget {
  const AimsObjectivesCard({super.key});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppStrings.aimsProgramHeading.tr(),
                  style: getExtraBoldStyle(
                    fontSize: FontSize.s15.sp,
                    color: ColorManager.navy,
                  ),
                ),
              ),
              CourseListenControl(
                asset: AudioAssets.aimsObjectives(),
                color: ColorManager.navy,
                compact: true,
              ),
            ],
          ),
          SizedBox(height: AppPadding.p12.h),
          Text(
            AppStrings.aimsOutcomeLead.tr(),
            style: getBoldStyle(
              fontSize: FontSize.s13.sp,
              color: ColorManager.slate800,
              height: 1.5,
            ),
          ),
          SizedBox(height: AppPadding.p12.h),
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
    );
  }
}
