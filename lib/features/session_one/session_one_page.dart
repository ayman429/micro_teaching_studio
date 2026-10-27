import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/app/imports.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/features/course_shell/course_flow.dart';
import 'package:micro_teaching_studio/features/home/cubit/course_progress_cubit.dart';
import 'package:micro_teaching_studio/features/course_shell/widgets/course_scaffold.dart';
import 'package:micro_teaching_studio/features/course_shell/widgets/session_score_line.dart';
import 'package:micro_teaching_studio/features/greetings/cubit/greetings_state.dart';
import 'package:micro_teaching_studio/features/greetings/greetings_script.dart';
import 'package:micro_teaching_studio/features/course_shell/widgets/course_segmented_tabs.dart';
import 'package:micro_teaching_studio/features/greetings/cubit/greetings_cubit.dart';
import 'package:micro_teaching_studio/features/greetings/greetings_page.dart';
import 'package:micro_teaching_studio/features/quiz/cubit/quiz_cubit.dart';
import 'package:micro_teaching_studio/features/quiz/widgets/quiz_card.dart';
import 'package:micro_teaching_studio/features/session_instructions/session_instructions_panel.dart';

class SessionOnePage extends StatefulWidget {
  const SessionOnePage({super.key});

  @override
  State<SessionOnePage> createState() => _SessionOnePageState();
}

class _SessionOnePageState extends State<SessionOnePage> {
  var _generation = 0;

  Future<void> _restudy() async {
    await CourseFlow.prepareRestudy(
      context,
      module: 2,
      session: 1,
      videoAsset: GreetingsScript.plan.videoAsset,
    );
    if (!mounted) return;
    setState(() => _generation++);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      key: ValueKey(_generation),
      providers: [
        BlocProvider(create: (_) => instance<GreetingsCubit>()),
        BlocProvider(create: (_) => instance<QuizCubit>()..start()),
      ],
      child: _SessionOneBody(
        key: ValueKey(_generation),
        onRestudy: _restudy,
      ),
    );
  }
}

class SessionOneView extends SessionOnePage {
  const SessionOneView({super.key});
}

class _SessionOneBody extends StatefulWidget {
  const _SessionOneBody({super.key, required this.onRestudy});

  final Future<void> Function() onRestudy;

  @override
  State<_SessionOneBody> createState() => _SessionOneBodyState();
}

class _SessionOneBodyState extends State<_SessionOneBody> {
  var _tab = 0;
  var _greetingsStarted = false;
  var _switching = false;
  var _routeCurrent = true;
  var _instructionsReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (context.read<CourseProgressCubit>().chatOpened(2, 1)) {
        _instructionsReady = true;
        unawaited(_selectTab(1));
        return;
      }
      if (_tab != 0) return;
      _playInstructions();
    });
  }

  void _playInstructions() {
    setState(() => _instructionsReady = false);
    unawaited(
      playSessionInstructions(
        2,
        1,
        onFinished: () {
          if (!mounted) return;
          setState(() => _instructionsReady = true);
        },
      ),
    );
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
      unawaited(context.read<QuizCubit>().onTabHidden());
    }
  }

  @override
  Widget build(BuildContext context) {
    return CourseScaffold(
      title: AppStrings.session1Greetings.tr(),
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
                    const SessionScoreLine(module: 2, session: 1),
                    CourseSegmentedTabs(
                      labels: [
                        AppStrings.instructionsTab.tr(),
                        AppStrings.greetingsTab.tr(),
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
        module: 2,
        session: 1,
        onContinue: () => unawaited(_selectTab(2)),
        onRestudy: () => unawaited(widget.onRestudy()),
      );
    }
    if (_tab == 2) {
      return QuizCard(onRestudy: () => unawaited(widget.onRestudy()));
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
          module: 2,
          session: 1,
          sessionName: AppStrings.session1Greetings.tr(),
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
    final greetings = context.read<GreetingsCubit>();
    final quiz = context.read<QuizCubit>();
    setState(() => _tab = index);
    try {
      if (previous == 1) {
        await greetings.pauseForOverlay();
      }
      if (previous == 2) {
        await quiz.onTabHidden();
      }
      if (!mounted || _tab != index) return;
      if (index == 1) {
        context.read<CourseProgressCubit>().markChatOpened(2, 1);
        if (!_greetingsStarted) {
          _greetingsStarted = true;
          await greetings.start();
        } else {
          await greetings.resumeFromOverlay();
        }
      }
      if (index == 2) {
        await quiz.onTabShown();
      }
    } finally {
      _switching = false;
    }
  }
}
