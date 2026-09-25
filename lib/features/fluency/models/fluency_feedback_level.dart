import 'package:flutter/material.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';

class FluencyFeedbackLevel {
  const FluencyFeedbackLevel({
    required this.dotColor,
    required this.labelKey,
  });

  final Color dotColor;
  final String labelKey;

  static const List<FluencyFeedbackLevel> catalog = [
    FluencyFeedbackLevel(
      dotColor: ColorManager.progressGreen,
      labelKey: AppStrings.feedbackExcellent,
    ),
    FluencyFeedbackLevel(
      dotColor: ColorManager.actionBlue,
      labelKey: AppStrings.feedbackWellDone,
    ),
    FluencyFeedbackLevel(
      dotColor: ColorManager.accentAmber,
      labelKey: AppStrings.feedbackGoodEffort,
    ),
    FluencyFeedbackLevel(
      dotColor: ColorManager.softCoral,
      labelKey: AppStrings.feedbackDontGiveUp,
    ),
    FluencyFeedbackLevel(
      dotColor: ColorManager.slate600,
      labelKey: AppStrings.feedbackNoResponse,
    ),
  ];
}
