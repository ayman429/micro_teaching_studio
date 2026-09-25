import 'package:micro_teaching_studio/features/pronunciation_assessment/models/pronunciation_result.dart';

class StoredPartState {
  const StoredPartState({
    required this.attemptCount,
    required this.locked,
    this.result,
  });

  final int attemptCount;
  final bool locked;
  final PronunciationResult? result;

  bool get hasAttempt => attemptCount > 0;
}
