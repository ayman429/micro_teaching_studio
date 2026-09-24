import 'package:equatable/equatable.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/pronunciation_constants.dart';
import 'package:micro_teaching_studio/features/quiz/quiz_script.dart';

class VocabQuizState extends Equatable {
  const VocabQuizState({
    this.ready = false,
    this.magnificent = '',
    this.monument = '',
    this.heard = '',
    this.pronouncedWell = false,
    this.attemptCount = 0,
    this.tone = QuizTone.none,
    this.settled = false,
    this.submitting = false,
    this.recording = false,
    this.assessing = false,
    this.notice = 0,
    this.noticeMessage,
  });

  final bool ready;
  final String magnificent;
  final String monument;
  final String heard;
  final bool pronouncedWell;
  final int attemptCount;
  final QuizTone tone;
  final bool settled;
  final bool submitting;
  final bool recording;
  final bool assessing;
  final int notice;
  final String? noticeMessage;

  bool get canSubmit =>
      ready &&
      !settled &&
      !submitting &&
      !recording &&
      !assessing &&
      magnificent.trim().isNotEmpty &&
      monument.trim().isNotEmpty &&
      heard.trim().isNotEmpty;

  int get attemptsLeft {
    final left = PronunciationConstants.maxAttempts - attemptCount;
    return left < 0 ? 0 : left;
  }

  VocabQuizState copyWith({
    bool? ready,
    String? magnificent,
    String? monument,
    String? heard,
    bool? pronouncedWell,
    int? attemptCount,
    QuizTone? tone,
    bool? settled,
    bool? submitting,
    bool? recording,
    bool? assessing,
    int? notice,
    String? noticeMessage,
  }) {
    return VocabQuizState(
      ready: ready ?? this.ready,
      magnificent: magnificent ?? this.magnificent,
      monument: monument ?? this.monument,
      heard: heard ?? this.heard,
      pronouncedWell: pronouncedWell ?? this.pronouncedWell,
      attemptCount: attemptCount ?? this.attemptCount,
      tone: tone ?? this.tone,
      settled: settled ?? this.settled,
      submitting: submitting ?? this.submitting,
      recording: recording ?? this.recording,
      assessing: assessing ?? this.assessing,
      notice: notice ?? this.notice,
      noticeMessage: noticeMessage ?? this.noticeMessage,
    );
  }

  @override
  List<Object?> get props => [
        ready,
        magnificent,
        monument,
        heard,
        pronouncedWell,
        attemptCount,
        tone,
        settled,
        submitting,
        recording,
        assessing,
        notice,
        noticeMessage,
      ];
}
