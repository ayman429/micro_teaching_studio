import 'package:micro_teaching_studio/common/resources/assets_manager.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/common/widgets/default_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

class DefaultErrorWidget extends StatelessWidget {
  final String errorMessage;
  final String buttonTitle;
  final void Function()? onPressed;
  const DefaultErrorWidget(
      {super.key,
      required this.errorMessage,
      this.onPressed,
      this.buttonTitle = ''});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset(JsonAssets.error, height: 100.h),
          SizedBox(
            height: 20.h,
          ),
          Text(
            errorMessage,
            style: getBoldStyle(fontSize: 15.sp, color: ColorManager.grey),
            textAlign: TextAlign.start,
          ),
          SizedBox(
            height: 20.h,
          ),
          if (onPressed != null && buttonTitle.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: DefaultButtonWidget(
                text: buttonTitle,
                color: ColorManager.primary,
                onPressed: onPressed,
                textColor: ColorManager.white,
              ),
            )
        ],
      ),
    );
  }
}
