import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/common/widgets/default_button_widget.dart';
import 'package:micro_teaching_studio/features/fluency/models/fluency_feedback_level.dart';

class FluencyFeedbackCard extends StatelessWidget {
  const FluencyFeedbackCard({
    super.key,
    required this.onTryAgain,
    required this.onContinue,
  });

  final VoidCallback onTryAgain;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppPadding.p16.w),
      decoration: BoxDecoration(
        color: ColorManager.slate900,
        borderRadius: BorderRadius.circular(AppRadius.r24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.feedbackTitle.tr(),
            style: getBoldStyle(
              fontSize: FontSize.s11.sp,
              color: ColorManager.onDarkSoft,
            ).copyWith(letterSpacing: AppLetterSpacing.video),
          ),
          SizedBox(height: AppPadding.p16.h),
          ...FluencyFeedbackLevel.catalog.map(
            (level) => Padding(
              padding: EdgeInsets.only(bottom: AppPadding.p8.h),
              child: _FeedbackRow(level: level),
            ),
          ),
          SizedBox(height: AppPadding.p8.h),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: AppSize.s40.h,
                  child: DefaultButtonWidget(
                    onPressed: onTryAgain,
                    color: ColorManager.onDarkFill,
                    radius: AppRadius.rCapsule.r,
                    elevation: 0,
                    child: Text(
                      AppStrings.tryAgainAction.tr(),
                      style: getBoldStyle(
                        fontSize: FontSize.s11.sp,
                        color: ColorManager.white,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppPadding.p8.w),
              Expanded(
                child: SizedBox(
                  height: AppSize.s40.h,
                  child: DefaultButtonWidget(
                    onPressed: onContinue,
                    color: ColorManager.white,
                    radius: AppRadius.rCapsule.r,
                    elevation: 0,
                    child: Text(
                      AppStrings.continueString.tr(),
                      style: getBoldStyle(
                        fontSize: FontSize.s11.sp,
                        color: ColorManager.slate900,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeedbackRow extends StatelessWidget {
  const _FeedbackRow({required this.level});

  final FluencyFeedbackLevel level;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: AppSize.s32.h,
      padding: EdgeInsets.symmetric(horizontal: AppPadding.p12.w),
      decoration: BoxDecoration(
        color: ColorManager.onDarkFill,
        borderRadius: BorderRadius.circular(AppRadius.rCapsule.r),
      ),
      child: Row(
        children: [
          Container(
            width: AppSize.s8.w,
            height: AppSize.s8.w,
            decoration: BoxDecoration(
              color: level.dotColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: AppPadding.p8.w),
          Expanded(
            child: Text(
              level.labelKey.tr(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: getRegularStyle(
                fontSize: FontSize.s11.sp,
                color: ColorManager.onDarkMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
