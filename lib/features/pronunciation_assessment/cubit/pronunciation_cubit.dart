import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/features/analytics/data/analytics_repository.dart';
import 'package:micro_teaching_studio/features/analytics/models/assessment_part_context.dart';
import 'package:micro_teaching_studio/features/course_audio/cubit/course_audio_cubit.dart';
import 'package:micro_teaching_studio/features/home/cubit/course_progress_cubit.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/cubit/pronunciation_state.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/models/pronunciation_result.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/data/pronunciation_engine.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/data/speech_config_repository.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/pronunciation_constants.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/pronunciation_ui.dart';

class PronunciationCubit extends Cubit<PronunciationState> {
  PronunciationCubit(
    this._configRepository,
    this._engine,
    this._analytics,
    this._progress,
    this._audio,
  ) : super(const PronunciationState()) {
    unawaited(_configRepository.load());
  }

  final SpeechConfigRepository _configRepository;
  final PronunciationEngine _engine;
  final AnalyticsRepository _analytics;
  final CourseProgressCubit _progress;
  final CourseAudioCubit _audio;
  AssessmentPartContext? _part;
  DateTime? _startedAt;
  bool _busy = false;

  Future<void> toggle({
    required String referenceText,
    required AssessmentPartContext part,
    bool enableProsody = true,
  }) async {
    _part = part;
    if (_busy || state.isAssessing) return;
    if (!state.isRecording && !state.canStartRecording) return;
    if (state.isRecording) {
      await _stopAndAssess(
        referenceText: referenceText,
        enableProsody: enableProsody,
      );
      return;
    }
    await _start();
  }

  void resetScore() {
    emit(const PronunciationState());
  }

  Future<void> restore(AssessmentPartContext part) async {
    _part = part;
    await _audio.stop();
    try {
      if (!_analytics.isHydrated) {
        await _analytics.hydrate();
      }
      if (isClosed) return;
      final stored = _analytics.peekStoredState(part.partId);
      if (!stored.hasAttempt) {
        emit(const PronunciationState());
        return;
      }
      emit(
        PronunciationState(
          status: stored.result == null
              ? PronunciationStatus.idle
              : PronunciationStatus.scored,
          result: stored.result,
          attemptCount: stored.attemptCount,
          locked: stored.locked,
        ),
      );
    } catch (error, stack) {
      log('pronunciation restore: $error', stackTrace: stack);
      if (!isClosed) emit(const PronunciationState());
    }
  }

  Future<void> _start() async {
    _busy = true;
    unawaited(_configRepository.load());
    try {
      await _audio.stop();
    await _engine.startRecording();
      _startedAt = DateTime.now();
      emit(
        state.copyWith(
          status: PronunciationStatus.recording,
          clearResult: true,
          clearError: true,
        ),
      );
    } catch (error, stack) {
      log('pronunciation start: $error', stackTrace: stack);
      emit(
        PronunciationState(
          status: PronunciationStatus.failure,
          errorMessage: _messageOf(error),
          attemptCount: state.attemptCount,
          locked: state.locked,
        ),
      );
    } finally {
      _busy = false;
    }
  }

  Future<void> _stopAndAssess({
    required String referenceText,
    required bool enableProsody,
  }) async {
    _busy = true;
    emit(state.copyWith(status: PronunciationStatus.assessing, clearError: true));
    final startedAt = _startedAt ?? DateTime.now();
    try {
      final file = await _engine.stopRecording();
      final config = await _configRepository.load();
      final result = await _engine.assess(
        audioFile: file,
        referenceText: referenceText,
        config: config,
        enableProsody: enableProsody,
      );
      final attemptCount = state.attemptCount + 1;
      final locked = result.band == PronunciationBand.excellent ||
          attemptCount >= PronunciationConstants.maxAttempts;
      final scored = PronunciationState(
        status: PronunciationStatus.scored,
        result: result,
        attemptCount: attemptCount,
        locked: locked,
      );
      emit(scored);
      unawaited(
        _persistScored(
          scored: scored,
          startedAt: startedAt,
          language: config.language,
          region: config.region,
        ),
      );
    } catch (error, stack) {
      log('pronunciation assess: $error', stackTrace: stack);
      emit(
        PronunciationState(
          status: PronunciationStatus.failure,
          errorMessage: _messageOf(error),
          attemptCount: state.attemptCount,
          locked: state.locked,
        ),
      );
      _persistFailed(
        attemptNumber: state.attemptCount + 1,
        startedAt: startedAt,
        errorMessage: _messageOf(error),
      );
    } finally {
      _busy = false;
      _startedAt = null;
    }
  }

  Future<void> _persistScored({
    required PronunciationState scored,
    required DateTime startedAt,
    required String language,
    required String region,
  }) async {
    final part = _part;
    final result = scored.result;
    if (part == null || result == null) return;
    final twinTip = part.isPhonics
        ? phonicsTwinTip(scored)
        : pronunciationTwinTip(scored, AppStrings.fluencyAiTwinTip);
    try {
      await _analytics.recordScoredAttempt(
        part: part,
        result: result,
        attemptNumber: scored.attemptCount,
        twinTip: twinTip,
        startedAt: startedAt,
        endedAt: DateTime.now(),
        language: language,
        region: region,
      );
      if (scored.locked) {
        await _progress.completePart(part.partId);
      }
    } catch (error, stack) {
      log('analytics scored: $error', stackTrace: stack);
    }
  }

  void _persistFailed({
    required int attemptNumber,
    required DateTime startedAt,
    required String errorMessage,
  }) {
    final part = _part;
    if (part == null) return;
    unawaited(
      _analytics
          .recordFailedAttempt(
            part: part,
            attemptNumber: attemptNumber,
            startedAt: startedAt,
            endedAt: DateTime.now(),
            errorMessage: errorMessage,
          )
          .onError((error, stack) {
        log('analytics failed: $error', stackTrace: stack);
      }),
    );
  }

  String _messageOf(Object error) {
    log('pronunciation error type=${error.runtimeType} value=$error');
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
    if (error is FileSystemException) {
      return AppStrings.pronunciationNoAudio;
    }
    return AppStrings.pronunciationServiceError;
  }

  @override
  Future<void> close() {
    _engine.dispose();
    return super.close();
  }
}
