import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/features/phonics/models/phonics_word.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/pronunciation_ui.dart';

class PhonicsWordChip extends StatelessWidget {
  const PhonicsWordChip({
    super.key,
    required this.word,
    required this.isSelected,
    required this.onTap,
  });

  final PhonicsWord word;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? ColorManager.navy : ColorManager.white,
      borderRadius: BorderRadius.circular(AppRadius.rCapsule.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.rCapsule.r),
        child: Container(
          height: AppSize.s36.h,
          padding: EdgeInsets.symmetric(horizontal: AppPadding.p16.w),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.rCapsule.r),
            border: Border.all(
              color: isSelected ? ColorManager.navy : ColorManager.slate200,
            ),
          ),
          child: Text(
            capitalizeWord(word.wordKey.tr()),
            style: getBoldStyle(
              fontSize: FontSize.s12.sp,
              color: isSelected ? ColorManager.white : ColorManager.slate700,
            ),
          ),
        ),
      ),
    );
  }
}
