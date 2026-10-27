import 'package:micro_teaching_studio/features/classroom/classroom_script.dart';
import 'package:micro_teaching_studio/features/grammar/grammar_script.dart';
import 'package:micro_teaching_studio/features/home/cubit/course_progress_cubit.dart';
import 'package:micro_teaching_studio/features/home/models/course_progress.dart';
import 'package:micro_teaching_studio/features/phonics/models/phonics_word.dart';
import 'package:micro_teaching_studio/features/presentation/presentation_script.dart';
import 'package:micro_teaching_studio/features/quiz/quiz_script.dart';

class CourseSessionRef {
  const CourseSessionRef({required this.module, required this.session});

  final int module;
  final int session;

  String get key => CourseSessions.key(module, session);
}

class CourseSessions {
  static const List<CourseSessionRef> order = [
    CourseSessionRef(module: 1, session: 1),
    CourseSessionRef(module: 1, session: 2),
    CourseSessionRef(module: 2, session: 1),
    CourseSessionRef(module: 2, session: 2),
    CourseSessionRef(module: 3, session: 1),
    CourseSessionRef(module: 3, session: 2),
    CourseSessionRef(module: 3, session: 3),
  ];

  static String key(int module, int session) => '$module-$session';

  static bool allFinished(Set<String> finished) {
    for (final session in order) {
      if (!finished.contains(session.key)) return false;
    }
    return true;
  }

  /// First session in course order that has not reached its end screen.
  static CourseSessionRef? firstUnfinished(Set<String> finished) {
    for (final session in order) {
      if (!finished.contains(session.key)) return session;
    }
    return null;
  }

  static List<String> taskIds(int module, int session) {
    if (module == 1 && session == 1) {
      return const [CourseProgressIds.fluencyPassage];
    }
    if (module == 1 && session == 2) {
      return [
        for (final word in PhonicsWord.catalog)
          CourseProgressIds.phonicsWord(word.wordKey),
      ];
    }
    if (module == 2 && session == 1) {
      return [
        CourseProgressIds.greetingsNoise,
        CourseProgressIds.greetingsTpr,
        CourseProgressIds.greetingsExpressions,
        for (var index = 0; index < QuizScript.statements.length; index++)
          quizTask(CourseProgressIds.sessionQuiz, index),
      ];
    }
    if (module == 2 && session == 2) {
      return [
        CourseProgressIds.classroomNoise,
        CourseProgressIds.classroomResponse,
        CourseProgressIds.classroomExpressions,
        for (var index = 0; index < ClassroomScript.quizItems.length; index++)
          quizTask(CourseProgressIds.classroomQuiz, index),
      ];
    }
    if (module == 3 && session == 1) {
      return [
        CourseProgressIds.vocabCivilization,
        CourseProgressIds.vocabMagnificent,
        CourseProgressIds.vocabMonuments,
        CourseProgressIds.vocabHeritage,
        CourseProgressIds.vocabStages,
        CourseProgressIds.vocabMonumentMeaning,
        CourseProgressIds.vocabStudentQuestion,
        CourseProgressIds.vocabTeacherReply,
        CourseProgressIds.vocabMagnificentMeaning,
        CourseProgressIds.vocabMask,
        for (var index = 0; index < 3; index++)
          quizTask(CourseProgressIds.vocabQuiz, index),
      ];
    }
    if (module == 3 && session == 2) {
      return [
        CourseProgressIds.grammarWarmup,
        CourseProgressIds.grammarJump,
        CourseProgressIds.grammarMistake,
        CourseProgressIds.grammarPicture,
        CourseProgressIds.grammarEating,
        for (var index = 0; index < GrammarScript.quizItems.length; index++)
          quizTask(CourseProgressIds.grammarQuiz, index),
      ];
    }
    if (module == 3 && session == 3) {
      return [
        CourseProgressIds.presentStart,
        CourseProgressIds.presentTechnique,
        CourseProgressIds.presentPraise,
        CourseProgressIds.presentMoaz,
        CourseProgressIds.presentCorrection,
        CourseProgressIds.presentPictures,
        for (var index = 0;
            index < PresentationScript.quizItems.length;
            index++)
          quizTask(CourseProgressIds.presentQuiz, index),
      ];
    }
    return const [];
  }

  static String quizTask(String partId, int index) => '$partId#$index';

  static int earned(Set<String> pointIds, int module, int session) {
    var count = 0;
    for (final id in taskIds(module, session)) {
      if (pointIds.contains(id)) count++;
    }
    return count;
  }

  static bool hasMissedTask(Set<String> pointIds, int module, int session) {
    for (final id in taskIds(module, session)) {
      if (!pointIds.contains(id)) return true;
    }
    return false;
  }

  /// Spoken chat tasks only. Unopened quiz questions are not a miss yet.
  static bool hasMissedSpokenTask(
    Set<String> pointIds,
    int module,
    int session,
  ) {
    for (final id in taskIds(module, session)) {
      if (id.contains('#')) continue;
      if (!pointIds.contains(id)) return true;
    }
    return false;
  }

  static List<String> partIds(int module, int session) {
    final parts = <String>[];
    for (final id in taskIds(module, session)) {
      final part = id.split('#').first;
      if (part.isEmpty || parts.contains(part)) continue;
      parts.add(part);
    }
    return parts;
  }

  /// Part documents to unlock so a missed task can be attempted again.
  static List<String> missedPartIds(
    Set<String> pointIds,
    int module,
    int session,
  ) {
    final parts = <String>{};
    for (final id in taskIds(module, session)) {
      if (pointIds.contains(id)) continue;
      final part = id.split('#').first;
      if (part.isNotEmpty) parts.add(part);
    }
    return parts.toList();
  }

  static Future<void> awardMatches(
    CourseProgressCubit progress,
    String partId,
    List<Map<String, dynamic>> records,
  ) async {
    for (final record in records) {
      if (record['matched'] != true) continue;
      final index = (record['index'] as num?)?.toInt() ?? 0;
      if (index <= 0) continue;
      await progress.awardPoint(quizTask(partId, index - 1));
    }
  }
}

/// Asks the next lesson start to play from the beginning instead of resuming.
class LessonReplay {
  static String? _pending;

  static void request(int module, int session) {
    _pending = CourseSessions.key(module, session);
  }

  static bool consume(String sessionKey) {
    if (_pending != sessionKey) return false;
    _pending = null;
    return true;
  }
}
