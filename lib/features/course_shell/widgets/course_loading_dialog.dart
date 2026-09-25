import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';

class CourseLoadingDialog {
  static Future<T?> run<T>({
    required BuildContext context,
    required Future<T> Function() task,
  }) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: ColorManager.navy.withValues(alpha: 0.35),
      builder: (_) {
        return PopScope(
          canPop: false,
          child: Center(
            child: Material(
              color: ColorManager.white,
              borderRadius: BorderRadius.circular(AppRadius.r24.r),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppPadding.p24.w,
                  vertical: AppPadding.p24.h,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LoadingAnimationWidget.staggeredDotsWave(
                      color: ColorManager.navy,
                      size: AppSize.s40.w,
                    ),
                    SizedBox(height: AppPadding.p16.h),
                    Text(
                      AppStrings.loadingProgress.tr(),
                      textAlign: TextAlign.center,
                      style: getBoldStyle(
                        fontSize: FontSize.s14.sp,
                        color: ColorManager.navy,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    try {
      return await task();
    } finally {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }
}
