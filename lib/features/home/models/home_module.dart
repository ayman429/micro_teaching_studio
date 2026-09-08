import 'package:flutter/material.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/features/home/models/home_session.dart';
import 'package:micro_teaching_studio/images_urls/assets.dart';

class HomeModule {
  const HomeModule({
    required this.number,
    required this.iconAsset,
    required this.iconBackground,
    required this.progress,
    required this.titleKey,
    required this.sessions,
  });

  final int number;
  final String iconAsset;
  final Color iconBackground;
  final double progress;
  final String titleKey;
  final List<HomeSession> sessions;

  static const List<HomeModule> catalog = [
    HomeModule(
      number: 1,
      iconAsset: Assets.assetsIconsModuleSpeaker,
      iconBackground: ColorManager.actionBlue,
      progress: 0.6,
      titleKey: AppStrings.module1Title,
      sessions: [
        HomeSession(number: 1, labelKey: AppStrings.session1Fluency),
        HomeSession(number: 2, labelKey: AppStrings.session2Phonics),
      ],
    ),
    HomeModule(
      number: 2,
      iconAsset: Assets.assetsIconsModuleUsers,
      iconBackground: ColorManager.navy,
      progress: 0.25,
      titleKey: AppStrings.module2Title,
      sessions: [
        HomeSession(number: 1, labelKey: AppStrings.session1Greetings),
        HomeSession(number: 2, labelKey: AppStrings.session2ClassroomLanguage),
      ],
    ),
    HomeModule(
      number: 3,
      iconAsset: Assets.assetsIconsModuleBook,
      iconBackground: ColorManager.accentAmber,
      progress: 0,
      titleKey: AppStrings.module3Title,
      sessions: [
        HomeSession(number: 1, labelKey: AppStrings.sessionVocabPresentation),
        HomeSession(
          number: 2,
          labelKey: AppStrings.sessionPresentContinuousWarmup,
        ),
        HomeSession(
          number: 3,
          labelKey: AppStrings.sessionPresentContinuousPresentation,
        ),
      ],
    ),
  ];
}
