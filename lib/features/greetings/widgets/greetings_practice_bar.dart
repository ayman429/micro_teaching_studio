import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/common/widgets/default_button_widget.dart';
import 'package:micro_teaching_studio/features/greetings/cubit/greetings_state.dart';
import 'package:micro_teaching_studio/images_urls/assets.dart';

class GreetingsPracticeBar extends StatelessWidget {
  const GreetingsPracticeBar({
    super.key,
    required this.state,
    required this.onPressed,
  });

  final GreetingsState state;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final recording = state.isRecording;
    final assessing = state.isAssessing;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppPadding.p16.w,
        AppPadding.p12.h,
        AppPadding.p16.w,
        AppPadding.p12.h,
      ),
      decoration: const BoxDecoration(
        color: ColorManager.white,
        border: Border(top: BorderSide(color: ColorManager.slate100)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _hint(),
            textAlign: TextAlign.center,
            style: getRegularStyle(
              fontSize: FontSize.s11.sp,
              color: recording ? ColorManager.red : ColorManager.slate,
            ),
          ),
          SizedBox(height: AppPadding.p8.h),
          SizedBox(
            width: double.infinity,
            height: AppSize.s48.h,
            child: DefaultButtonWidget(
              onPressed: assessing ? null : onPressed,
              text: recording
                  ? AppStrings.greetingsStop.tr()
                  : AppStrings.practiceTab.tr(),
              isLoading: assessing,
              isIcon: !assessing,
              svgPath: Assets.assetsIconsSessionMic,
              iconColor: ColorManager.white,
              iconSize: AppSize.s16.w,
              color: recording ? ColorManager.red : ColorManager.navy,
              textColor: ColorManager.white,
              radius: AppRadius.rCapsule.r,
              elevation: 0,
              verticalPadding: 0,
              fontSize: FontSize.s13.sp,
              loadingColor: ColorManager.white,
            ),
          ),
        ],
      ),
    );
  }

  String _hint() {
    if (state.isRecording) return AppStrings.pronunciationRecording.tr();
    if (state.isAssessing) return AppStrings.greetingsChecking.tr();
    final left = state.maxAttempts - state.attemptCount;
    final count = '${left < 0 ? 0 : left}';
    if (state.attemptCount == 0) {
      return AppStrings.threeAttemptsOnly.tr(namedArgs: {'count': count});
    }
    return AppStrings.attemptsLeft.tr(namedArgs: {'count': count});
  }
}
