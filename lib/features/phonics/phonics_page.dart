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
import 'package:micro_teaching_studio/features/session_instructions/session_instructions_panel.dart';
import 'package:micro_teaching_studio/features/phonics/models/phonics_word.dart';
import 'package:micro_teaching_studio/features/phonics/widgets/phonics_banner.dart';
import 'package:micro_teaching_studio/features/phonics/widgets/phonics_word_card.dart';
import 'package:micro_teaching_studio/features/phonics/widgets/phonics_word_chip.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/cubit/pronunciation_cubit.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/cubit/pronunciation_state.dart';

class PhonicsPage extends StatefulWidget {
  const PhonicsPage({super.key});

  @override
  State<PhonicsPage> createState() => _PhonicsPageState();
}

class _PhonicsPageState extends State<PhonicsPage> {
  int _selectedIndex = 0;
  int _tab = 0;
  var _generation = 0;
  var _instructionsReady = false;
  var _clipReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _tab != 0) return;
      _playInstructions();
    });
  }

  void _playInstructions() {
    setState(() => _instructionsReady = false);
    unawaited(
      playSessionInstructions(
        1,
        2,
        onFinished: () {
          if (!mounted) return;
          setState(() => _instructionsReady = true);
        },
      ),
    );
  }

  Future<void> _restudy() async {
    await CourseFlow.prepareRestudy(context, module: 1, session: 2);
    if (!mounted) return;
    setState(() {
      _generation++;
      _tab = 0;
      _selectedIndex = 0;
      _instructionsReady = false;
      _clipReady = false;
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
    final word = PhonicsWord.catalog[_selectedIndex];
    return MultiBlocProvider(
      key: ValueKey(_generation),
      providers: [
        BlocProvider(
          create: (_) {
            final cubit = instance<PronunciationCubit>();
            unawaited(cubit.restore(_partFor(0)));
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
          builder: (context) {
            return CourseScaffold(
              title: AppStrings.phonicsEnglishTitle.tr(),
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
                    child: Column(
                      children: [
                        const SessionScoreLine(module: 1, session: 2),
                        CourseSegmentedTabs(
                          labels: [
                            AppStrings.instructionsTab.tr(),
                            AppStrings.practiceTab.tr(),
                          ],
                          selectedIndex: _tab,
                          enabled: [true, _instructionsReady],
                          onSelected: (index) => _selectTab(context, index),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(
                        AppPadding.p16.w,
                        AppPadding.p16.h,
                        AppPadding.p16.w,
                        AppPadding.p16.h,
                      ),
                      children: [
                        if (_tab == 0)
                          SessionInstructionsPanel(
                            module: 1,
                            session: 2,
                            sessionName: AppStrings.phonicsEnglishTitle.tr(),
                            startEnabled: _instructionsReady,
                            onStart: () => _selectTab(context, 1),
                          )
                        else ...[
                          const PhonicsBanner(),
                          SizedBox(height: AppPadding.p16.h),
                          SizedBox(
                            height: AppSize.s40.h,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: PhonicsWord.catalog.length,
                              separatorBuilder: (_, __) =>
                                  SizedBox(width: AppPadding.p8.w),
                              itemBuilder: (context, index) {
                                return PhonicsWordChip(
                                  word: PhonicsWord.catalog[index],
                                  isSelected: index == _selectedIndex,
                                  onTap: () {
                                    if (index > _selectedIndex) return;
                                    setState(() => _selectedIndex = index);
                                    unawaited(
                                      _restoreAndListen(
                                        context.read<PronunciationCubit>(),
                                        index,
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          SizedBox(height: AppPadding.p16.h),
                          BlocBuilder<PronunciationCubit, PronunciationState>(
                            builder: (context, state) {
                              final last = _selectedIndex >=
                                  PhonicsWord.catalog.length - 1;
                              final terminal = state.locked || state.showNext;
                              return Column(
                                children: [
                                  PhonicsWordCard(
                                    word: word,
                                    onSpeak: () {
                                      if (!_clipReady && !state.isScored) {
                                        return;
                                      }
                                      context.read<PronunciationCubit>().toggle(
                                            referenceText: word.wordKey.tr(),
                                            enableProsody: false,
                                            part: AssessmentPartContext.phonics(
                                              word: word,
                                              referenceText: word.wordKey.tr(),
                                              referenceIpa: word.ipaKey.tr(),
                                            ),
                                          );
                                    },
                                    onNext: last || !terminal
                                        ? null
                                        : () => _goNext(context),
                                  ),
                                  if (last && terminal)
                                    SessionEndBar(
                                      module: 1,
                                      session: 2,
                                      onRestudy: () => unawaited(_restudy()),
                                    ),
                                ],
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _selectTab(BuildContext context, int index) {
    if (index > 0 && !_instructionsReady) return;
    if (index == _tab) return;
    setState(() => _tab = index);
    if (index == 0) return;
    unawaited(
      _restoreAndListen(
        context.read<PronunciationCubit>(),
        _selectedIndex,
      ),
    );
  }

  Future<void> _goNext(BuildContext context) async {
    if (_selectedIndex < PhonicsWord.catalog.length - 1) {
      final next = _selectedIndex + 1;
      setState(() => _selectedIndex = next);
      if (!context.mounted) return;
      await _restoreAndListen(
        context.read<PronunciationCubit>(),
        next,
      );
      return;
    }
  }

  Future<void> _restoreAndListen(PronunciationCubit cubit, int index) async {
    await cubit.restore(_partFor(index));
    if (cubit.state.isScored ||
        cubit.state.isRecording ||
        cubit.state.isAssessing) {
      if (mounted) setState(() => _clipReady = true);
      return;
    }
    final word = PhonicsWord.catalog[index];
    if (mounted) setState(() => _clipReady = false);
    await instance<CourseAudioCubit>().play(
      AudioAssets.phonicsClip(word.wordKey.tr()),
      onFinished: () {
        if (!mounted) return;
        setState(() => _clipReady = true);
      },
    );
  }

  AssessmentPartContext _partFor(int index) {
    final word = PhonicsWord.catalog[index];
    return AssessmentPartContext.phonics(
      word: word,
      referenceText: word.wordKey.tr(),
      referenceIpa: word.ipaKey.tr(),
    );
  }
}

class PhonicsView extends PhonicsPage {
  const PhonicsView({super.key});
}
