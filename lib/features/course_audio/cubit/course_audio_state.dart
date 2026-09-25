import 'package:equatable/equatable.dart';

class CourseAudioState extends Equatable {
  const CourseAudioState({
    this.playingAsset,
    this.errorMessage,
  });

  final String? playingAsset;
  final String? errorMessage;

  bool get isPlaying => playingAsset != null;

  bool isPlayingAsset(String asset) {
    final current = playingAsset?.replaceAll('\\', '/').toLowerCase();
    final wanted = asset.replaceAll('\\', '/').toLowerCase();
    if (current == null || current.isEmpty || wanted.isEmpty) return false;
    return current == wanted ||
        current.split('/').last == wanted.split('/').last;
  }

  CourseAudioState copyWith({
    String? playingAsset,
    String? errorMessage,
    bool clearPlaying = false,
    bool clearError = false,
  }) {
    return CourseAudioState(
      playingAsset: clearPlaying ? null : playingAsset ?? this.playingAsset,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [playingAsset, errorMessage];
}
