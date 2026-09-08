import 'package:flutter/material.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/features/course_shell/course_constants.dart';
import 'package:micro_teaching_studio/features/course_shell/widgets/course_bottom_nav.dart';
import 'package:micro_teaching_studio/features/course_shell/widgets/course_lesson_header.dart';

class CourseScaffold extends StatelessWidget {
  const CourseScaffold({
    super.key,
    required this.voiceCode,
    required this.title,
    this.titleAr,
    required this.currentIndex,
    required this.body,
    this.bodyGradient = ColorManager.gradientLoginSurface,
    this.onClose,
    this.onHelp,
    this.onSkip,
    this.onBack,
    this.onNext,
    this.backEnabled = true,
    this.closeAsset,
  });

  final String voiceCode;
  final String title;
  final String? titleAr;
  final int currentIndex;
  final Widget body;
  final List<Color> bodyGradient;
  final VoidCallback? onClose;
  final VoidCallback? onHelp;
  final VoidCallback? onSkip;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final bool backEnabled;
  final String? closeAsset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.surfaceMuted,
      body: Column(
        children: [
          CourseLessonHeader(
            voiceCode: voiceCode,
            title: title,
            titleAr: titleAr,
            onClose: onClose,
            onHelp: onHelp,
            onSkip: onSkip,
            closeAsset: closeAsset,
          ),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: bodyGradient,
                ),
              ),
              child: body,
            ),
          ),
          CourseBottomNav(
            currentIndex: currentIndex,
            totalSteps: CourseConstants.totalFrames,
            backEnabled: backEnabled,
            onBack: onBack,
            onNext: onNext,
          ),
        ],
      ),
    );
  }
}
