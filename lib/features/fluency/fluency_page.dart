import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_teaching_studio/app/app_functions.dart';
import 'package:micro_teaching_studio/app/imports.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/features/analytics/models/assessment_part_context.dart';
import 'package:micro_teaching_studio/features/course_audio/cubit/course_audio_cubit.dart';
import 'package:micro_teaching_studio/features/course_shell/course_constants.dart';
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
          voiceCode: CourseConstants.fluencyVoiceCode,
          title: AppStrings.fluencyEnglishTitle.tr(),
          currentIndex: CourseConstants.fluencyStepIndex,
          bodyGradient: ColorManager.gradientFluencySurface,
          onBack: () => CourseFlow.back(context),
          onNext: () => CourseFlow.next(context),
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
    if (index != 1) {
      unawaited(instance<CourseAudioCubit>().stop());
    }
    setState(() => _selectedTab = index);
  }

  void _showPractice() {
    setState(() => _selectedTab = 1);
  }

  void _popIfPossible() {
    if (context.canPop()) context.pop();
  }
}

class FluencyView extends FluencyPage {
  const FluencyView({super.key});
}
