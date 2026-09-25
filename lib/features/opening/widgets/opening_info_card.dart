import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/features/opening/opening_metrics.dart';
import 'package:micro_teaching_studio/features/opening/widgets/opening_info_row.dart';

class OpeningInfoCard extends StatelessWidget {
  const OpeningInfoCard({super.key});

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
          Text(
            AppStrings.courseInformation.tr(),
            style: getExtraBoldStyle(
              fontSize: FontSize.s15.sp,
              color: ColorManager.navy,
            ),
          ),
          SizedBox(height: AppPadding.p16.h),
          ...OpeningMetrics.infoItems.asMap().entries.map((entry) {
            final isLast = entry.key == OpeningMetrics.infoItems.length - 1;
            return OpeningInfoRow(
              item: entry.value,
              showDivider: !isLast,
            );
          }),
        ],
      ),
    );
  }
}
