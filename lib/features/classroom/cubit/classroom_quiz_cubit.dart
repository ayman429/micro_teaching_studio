import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:micro_teaching_studio/features/analytics/analytics_constants.dart';
import 'package:micro_teaching_studio/features/analytics/data/analytics_repository.dart';
import 'package:micro_teaching_studio/features/analytics/models/assessment_part_context.dart';
import 'package:micro_teaching_studio/features/analytics/models/lesson_analytics.dart';
import 'package:micro_teaching_studio/features/classroom/classroom_script.dart';
import 'package:micro_teaching_studio/features/classroom/cubit/classroom_quiz_state.dart';
import 'package:micro_teaching_studio/features/course_audio/cubit/course_audio_cubit.dart';
import 'package:micro_teaching_studio/features/home/cubit/course_progress_cubit.dart';
import 'package:micro_teaching_studio/features/home/models/course_progress.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/pronunciation_constants.dart';
import 'package:micro_teaching_studio/features/quiz/quiz_script.dart';

class ClassroomQuizCubit extends Cubit<ClassroomQuizState> {
  ClassroomQuizCubit(
    this._analytics,
    this._progress,
    this._audio,
  ) : super(const ClassroomQuizState());

  final AnalyticsRepository _analytics;
  final CourseProgressCubit _progress;
  final CourseAudioCubit _audio;

  var _started = false;
  var _introPlayed = false;
  var _visible = false;
  DateTime _openedAt = DateTime.now();
  final _ready = Completer<void>();

  AssessmentPartContext get _part => AssessmentPartContext.fromPartId(
        CourseProgressIds.classroomQuiz,
        referenceText: ClassroomScript.quizPromptText,
      );

  Future<void> start() async {
    if (_started) {
      await _ready.future;
      return;
    }
    _started = true;
    try {
      if (!_analytics.isHydrated) await _analytics.hydrate();
      final doc = _analytics.peekPartDoc(CourseProgressIds.classroomQuiz);
      if (doc == null) {
        await _analytics.reachPart(_part);
      }
      if (isClosed) return;
      final stored =
          _analytics.peekStoredState(CourseProgressIds.classroomQuiz);
      final fresh = _analytics.peekPartDoc(CourseProgressIds.classroomQuiz);
      final outcome = (fresh?['contentOutcome'] as String?)?.trim() ?? '';
      final settled = stored.locked ||
          outcome == AnalyticsConstants.contentCorrect ||
          outcome == AnalyticsConstants.contentIncorrect;
      emit(
        state.copyWith(
          ready: true,
          selections: ClassroomScript.selectionsFrom(fresh?['statements']),
          attemptCount: stored.attemptCount < 0 ? 0 : stored.attemptCount,
          tone: QuizScriptTone.forOutcome(
            outcome: outcome,
            attemptCount: stored.attemptCount,
          ),
          settled: settled,
        ),
      );
    } catch (error, stack) {
      log('classroom quiz start: $error', stackTrace: stack);
      if (!isClosed) emit(state.copyWith(ready: true));
    } finally {
      if (!_ready.isCompleted) _ready.complete();
    }
  }

  void select(int question, int choice) {
    if (!state.ready || state.settled || state.submitting) return;
    if (question < 0 || question >= state.selections.length) return;
    final next = [...state.selections];
    next[question] = choice;
    emit(state.copyWith(selections: next));
    unawaited(_saveDraft(next));
  }

  Future<void> submit() async {
    if (!state.canSubmit) return;
    final selections = [...state.selections];
    final nextAttempt = state.attemptCount + 1;
    final grade = ClassroomScript.gradeQuiz(
      matched: ClassroomScript.matchesQuiz(selections),
      nextAttempt: nextAttempt,
    );
    emit(
      state.copyWith(
        submitting: true,
        attemptCount: nextAttempt,
        tone: grade.tone,
        settled: grade.settles,
      ),
    );
    final ended = DateTime.now();
    try {
      await _analytics.recordLessonAttempt(
        part: _part,
        attemptNumber: nextAttempt,
        lesson: LessonAnalytics(
          contentOutcome: grade.outcome,
          contentMatched: grade.outcome == AnalyticsConstants.contentCorrect,
          lessonFeedback: grade.feedbackText,
          statements: ClassroomScript.records(selections, graded: true),
        ),
        startedAt: _openedAt,
        endedAt: ended,
        language: PronunciationConstants.defaultLanguage,
        region: PronunciationConstants.defaultRegion,
      );
      if (grade.settles) {
        await _progress.completePart(CourseProgressIds.classroomQuiz);
      }
    } catch (error, stack) {
      log('classroom quiz submit: $error', stackTrace: stack);
    }
    _openedAt = DateTime.now();
    if (isClosed) return;
    emit(state.copyWith(submitting: false));
    final asset = ClassroomScript.audioFor(grade.tone);
    if (_visible && asset.isNotEmpty) {
      await _audio.play(asset);
    }
  }

  Future<void> onTabShown() async {
    _visible = true;
    _openedAt = DateTime.now();
    await start();
    if (isClosed || !_visible || _introPlayed) return;
    if (state.attemptCount > 0 || state.settled) {
      _introPlayed = true;
      return;
    }
    _introPlayed = true;
    await _audio.playSequence(ClassroomScript.introAssets());
  }

  Future<void> onTabHidden() async {
    _visible = false;
    await _audio.stop();
    await _saveDraft(state.selections);
  }

  Future<void> _saveDraft(List<int?> selections) async {
    if (state.settled) return;
    try {
      await _analytics.saveQuizDraft(
        part: _part,
        statements: ClassroomScript.records(selections, graded: false),
      );
    } catch (error, stack) {
      log('classroom quiz draft: $error', stackTrace: stack);
    }
  }

  @override
  Future<void> close() async {
    final stopAudio = _visible;
    _visible = false;
    if (stopAudio) await _audio.stop();
    return super.close();
  }
}

class QuizScriptTone {
  static QuizTone forOutcome({
    required String outcome,
    required int attemptCount,
  }) {
    if (outcome == AnalyticsConstants.contentCorrect) return QuizTone.correct;
    if (outcome == AnalyticsConstants.contentIncorrect) return QuizTone.review;
    if (outcome == AnalyticsConstants.contentRetry) {
      return attemptCount <= 1 ? QuizTone.wrong : QuizTone.review;
    }
    return QuizTone.none;
  }
}
