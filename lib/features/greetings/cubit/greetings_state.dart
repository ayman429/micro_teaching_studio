import 'package:equatable/equatable.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/pronunciation_constants.dart';

enum GreetingsPhase {
  intro,
  watching,
  question,
  recording,
  assessing,
  feedback,
  reflection,
  done,
  exit,
}

enum GreetingsSpeaker { twin, student }

enum GreetingsTone { speech, correct, retry, exhausted }

class GreetingsMessage extends Equatable {
  const GreetingsMessage({
    required this.id,
    required this.speaker,
    required this.text,
    this.tone = GreetingsTone.speech,
    this.localized = true,
    this.afterVideo = false,
  });

  final String id;
  final GreetingsSpeaker speaker;
  final String text;
  final GreetingsTone tone;
  final bool localized;
  final bool afterVideo;

  @override
  List<Object?> get props => [id, speaker, text, tone, localized, afterVideo];
}

class GreetingsState extends Equatable {
  const GreetingsState({
    this.phase = GreetingsPhase.intro,
    this.questionIndex = 0,
    this.attemptCount = 0,
    this.messages = const [],
    this.practiceEnabled = false,
    this.videoVisible = false,
    this.maxAttempts = PronunciationConstants.maxAttempts,
    this.errorMessage,
  });

  final GreetingsPhase phase;
  final int questionIndex;
  final int attemptCount;
  final List<GreetingsMessage> messages;
  final bool practiceEnabled;
  final bool videoVisible;
  final int maxAttempts;
  final String? errorMessage;

  bool get isRecording => phase == GreetingsPhase.recording;
  bool get isAssessing => phase == GreetingsPhase.assessing;

  bool get showPractice =>
      practiceEnabled &&
      (phase == GreetingsPhase.question ||
          phase == GreetingsPhase.recording ||
          phase == GreetingsPhase.assessing);

  GreetingsState copyWith({
    GreetingsPhase? phase,
    int? questionIndex,
    int? attemptCount,
    List<GreetingsMessage>? messages,
    bool? practiceEnabled,
    bool? videoVisible,
    int? maxAttempts,
    String? errorMessage,
    bool clearError = false,
  }) {
    return GreetingsState(
      phase: phase ?? this.phase,
      questionIndex: questionIndex ?? this.questionIndex,
      attemptCount: attemptCount ?? this.attemptCount,
      messages: messages ?? this.messages,
      practiceEnabled: practiceEnabled ?? this.practiceEnabled,
      videoVisible: videoVisible ?? this.videoVisible,
      maxAttempts: maxAttempts ?? this.maxAttempts,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        phase,
        questionIndex,
        attemptCount,
        messages,
        practiceEnabled,
        videoVisible,
        maxAttempts,
        errorMessage,
      ];
}
