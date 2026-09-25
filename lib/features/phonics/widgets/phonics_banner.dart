import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';

class PhonicsBanner extends StatelessWidget {
  const PhonicsBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppPadding.p16.w),
      decoration: BoxDecoration(
        color: ColorManager.navy,
        borderRadius: BorderRadius.circular(AppRadius.r20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.phonicsTraining.tr(),
            style: getBoldStyle(
              fontSize: FontSize.s13.sp,
              color: ColorManager.white,
            ),
          ),
          SizedBox(height: AppPadding.p4.h),
          Text(
            AppStrings.phonicsSessionSubtitle.tr(
              namedArgs: {
                'module': '1',
                'session': '2',
              },
            ),
            style: getRegularStyle(
              fontSize: FontSize.s11.sp,
              color: ColorManager.onNavyMuted,
            ),
          ),
        ],
      ),
    );
  }
}
