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
import 'package:micro_teaching_studio/features/home/cubit/course_progress_cubit.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/data/pronunciation_engine.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/data/speech_config_repository.dart';
import 'package:micro_teaching_studio/features/vocabulary/cubit/vocab_cubit.dart';
import 'package:micro_teaching_studio/features/vocabulary/cubit/vocab_quiz_cubit.dart';
import 'package:micro_teaching_studio/features/vocabulary/vocab_page.dart';
import 'package:micro_teaching_studio/features/vocabulary/widgets/vocab_quiz_card.dart';

class SessionThreePage extends StatelessWidget {
  const SessionThreePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => VocabCubit(
            instance<SpeechConfigRepository>(),
            instance<PronunciationEngine>(),
            instance<AnalyticsRepository>(),
            instance<CourseProgressCubit>(),
            instance<CourseAudioCubit>(),
          ),
        ),
        BlocProvider(
          create: (_) => VocabQuizCubit(
            instance<SpeechConfigRepository>(),
            instance<PronunciationEngine>(),
            instance<AnalyticsRepository>(),
            instance<CourseProgressCubit>(),
            instance<CourseAudioCubit>(),
          )..start(),
        ),
      ],
      child: const _SessionThreeBody(),
    );
  }
}

class SessionThreeView extends SessionThreePage {
  const SessionThreeView({super.key});
}

class _SessionThreeBody extends StatefulWidget {
  const _SessionThreeBody();

  @override
  State<_SessionThreeBody> createState() => _SessionThreeBodyState();
}

class _SessionThreeBodyState extends State<_SessionThreeBody> {
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
      unawaited(context.read<VocabCubit>().pauseForOverlay());
    }
    if (_tab == 2) {
      unawaited(context.read<VocabQuizCubit>().onTabHidden());
    }
  }

  @override
  Widget build(BuildContext context) {
    return CourseScaffold(
      title: AppStrings.sessionVocabPresentation.tr(),
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
                AppStrings.vocabularyTab.tr(),
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
    if (_tab == 1) return const VocabPage();
    if (_tab == 2) return const VocabQuizCard();
    return const SizedBox.expand();
  }

  Future<void> _selectTab(int index) async {
    if (_switching || index == _tab || !mounted) return;
    _switching = true;
    final previous = _tab;
    final lesson = context.read<VocabCubit>();
    final quiz = context.read<VocabQuizCubit>();
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
