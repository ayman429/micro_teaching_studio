import 'package:flutter/material.dart';
import 'package:micro_teaching_studio/common/resources/assets_manager.dart';
import 'package:micro_teaching_studio/features/course_video/widgets/course_video_player.dart';

class HelpVideoCard extends StatelessWidget {
  const HelpVideoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return CourseVideoPlayer(asset: VideoAssets.help());
  }
}
