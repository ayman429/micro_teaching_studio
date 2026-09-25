import 'package:flutter/material.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';

class FluencyRating {
  const FluencyRating({
    required this.titleKey,
    required this.background,
    required this.border,
    required this.foreground,
  });

  final String titleKey;
  final Color background;
  final Color border;
  final Color foreground;

  static const List<FluencyRating> catalog = [
    FluencyRating(
      titleKey: AppStrings.phonicsExcellent,
      background: ColorManager.mintSoft,
      border: ColorManager.mintBorder,
      foreground: ColorManager.emerald,
    ),
    FluencyRating(
      titleKey: AppStrings.phonicsNeedsImprov,
      background: ColorManager.amberWash,
      border: ColorManager.amberBorder,
      foreground: ColorManager.amberDeep,
    ),
    FluencyRating(
      titleKey: AppStrings.phonicsIncorrect,
      background: ColorManager.roseSoft,
      border: ColorManager.roseBorder,
      foreground: ColorManager.roseDeep,
    ),
  ];
}
