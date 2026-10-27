import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/app/app_functions.dart';
import 'package:micro_teaching_studio/app/imports.dart';
import 'package:micro_teaching_studio/common/resources/assets_manager.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/features/analytics/models/assessment_part_context.dart';
import 'package:micro_teaching_studio/features/course_audio/cubit/course_audio_cubit.dart';
import 'package:micro_teaching_studio/features/course_shell/course_flow.dart';
import 'package:micro_teaching_studio/features/course_shell/widgets/course_scaffold.dart';
import 'package:micro_teaching_studio/features/course_shell/widgets/session_end_bar.dart';
import 'package:micro_teaching_studio/features/course_shell/widgets/session_score_line.dart';
import 'package:micro_teaching_studio/features/course_shell/widgets/course_segmented_tabs.dart';
// import 'package:micro_teaching_studio/features/fluency/widgets/fluency_feedback_card.dart';
import 'package:micro_teaching_studio/features/fluency/widgets/fluency_instructions_card.dart';
import 'package:micro_teaching_studio/features/fluency/widgets/fluency_practice_card.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/cubit/pronunciation_cubit.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/cubit/pronunciation_state.dart';

class FluencyPage extends StatefulWidget {
  const FluencyPage({super.key});

  @override
  State<FluencyPage> createState() => _FluencyPageState();
}

class _FluencyPageState extends State<FluencyPage> {
  int _selectedTab = 0;
  var _generation = 0;
  var _instructionsReady = false;
  var _passageHeard = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _playInstructions();
    });
  }

  void _playInstructions() {
    setState(() => _instructionsReady = false);
    unawaited(
      instance<CourseAudioCubit>().playSequence(
        AudioAssets.fluencyInstructionsSequence(),
        onFinished: () {
          if (!mounted) return;
          setState(() => _instructionsReady = true);
        },
      ),
    );
  }

  Future<void> _restudy() async {
    await CourseFlow.prepareRestudy(context, module: 1, session: 1);
    if (!mounted) return;
    setState(() {
      _generation++;
      _selectedTab = 0;
      _instructionsReady = false;
      _passageHeard = false;
    });
    _playInstructions();
  }

  @override
  void dispose() {
    unawaited(instance<CourseAudioCubit>().stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      key: ValueKey(_generation),
      providers: [
        BlocProvider(
          create: (_) {
            final cubit = instance<PronunciationCubit>();
            unawaited(
              cubit.restore(
                AssessmentPartContext.fluency(
                  referenceText: AppStrings.fluencyPracticePassage.tr(),
                ),
              ),
            );
            return cubit;
          },
        ),
        BlocProvider.value(value: instance<CourseAudioCubit>()),
      ],
      child: BlocListener<PronunciationCubit, PronunciationState>(
        listenWhen: (previous, current) =>
            current.status == PronunciationStatus.failure &&
            current.errorMessage != null,
        listener: (context, state) {
          AppFunctions.showsToast(
            state.errorMessage!.tr(),
            ColorManager.red,
            context,
          );
        },
        child: Builder(
          builder: (context) => CourseScaffold(
          title: AppStrings.fluencyEnglishTitle.tr(),
          bodyGradient: ColorManager.gradientFluencySurface,
          body: ListView(
            padding: EdgeInsets.fromLTRB(
              AppPadding.p16.w,
              AppPadding.p16.h,
              AppPadding.p16.w,
              AppPadding.p16.h,
            ),
            children: [
              const SessionScoreLine(module: 1, session: 1),
              CourseSegmentedTabs(
                labels: [
                  AppStrings.instructionsTab.tr(),
                  AppStrings.practiceTab.tr(),
                ],
                selectedIndex: _selectedTab,
                enabled: [true, _instructionsReady],
                onSelected: (index) => _selectTab(context, index),
              ),
              SizedBox(height: AppPadding.p16.h),
              if (_selectedTab == 0)
                FluencyInstructionsCard(
                  startEnabled: _instructionsReady,
                  onStartPractice: () => _showPractice(context),
                )
              else ...[
                BlocBuilder<PronunciationCubit, PronunciationState>(
                  builder: (context, state) {
                    final terminal = state.locked || state.showNext;
                    return Column(
                      children: [
                        FluencyPracticeCard(
                          onSpeak: () {
                            if (!_passageHeard && !state.isScored) return;
                            context.read<PronunciationCubit>().toggle(
                                  referenceText:
                                      AppStrings.fluencyPracticePassage.tr(),
                                  part: AssessmentPartContext.fluency(
                                    referenceText:
                                        AppStrings.fluencyPracticePassage.tr(),
                                  ),
                                );
                          },
                          onNext: null,
                        ),
                        if (terminal)
                          SessionEndBar(
                            module: 1,
                            session: 1,
                            onRestudy: () => unawaited(_restudy()),
                          ),
                      ],
                    );
                  },
                ),
                // SizedBox(height: AppPadding.p16.h),
                // FluencyFeedbackCard(
                //   onTryAgain: () {},
                //   onContinue: _popIfPossible,
                // ),
              ],
            ],
          ),
        ),
        ),
      ),
    );
  }

  void _selectTab(BuildContext context, int index) {
    if (index > 0 && !_instructionsReady) return;
    setState(() => _selectedTab = index);
    if (index == 1) {
      unawaited(_playListenIfNeeded(context));
      return;
    }
    _playInstructions();
  }

  void _showPractice(BuildContext context) {
    if (!_instructionsReady) return;
    setState(() => _selectedTab = 1);
    unawaited(_playListenIfNeeded(context));
  }

  Future<void> _playListenIfNeeded(BuildContext context) async {
    final cubit = context.read<PronunciationCubit>();
    if (cubit.state.isScored || cubit.state.isRecording || cubit.state.isAssessing) {
      if (mounted) setState(() => _passageHeard = true);
      return;
    }
    setState(() => _passageHeard = false);
    await instance<CourseAudioCubit>().play(
      AudioAssets.fluencyParagraph(),
      onFinished: () {
        if (!mounted) return;
        setState(() => _passageHeard = true);
      },
    );
  }
}

class FluencyView extends FluencyPage {
  const FluencyView({super.key});
}
