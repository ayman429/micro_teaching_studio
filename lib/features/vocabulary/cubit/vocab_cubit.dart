import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:micro_teaching_studio/common/resources/assets_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/features/analytics/analytics_constants.dart';
import 'package:micro_teaching_studio/features/analytics/data/analytics_repository.dart';
import 'package:micro_teaching_studio/features/analytics/models/assessment_part_context.dart';
import 'package:micro_teaching_studio/features/analytics/models/lesson_analytics.dart';
import 'package:micro_teaching_studio/features/course_audio/cubit/course_audio_cubit.dart';
import 'package:micro_teaching_studio/features/course_audio/cubit/course_audio_state.dart';
import 'package:micro_teaching_studio/features/greetings/cubit/greetings_state.dart';
import 'package:micro_teaching_studio/features/home/cubit/course_progress_cubit.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/data/pronunciation_engine.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/data/speech_config_repository.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/models/pronunciation_result.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/pronunciation_constants.dart';
import 'package:micro_teaching_studio/features/vocabulary/vocab_script.dart';

enum _Cue { none, prompt, bridge, feedback, reflection }

enum _Pending { none, retry, advance, bridge, reflect, finish }

class VocabCubit extends Cubit<GreetingsState> {
  VocabCubit(
    this._configRepository,
    this._engine,
    this._analytics,
    this._progress,
    this._audio,
  ) : super(const GreetingsState());

  final SpeechConfigRepository _configRepository;
  final PronunciationEngine _engine;
  final AnalyticsRepository _analytics;
  final CourseProgressCubit _progress;
  final CourseAudioCubit _audio;

  StreamSubscription<CourseAudioState>? _audioSub;
  var _started = false;
  var _visible = false;
  var _busy = false;
  var _videoFinished = false;
  var _questionsStarted = false;
  var _onWords = true;
  var _messageSeq = 0;
  var _heardPlayback = false;
  var _cue = _Cue.none;
  var _pausedCue = _Cue.none;
  var _pending = _Pending.none;
  String? _currentAsset;
  String? _pausedAsset;

  Future<void> start() async {
    _visible = true;
    if (_started) return;
    _started = true;
    _audioSub = _audio.stream.listen(_onAudio);
    try {
      if (await _restore()) return;
    } catch (error, stack) {
      log('vocab restore: $error', stackTrace: stack);
    }
    if (isClosed) return;
    await _askWord(0, playPrompt: true);
  }

  Future<void> onVideoStarted() async {
    if (_cue != _Cue.bridge) {
      await _audio.stop();
      return;
    }
    _cue = _Cue.none;
    _heardPlayback = false;
    await _audio.stop();
    if (!isClosed) emit(state.copyWith(phase: GreetingsPhase.watching));
  }

  Future<void> onVideoCompleted() async {
    if (_videoFinished) return;
    _videoFinished = true;
    _cue = _Cue.none;
    _heardPlayback = false;
    await _audio.stop();
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
      _cue = _Cue.none;
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
      log('vocab record: $error', stackTrace: stack);
      _emitError(error);
    } finally {
      _busy = false;
    }
  }

  Future<void> pauseForOverlay() async {
    _visible = false;
    if (state.phase == GreetingsPhase.recording) {
      try {
        await _engine.stopRecording();
      } catch (error, stack) {
        log('vocab pause recording: $error', stackTrace: stack);
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
    if (_cue == _Cue.none) {
      await _audio.stop();
      return;
    }
    _pausedCue = _cue;
    _pausedAsset = _currentAsset;
    _cue = _Cue.none;
    _heardPlayback = false;
    await _audio.stop();
  }

  Future<void> resumeFromOverlay() async {
    _visible = true;
    final cue = _pausedCue;
    final asset = _pausedAsset;
    _pausedCue = _Cue.none;
    _pausedAsset = null;
    if (cue == _Cue.none || asset == null || asset.isEmpty) return;
    if (isClosed || state.phase == GreetingsPhase.exit) return;
    await _play(asset, cue);
  }

  Future<void> _askWord(int index, {required bool playPrompt}) async {
    if (isClosed || index < 0 || index >= VocabScript.words.length) return;
    _onWords = true;
    final turn = VocabScript.words[index];
    await _reach(turn);
    if (isClosed) return;
    emit(
      state.copyWith(
        phase: GreetingsPhase.question,
        questionIndex: index,
        attemptCount: playPrompt ? 0 : state.attemptCount,
        maxAttempts: turn.maxAttempts,
        practiceEnabled: !playPrompt,
        videoVisible: false,
        clearError: true,
        messages: [
          ...state.messages,
          _twin(turn.promptKey),
        ],
      ),
    );
    if (playPrompt) await _play(turn.voiceAsset, _Cue.prompt);
  }

  Future<void> _beginBridge() async {
    if (isClosed) return;
    _onWords = false;
    emit(
      state.copyWith(
        phase: GreetingsPhase.intro,
        practiceEnabled: false,
        videoVisible: true,
        messages: [
          ...state.messages,
          _twin(AppStrings.vocabVoice5),
        ],
      ),
    );
    await _play(AudioAssets.vocabVoice(5), _Cue.bridge);
  }

  Future<void> _beginQuestions() async {
    if (_questionsStarted || isClosed) return;
    _questionsStarted = true;
    _onWords = false;
    await _askQuestion(0, playPrompt: true);
  }

  Future<void> _askQuestion(int index, {required bool playPrompt}) async {
    if (isClosed || index < 0 || index >= VocabScript.questions.length) return;
    final turn = VocabScript.questions[index];
    await _reach(turn);
    if (isClosed) return;
    emit(
      state.copyWith(
        phase: GreetingsPhase.question,
        questionIndex: index,
        attemptCount: playPrompt ? 0 : state.attemptCount,
        maxAttempts: turn.maxAttempts,
        practiceEnabled: !playPrompt,
        videoVisible: true,
        clearError: true,
        messages: [
          ...state.messages,
          _twin(turn.promptKey, afterVideo: true),
        ],
      ),
    );
    if (playPrompt) await _play(turn.voiceAsset, _Cue.prompt);
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
    final turn = _currentTurn();
    try {
      final file = await _engine.stopRecording();
      final config = await _configRepository.load();
      final result = await _engine.assess(
        audioFile: file,
        referenceText: turn.referenceText,
        config: config,
        enableProsody: false,
        phonics: turn.pronunciation,
      );
      if (isClosed) return;
      if (!_hasSpeech(result)) {
        await _recordNoResponse(
          turn: turn,
          result: result,
          startedAt: startedAt,
          language: config.language,
          region: config.region,
        );
        _requestExit();
        return;
      }
      final heard = result.heardText!.trim();
      final matched = turn.pronunciation
          ? result.band == PronunciationBand.excellent
          : (turn.matches?.call(heard) ?? false);
      final attempts = state.attemptCount + 1;
      final exhausted = !matched && attempts >= turn.maxAttempts;
      final lastQuestion = !_onWords &&
          state.questionIndex >= VocabScript.questions.length - 1;
      final lastWord = _onWords && state.questionIndex >= VocabScript.words.length - 1;
      _pending = matched
          ? (lastQuestion
              ? _Pending.reflect
              : (lastWord ? _Pending.bridge : _Pending.advance))
          : (exhausted
              ? (lastQuestion
                  ? _Pending.finish
                  : (lastWord ? _Pending.bridge : _Pending.advance))
              : _Pending.retry);
      final showText = matched || !turn.pronunciation || !exhausted;
      emit(
        state.copyWith(
          phase: GreetingsPhase.feedback,
          attemptCount: attempts,
          practiceEnabled: false,
          messages: [
            ...state.messages,
            _student(heard, afterVideo: !_onWords),
            if (showText)
              _twin(
                matched
                    ? turn.successKey
                    : (exhausted
                        ? AppStrings.greetingsFeedbackExhausted
                        : AppStrings.greetingsFeedbackRetry),
                tone: matched
                    ? GreetingsTone.correct
                    : (exhausted ? GreetingsTone.exhausted : GreetingsTone.retry),
                afterVideo: !_onWords,
              ),
          ],
        ),
      );
      unawaited(
        _record(
          turn: turn,
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
        unawaited(_progress.completePart(turn.partId));
      }
      await _play(
        matched
            ? turn.successAsset
            : (exhausted
                ? AudioAssets.vocabIncorrect()
                : AudioAssets.vocabTryAgain()),
        _Cue.feedback,
      );
    } catch (error, stack) {
      log('vocab assess: $error', stackTrace: stack);
      if (_isSilence(error)) {
        await _recordNoResponse(
          turn: turn,
          startedAt: startedAt,
          language: PronunciationConstants.defaultLanguage,
          region: PronunciationConstants.defaultRegion,
        );
        _requestExit();
        return;
      }
      _emitError(error);
    } finally {
      _busy = false;
    }
  }

  VocabTurn _currentTurn() {
    if (_onWords) return VocabScript.words[state.questionIndex];
    return VocabScript.questions[state.questionIndex];
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
    required VocabTurn turn,
    required PronunciationResult result,
    required int attemptNumber,
    required bool matched,
    required bool exhausted,
    required DateTime startedAt,
    required String language,
    required String region,
  }) async {
    final feedback = matched
        ? turn.successText
        : (exhausted
            ? (turn.pronunciation ? 'Incorrect' : VocabScript.exhaustedText)
            : VocabScript.retryText);
    try {
      await _analytics.recordLessonAttempt(
        part: AssessmentPartContext.fromPartId(
          turn.partId,
          referenceText: turn.referenceText,
        ),
        result: result,
        attemptNumber: attemptNumber,
        maxAttempts: turn.maxAttempts,
        lesson: LessonAnalytics(
          contentOutcome: matched
              ? AnalyticsConstants.contentCorrect
              : (exhausted
                  ? AnalyticsConstants.contentIncorrect
                  : AnalyticsConstants.contentRetry),
          contentMatched: matched,
          lessonFeedback: feedback,
        ),
        startedAt: startedAt,
        endedAt: DateTime.now(),
        language: language,
        region: region,
      );
    } catch (error, stack) {
      log('vocab analytics: $error', stackTrace: stack);
    }
  }

  Future<void> _recordNoResponse({
    required VocabTurn turn,
    required DateTime startedAt,
    required String language,
    required String region,
    PronunciationResult? result,
  }) async {
    try {
      await _analytics.recordLessonAttempt(
        part: AssessmentPartContext.fromPartId(
          turn.partId,
          referenceText: turn.referenceText,
        ),
        result: result,
        attemptNumber: state.attemptCount,
        maxAttempts: turn.maxAttempts,
        lesson: const LessonAnalytics(
          contentOutcome: AnalyticsConstants.contentNoResponse,
          contentMatched: false,
          lessonFeedback: VocabScript.noResponseText,
        ),
        startedAt: startedAt,
        endedAt: DateTime.now(),
        language: language,
        region: region,
      );
    } catch (error, stack) {
      log('vocab no response: $error', stackTrace: stack);
    }
  }

  Future<void> _afterFeedback() async {
    switch (_pending) {
      case _Pending.advance:
        if (_onWords) {
          await _askWord(state.questionIndex + 1, playPrompt: true);
        } else {
          await _askQuestion(state.questionIndex + 1, playPrompt: true);
        }
      case _Pending.bridge:
        await _beginBridge();
      case _Pending.reflect:
        await _reflect();
      case _Pending.finish:
        if (!isClosed) {
          emit(
            state.copyWith(
              phase: GreetingsPhase.done,
              practiceEnabled: false,
            ),
          );
        }
      case _Pending.retry:
        if (!isClosed) {
          emit(
            state.copyWith(
              phase: GreetingsPhase.question,
              practiceEnabled: true,
            ),
          );
        }
      case _Pending.none:
        break;
    }
  }

  Future<void> _reflect() async {
    if (isClosed) return;
    emit(
      state.copyWith(
        phase: GreetingsPhase.reflection,
        practiceEnabled: false,
        videoVisible: true,
        messages: [
          ...state.messages,
          _twin(AppStrings.vocabVoice12, afterVideo: true),
        ],
      ),
    );
    await _play(AudioAssets.vocabVoice(12), _Cue.reflection);
  }

  Future<void> _play(String asset, _Cue cue) async {
    if (isClosed) return;
    _pausedCue = _Cue.none;
    _pausedAsset = null;
    _currentAsset = asset;
    _cue = cue;
    _heardPlayback = false;
    await _audio.play(asset);
  }

  void _onAudio(CourseAudioState audio) {
    if (_cue == _Cue.none) return;
    if (audio.isPlaying) {
      _heardPlayback = true;
      return;
    }
    if (!_heardPlayback) return;
    final cue = _cue;
    _cue = _Cue.none;
    _heardPlayback = false;
    if (audio.errorMessage != null && !isClosed) {
      emit(state.copyWith(errorMessage: audio.errorMessage));
    }
    switch (cue) {
      case _Cue.prompt:
        if (!isClosed) {
          emit(
            state.copyWith(
              phase: GreetingsPhase.question,
              practiceEnabled: true,
              clearError: true,
            ),
          );
        }
      case _Cue.bridge:
        if (!_videoFinished && !isClosed) {
          emit(state.copyWith(phase: GreetingsPhase.watching));
        }
      case _Cue.feedback:
        unawaited(_afterFeedback());
      case _Cue.reflection:
        _requestExit();
      case _Cue.none:
        break;
    }
  }

  void _requestExit() {
    if (isClosed || state.phase == GreetingsPhase.exit) return;
    _cue = _Cue.none;
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

  Future<void> _reach(VocabTurn turn) async {
    try {
      await _analytics.reachPart(
        AssessmentPartContext.fromPartId(
          turn.partId,
          referenceText: turn.referenceText,
        ),
        maxAttempts: turn.maxAttempts,
      );
    } catch (error, stack) {
      log('vocab reach: $error', stackTrace: stack);
    }
  }

  Future<bool> _restore() async {
    if (!_analytics.isHydrated) await _analytics.hydrate();
    if (isClosed) return true;
    final wordIndex = _resumeIndex(VocabScript.words);
    if (wordIndex < 0) return false;
    final messages = <GreetingsMessage>[];
    if (wordIndex < VocabScript.words.length) {
      _onWords = true;
      for (var cursor = 0; cursor < wordIndex; cursor++) {
        messages.addAll(_savedTurns(VocabScript.words[cursor], afterVideo: false));
      }
      final turn = VocabScript.words[wordIndex];
      messages.addAll(_savedTurns(turn, afterVideo: false));
      final attempts = _attemptCount(turn);
      emit(
        state.copyWith(
          phase: GreetingsPhase.question,
          questionIndex: wordIndex,
          attemptCount: attempts,
          maxAttempts: turn.maxAttempts,
          practiceEnabled: attempts > 0,
          videoVisible: false,
          messages: messages,
        ),
      );
      if (attempts <= 0) await _play(turn.voiceAsset, _Cue.prompt);
      return true;
    }
    for (final turn in VocabScript.words) {
      messages.addAll(_savedTurns(turn, afterVideo: false));
    }
    messages.add(_twin(AppStrings.vocabVoice5));
    final questionIndex = _resumeIndex(VocabScript.questions);
    if (questionIndex < 0) {
      _videoFinished = false;
      _onWords = false;
      emit(
        state.copyWith(
          phase: GreetingsPhase.intro,
          videoVisible: true,
          practiceEnabled: false,
          messages: messages,
        ),
      );
      await _play(AudioAssets.vocabVoice(5), _Cue.bridge);
      return true;
    }
    _videoFinished = true;
    _questionsStarted = true;
    _onWords = false;
    if (questionIndex >= VocabScript.questions.length) {
      for (final turn in VocabScript.questions) {
        messages.addAll(_savedTurns(turn, afterVideo: true));
      }
      final last = _analytics.peekPartDoc(VocabScript.questions.last.partId);
      final correct = (last?['contentOutcome'] as String?)?.trim() ==
          AnalyticsConstants.contentCorrect;
      if (correct) {
        messages.add(_twin(AppStrings.vocabVoice12, afterVideo: true));
      }
      emit(
        state.copyWith(
          phase: GreetingsPhase.done,
          videoVisible: true,
          practiceEnabled: false,
          questionIndex: VocabScript.questions.length - 1,
          messages: messages,
        ),
      );
      return true;
    }
    for (var cursor = 0; cursor < questionIndex; cursor++) {
      messages.addAll(
        _savedTurns(VocabScript.questions[cursor], afterVideo: true),
      );
    }
    final turn = VocabScript.questions[questionIndex];
    messages.addAll(_savedTurns(turn, afterVideo: true));
    final attempts = _attemptCount(turn);
    emit(
      state.copyWith(
        phase: GreetingsPhase.question,
        questionIndex: questionIndex,
        attemptCount: attempts,
        maxAttempts: turn.maxAttempts,
        practiceEnabled: attempts > 0,
        videoVisible: true,
        messages: messages,
      ),
    );
    if (attempts <= 0) await _play(turn.voiceAsset, _Cue.prompt);
    return true;
  }

  int _resumeIndex(List<VocabTurn> turns) {
    var seen = false;
    for (var index = 0; index < turns.length; index++) {
      final doc = _analytics.peekPartDoc(turns[index].partId);
      if (doc == null) return seen ? index : (index == 0 ? -1 : index);
      seen = true;
      if (!_settled(turns[index])) return index;
    }
    return seen ? turns.length : -1;
  }

  bool _settled(VocabTurn turn) {
    final doc = _analytics.peekPartDoc(turn.partId);
    final stored = _analytics.peekStoredState(turn.partId);
    final outcome = (doc?['contentOutcome'] as String?)?.trim() ?? '';
    return stored.locked ||
        outcome == AnalyticsConstants.contentCorrect ||
        outcome == AnalyticsConstants.contentIncorrect ||
        stored.attemptCount >= turn.maxAttempts;
  }

  int _attemptCount(VocabTurn turn) {
    final count = _analytics.peekStoredState(turn.partId).attemptCount;
    return count < 0 ? 0 : count;
  }

  List<GreetingsMessage> _savedTurns(VocabTurn turn, {required bool afterVideo}) {
    final messages = <GreetingsMessage>[
      _twin(turn.promptKey, afterVideo: afterVideo),
    ];
    for (final attempt in _analytics.peekAttempts(turn.partId)) {
      final outcome = (attempt['contentOutcome'] as String?)?.trim() ?? '';
      if (outcome == AnalyticsConstants.contentNoResponse) continue;
      final heard = (attempt['heardText'] as String?)?.trim() ?? '';
      if (heard.isEmpty) continue;
      messages.add(_student(heard, afterVideo: afterVideo));
      if (outcome.isEmpty) continue;
      if (turn.pronunciation && outcome == AnalyticsConstants.contentIncorrect) {
        continue;
      }
      messages.add(
        _twin(
          outcome == AnalyticsConstants.contentCorrect
              ? turn.successKey
              : (outcome == AnalyticsConstants.contentIncorrect
                  ? AppStrings.greetingsFeedbackExhausted
                  : AppStrings.greetingsFeedbackRetry),
          tone: outcome == AnalyticsConstants.contentCorrect
              ? GreetingsTone.correct
              : (outcome == AnalyticsConstants.contentIncorrect
                  ? GreetingsTone.exhausted
                  : GreetingsTone.retry),
          afterVideo: afterVideo,
        ),
      );
    }
    return messages;
  }

  GreetingsMessage _twin(
    String text, {
    GreetingsTone tone = GreetingsTone.speech,
    bool afterVideo = false,
  }) {
    _messageSeq++;
    return GreetingsMessage(
      id: 'vocab-twin-$_messageSeq',
      speaker: GreetingsSpeaker.twin,
      text: text,
      tone: tone,
      afterVideo: afterVideo,
    );
  }

  GreetingsMessage _student(String text, {required bool afterVideo}) {
    _messageSeq++;
    return GreetingsMessage(
      id: 'vocab-student-$_messageSeq',
      speaker: GreetingsSpeaker.student,
      text: text,
      localized: false,
      afterVideo: afterVideo,
    );
  }

  @override
  Future<void> close() async {
    final stopAudio = _visible;
    _visible = false;
    _cue = _Cue.none;
    await _audioSub?.cancel();
    if (stopAudio) await _audio.stop();
    await _engine.dispose();
    return super.close();
  }
}
