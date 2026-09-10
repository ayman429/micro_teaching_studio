import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_teaching_studio/common/resources/app_router.dart';
import 'package:micro_teaching_studio/features/auth/cubit/auth_cubit.dart';
import 'package:micro_teaching_studio/features/auth/cubit/auth_state.dart';
import 'package:micro_teaching_studio/features/course_shell/course_constants.dart';

class CourseStep {
  const CourseStep({
    required this.route,
    required this.index,
    required this.voiceCode,
    this.blocksNext = false,
    this.module,
    this.session,
  });

  final String route;
  final int index;
  final String voiceCode;
  final bool blocksNext;
  final int? module;
  final int? session;
}

class CourseFlow {
  static final List<CourseStep> steps = [
    CourseStep(
      route: AppRouters.helpView,
      index: CourseConstants.helpStepIndex,
      voiceCode: CourseConstants.helpVoiceCode,
    ),
    CourseStep(
      route: AppRouters.loginView,
      index: CourseConstants.loginStepIndex,
      voiceCode: CourseConstants.loginVoiceCode,
      blocksNext: true,
    ),
    CourseStep(
      route: AppRouters.homeView,
      index: CourseConstants.homeStepIndex,
      voiceCode: CourseConstants.homeVoiceCode,
    ),
    CourseStep(
      route: AppRouters.aimsView,
      index: CourseConstants.aimsStepIndex,
      voiceCode: CourseConstants.aimsVoiceCode,
    ),
    CourseStep(
      route: AppRouters.fluencyView,
      index: CourseConstants.fluencyStepIndex,
      voiceCode: CourseConstants.fluencyVoiceCode,
      module: 1,
      session: 1,
    ),
    CourseStep(
      route: AppRouters.phonicsView,
      index: CourseConstants.phonicsStepIndex,
      voiceCode: CourseConstants.phonicsVoiceCode,
      module: 1,
      session: 2,
    ),
    CourseStep(
      route: AppRouters.sessionLocation(2, 1),
      index: CourseConstants.module2Session1StepIndex,
      voiceCode: CourseConstants.module2Session1VoiceCode,
      module: 2,
      session: 1,
    ),
    CourseStep(
      route: AppRouters.sessionLocation(2, 2),
      index: CourseConstants.module2Session2StepIndex,
      voiceCode: CourseConstants.module2Session2VoiceCode,
      module: 2,
      session: 2,
    ),
    CourseStep(
      route: AppRouters.sessionLocation(3, 1),
      index: CourseConstants.module3Session1StepIndex,
      voiceCode: CourseConstants.module3Session1VoiceCode,
      module: 3,
      session: 1,
    ),
    CourseStep(
      route: AppRouters.sessionLocation(3, 2),
      index: CourseConstants.module3Session2StepIndex,
      voiceCode: CourseConstants.module3Session2VoiceCode,
      module: 3,
      session: 2,
    ),
    CourseStep(
      route: AppRouters.sessionLocation(3, 3),
      index: CourseConstants.module3Session3StepIndex,
      voiceCode: CourseConstants.module3Session3VoiceCode,
      module: 3,
      session: 3,
    ),
  ];

  static CourseStep? stepOf(BuildContext context) {
    return stepForLocation(GoRouterState.of(context).matchedLocation);
  }

  static CourseStep? stepForLocation(String location) {
    if (location == AppRouters.signInView) {
      return steps[1];
    }
    for (final step in steps) {
      if (location == step.route) return step;
    }
    return null;
  }

  static CourseStep? stepForSession(int module, int session) {
    for (final step in steps) {
      if (step.module == module && step.session == session) return step;
    }
    return null;
  }

  static bool isSignedIn(BuildContext context) {
    return context.read<AuthCubit>().state.status == AuthStatus.authenticated;
  }

  static bool hasPrevious(BuildContext context) {
    final step = stepOf(context);
    if (step?.route == AppRouters.homeView) return false;
    if (context.canPop()) return true;
    return _indexOf(step) > 0;
  }

  static void next(BuildContext context) {
    final step = stepOf(context);
    if (step == null || step.blocksNext) return;
    if (step.route == AppRouters.helpView && context.canPop()) {
      context.pop();
      return;
    }
    final index = _indexOf(step);
    if (index < 0 || index >= steps.length - 1) return;
    context.go(steps[index + 1].route);
  }

  static void back(BuildContext context) {
    final step = stepOf(context);
    if (step == null) {
      if (context.canPop()) context.pop();
      return;
    }
    if (step.route == AppRouters.homeView) return;
    if (step.route == AppRouters.helpView) {
      if (context.canPop()) context.pop();
      return;
    }
    final index = _indexOf(step);
    if (index <= 0) return;
    context.go(steps[index - 1].route);
  }

  static void goHome(BuildContext context) {
    if (isSignedIn(context)) {
      context.go(AppRouters.homeView);
      return;
    }
    final location = GoRouterState.of(context).matchedLocation;
    if (location == AppRouters.loginView ||
        location == AppRouters.signInView) {
      context.go(AppRouters.helpView);
      return;
    }
    if (context.canPop()) context.pop();
  }

  static void openSession(BuildContext context, int module, int session) {
    final step = stepForSession(module, session);
    if (step == null) return;
    context.go(step.route);
  }

  static int _indexOf(CourseStep? step) {
    if (step == null) return -1;
    return steps.indexWhere((item) => item.route == step.route);
  }
}
