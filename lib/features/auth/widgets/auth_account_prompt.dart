import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';

class AuthAccountPrompt extends StatelessWidget {
  const AuthAccountPrompt({
    super.key,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            message,
            style: getRegularStyle(
              fontSize: FontSize.s12.sp,
              color: ColorManager.slate,
            ),
          ),
        ),
        SizedBox(width: AppPadding.p4.w),
        GestureDetector(
          onTap: onAction,
          child: Text(
            actionLabel,
            style: getBoldStyle(
              fontSize: FontSize.s12.sp,
              color: ColorManager.navy,
            ),
          ),
        ),
      ],
    );
  }
}
