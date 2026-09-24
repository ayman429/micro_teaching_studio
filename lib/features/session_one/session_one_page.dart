import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/app/imports.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/features/course_shell/widgets/course_scaffold.dart';
import 'package:micro_teaching_studio/features/course_shell/widgets/course_segmented_tabs.dart';
import 'package:micro_teaching_studio/features/greetings/cubit/greetings_cubit.dart';
import 'package:micro_teaching_studio/features/greetings/greetings_page.dart';
import 'package:micro_teaching_studio/features/quiz/cubit/quiz_cubit.dart';
import 'package:micro_teaching_studio/features/quiz/widgets/quiz_card.dart';

class SessionOnePage extends StatelessWidget {
  const SessionOnePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => instance<GreetingsCubit>()),
        BlocProvider(create: (_) => instance<QuizCubit>()..start()),
      ],
      child: const _SessionOneBody(),
    );
  }
}

class SessionOneView extends SessionOnePage {
  const SessionOneView({super.key});
}

class _SessionOneBody extends StatefulWidget {
  const _SessionOneBody();

  @override
  State<_SessionOneBody> createState() => _SessionOneBodyState();
}

class _SessionOneBodyState extends State<_SessionOneBody> {
  var _tab = 0;
  var _greetingsStarted = false;
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
      unawaited(context.read<QuizCubit>().onTabHidden());
    }
  }

  @override
  Widget build(BuildContext context) {
    return CourseScaffold(
      title: AppStrings.session1Greetings.tr(),
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
                AppStrings.greetingsTab.tr(),
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
    if (_tab == 2) return const QuizCard();
    return const SizedBox.expand();
  }

  Future<void> _selectTab(int index) async {
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
