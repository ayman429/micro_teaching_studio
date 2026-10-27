import 'package:equatable/equatable.dart';
import 'package:micro_teaching_studio/features/home/models/course_progress.dart';

class CourseProgressState extends Equatable {
  const CourseProgressState({
    this.completedIds = const {},
    this.finishedSessions = const {},
    this.restudiedSessions = const {},
    this.pointIds = const {},
  });

  final Set<String> completedIds;
  final Set<String> finishedSessions;
  final Set<String> restudiedSessions;
  final Set<String> pointIds;

  CourseProgressSnapshot get snapshot =>
      CourseProgressSnapshot(completedIds: completedIds);

  CourseProgressState copyWith({
    Set<String>? completedIds,
    Set<String>? finishedSessions,
    Set<String>? restudiedSessions,
    Set<String>? pointIds,
  }) {
    return CourseProgressState(
      completedIds: completedIds ?? this.completedIds,
      finishedSessions: finishedSessions ?? this.finishedSessions,
      restudiedSessions: restudiedSessions ?? this.restudiedSessions,
      pointIds: pointIds ?? this.pointIds,
    );
  }

  @override
  List<Object?> get props => [
        completedIds,
        finishedSessions,
        restudiedSessions,
        pointIds,
      ];
}
