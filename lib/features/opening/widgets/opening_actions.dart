import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/common/widgets/default_button_widget.dart';
import 'package:micro_teaching_studio/features/course_shell/widgets/course_svg_icon.dart';
import 'package:micro_teaching_studio/images_urls/assets.dart';

class OpeningActions extends StatelessWidget {
  const OpeningActions({
    super.key,
    required this.onHelp,
    required this.onSkip,
  });

  final VoidCallback onHelp;
  final VoidCallback onSkip;

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
              onPressed: onSkip,
              color: ColorManager.navy,
              radius: AppRadius.r16.r,
              elevation: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.skip.tr(),
                    style: getBoldStyle(
                      fontSize: FontSize.s16.sp,
                      color: ColorManager.white,
                    ).copyWith(letterSpacing: AppLetterSpacing.title),
                  ),
                  SizedBox(width: AppPadding.p8.w),
                  CourseSvgIcon(
                    asset: Assets.assetsIconsCourseSkip,
                    size: AppSize.s18.w,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
