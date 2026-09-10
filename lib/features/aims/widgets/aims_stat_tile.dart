import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/features/aims/aims_metrics.dart';

class AimsStatTile extends StatelessWidget {
  const AimsStatTile({super.key, required this.stat});

  final AimsStat stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSize.s64.h,
      padding: EdgeInsets.symmetric(horizontal: AppPadding.p8.w),
      decoration: BoxDecoration(
        color: ColorManager.slate900,
        borderRadius: BorderRadius.circular(AppRadius.r16.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            stat.value,
            style: getExtraBoldStyle(
              fontSize: FontSize.s18.sp,
              color: ColorManager.white,
            ),
          ),
          Text(
            stat.labelKey.tr(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: getRegularStyle(
              fontSize: FontSize.s9.sp,
              color: ColorManager.onDarkSoft,
            ).copyWith(letterSpacing: AppLetterSpacing.stat),
          ),
        ],
      ),
    );
  }
}
