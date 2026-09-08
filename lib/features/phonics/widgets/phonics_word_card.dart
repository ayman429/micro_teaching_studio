import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/features/course_shell/widgets/course_svg_icon.dart';
import 'package:micro_teaching_studio/features/phonics/models/phonics_rating.dart';
import 'package:micro_teaching_studio/features/phonics/models/phonics_word.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/cubit/pronunciation_cubit.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/cubit/pronunciation_state.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/pronunciation_ui.dart';
import 'package:micro_teaching_studio/images_urls/assets.dart';

class PhonicsWordCard extends StatelessWidget {
  const PhonicsWordCard({
    super.key,
    required this.word,
    required this.onSpeak,
  });

  final PhonicsWord word;
  final VoidCallback onSpeak;

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
              Text(
                AppStrings.currentWord.tr(),
                textAlign: TextAlign.center,
                style: getBoldStyle(
                  fontSize: FontSize.s10.sp,
                  color: ColorManager.slate400,
                ).copyWith(letterSpacing: AppLetterSpacing.label),
              ),
              SizedBox(height: AppPadding.p8.h),
              Text(
                word.wordKey.tr(),
                textAlign: TextAlign.center,
                style: getExtraBoldStyle(
                  fontSize: FontSize.s32.sp,
                  color: pronunciationBandColor(state.band, ColorManager.navy),
                ).copyWith(letterSpacing: AppLetterSpacing.display),
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
                onPressed: onSpeak,
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
              Row(
                children: PhonicsRating.catalog
                    .map(
                      (rating) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppPadding.p4.w,
                          ),
                          child: _RatingTile(
                            rating: rating,
                            isActive: pronunciationTileActive(
                              titleKey: rating.titleKey,
                              band: state.band,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              SizedBox(height: AppPadding.p16.h),
              _AiTwinTip(
                tip: pronunciationTwinTip(state, AppStrings.phonicsAiTwinTip),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RatingTile extends StatelessWidget {
  const _RatingTile({
    required this.rating,
    required this.isActive,
  });

  final PhonicsRating rating;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isActive ? 1 : 0.4,
      child: Container(
        height: AppSize.s40.h,
        padding: EdgeInsets.symmetric(horizontal: AppPadding.p4.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: rating.background,
          borderRadius: BorderRadius.circular(AppRadius.r16.r),
          border: Border.all(color: rating.border),
        ),
        child: Text(
          rating.titleKey.tr(),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: getBoldStyle(
            fontSize: FontSize.s10.sp,
            color: rating.foreground,
          ),
        ),
      ),
    );
  }
}

class _AiTwinTip extends StatelessWidget {
  const _AiTwinTip({required this.tip});

  final String tip;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppPadding.p12.w),
      decoration: BoxDecoration(
        color: ColorManager.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.r16.r),
        border: Border.all(color: ColorManager.slate200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppSize.s32.w,
            height: AppSize.s32.w,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: ColorManager.gradientAvatarGirl,
              ),
            ),
            child: CourseSvgIcon(
              asset: Assets.assetsIconsAiTwin,
              size: AppSize.s28.w,
            ),
          ),
          SizedBox(width: AppPadding.p12.w),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${AppStrings.aiTwinLabel.tr()} ',
                    style: getBoldStyle(
                      fontSize: FontSize.s11.sp,
                      color: ColorManager.slate700,
                    ),
                  ),
                  TextSpan(
                    text: tip,
                    style: getRegularStyle(
                      fontSize: FontSize.s11.sp,
                      color: ColorManager.slate700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
