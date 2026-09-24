import 'package:equatable/equatable.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/pronunciation_constants.dart';
import 'package:micro_teaching_studio/features/quiz/quiz_script.dart';

class ClassroomQuizState extends Equatable {
  const ClassroomQuizState({
    this.ready = false,
    this.selections = const [null, null],
    this.attemptCount = 0,
    this.tone = QuizTone.none,
    this.settled = false,
    this.submitting = false,
  });

  final bool ready;
  final List<int?> selections;
  final int attemptCount;
  final QuizTone tone;
  final bool settled;
  final bool submitting;

  bool get canSubmit =>
      ready &&
      !settled &&
      !submitting &&
      selections.every((selected) => selected != null);

  int get attemptsLeft {
    final left = PronunciationConstants.maxAttempts - attemptCount;
    return left < 0 ? 0 : left;
  }

  ClassroomQuizState copyWith({
    bool? ready,
    List<int?>? selections,
    int? attemptCount,
    QuizTone? tone,
    bool? settled,
    bool? submitting,
  }) {
    return ClassroomQuizState(
      ready: ready ?? this.ready,
      selections: selections ?? this.selections,
      attemptCount: attemptCount ?? this.attemptCount,
      tone: tone ?? this.tone,
      settled: settled ?? this.settled,
      submitting: submitting ?? this.submitting,
    );
  }

  @override
  List<Object?> get props => [
        ready,
        selections,
        attemptCount,
        tone,
        settled,
        submitting,
      ];
}
