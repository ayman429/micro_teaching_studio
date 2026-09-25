import 'package:micro_teaching_studio/common/resources/strings_manager.dart';

class PhonicsWord {
  const PhonicsWord({
    required this.wordKey,
    required this.ipaKey,
  });

  final String wordKey;
  final String ipaKey;

  static const List<PhonicsWord> catalog = [
    PhonicsWord(
      wordKey: AppStrings.phonicsWordPreserve,
      ipaKey: AppStrings.phonicsIpaPreserve,
    ),
    PhonicsWord(
      wordKey: AppStrings.phonicsWordIdentity,
      ipaKey: AppStrings.phonicsIpaIdentity,
    ),
    PhonicsWord(
      wordKey: AppStrings.phonicsWordHeritage,
      ipaKey: AppStrings.phonicsIpaHeritage,
    ),
    PhonicsWord(
      wordKey: AppStrings.phonicsWordPride,
      ipaKey: AppStrings.phonicsIpaPride,
    ),
    PhonicsWord(
      wordKey: AppStrings.phonicsWordCivilizations,
      ipaKey: AppStrings.phonicsIpaCivilizations,
    ),
    PhonicsWord(
      wordKey: AppStrings.phonicsWordAchievements,
      ipaKey: AppStrings.phonicsIpaAchievements,
    ),
    PhonicsWord(
      wordKey: AppStrings.phonicsWordMonuments,
      ipaKey: AppStrings.phonicsIpaMonuments,
    ),
    PhonicsWord(
      wordKey: AppStrings.phonicsWordCulture,
      ipaKey: AppStrings.phonicsIpaCulture,
    ),
    PhonicsWord(
      wordKey: AppStrings.phonicsWordAncient,
      ipaKey: AppStrings.phonicsIpaAncient,
    ),
    PhonicsWord(
      wordKey: AppStrings.phonicsWordAncestors,
      ipaKey: AppStrings.phonicsIpaAncestors,
    ),
    PhonicsWord(
      wordKey: AppStrings.phonicsWordKnowledge,
      ipaKey: AppStrings.phonicsIpaKnowledge,
    ),
  ];
}
