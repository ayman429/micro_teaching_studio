import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/features/opening/opening_metrics.dart';

class OpeningInfoRow extends StatelessWidget {
  const OpeningInfoRow({
    super.key,
    required this.item,
    this.showDivider = true,
  });

  final OpeningInfoItem item;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.labelKey.tr(),
          style: getBoldStyle(
            fontSize: FontSize.s10.sp,
            color: ColorManager.slate,
          ).copyWith(letterSpacing: AppLetterSpacing.label),
        ),
        SizedBox(height: AppPadding.p4.h),
        Text(
          item.valueKey.tr(),
          style: getBoldStyle(
            fontSize: FontSize.s13.sp,
            color: ColorManager.slate800,
          ),
        ),
        if (showDivider) ...[
          SizedBox(height: AppPadding.p12.h),
          Divider(
            height: 1.h,
            thickness: 1.h,
            color: ColorManager.slate100,
          ),
          SizedBox(height: AppPadding.p12.h),
        ],
      ],
    );
  }
}
