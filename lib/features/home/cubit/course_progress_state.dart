import 'package:equatable/equatable.dart';
import 'package:micro_teaching_studio/features/home/models/course_progress.dart';

class CourseProgressState extends Equatable {
  const CourseProgressState({this.completedIds = const {}});

  final Set<String> completedIds;

  CourseProgressSnapshot get snapshot =>
      CourseProgressSnapshot(completedIds: completedIds);

  @override
  List<Object?> get props => [completedIds];
}
