import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/app/imports.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/features/analytics/data/analytics_repository.dart';
import 'package:micro_teaching_studio/features/course_audio/cubit/course_audio_cubit.dart';
import 'package:micro_teaching_studio/features/course_shell/widgets/course_scaffold.dart';
import 'package:micro_teaching_studio/features/course_shell/widgets/course_segmented_tabs.dart';
import 'package:micro_teaching_studio/features/greetings/cubit/greetings_cubit.dart';
import 'package:micro_teaching_studio/features/greetings/greetings_page.dart';
import 'package:micro_teaching_studio/features/home/cubit/course_progress_cubit.dart';
import 'package:micro_teaching_studio/features/presentation/cubit/presentation_quiz_cubit.dart';
import 'package:micro_teaching_studio/features/presentation/presentation_script.dart';
import 'package:micro_teaching_studio/features/presentation/widgets/presentation_quiz_card.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/data/pronunciation_engine.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/data/speech_config_repository.dart';

class PresentationSessionPage extends StatelessWidget {
  const PresentationSessionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => GreetingsCubit(
            instance<SpeechConfigRepository>(),
            instance<PronunciationEngine>(),
            instance<AnalyticsRepository>(),
            instance<CourseProgressCubit>(),
            instance<CourseAudioCubit>(),
            plan: PresentationScript.plan,
          ),
        ),
        BlocProvider(
          create: (_) => PresentationQuizCubit(
            instance<AnalyticsRepository>(),
            instance<CourseProgressCubit>(),
            instance<CourseAudioCubit>(),
          )..start(),
        ),
      ],
      child: const _PresentationSessionBody(),
    );
  }
}

class PresentationSessionView extends PresentationSessionPage {
  const PresentationSessionView({super.key});
}

class _PresentationSessionBody extends StatefulWidget {
  const _PresentationSessionBody();

  @override
  State<_PresentationSessionBody> createState() =>
      _PresentationSessionBodyState();
}

class _PresentationSessionBodyState extends State<_PresentationSessionBody> {
  var _tab = 0;
  var _lessonStarted = false;
  var _switching = false;
  var _routeCurrent = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final current = ModalRoute.of(context)?.isCurrent ?? true;
    if (current == _routeCurrent) return;
    _routeCurrent = current;
    if (current) return;
    if (_tab == 1) {
      unawaited(context.read<GreetingsCubit>().pauseForOverlay());
    }
    if (_tab == 2) {
      unawaited(context.read<PresentationQuizCubit>().onTabHidden());
    }
  }

  @override
  Widget build(BuildContext context) {
    return CourseScaffold(
      title: AppStrings.sessionPresentContinuousPresentation.tr(),
      showSkip: false,
      bodyGradient: ColorManager.gradientFluencySurface,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppPadding.p16.w,
              AppPadding.p16.h,
              AppPadding.p16.w,
              0,
            ),
            child: CourseSegmentedTabs(
              labels: [
                AppStrings.instructionsTab.tr(),
                AppStrings.presentationTab.tr(),
                AppStrings.quizTab.tr(),
              ],
              selectedIndex: _tab,
              onSelected: _selectTab,
            ),
          ),
          Expanded(child: _panel()),
        ],
      ),
    );
  }

  Widget _panel() {
    if (_tab == 1) return const GreetingsPage(embedded: true);
    if (_tab == 2) return const PresentationQuizCard();
    return const SizedBox.expand();
  }

  Future<void> _selectTab(int index) async {
    if (_switching || index == _tab || !mounted) return;
    _switching = true;
    final previous = _tab;
    final lesson = context.read<GreetingsCubit>();
    final quiz = context.read<PresentationQuizCubit>();
    setState(() => _tab = index);
    try {
      if (previous == 1) await lesson.pauseForOverlay();
      if (previous == 2) await quiz.onTabHidden();
      if (!mounted || _tab != index) return;
      if (index == 1) {
        if (!_lessonStarted) {
          _lessonStarted = true;
          await lesson.start();
        } else {
          await lesson.resumeFromOverlay();
        }
      }
      if (index == 2) await quiz.onTabShown();
    } finally {
      _switching = false;
    }
  }
}
