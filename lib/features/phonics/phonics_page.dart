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

  @override
  void dispose() {
    unawaited(instance<CourseAudioCubit>().stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final word = PhonicsWord.catalog[_selectedIndex];
    return MultiBlocProvider(
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
        child: CourseScaffold(
          voiceCode: CourseConstants.phonicsVoiceCode,
          title: AppStrings.phonicsEnglishTitle.tr(),
          currentIndex: CourseConstants.phonicsStepIndex,
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
                        setState(() => _selectedIndex = index);
                        unawaited(
                          context.read<PronunciationCubit>().restore(
                                _partFor(index),
                              ),
                        );
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: AppPadding.p16.h),
              Builder(
                builder: (context) {
                  return PhonicsWordCard(
                    word: word,
                    onSpeak: () {
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
                    onNext: () => _goNext(context),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _goNext(BuildContext context) async {
    if (_selectedIndex < PhonicsWord.catalog.length - 1) {
      final next = _selectedIndex + 1;
      setState(() => _selectedIndex = next);
      if (!context.mounted) return;
      await context.read<PronunciationCubit>().restore(_partFor(next));
      return;
    }
    CourseFlow.next(context);
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
