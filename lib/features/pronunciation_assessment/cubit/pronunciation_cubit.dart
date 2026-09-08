import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/cubit/pronunciation_state.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/data/pronunciation_engine.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/data/speech_config_repository.dart';

class PronunciationCubit extends Cubit<PronunciationState> {
  PronunciationCubit(this._configRepository, this._engine)
      : super(const PronunciationState()) {
    unawaited(_configRepository.load());
  }

  final SpeechConfigRepository _configRepository;
  final PronunciationEngine _engine;
  bool _busy = false;

  Future<void> toggle({
    required String referenceText,
    bool enableProsody = true,
  }) async {
    if (_busy || state.isAssessing) return;
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

  Future<void> _start() async {
    _busy = true;
    unawaited(_configRepository.load());
    try {
      await _engine.startRecording();
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
    try {
      final file = await _engine.stopRecording();
      final config = await _configRepository.load();
      final result = await _engine.assess(
        audioFile: file,
        referenceText: referenceText,
        config: config,
        enableProsody: enableProsody,
      );
      emit(
        PronunciationState(
          status: PronunciationStatus.scored,
          result: result,
        ),
      );
    } catch (error, stack) {
      log('pronunciation assess: $error', stackTrace: stack);
      emit(
        PronunciationState(
          status: PronunciationStatus.failure,
          errorMessage: _messageOf(error),
        ),
      );
    } finally {
      _busy = false;
    }
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
