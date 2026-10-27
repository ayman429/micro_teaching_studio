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
import 'package:micro_teaching_studio/features/course_shell/course_flow.dart';
import 'package:micro_teaching_studio/features/course_shell/widgets/session_score_line.dart';
import 'package:micro_teaching_studio/features/greetings/cubit/greetings_state.dart';
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
import 'package:micro_teaching_studio/features/session_instructions/session_instructions_panel.dart';

class PresentationSessionPage extends StatefulWidget {
  const PresentationSessionPage({super.key});

  @override
  State<PresentationSessionPage> createState() =>
      _PresentationSessionPageState();
}

class _PresentationSessionPageState extends State<PresentationSessionPage> {
  var _generation = 0;

  Future<void> _restudy() async {
    await CourseFlow.prepareRestudy(
      context,
      module: 3,
      session: 3,
      videoAsset: PresentationScript.plan.videoAsset,
    );
    if (!mounted) return;
    setState(() => _generation++);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      key: ValueKey(_generation),
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
      child: _PresentationSessionBody(
        key: ValueKey(_generation),
        onRestudy: _restudy,
      ),
    );
  }
}

class PresentationSessionView extends PresentationSessionPage {
  const PresentationSessionView({super.key});
}

class _PresentationSessionBody extends StatefulWidget {
  const _PresentationSessionBody({super.key, required this.onRestudy});

  final Future<void> Function() onRestudy;

  @override
  State<_PresentationSessionBody> createState() =>
      _PresentationSessionBodyState();
}

class _PresentationSessionBodyState extends State<_PresentationSessionBody> {
  var _tab = 0;
  var _lessonStarted = false;
  var _instructionsReady = false;

  void _playInstructions() {
    setState(() => _instructionsReady = false);
    unawaited(
      playSessionInstructions(
        3,
        3,
        onFinished: () {
          if (!mounted) return;
          setState(() => _instructionsReady = true);
        },
      ),
    );
  }
  var _switching = false;
  var _routeCurrent = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _tab != 0) return;
      _playInstructions();
    });
  }

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
      body: BlocBuilder<GreetingsCubit, GreetingsState>(
        buildWhen: (previous, current) => previous.phase != current.phase,
        builder: (context, lesson) {
          final lessonDone = lesson.phase == GreetingsPhase.done;
          return Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppPadding.p16.w,
              AppPadding.p16.h,
              AppPadding.p16.w,
              0,
            ),
            child: Column(
              children: [
                const SessionScoreLine(module: 3, session: 3),
                CourseSegmentedTabs(
                  labels: [
                    AppStrings.instructionsTab.tr(),
                    AppStrings.presentationTab.tr(),
                    AppStrings.quizTab.tr(),
                  ],
                  selectedIndex: _tab,
                  enabled: [
                    true,
                    _instructionsReady,
                    _instructionsReady && lessonDone,
                  ],
                  onSelected: _selectTab,
                ),
              ],
            ),
          ),
          Expanded(child: _panel()),
        ],
      );
        },
      ),
    );
  }

  Widget _panel() {
    if (_tab == 1) {
      return GreetingsPage(
        embedded: true,
        module: 3,
        session: 3,
        onContinue: () => unawaited(_selectTab(2)),
        onRestudy: () => unawaited(widget.onRestudy()),
      );
    }
    if (_tab == 2) {
      return PresentationQuizCard(
        onRestudy: () => unawaited(widget.onRestudy()),
      );
    }
    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppPadding.p16.w,
        AppPadding.p16.h,
        AppPadding.p16.w,
        AppPadding.p16.h,
      ),
      children: [
        SessionInstructionsPanel(
          module: 3,
          session: 3,
          sessionName: AppStrings.sessionPresentContinuousPresentation.tr(),
          startEnabled: _instructionsReady,
          onStart: () => unawaited(_selectTab(1)),
        ),
      ],
    );
  }

  Future<void> _selectTab(int index) async {
    if (index > 0 && !_instructionsReady) return;
    final lessonDone =
        context.read<GreetingsCubit>().state.phase == GreetingsPhase.done;
    if (index > 1 && !lessonDone) return;
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
