import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/common/resources/assets_manager.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/features/course_audio/cubit/course_audio_cubit.dart';
import 'package:micro_teaching_studio/features/course_audio/widgets/course_listen_control.dart';
import 'package:micro_teaching_studio/features/course_shell/widgets/course_svg_icon.dart';
import 'package:micro_teaching_studio/features/phonics/models/phonics_word.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/cubit/pronunciation_cubit.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/cubit/pronunciation_state.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/pronunciation_ui.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/widgets/pronunciation_attempt_bar.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/widgets/pronunciation_result_panel.dart';
import 'package:micro_teaching_studio/images_urls/assets.dart';

class PhonicsWordCard extends StatelessWidget {
  const PhonicsWordCard({
    super.key,
    required this.word,
    required this.onSpeak,
    required this.onNext,
  });

  final PhonicsWord word;
  final VoidCallback onSpeak;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PronunciationCubit, PronunciationState>(
      builder: (context, state) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppPadding.p20.w),
          decoration: BoxDecoration(
            color: ColorManager.white,
            borderRadius: BorderRadius.circular(AppRadius.r24.r),
            border: Border.all(color: ColorManager.slate100),
            boxShadow: [
              BoxShadow(
                color: ColorManager.black.withValues(alpha: 0.05),
                blurRadius: AppPadding.p4.r,
                offset: Offset(0, 1.h),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      AppStrings.currentWord.tr(),
                      style: getBoldStyle(
                        fontSize: FontSize.s10.sp,
                        color: ColorManager.slate400,
                      ).copyWith(letterSpacing: AppLetterSpacing.label),
                    ),
                  ),
                  CourseListenControl(
                    asset: AudioAssets.phonicsClip(word.wordKey.tr()),
                    color: ColorManager.actionBlue,
                    enabled: !state.isRecording && !state.isAssessing,
                    compact: true,
                  ),
                ],
              ),
              SizedBox(height: AppPadding.p8.h),
              GestureDetector(
                onTap: !state.isRecording && !state.isAssessing
                    ? () => context.read<CourseAudioCubit>().toggle(
                          AudioAssets.phonicsClip(word.wordKey.tr()),
                        )
                    : null,
                child: Text(
                  capitalizeWord(word.wordKey.tr()),
                  textAlign: TextAlign.center,
                  style: getExtraBoldStyle(
                    fontSize: FontSize.s32.sp,
                    color: pronunciationBandColor(state.band, ColorManager.navy),
                  ).copyWith(letterSpacing: AppLetterSpacing.display),
                ),
              ),
              SizedBox(height: AppPadding.p8.h),
              Text.rich(
                TextSpan(
                  children: pronunciationIpaSpans(
                    ipa: word.ipaKey.tr(),
                    result: state.result,
                    baseStyle: getRegularStyle(
                      fontSize: FontSize.s12.sp,
                      color: ColorManager.slate,
                    ),
                  ),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppPadding.p24.h),
              CourseCircleIconButton(
                asset: Assets.assetsIconsSessionMic,
                size: AppSize.s72.w,
                iconSize: AppSize.s24.w,
                backgroundColor: pronunciationMicColor(
                  state,
                  ColorManager.actionBlue,
                ),
                onPressed: state.canStartRecording ? onSpeak : null,
              ),
              SizedBox(height: AppPadding.p8.h),
              Text(
                pronunciationMicHint(state, AppStrings.tapAndPronounce),
                textAlign: TextAlign.center,
                style: getRegularStyle(
                  fontSize: FontSize.s11.sp,
                  color: state.isRecording
                      ? ColorManager.red
                      : ColorManager.slate,
                ),
              ),
              SizedBox(height: AppPadding.p16.h),
              PronunciationAttemptsLabel(state: state),
              if (state.isScored && state.band != null) ...[
                SizedBox(height: AppPadding.p16.h),
                PronunciationResultBanner(band: state.band!),
              ],
              PronunciationAttemptBar(
                state: state,
                onRetry: onSpeak,
                onNext: onNext,
              ),
              if (state.isScored && state.band != null) ...[
                SizedBox(height: AppPadding.p16.h),
                PronunciationAiTwinReport(state: state),
              ],
            ],
          ),
        );
      },
    );
  }
}
