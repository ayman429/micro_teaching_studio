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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_playInstructions());
    });
  }

  @override
  void dispose() {
    unawaited(instance<CourseAudioCubit>().stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
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
        child: CourseScaffold(
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
              CourseSegmentedTabs(
                labels: [
                  AppStrings.instructionsTab.tr(),
                  AppStrings.practiceTab.tr(),
                ],
                selectedIndex: _selectedTab,
                onSelected: _selectTab,
              ),
              SizedBox(height: AppPadding.p16.h),
              if (_selectedTab == 0)
                FluencyInstructionsCard(onStartPractice: _showPractice)
              else ...[
                Builder(
                  builder: (context) {
                    return FluencyPracticeCard(
                      onSpeak: () {
                        context.read<PronunciationCubit>().toggle(
                              referenceText:
                                  AppStrings.fluencyPracticePassage.tr(),
                              part: AssessmentPartContext.fluency(
                                referenceText:
                                    AppStrings.fluencyPracticePassage.tr(),
                              ),
                            );
                      },
                      onNext: () => CourseFlow.next(context),
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
    );
  }

  void _selectTab(int index) {
    setState(() => _selectedTab = index);
    if (index == 1) {
      unawaited(_playListenIfNeeded());
      return;
    }
    unawaited(_playInstructions());
  }

  void _showPractice() {
    setState(() => _selectedTab = 1);
    unawaited(_playListenIfNeeded());
  }

  Future<void> _playInstructions() {
    return instance<CourseAudioCubit>().playSequence(
      AudioAssets.fluencyInstructionsSequence(),
    );
  }

  Future<void> _playListenIfNeeded() async {
    final cubit = instance<PronunciationCubit>();
    if (cubit.state.isScored || cubit.state.isRecording || cubit.state.isAssessing) {
      return;
    }
    await instance<CourseAudioCubit>().play(AudioAssets.fluencyParagraph());
  }
}

class FluencyView extends FluencyPage {
  const FluencyView({super.key});
}
