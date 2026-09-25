import 'package:micro_teaching_studio/features/home/models/home_module.dart';
import 'package:micro_teaching_studio/features/phonics/models/phonics_word.dart';

class CourseProgressIds {
  static const String fluencyPassage = '1-1-passage';
  static const String greetingsNoise = '2-1-q1';
  static const String greetingsTpr = '2-1-q2';
  static const String greetingsExpressions = '2-1-q3';
  static const String sessionQuiz = '2-1-quiz';
  static const String classroomNoise = '2-2-q1';
  static const String classroomResponse = '2-2-q2';
  static const String classroomExpressions = '2-2-q3';
  static const String classroomQuiz = '2-2-quiz';
  static const String vocabCivilization = '3-1-w1';
  static const String vocabMagnificent = '3-1-w2';
  static const String vocabMonuments = '3-1-w3';
  static const String vocabHeritage = '3-1-w4';
  static const String vocabStages = '3-1-q1';
  static const String vocabMonumentMeaning = '3-1-q2';
  static const String vocabStudentQuestion = '3-1-q3';
  static const String vocabTeacherReply = '3-1-q4';
  static const String vocabMagnificentMeaning = '3-1-q5';
  static const String vocabMask = '3-1-q6';
  static const String vocabQuiz = '3-1-quiz';
  static const String grammarWarmup = '3-2-q1';
  static const String grammarJump = '3-2-q2';
  static const String grammarMistake = '3-2-q3';
  static const String grammarPicture = '3-2-q4';
  static const String grammarEating = '3-2-q5';
  static const String grammarQuiz = '3-2-quiz';
  static const String presentStart = '3-3-q1';
  static const String presentTechnique = '3-3-q2';
  static const String presentPraise = '3-3-q3';
  static const String presentMoaz = '3-3-q4';
  static const String presentCorrection = '3-3-q5';
  static const String presentPictures = '3-3-q6';
  static const String presentQuiz = '3-3-quiz';

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
    if (moduleNumber == 2 && sessionNumber == 1) {
      return const [
        greetingsNoise,
        greetingsTpr,
        greetingsExpressions,
        sessionQuiz,
      ];
    }
    if (moduleNumber == 2 && sessionNumber == 2) {
      return const [
        classroomNoise,
        classroomResponse,
        classroomExpressions,
        classroomQuiz,
      ];
    }
    if (moduleNumber == 3 && sessionNumber == 1) {
      return const [
        vocabCivilization,
        vocabMagnificent,
        vocabMonuments,
        vocabHeritage,
        vocabStages,
        vocabMonumentMeaning,
        vocabStudentQuestion,
        vocabTeacherReply,
        vocabMagnificentMeaning,
        vocabMask,
        vocabQuiz,
      ];
    }
    if (moduleNumber == 3 && sessionNumber == 2) {
      return const [
        grammarWarmup,
        grammarJump,
        grammarMistake,
        grammarPicture,
        grammarEating,
        grammarQuiz,
      ];
    }
    if (moduleNumber == 3 && sessionNumber == 3) {
      return const [
        presentStart,
        presentTechnique,
        presentPraise,
        presentMoaz,
        presentCorrection,
        presentPictures,
        presentQuiz,
      ];
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
