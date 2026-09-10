import 'package:micro_teaching_studio/features/home/models/home_module.dart';
import 'package:micro_teaching_studio/features/phonics/models/phonics_word.dart';

class CourseProgressIds {
  static const String fluencyPassage = '1-1-passage';

  static String phonicsWord(String wordKey) => '1-2-$wordKey';

  static List<String> all() {
    return HomeModule.catalog.expand(partsForModule).toList();
  }

  static List<String> partsForModule(HomeModule module) {
    return module.sessions.expand((session) {
      return partsForSession(module.number, session.number);
    }).toList();
  }

  static List<String> partsForSession(int moduleNumber, int sessionNumber) {
    if (moduleNumber == 1 && sessionNumber == 1) {
      return const [fluencyPassage];
    }
    if (moduleNumber == 1 && sessionNumber == 2) {
      return PhonicsWord.catalog
          .map((word) => phonicsWord(word.wordKey))
          .toList();
    }
    return ['$moduleNumber-$sessionNumber-session'];
  }
}

class CourseProgressSnapshot {
  const CourseProgressSnapshot({required this.completedIds});

  final Set<String> completedIds;

  double get overallProgress => _ratio(CourseProgressIds.all());

  double moduleProgress(int moduleNumber) {
    final modules =
        HomeModule.catalog.where((module) => module.number == moduleNumber);
    if (modules.isEmpty) return 0;
    return _ratio(CourseProgressIds.partsForModule(modules.first));
  }

  double _ratio(List<String> ids) {
    if (ids.isEmpty) return 0;
    final done = ids.where(completedIds.contains).length;
    return done / ids.length;
  }
}
