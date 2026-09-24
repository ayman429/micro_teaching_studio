import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:micro_teaching_studio/features/analytics/analytics_constants.dart';
import 'package:micro_teaching_studio/features/analytics/data/analytics_repository.dart';
import 'package:micro_teaching_studio/features/analytics/models/assessment_part_context.dart';
import 'package:micro_teaching_studio/features/analytics/models/lesson_analytics.dart';
import 'package:micro_teaching_studio/features/classroom/cubit/classroom_quiz_cubit.dart';
import 'package:micro_teaching_studio/features/classroom/cubit/classroom_quiz_state.dart';
import 'package:micro_teaching_studio/features/course_audio/cubit/course_audio_cubit.dart';
import 'package:micro_teaching_studio/features/home/cubit/course_progress_cubit.dart';
import 'package:micro_teaching_studio/features/home/models/course_progress.dart';
import 'package:micro_teaching_studio/features/presentation/presentation_script.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/pronunciation_constants.dart';

class PresentationQuizCubit extends Cubit<ClassroomQuizState> {
  PresentationQuizCubit(
    this._analytics,
    this._progress,
    this._audio,
  ) : super(const ClassroomQuizState(selections: [null]));

  final AnalyticsRepository _analytics;
  final CourseProgressCubit _progress;
  final CourseAudioCubit _audio;

  var _started = false;
  var _introPlayed = false;
  var _visible = false;
  DateTime _openedAt = DateTime.now();
  final _ready = Completer<void>();

  AssessmentPartContext get _part => AssessmentPartContext.fromPartId(
        CourseProgressIds.presentQuiz,
        referenceText: PresentationScript.quizPromptText,
      );

  Future<void> start() async {
    if (_started) {
      await _ready.future;
      return;
    }
    _started = true;
    try {
      if (!_analytics.isHydrated) await _analytics.hydrate();
      final doc = _analytics.peekPartDoc(CourseProgressIds.presentQuiz);
      if (doc == null) await _analytics.reachPart(_part);
      if (isClosed) return;
      final stored = _analytics.peekStoredState(CourseProgressIds.presentQuiz);
      final fresh = _analytics.peekPartDoc(CourseProgressIds.presentQuiz);
      final outcome = (fresh?['contentOutcome'] as String?)?.trim() ?? '';
      final settled = stored.locked ||
          outcome == AnalyticsConstants.contentCorrect ||
          outcome == AnalyticsConstants.contentIncorrect;
      emit(
        state.copyWith(
          ready: true,
          selections: PresentationScript.selectionsFrom(fresh?['statements']),
          attemptCount: stored.attemptCount < 0 ? 0 : stored.attemptCount,
          tone: QuizScriptTone.forOutcome(
            outcome: outcome,
            attemptCount: stored.attemptCount,
          ),
          settled: settled,
        ),
      );
    } catch (error, stack) {
      log('presentation quiz start: $error', stackTrace: stack);
      if (!isClosed) {
        emit(
          state.copyWith(
            ready: true,
            selections: const [null],
          ),
        );
      }
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
    final grade = PresentationScript.gradeQuiz(
      matched: PresentationScript.matchesQuiz(selections),
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
    try {
      await _analytics.recordLessonAttempt(
        part: _part,
        attemptNumber: nextAttempt,
        lesson: LessonAnalytics(
          contentOutcome: grade.outcome,
          contentMatched: grade.outcome == AnalyticsConstants.contentCorrect,
          lessonFeedback: grade.feedbackText,
          statements: PresentationScript.records(selections, graded: true),
        ),
        startedAt: _openedAt,
        endedAt: DateTime.now(),
        language: PronunciationConstants.defaultLanguage,
        region: PronunciationConstants.defaultRegion,
      );
      if (grade.settles) {
        await _progress.completePart(CourseProgressIds.presentQuiz);
      }
    } catch (error, stack) {
      log('presentation quiz submit: $error', stackTrace: stack);
    }
    _openedAt = DateTime.now();
    if (isClosed) return;
    emit(state.copyWith(submitting: false));
    final asset = PresentationScript.audioFor(grade.tone);
    if (_visible && asset.isNotEmpty) await _audio.play(asset);
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
    await _audio.playSequence(PresentationScript.introAssets());
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
        statements: PresentationScript.records(selections, graded: false),
      );
    } catch (error, stack) {
      log('presentation quiz draft: $error', stackTrace: stack);
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
