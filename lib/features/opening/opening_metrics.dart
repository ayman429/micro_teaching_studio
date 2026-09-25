import 'package:micro_teaching_studio/common/resources/strings_manager.dart';

class OpeningInfoItem {
  const OpeningInfoItem({
    required this.labelKey,
    required this.valueKey,
  });

  final String labelKey;
  final String valueKey;
}

class OpeningMetrics {
  static const List<OpeningInfoItem> infoItems = [
    OpeningInfoItem(
      labelKey: AppStrings.instructorLabel,
      valueKey: AppStrings.instructorName,
    ),
    OpeningInfoItem(
      labelKey: AppStrings.divisionLabel,
      valueKey: AppStrings.divisionName,
    ),
    OpeningInfoItem(
      labelKey: AppStrings.facultyLabel,
      valueKey: AppStrings.facultyName,
    ),
  ];
}
