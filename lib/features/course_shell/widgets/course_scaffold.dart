import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_teaching_studio/common/resources/app_router.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/features/course_shell/course_flow.dart';
import 'package:micro_teaching_studio/features/course_shell/widgets/course_lesson_header.dart';

class CourseScaffold extends StatelessWidget {
  const CourseScaffold({
    super.key,
    required this.title,
    this.titleAr,
    required this.body,
    this.bodyGradient = ColorManager.gradientLoginSurface,
    this.onClose,
    this.onSkip,
    this.onNext,
    this.showSkip = false,
    this.closeAsset,
  });

  final String title;
  final String? titleAr;
  final Widget body;
  final List<Color> bodyGradient;
  final VoidCallback? onClose;
  final VoidCallback? onSkip;
  final VoidCallback? onNext;
  final bool showSkip;
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
            title: title,
            titleAr: titleAr,
            onClose: onClose ?? () => CourseFlow.goHome(context),
            onHelp: () => openHelp(context),
            onSkip: showSkip ? (onSkip ?? onNext) : null,
            showSkip: showSkip,
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
        ],
      ),
    );
  }
}
