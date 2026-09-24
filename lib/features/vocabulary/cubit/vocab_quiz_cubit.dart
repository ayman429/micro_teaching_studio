import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:micro_teaching_studio/common/resources/assets_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/features/analytics/analytics_constants.dart';
import 'package:micro_teaching_studio/features/analytics/data/analytics_repository.dart';
import 'package:micro_teaching_studio/features/analytics/models/assessment_part_context.dart';
import 'package:micro_teaching_studio/features/analytics/models/lesson_analytics.dart';
import 'package:micro_teaching_studio/features/course_audio/cubit/course_audio_cubit.dart';
import 'package:micro_teaching_studio/features/home/cubit/course_progress_cubit.dart';
import 'package:micro_teaching_studio/features/home/models/course_progress.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/data/pronunciation_engine.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/data/speech_config_repository.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/models/pronunciation_result.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/pronunciation_constants.dart';
import 'package:micro_teaching_studio/features/quiz/quiz_script.dart';
import 'package:micro_teaching_studio/features/vocabulary/cubit/vocab_quiz_state.dart';
import 'package:micro_teaching_studio/features/vocabulary/vocab_script.dart';

class VocabQuizCubit extends Cubit<VocabQuizState> {
  VocabQuizCubit(
    this._configRepository,
    this._engine,
    this._analytics,
    this._progress,
    this._audio,
  ) : super(const VocabQuizState());

  final SpeechConfigRepository _configRepository;
  final PronunciationEngine _engine;
  final AnalyticsRepository _analytics;
  final CourseProgressCubit _progress;
  final CourseAudioCubit _audio;

  var _started = false;
  var _introPlayed = false;
  var _visible = false;
  var _busy = false;
  DateTime _openedAt = DateTime.now();
  PronunciationResult? _spokenResult;
  final _ready = Completer<void>();

  AssessmentPartContext get _part => AssessmentPartContext.fromPartId(
        CourseProgressIds.vocabQuiz,
        referenceText: VocabScript.quizReference,
      );

  Future<void> start() async {
    if (_started) {
      await _ready.future;
      return;
    }
    _started = true;
    try {
      if (!_analytics.isHydrated) await _analytics.hydrate();
      final doc = _analytics.peekPartDoc(CourseProgressIds.vocabQuiz);
      if (doc == null) await _analytics.reachPart(_part);
      if (isClosed) return;
      final stored = _analytics.peekStoredState(CourseProgressIds.vocabQuiz);
      final fresh = _analytics.peekPartDoc(CourseProgressIds.vocabQuiz);
      final outcome = (fresh?['contentOutcome'] as String?)?.trim() ?? '';
      final saved = _readStatements(fresh?['statements']);
      emit(
        state.copyWith(
          ready: true,
          magnificent: saved.$1,
          monument: saved.$2,
          heard: saved.$3,
          pronouncedWell: saved.$4,
          attemptCount: stored.attemptCount < 0 ? 0 : stored.attemptCount,
          tone: _tone(outcome, stored.attemptCount),
          settled: stored.locked ||
              outcome == AnalyticsConstants.contentCorrect ||
              outcome == AnalyticsConstants.contentIncorrect,
        ),
      );
    } catch (error, stack) {
      log('vocab quiz start: $error', stackTrace: stack);
      if (!isClosed) emit(state.copyWith(ready: true));
    } finally {
      if (!_ready.isCompleted) _ready.complete();
    }
  }

  void setMagnificent(String value) {
    if (!state.ready || state.settled || state.submitting) return;
    emit(state.copyWith(magnificent: value));
    unawaited(_saveDraft());
  }

  void setMonument(String value) {
    if (!state.ready || state.settled || state.submitting) return;
    emit(state.copyWith(monument: value));
    unawaited(_saveDraft());
  }

  Future<void> toggleMic() async {
    if (_busy || state.settled || state.submitting || !state.ready) return;
    if (state.recording) {
      await _stopAndAssess();
      return;
    }
    _busy = true;
    try {
      await _audio.stop();
      await _engine.startRecording();
      if (isClosed) return;
      emit(state.copyWith(recording: true, assessing: false));
    } catch (error, stack) {
      log('vocab quiz mic: $error', stackTrace: stack);
    } finally {
      _busy = false;
    }
  }

  Future<void> _stopAndAssess() async {
    _busy = true;
    emit(state.copyWith(recording: false, assessing: true));
    try {
      final file = await _engine.stopRecording();
      final config = await _configRepository.load();
      final result = await _engine.assess(
        audioFile: file,
        referenceText: VocabScript.quizReference,
        config: config,
        enableProsody: false,
      );
      final heard = result.heardText?.trim() ?? '';
      if (heard.isEmpty || !_spoken(result)) {
        _notice(AppStrings.pronunciationNoResult);
        return;
      }
      if (isClosed) return;
      _spokenResult = result;
      emit(
        state.copyWith(
          assessing: false,
          heard: heard,
          pronouncedWell: result.band == PronunciationBand.excellent,
        ),
      );
      unawaited(_saveDraft());
    } catch (error, stack) {
      log('vocab quiz assess: $error', stackTrace: stack);
      if (_isSilence(error)) {
        _notice((error as StateError).message);
        return;
      }
      if (!isClosed) emit(state.copyWith(assessing: false, recording: false));
    } finally {
      _busy = false;
    }
  }

  void _notice(String message) {
    if (isClosed) return;
    emit(
      state.copyWith(
        assessing: false,
        recording: false,
        notice: state.notice + 1,
        noticeMessage: message,
      ),
    );
  }

  bool _isSilence(Object error) {
    if (error is! StateError) return false;
    return error.message == AppStrings.pronunciationTooShort ||
        error.message == AppStrings.pronunciationNoAudio ||
        error.message == AppStrings.pronunciationNoResult;
  }

  bool _spoken(PronunciationResult result) {
    final status = (result.recognitionStatus ?? '').trim().toLowerCase();
    if (status.isEmpty) return true;
    return status == 'success';
  }

  Future<void> submit() async {
    if (!state.canSubmit) return;
    final magnificentOk = matchesMagnificentBlank(state.magnificent);
    final monumentOk = matchesMonumentBlank(state.monument);
    final matched = magnificentOk && monumentOk && state.pronouncedWell;
    final nextAttempt = state.attemptCount + 1;
    final last = nextAttempt >= PronunciationConstants.maxAttempts;
    final tone = matched
        ? QuizTone.correct
        : (nextAttempt <= 1 ? QuizTone.wrong : QuizTone.review);
    final feedback = matched
        ? VocabScript.quizCorrectText
        : (nextAttempt <= 1
            ? VocabScript.quizWrongText
            : VocabScript.quizReviewText);
    emit(
      state.copyWith(
        submitting: true,
        attemptCount: nextAttempt,
        tone: tone,
        settled: matched || last,
      ),
    );
    try {
      await _analytics.recordLessonAttempt(
        part: _part,
        result: _spokenResult,
        attemptNumber: nextAttempt,
        lesson: LessonAnalytics(
          contentOutcome: matched
              ? AnalyticsConstants.contentCorrect
              : (last
                  ? AnalyticsConstants.contentIncorrect
                  : AnalyticsConstants.contentRetry),
          contentMatched: matched,
          lessonFeedback: feedback,
          statements: _statements(graded: true),
        ),
        startedAt: _openedAt,
        endedAt: DateTime.now(),
        language: PronunciationConstants.defaultLanguage,
        region: PronunciationConstants.defaultRegion,
      );
      if (matched || last) {
        await _progress.completePart(CourseProgressIds.vocabQuiz);
      }
    } catch (error, stack) {
      log('vocab quiz submit: $error', stackTrace: stack);
    }
    _openedAt = DateTime.now();
    if (isClosed) return;
    emit(state.copyWith(submitting: false));
    if (!_visible) return;
    final asset = matched
        ? AudioAssets.vocabQuizCorrect()
        : (nextAttempt <= 1
            ? AudioAssets.vocabQuizTryAgain()
            : AudioAssets.vocabQuizReview());
    await _audio.play(asset);
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
    await _audio.playSequence([
      AudioAssets.vocabQuizClip(1),
      AudioAssets.vocabQuizClip(2),
      AudioAssets.vocabQuizClip(3),
    ]);
  }

  Future<void> onTabHidden() async {
    _visible = false;
    if (state.recording) {
      try {
        await _engine.stopRecording();
      } catch (error, stack) {
        log('vocab quiz hide: $error', stackTrace: stack);
      }
      if (!isClosed) {
        emit(state.copyWith(recording: false, assessing: false));
      }
    }
    await _audio.stop();
    await _saveDraft();
  }

  List<Map<String, dynamic>> _statements({required bool graded}) {
    final magnificentOk = matchesMagnificentBlank(state.magnificent);
    final monumentOk = matchesMonumentBlank(state.monument);
    return [
      {
        'index': 1,
        'text': 'A word that means beautiful and grand is',
        'answered': state.magnificent.trim().isNotEmpty,
        'selectedText': state.magnificent.trim(),
        'expectedText': 'magnificent',
        'matched': graded && magnificentOk,
      },
      {
        'index': 2,
        'text':
            'Something that is built specifically to remember history and important people is',
        'answered': state.monument.trim().isNotEmpty,
        'selectedText': state.monument.trim(),
        'expectedText': 'monument',
        'matched': graded && monumentOk,
      },
      {
        'index': 3,
        'text': VocabScript.quizReference,
        'answered': state.heard.trim().isNotEmpty,
        'selectedText': state.heard.trim(),
        'expectedText': VocabScript.quizReference,
        'pronouncedWell': state.pronouncedWell,
        'matched': graded && state.pronouncedWell,
      },
    ];
  }

  (String, String, String, bool) _readStatements(Object? raw) {
    var magnificent = '';
    var monument = '';
    var heard = '';
    var pronounced = false;
    if (raw is! List) return (magnificent, monument, heard, pronounced);
    for (final item in raw) {
      if (item is! Map) continue;
      final index = (item['index'] as num?)?.toInt() ?? 0;
      final text = (item['selectedText'] as String?)?.trim() ?? '';
      if (index == 1) magnificent = text;
      if (index == 2) monument = text;
      if (index == 3) {
        heard = text;
        pronounced = item['pronouncedWell'] == true || item['matched'] == true;
      }
    }
    return (magnificent, monument, heard, pronounced);
  }

  QuizTone _tone(String outcome, int attempts) {
    if (outcome == AnalyticsConstants.contentCorrect) return QuizTone.correct;
    if (outcome == AnalyticsConstants.contentIncorrect) return QuizTone.review;
    if (outcome == AnalyticsConstants.contentRetry) {
      return attempts <= 1 ? QuizTone.wrong : QuizTone.review;
    }
    return QuizTone.none;
  }

  Future<void> _saveDraft() async {
    if (state.settled) return;
    try {
      await _analytics.saveQuizDraft(
        part: _part,
        statements: _statements(graded: false),
      );
    } catch (error, stack) {
      log('vocab quiz draft: $error', stackTrace: stack);
    }
  }

  @override
  Future<void> close() async {
    final stopAudio = _visible;
    _visible = false;
    if (state.recording) {
      try {
        await _engine.stopRecording();
      } catch (_) {}
    }
    await _engine.dispose();
    if (stopAudio) await _audio.stop();
    return super.close();
  }
}
