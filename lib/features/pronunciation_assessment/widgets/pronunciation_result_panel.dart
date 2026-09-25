import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/cubit/pronunciation_state.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/models/pronunciation_result.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/pronunciation_constants.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/pronunciation_ui.dart';
import 'package:micro_teaching_studio/images_urls/assets.dart';

class PronunciationAttemptsLabel extends StatelessWidget {
  const PronunciationAttemptsLabel({super.key, required this.state});

  final PronunciationState state;

  @override
  Widget build(BuildContext context) {
    if (state.band == PronunciationBand.excellent) {
      return const SizedBox.shrink();
    }
    final remaining = state.remainingAttempts;
    return Text(
      remaining == 0
          ? AppStrings.noAttemptsLeft.tr()
          : AppStrings.attemptsLeft.tr(
              namedArgs: {'count': '$remaining'},
            ),
      textAlign: TextAlign.center,
      style: getBoldStyle(
        fontSize: FontSize.s12.sp,
        color: ColorManager.navy,
      ),
    );
  }
}

class PronunciationResultBanner extends StatelessWidget {
  const PronunciationResultBanner({super.key, required this.band});

  final PronunciationBand band;

  @override
  Widget build(BuildContext context) {
    final color = pronunciationBandColor(band, ColorManager.navy);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppPadding.p16.w,
        vertical: AppPadding.p12.h,
      ),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.r16.r),
        border: Border.all(color: color),
      ),
      child: Text(
        pronunciationResultLabel(band),
        textAlign: TextAlign.center,
        style: getExtraBoldStyle(
          fontSize: FontSize.s16.sp,
          color: color,
        ),
      ),
    );
  }
}

class PronunciationAiTwinReport extends StatelessWidget {
  const PronunciationAiTwinReport({super.key, required this.state});

  final PronunciationState state;

  @override
  Widget build(BuildContext context) {
    final result = state.result;
    if (result == null) return const SizedBox.shrink();
    final lines = pronunciationErrorLines(result);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppPadding.p12.w),
      decoration: BoxDecoration(
        color: ColorManager.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.r16.r),
        border: Border.all(color: ColorManager.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipOval(
                child: Image.asset(
                  Assets.assetsImagesAiTwinHead,
                  width: AppSize.s32.w,
                  height: AppSize.s32.w,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: AppPadding.p12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.aiTwinLabel.tr(),
                      style: getBoldStyle(
                        fontSize: FontSize.s11.sp,
                        color: ColorManager.slate700,
                      ),
                    ),
                    SizedBox(height: AppPadding.p4.h),
                    if (lines.isEmpty)
                      Text(
                        result.phonics
                            ? AppStrings.phonicsAiTwinExcellent.tr()
                            : AppStrings.allWordsCorrect.tr(),
                        style: getRegularStyle(
                          fontSize: FontSize.s11.sp,
                          color: ColorManager.slate700,
                        ),
                      )
                    else
                      ...lines.map(
                        (line) => Padding(
                          padding: EdgeInsets.only(bottom: AppPadding.p4.h),
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: line.word,
                                  style: getBoldStyle(
                                    fontSize: FontSize.s11.sp,
                                    color: pronunciationBandColor(
                                      line.band,
                                      ColorManager.navy,
                                    ),
                                  ),
                                ),
                                TextSpan(
                                  text: ' — ${line.description}',
                                  style: getRegularStyle(
                                    fontSize: FontSize.s11.sp,
                                    color: ColorManager.slate,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppPadding.p12.h),
          Text(
            AppStrings.pronunciationScoreLabel.tr(
              namedArgs: {
                'value':
                    '${(result.pronScore ?? result.accuracyScore ?? 0).round()}',
              },
            ),
            style: getBoldStyle(
              fontSize: FontSize.s12.sp,
              color: pronunciationBandColor(result.band, ColorManager.navy),
            ),
          ),
          SizedBox(height: AppPadding.p8.h),
          PronunciationColorLegend(phonics: result.phonics),
        ],
      ),
    );
  }
}

class PronunciationColorLegend extends StatelessWidget {
  const PronunciationColorLegend({super.key, this.phonics = false});

  final bool phonics;

  @override
  Widget build(BuildContext context) {
    final excellentMin = phonics
        ? PronunciationConstants.phonicsExcellentMin
        : PronunciationConstants.excellentMin;
    final needsMin = PronunciationConstants.needsImprovMin;
    return Column(
      children: [
        _LegendRow(
          color: ColorManager.emerald,
          label: AppStrings.colorLegendExcellent.tr(
            namedArgs: {'min': '${excellentMin.toInt()}'},
          ),
        ),
        SizedBox(height: AppPadding.p4.h),
        _LegendRow(
          color: ColorManager.amberDeep,
          label: AppStrings.colorLegendNeedsImprov.tr(
            namedArgs: {
              'min': '${needsMin.toInt()}',
              'max': '${excellentMin.toInt() - 1}',
            },
          ),
        ),
        SizedBox(height: AppPadding.p4.h),
        _LegendRow(
          color: ColorManager.roseDeep,
          label: AppStrings.colorLegendIncorrect.tr(
            namedArgs: {'max': '${needsMin.toInt()}'},
          ),
        ),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: AppSize.s12.w,
          height: AppSize.s12.w,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppRadius.rCapsule.r),
          ),
        ),
        SizedBox(width: AppPadding.p8.w),
        Expanded(
          child: Text(
            label,
            style: getRegularStyle(
              fontSize: FontSize.s10.sp,
              color: ColorManager.slate,
            ),
          ),
        ),
      ],
    );
  }
}
