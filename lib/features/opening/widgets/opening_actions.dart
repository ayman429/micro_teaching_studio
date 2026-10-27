import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/common/widgets/default_button_widget.dart';

class OpeningActions extends StatelessWidget {
  const OpeningActions({
    super.key,
    required this.onHelp,
    required this.onContinue,
  });

  final VoidCallback onHelp;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: AppSize.submitHeight.h,
            child: DefaultButtonWidget(
              onPressed: onHelp,
              color: ColorManager.white,
              withBorder: true,
              borderColor: ColorManager.navy,
              radius: AppRadius.r16.r,
              elevation: 0,
              child: Text(
                AppStrings.helpAction.tr(),
                textAlign: TextAlign.center,
                style: getBoldStyle(
                  fontSize: FontSize.s16.sp,
                  color: ColorManager.navy,
                ).copyWith(letterSpacing: AppLetterSpacing.title),
              ),
            ),
          ),
        ),
        SizedBox(width: AppPadding.p12.w),
        Expanded(
          child: SizedBox(
            height: AppSize.submitHeight.h,
            child: DefaultButtonWidget(
              onPressed: onContinue,
              color: ColorManager.navy,
              radius: AppRadius.r16.r,
              elevation: 0,
              child: Text(
                AppStrings.continueAction.tr(),
                textAlign: TextAlign.center,
                style: getBoldStyle(
                  fontSize: FontSize.s16.sp,
                  color: ColorManager.white,
                ).copyWith(letterSpacing: AppLetterSpacing.title),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
