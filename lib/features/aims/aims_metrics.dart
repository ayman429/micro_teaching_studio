import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/features/course_shell/course_constants.dart';

class AimsMetrics {
  static const String twinGlyph = '👩🏻‍🏫';

  static const List<String> itemKeys = [
    AppStrings.aimsItemFluency,
    AppStrings.aimsItemPhonics,
    AppStrings.aimsItemManagement,
    AppStrings.aimsItemTpr,
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
