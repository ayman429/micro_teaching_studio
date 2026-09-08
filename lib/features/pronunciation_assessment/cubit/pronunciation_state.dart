import 'package:equatable/equatable.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/models/pronunciation_result.dart';

enum PronunciationStatus { idle, recording, assessing, scored, failure }

class PronunciationState extends Equatable {
  const PronunciationState({
    this.status = PronunciationStatus.idle,
    this.result,
    this.errorMessage,
  });

  final PronunciationStatus status;
  final PronunciationResult? result;
  final String? errorMessage;

  bool get isRecording => status == PronunciationStatus.recording;
  bool get isAssessing => status == PronunciationStatus.assessing;
  PronunciationBand? get band => result?.band;

  PronunciationState copyWith({
    PronunciationStatus? status,
    PronunciationResult? result,
    String? errorMessage,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return PronunciationState(
      status: status ?? this.status,
      result: clearResult ? null : result ?? this.result,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, result, errorMessage];
}
