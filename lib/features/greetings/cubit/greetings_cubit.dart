import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/features/analytics/analytics_constants.dart';
import 'package:micro_teaching_studio/features/analytics/data/analytics_repository.dart';
import 'package:micro_teaching_studio/features/analytics/models/assessment_part_context.dart';
import 'package:micro_teaching_studio/features/analytics/models/lesson_analytics.dart';
import 'package:micro_teaching_studio/features/course_audio/cubit/course_audio_cubit.dart';
import 'package:micro_teaching_studio/features/course_audio/cubit/course_audio_state.dart';
import 'package:micro_teaching_studio/features/greetings/cubit/greetings_state.dart';
import 'package:micro_teaching_studio/features/greetings/greetings_resume.dart';
import 'package:micro_teaching_studio/features/greetings/greetings_script.dart';
import 'package:micro_teaching_studio/features/home/cubit/course_progress_cubit.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/data/pronunciation_engine.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/data/speech_config_repository.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/models/pronunciation_result.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/pronunciation_constants.dart';

enum _AudioCue { none, intro, question, feedback, reflection }

enum _Pending { none, retry, advance, reflect, finish }

class GreetingsCubit extends Cubit<GreetingsState> {
  GreetingsCubit(
    this._configRepository,
    this._engine,
    this._analytics,
    this._progress,
    this._audio, {
    SpokenLessonPlan? plan,
  })  : _plan = plan ?? GreetingsScript.plan,
        super(const GreetingsState());

  final SpeechConfigRepository _configRepository;
  final PronunciationEngine _engine;
  final AnalyticsRepository _analytics;
  final CourseProgressCubit _progress;
  final CourseAudioCubit _audio;
  final SpokenLessonPlan _plan;

  SpokenLessonPlan get plan => _plan;

  StreamSubscription<CourseAudioState>? _audioSub;
  var _started = false;
  var _busy = false;
  var _videoFinished = false;
  var _questionsStarted = false;
  var _messageSeq = 0;
  var _heardPlayback = false;
  var _audioCue = _AudioCue.none;
  var _pausedCue = _AudioCue.none;
  var _pending = _Pending.none;
  String? _currentAsset;
  String? _pausedAsset;

  Future<void> start() async {
    if (_started) return;
    _started = true;
    _audioSub = _audio.stream.listen(_onAudio);
    try {
      if (await _restore()) return;
    } catch (error, stack) {
      log('greetings restore: $error', stackTrace: stack);
    }
    if (isClosed) return;
    emit(
      state.copyWith(
        phase: GreetingsPhase.intro,
        videoVisible: true,
        messages: [
          _twin(_plan.introKey),
        ],
      ),
    );
    await _playCue(_plan.introAsset, _AudioCue.intro);
  }

  Future<void> onVideoStarted() async {
    if (_audioCue == _AudioCue.intro) {
      _audioCue = _AudioCue.none;
      _heardPlayback = false;
      await _audio.stop();
      if (!isClosed && state.phase == GreetingsPhase.intro) {
        emit(state.copyWith(phase: GreetingsPhase.watching));
      }
      return;
    }
    if (_audioCue == _AudioCue.question) {
      _audioCue = _AudioCue.none;
      _heardPlayback = false;
      await _audio.stop();
      if (!isClosed) {
        emit(
          state.copyWith(
            phase: GreetingsPhase.question,
            practiceEnabled: true,
          ),
        );
      }
      return;
    }
    if (_audioCue == _AudioCue.feedback || _audioCue == _AudioCue.reflection) {
      final cue = _audioCue;
      _audioCue = _AudioCue.none;
      _heardPlayback = false;
      await _audio.stop();
      _finishCue(cue);
      return;
    }
    await _audio.stop();
  }

  Future<void> onVideoCompleted() async {
    if (_videoFinished) return;
    _videoFinished = true;
    if (state.phase != GreetingsPhase.intro &&
        state.phase != GreetingsPhase.watching) {
      return;
    }
    await _beginQuestions();
  }

  Future<void> toggleMic() async {
    if (_busy || isClosed) return;
    if (state.phase == GreetingsPhase.recording) {
      await _stopAndAssess();
      return;
    }
    if (!state.practiceEnabled || state.phase != GreetingsPhase.question) {
      return;
    }
    _busy = true;
    try {
      _audioCue = _AudioCue.none;
      _heardPlayback = false;
      await _audio.stop();
      await _engine.startRecording();
      if (isClosed) return;
      emit(
        state.copyWith(
          phase: GreetingsPhase.recording,
          practiceEnabled: true,
          clearError: true,
        ),
      );
    } catch (error, stack) {
      log('greetings record: $error', stackTrace: stack);
      _emitError(error);
    } finally {
      _busy = false;
    }
  }

  Future<void> pauseForOverlay() async {
    if (state.phase == GreetingsPhase.recording) {
      try {
        await _engine.stopRecording();
      } catch (error, stack) {
        log('greetings pause recording: $error', stackTrace: stack);
      }
      if (!isClosed) {
        emit(
          state.copyWith(
            phase: GreetingsPhase.question,
            practiceEnabled: true,
          ),
        );
      }
    }
    if (_audioCue == _AudioCue.none) {
      await _audio.stop();
      return;
    }
    _pausedCue = _audioCue;
    _pausedAsset = _currentAsset;
    _audioCue = _AudioCue.none;
    _heardPlayback = false;
    await _audio.stop();
  }

  Future<void> resumeFromOverlay() async {
    final cue = _pausedCue;
    final asset = _pausedAsset;
    _pausedCue = _AudioCue.none;
    _pausedAsset = null;
    if (cue == _AudioCue.none || asset == null || asset.isEmpty) return;
    if (isClosed || state.phase == GreetingsPhase.exit) return;
    await _playCue(asset, cue);
  }

  Future<void> _beginQuestions() async {
    if (_questionsStarted || isClosed) return;
    _questionsStarted = true;
    _audioCue = _AudioCue.none;
    _heardPlayback = false;
    await _audio.stop();
    await _reach(_plan.questions.first);
    await _ask(0);
  }

  Future<void> _ask(int index) async {
    if (isClosed) return;
    if (index < 0 || index >= _plan.questions.length) return;
    final question = _plan.questions[index];
    await _reach(question);
    if (isClosed) return;
    emit(
      state.copyWith(
        phase: GreetingsPhase.question,
        questionIndex: index,
        attemptCount: 0,
        practiceEnabled: false,
        clearError: true,
        messages: [
          ...state.messages,
          _twin(question.promptKey, afterVideo: true),
        ],
      ),
    );
    await _playCue(question.voiceAsset, _AudioCue.question);
  }

  Future<void> _stopAndAssess() async {
    if (_busy || isClosed) return;
    _busy = true;
    emit(
      state.copyWith(
        phase: GreetingsPhase.assessing,
        practiceEnabled: true,
        clearError: true,
      ),
    );
    final startedAt = DateTime.now();
    final question = _plan.questions[state.questionIndex];
    try {
      final file = await _engine.stopRecording();
      final config = await _configRepository.load();
      final result = await _engine.assess(
        audioFile: file,
        referenceText: question.referenceText,
        config: config,
        enableProsody: false,
      );
      if (isClosed) return;
      if (!_hasSpeech(result)) {
        await _recordNoResponse(
          question: question,
          result: result,
          startedAt: startedAt,
          language: config.language,
          region: config.region,
        );
        _requestExit();
        return;
      }
      final heard = result.heardText!.trim();
      final matched = question.matches(heard);
      final attempts = state.attemptCount + 1;
      final exhausted =
          !matched && attempts >= PronunciationConstants.maxAttempts;
      final last = state.questionIndex >= _plan.questions.length - 1;
      _pending = matched
          ? (last ? _Pending.reflect : _Pending.advance)
          : (exhausted
              ? (last ? _Pending.finish : _Pending.advance)
              : _Pending.retry);
      final feedbackKey = matched
          ? question.successKey
          : (exhausted
              ? _plan.exhaustedKey
              : _plan.retryKey);
      final tone = matched
          ? GreetingsTone.correct
          : (exhausted ? GreetingsTone.exhausted : GreetingsTone.retry);
      emit(
        state.copyWith(
          phase: GreetingsPhase.feedback,
          attemptCount: attempts,
          practiceEnabled: false,
          messages: [
            ...state.messages,
            _student(heard),
            _twin(feedbackKey, tone: tone, afterVideo: true),
          ],
        ),
      );
      unawaited(
        _record(
          question: question,
          result: result,
          attemptNumber: attempts,
          matched: matched,
          exhausted: exhausted,
          startedAt: startedAt,
          language: config.language,
          region: config.region,
        ),
      );
      if (matched || exhausted) {
        unawaited(_progress.completePart(question.partId));
      }
      await _playCue(
        matched
            ? question.successAsset
            : (exhausted ? _plan.exhaustedAsset : _plan.retryAsset),
        _AudioCue.feedback,
      );
    } catch (error, stack) {
      log('greetings assess: $error', stackTrace: stack);
      if (_isSilence(error)) {
        await _recordNoResponse(
          question: question,
          startedAt: startedAt,
          language: PronunciationConstants.defaultLanguage,
          region: PronunciationConstants.defaultRegion,
        );
        _requestExit();
        return;
      }
      try {
        if (await _engineIsRecording()) {
          await _engine.stopRecording();
        }
      } catch (_) {}
      _emitError(error);
    } finally {
      _busy = false;
    }
  }

  Future<bool> _engineIsRecording() async {
    return state.phase == GreetingsPhase.recording ||
        state.phase == GreetingsPhase.assessing;
  }

  bool _hasSpeech(PronunciationResult result) {
    final heard = result.heardText?.trim() ?? '';
    if (heard.isEmpty) return false;
    final status = (result.recognitionStatus ?? '').trim().toLowerCase();
    if (status.isEmpty) return true;
    return status == 'success';
  }

  bool _isSilence(Object error) {
    if (error is! StateError) return false;
    return error.message == AppStrings.pronunciationTooShort ||
        error.message == AppStrings.pronunciationNoAudio ||
        error.message == AppStrings.pronunciationNoResult;
  }

  Future<void> _record({
    required GreetingsQuestion question,
    required PronunciationResult result,
    required int attemptNumber,
    required bool matched,
    required bool exhausted,
    required DateTime startedAt,
    required String language,
    required String region,
  }) async {
    final lesson = _lessonFor(
      question: question,
      matched: matched,
      exhausted: exhausted,
    );
    try {
      await _analytics.recordLessonAttempt(
        part: _partFor(question),
        result: result,
        attemptNumber: attemptNumber,
        lesson: lesson,
        startedAt: startedAt,
        endedAt: DateTime.now(),
        language: language,
        region: region,
      );
    } catch (error, stack) {
      log('greetings analytics: $error', stackTrace: stack);
    }
  }

  Future<void> _recordNoResponse({
    required GreetingsQuestion question,
    required DateTime startedAt,
    required String language,
    required String region,
    PronunciationResult? result,
  }) async {
    try {
      await _analytics.recordLessonAttempt(
        part: _partFor(question),
        result: result,
        attemptNumber: state.attemptCount,
        lesson: LessonAnalytics(
          contentOutcome: AnalyticsConstants.contentNoResponse,
          contentMatched: false,
          lessonFeedback: _plan.noResponseText,
        ),
        startedAt: startedAt,
        endedAt: DateTime.now(),
        language: language,
        region: region,
      );
    } catch (error, stack) {
      log('greetings no response: $error', stackTrace: stack);
    }
  }

  Future<void> _afterFeedback() async {
    switch (_pending) {
      case _Pending.advance:
        await _ask(state.questionIndex + 1);
      case _Pending.reflect:
        await _reflect();
      case _Pending.finish:
        if (isClosed) return;
        emit(
          state.copyWith(
            phase: GreetingsPhase.done,
            practiceEnabled: false,
          ),
        );
      case _Pending.retry:
        if (isClosed) return;
        emit(
          state.copyWith(
            phase: GreetingsPhase.question,
            practiceEnabled: true,
          ),
        );
      case _Pending.none:
        break;
    }
  }

  Future<void> _reflect() async {
    if (isClosed) return;
    for (final question in _plan.questions) {
      unawaited(_progress.completePart(question.partId));
    }
    emit(
      state.copyWith(
        phase: GreetingsPhase.reflection,
        practiceEnabled: false,
        messages: [
          ...state.messages,
          _twin(_plan.reflectionKey, afterVideo: true),
        ],
      ),
    );
    await _playCue(_plan.reflectionAsset, _AudioCue.reflection);
  }

  Future<void> _playCue(String asset, _AudioCue cue) async {
    if (isClosed) return;
    _pausedCue = _AudioCue.none;
    _pausedAsset = null;
    _currentAsset = asset;
    _audioCue = cue;
    _heardPlayback = false;
    await _audio.play(asset);
  }

  void _onAudio(CourseAudioState audio) {
    if (_audioCue == _AudioCue.none) return;
    if (audio.isPlaying) {
      _heardPlayback = true;
      return;
    }
    if (!_heardPlayback) return;
    final cue = _audioCue;
    _audioCue = _AudioCue.none;
    _heardPlayback = false;
    if (audio.errorMessage != null && !isClosed) {
      emit(state.copyWith(errorMessage: audio.errorMessage));
    }
    _finishCue(cue);
  }

  void _finishCue(_AudioCue cue) {
    switch (cue) {
      case _AudioCue.intro:
        if (_videoFinished) {
          unawaited(_beginQuestions());
        } else if (!isClosed) {
          emit(state.copyWith(phase: GreetingsPhase.watching));
        }
      case _AudioCue.question:
        if (!isClosed) {
          emit(
            state.copyWith(
              phase: GreetingsPhase.question,
              practiceEnabled: true,
              clearError: true,
            ),
          );
        }
      case _AudioCue.feedback:
        unawaited(_afterFeedback());
      case _AudioCue.reflection:
        _requestExit();
      case _AudioCue.none:
        break;
    }
  }

  void _requestExit() {
    if (isClosed || state.phase == GreetingsPhase.exit) return;
    _audioCue = _AudioCue.none;
    _pending = _Pending.none;
    emit(
      state.copyWith(
        phase: GreetingsPhase.exit,
        practiceEnabled: false,
      ),
    );
  }

  void _emitError(Object error) {
    if (isClosed) return;
    emit(
      state.copyWith(
        phase: GreetingsPhase.question,
        practiceEnabled: true,
        errorMessage: _messageOf(error),
      ),
    );
  }

  String _messageOf(Object error) {
    if (error is StateError) return error.message;
    if (error is FirebaseException) {
      final message = error.message?.toLowerCase() ?? '';
      if (error.code == 'unavailable' || message.contains('offline')) {
        return AppStrings.noInternetError;
      }
      return AppStrings.pronunciationConfigMissing;
    }
    if (error is TimeoutException || error is SocketException) {
      return AppStrings.noInternetError;
    }
    return AppStrings.pronunciationServiceError;
  }

  Future<bool> _restore() async {
    if (!_analytics.isHydrated) await _analytics.hydrate();
    if (isClosed) return true;
    final snapshots = [
      for (final question in _plan.questions)
        _snapshot(question.partId),
    ];
    final index = GreetingsResumePlan.resumeIndex(snapshots);
    if (index < 0) return false;
    _videoFinished = true;
    _questionsStarted = true;
    final messages = <GreetingsMessage>[
      _twin(_plan.introKey),
    ];
    if (index >= _plan.questions.length) {
      for (final question in _plan.questions) {
        messages.addAll(_savedTurns(question));
      }
      if (snapshots.last.answeredCorrectly) {
        messages.add(_twin(_plan.reflectionKey, afterVideo: true));
      }
      if (isClosed) return true;
      emit(
        state.copyWith(
          phase: GreetingsPhase.done,
          videoVisible: true,
          practiceEnabled: false,
          questionIndex: _plan.questions.length - 1,
          messages: messages,
        ),
      );
      return true;
    }
    for (var cursor = 0; cursor < index; cursor++) {
      messages.addAll(_savedTurns(_plan.questions[cursor]));
    }
    final question = _plan.questions[index];
    messages.addAll(_savedTurns(question));
    final attempts = snapshots[index].attemptCount;
    final playPrompt = attempts <= 0;
    if (isClosed) return true;
    emit(
      state.copyWith(
        phase: GreetingsPhase.question,
        videoVisible: true,
        questionIndex: index,
        attemptCount: attempts < 0 ? 0 : attempts,
        practiceEnabled: !playPrompt,
        messages: messages,
      ),
    );
    if (playPrompt) {
      await _playCue(question.voiceAsset, _AudioCue.question);
    }
    return true;
  }

  GreetingsPartSnapshot _snapshot(String partId) {
    final doc = _analytics.peekPartDoc(partId);
    final stored = _analytics.peekStoredState(partId);
    return GreetingsPartSnapshot(
      reached: doc != null,
      attemptCount: stored.attemptCount,
      locked:
          stored.locked || doc?['status'] == AnalyticsConstants.statusCompleted,
      contentOutcome: (doc?['contentOutcome'] as String?)?.trim() ?? '',
    );
  }

  List<GreetingsMessage> _savedTurns(GreetingsQuestion question) {
    final messages = <GreetingsMessage>[
      _twin(question.promptKey, afterVideo: true),
    ];
    for (final attempt in _analytics.peekAttempts(question.partId)) {
      final outcome = (attempt['contentOutcome'] as String?)?.trim() ?? '';
      if (outcome == AnalyticsConstants.contentNoResponse) continue;
      final heard = (attempt['heardText'] as String?)?.trim() ?? '';
      if (heard.isEmpty) continue;
      messages.add(_student(heard));
      if (outcome.isEmpty) continue;
      messages.add(
        _twin(
          _feedbackKey(question, outcome),
          tone: _feedbackTone(outcome),
          afterVideo: true,
        ),
      );
    }
    return messages;
  }

  String _feedbackKey(GreetingsQuestion question, String outcome) {
    switch (outcome) {
      case AnalyticsConstants.contentCorrect:
        return question.successKey;
      case AnalyticsConstants.contentIncorrect:
        return _plan.exhaustedKey;
      default:
        return _plan.retryKey;
    }
  }

  GreetingsTone _feedbackTone(String outcome) {
    switch (outcome) {
      case AnalyticsConstants.contentCorrect:
        return GreetingsTone.correct;
      case AnalyticsConstants.contentIncorrect:
        return GreetingsTone.exhausted;
      default:
        return GreetingsTone.retry;
    }
  }

  Future<void> _reach(GreetingsQuestion question) async {
    try {
      await _analytics.reachPart(_partFor(question));
    } catch (error, stack) {
      log('greetings reach: $error', stackTrace: stack);
    }
  }

  AssessmentPartContext _partFor(GreetingsQuestion question) {
    return AssessmentPartContext.fromPartId(
      question.partId,
      referenceText: question.referenceText,
    );
  }

  LessonAnalytics _lessonFor({
    required GreetingsQuestion question,
    required bool matched,
    required bool exhausted,
  }) {
    if (matched) {
      return LessonAnalytics(
        contentOutcome: AnalyticsConstants.contentCorrect,
        contentMatched: true,
        lessonFeedback: question.successText,
      );
    }
    if (exhausted) {
      return LessonAnalytics(
        contentOutcome: AnalyticsConstants.contentIncorrect,
        contentMatched: false,
        lessonFeedback: _plan.exhaustedText,
      );
    }
    return LessonAnalytics(
      contentOutcome: AnalyticsConstants.contentRetry,
      contentMatched: false,
      lessonFeedback: _plan.retryText,
    );
  }

  GreetingsMessage _twin(
    String text, {
    GreetingsTone tone = GreetingsTone.speech,
    bool afterVideo = false,
  }) {
    _messageSeq++;
    return GreetingsMessage(
      id: 'twin-$_messageSeq',
      speaker: GreetingsSpeaker.twin,
      text: text,
      tone: tone,
      afterVideo: afterVideo,
    );
  }

  GreetingsMessage _student(String text) {
    _messageSeq++;
    return GreetingsMessage(
      id: 'student-$_messageSeq',
      speaker: GreetingsSpeaker.student,
      text: text,
      localized: false,
      afterVideo: true,
    );
  }

  @override
  Future<void> close() async {
    _audioCue = _AudioCue.none;
    await _audioSub?.cancel();
    await _audio.stop();
    await _engine.dispose();
    return super.close();
  }
}
