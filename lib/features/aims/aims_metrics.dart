import 'package:micro_teaching_studio/common/resources/assets_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/features/course_shell/course_constants.dart';

class AimsMetrics {
  static const String twinGlyph = '👩🏻‍🏫';

  static const List<String> itemKeys = [
    AppStrings.aimsObjective1,
    AppStrings.aimsObjective2,
    AppStrings.aimsObjective3,
    AppStrings.aimsObjective4,
    AppStrings.aimsObjective5,
    AppStrings.aimsObjective6,
    AppStrings.aimsObjective7,
    AppStrings.aimsObjective8,
    AppStrings.aimsObjective9,
    AppStrings.aimsObjective10,
    AppStrings.aimsObjective11,
    AppStrings.aimsObjective12,
    AppStrings.aimsObjective13,
  ];

  static List<String> audioSequence() => [
        AudioAssets.aimsTwinIntro(),
        AudioAssets.aimsObjectives(),
      ];

  static const List<AimsStat> stats = [
    AimsStat(
      value: '${CourseConstants.totalFrames}',
      labelKey: AppStrings.microSkillsLabel,
    ),
    AimsStat(
      value: '${CourseConstants.moduleCount}',
      labelKey: AppStrings.modulesStatLabel,
    ),
    AimsStat(
      value: '${CourseConstants.contentFrameCount}',
      labelKey: AppStrings.framesLabel,
    ),
  ];
}

class AimsStat {
  const AimsStat({
    required this.value,
    required this.labelKey,
  });

  final String value;
  final String labelKey;
}
