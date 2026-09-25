import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/common/widgets/default_button_widget.dart';

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSize.submitHeight.h,
      width: double.infinity,
      child: DefaultButtonWidget(
        text: label,
        onPressed: isLoading ? null : onPressed,
        isLoading: isLoading,
        color: ColorManager.navy,
        textColor: ColorManager.white,
        radius: AppRadius.r16.r,
        fontSize: FontSize.s12.sp,
        elevation: 0,
        textStyle: getExtraBoldStyle(
          fontSize: FontSize.s12.sp,
          color: ColorManager.white,
        ).copyWith(letterSpacing: AppLetterSpacing.button),
      ),
    );
  }
}
