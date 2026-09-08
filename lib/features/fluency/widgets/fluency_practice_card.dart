import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/features/course_shell/widgets/course_svg_icon.dart';
import 'package:micro_teaching_studio/features/fluency/models/fluency_rating.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/cubit/pronunciation_cubit.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/cubit/pronunciation_state.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/pronunciation_ui.dart';
import 'package:micro_teaching_studio/images_urls/assets.dart';

class FluencyPracticeCard extends StatelessWidget {
  const FluencyPracticeCard({
    super.key,
    required this.onSpeak,
  });

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
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  AppStrings.readThisText.tr(),
                  style: getBoldStyle(
                    fontSize: FontSize.s10.sp,
                    color: ColorManager.slate400,
                  ).copyWith(letterSpacing: AppLetterSpacing.label),
                ),
              ),
              SizedBox(height: AppPadding.p12.h),
              Text.rich(
                TextSpan(
                  children: pronunciationPassageSpans(
                    passage: AppStrings.fluencyPracticePassage.tr(),
                    result: state.result,
                    baseStyle: getMediumStyle(
                      fontSize: FontSize.s14.sp,
                      color: ColorManager.slate800,
                      height: 1.625,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppPadding.p20.h),
              DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: pronunciationMicGlow(state, ColorManager.navyGlow),
                      blurRadius: AppSize.s16,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: CourseCircleIconButton(
                  asset: Assets.assetsIconsSessionMic,
                  size: AppSize.s84.w,
                  iconSize: AppSize.s28.w,
                  backgroundColor: pronunciationMicColor(
                    state,
                    ColorManager.navy,
                  ),
                  onPressed: onSpeak,
                ),
              ),
              SizedBox(height: AppPadding.p16.h),
              Text(
                pronunciationMicHint(state, AppStrings.tapToSpeak),
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
                children: FluencyRating.catalog
                    .map(
                      (rating) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppPadding.p4.w,
                          ),
                          child: _FluencyRatingTile(
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
              _FluencyAiTwinTip(
                tip: pronunciationTwinTip(state, AppStrings.fluencyAiTwinTip),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FluencyRatingTile extends StatelessWidget {
  const _FluencyRatingTile({
    required this.rating,
    required this.isActive,
  });

  final FluencyRating rating;
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

class _FluencyAiTwinTip extends StatelessWidget {
  const _FluencyAiTwinTip({required this.tip});

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
