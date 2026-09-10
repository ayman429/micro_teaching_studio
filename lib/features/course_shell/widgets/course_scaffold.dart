import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_teaching_studio/common/resources/app_router.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/features/course_shell/course_constants.dart';
import 'package:micro_teaching_studio/features/course_shell/course_flow.dart';
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
  final VoidCallback? onSkip;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final bool backEnabled;
  final String? closeAsset;

  static void openHelp(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location == AppRouters.helpView) return;
    context.push(AppRouters.helpView);
  }

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
            onClose: onClose ?? () => CourseFlow.goHome(context),
            onHelp: () => openHelp(context),
            onSkip: onSkip ?? onNext,
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
