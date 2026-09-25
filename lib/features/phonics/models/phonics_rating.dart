import 'package:flutter/material.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';

class PhonicsRating {
  const PhonicsRating({
    required this.titleKey,
    required this.background,
    required this.border,
    required this.foreground,
  });

  final String titleKey;
  final Color background;
  final Color border;
  final Color foreground;

  static const List<PhonicsRating> catalog = [
    PhonicsRating(
      titleKey: AppStrings.phonicsExcellent,
      background: ColorManager.mintSoft,
      border: ColorManager.mintBorder,
      foreground: ColorManager.emerald,
    ),
    PhonicsRating(
      titleKey: AppStrings.phonicsNeedsImprov,
      background: ColorManager.amberWash,
      border: ColorManager.amberBorder,
      foreground: ColorManager.amberDeep,
    ),
    PhonicsRating(
      titleKey: AppStrings.phonicsIncorrect,
      background: ColorManager.roseSoft,
      border: ColorManager.roseBorder,
      foreground: ColorManager.roseDeep,
    ),
  ];
}
