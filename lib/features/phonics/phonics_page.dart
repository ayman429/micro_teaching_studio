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
import 'package:micro_teaching_studio/features/course_shell/course_constants.dart';
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
  Widget build(BuildContext context) {
    final word = PhonicsWord.catalog[_selectedIndex];
    return BlocProvider(
      create: (_) => instance<PronunciationCubit>(),
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
          onClose: _popIfPossible,
          onHelp: _popIfPossible,
          onSkip: _popIfPossible,
          onBack: _popIfPossible,
          onNext: _popIfPossible,
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
                        context.read<PronunciationCubit>().resetScore();
                        setState(() => _selectedIndex = index);
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
                          );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _popIfPossible() {
    if (context.canPop()) context.pop();
  }
}

class PhonicsView extends PhonicsPage {
  const PhonicsView({super.key});
}
