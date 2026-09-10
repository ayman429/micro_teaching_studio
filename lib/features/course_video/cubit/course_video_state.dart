import 'package:equatable/equatable.dart';

enum CourseVideoStatus { loading, ready, error }

class CourseVideoState extends Equatable {
  const CourseVideoState({
    this.status = CourseVideoStatus.loading,
    this.isPlaying = false,
    this.progress = 0,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.errorMessage,
  });

  final CourseVideoStatus status;
  final bool isPlaying;
  final double progress;
  final Duration position;
  final Duration duration;
  final String? errorMessage;

  bool get isReady => status == CourseVideoStatus.ready;

  String get durationLabel {
    final total = duration.inSeconds;
    final minutes = total ~/ 60;
    final seconds = total % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  CourseVideoState copyWith({
    CourseVideoStatus? status,
    bool? isPlaying,
    double? progress,
    Duration? position,
    Duration? duration,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CourseVideoState(
      status: status ?? this.status,
      isPlaying: isPlaying ?? this.isPlaying,
      progress: progress ?? this.progress,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        isPlaying,
        progress,
        position,
        duration,
        errorMessage,
      ];
}
