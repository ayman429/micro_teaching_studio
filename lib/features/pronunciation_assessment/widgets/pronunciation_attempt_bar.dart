import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/common/widgets/default_button_widget.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/cubit/pronunciation_state.dart';

class PronunciationAttemptBar extends StatelessWidget {
  const PronunciationAttemptBar({
    super.key,
    required this.state,
    required this.onRetry,
    required this.onNext,
  });

  final PronunciationState state;
  final VoidCallback onRetry;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    if (!state.showNext) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(top: AppPadding.p16.h),
      child: Row(
        children: [
          if (state.canRetry) ...[
            Expanded(
              child: SizedBox(
                height: AppSize.s40.h,
                child: DefaultButtonWidget(
                  onPressed: onRetry,
                  color: ColorManager.iceBlue,
                  radius: AppRadius.rCapsule.r,
                  elevation: 0,
                  child: Text(
                    AppStrings.tryAgainAction.tr(),
                    style: getBoldStyle(
                      fontSize: FontSize.s11.sp,
                      color: ColorManager.navy,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: AppPadding.p8.w),
          ],
          Expanded(
            child: SizedBox(
              height: AppSize.s40.h,
              child: DefaultButtonWidget(
                onPressed: onNext,
                color: ColorManager.navy,
                radius: AppRadius.rCapsule.r,
                elevation: 0,
                child: Text(
                  AppStrings.pronunciationNext.tr(),
                  style: getBoldStyle(
                    fontSize: FontSize.s11.sp,
                    color: ColorManager.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
