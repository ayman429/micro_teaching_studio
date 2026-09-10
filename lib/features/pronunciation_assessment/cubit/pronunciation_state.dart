import 'package:equatable/equatable.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/models/pronunciation_result.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/pronunciation_constants.dart';

enum PronunciationStatus { idle, recording, assessing, scored, failure }

class PronunciationState extends Equatable {
  const PronunciationState({
    this.status = PronunciationStatus.idle,
    this.result,
    this.errorMessage,
    this.attemptCount = 0,
    this.locked = false,
  });

  final PronunciationStatus status;
  final PronunciationResult? result;
  final String? errorMessage;
  final int attemptCount;
  final bool locked;

  bool get isRecording => status == PronunciationStatus.recording;
  bool get isAssessing => status == PronunciationStatus.assessing;
  bool get isScored => status == PronunciationStatus.scored;
  PronunciationBand? get band => result?.band;

  bool get canRetry =>
      !locked &&
      isScored &&
      band != PronunciationBand.excellent &&
      attemptCount < PronunciationConstants.maxAttempts;

  bool get showNext => isScored || locked;

  bool get canStartRecording {
    if (locked) return false;
    if (isRecording || isAssessing) return true;
    if (attemptCount >= PronunciationConstants.maxAttempts) return false;
    if (isScored && band == PronunciationBand.excellent) return false;
    return true;
  }

  PronunciationState copyWith({
    PronunciationStatus? status,
    PronunciationResult? result,
    String? errorMessage,
    int? attemptCount,
    bool? locked,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return PronunciationState(
      status: status ?? this.status,
      result: clearResult ? null : result ?? this.result,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      attemptCount: attemptCount ?? this.attemptCount,
      locked: locked ?? this.locked,
    );
  }

  @override
  List<Object?> get props => [status, result, errorMessage, attemptCount, locked];
}
