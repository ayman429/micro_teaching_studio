import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/common/widgets/default_button_widget.dart';
import 'package:micro_teaching_studio/features/quiz/cubit/quiz_cubit.dart';
import 'package:micro_teaching_studio/features/quiz/cubit/quiz_state.dart';
import 'package:micro_teaching_studio/features/quiz/quiz_script.dart';
import 'package:micro_teaching_studio/images_urls/assets.dart';

class QuizCard extends StatelessWidget {
  const QuizCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: BlocBuilder<QuizCubit, QuizState>(
        builder: (context, state) {
          return ListView(
            padding: EdgeInsets.fromLTRB(
              AppPadding.p16.w,
              AppPadding.p16.h,
              AppPadding.p16.w,
              AppPadding.p16.h,
            ),
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppPadding.p20.w),
                decoration: BoxDecoration(
                  color: ColorManager.white,
                  borderRadius: BorderRadius.circular(AppRadius.r24.r),
                  border: Border.all(color: ColorManager.slate100),
                  boxShadow: [
                    BoxShadow(
                      color: ColorManager.black.withValues(alpha: 0.05),
                      blurRadius: AppPadding.p4.r,
                      offset: Offset(0, 1.h),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ClipOval(
                          child: Image.asset(
                            Assets.assetsImagesAiTwinHead,
                            width: AppSize.s40.w,
                            height: AppSize.s40.w,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: AppPadding.p8.w),
                        Text(
                          AppStrings.aiTwinTitle.tr(),
                          style: getBoldStyle(
                            fontSize: FontSize.s13.sp,
                            color: ColorManager.navy,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppPadding.p16.h),
                    Text(
                      AppStrings.quizPrompt.tr(),
                      style: getBoldStyle(
                        fontSize: FontSize.s14.sp,
                        color: ColorManager.slate800,
                        height: 1.45,
                      ),
                    ),
                    SizedBox(height: AppPadding.p16.h),
                    for (var index = 0;
                        index < QuizScript.statements.length;
                        index++) ...[
                      _StatementTile(
                        index: index,
                        selected: state.selections[index],
                        enabled:
                            state.ready && !state.settled && !state.submitting,
                        onSelected: (value) =>
                            context.read<QuizCubit>().select(index, value),
                      ),
                      if (index < QuizScript.statements.length - 1)
                        SizedBox(height: AppPadding.p12.h),
                    ],
                    if (state.tone != QuizTone.none) ...[
                      SizedBox(height: AppPadding.p16.h),
                      _FeedbackBanner(tone: state.tone),
                    ],
                    if (!state.settled) ...[
                      SizedBox(height: AppPadding.p16.h),
                      Text(
                        _attempts(state),
                        style: getRegularStyle(
                          fontSize: FontSize.s11.sp,
                          color: ColorManager.slate,
                        ),
                      ),
                      SizedBox(height: AppPadding.p12.h),
                    ] else
                      SizedBox(height: AppPadding.p16.h),
                    SizedBox(
                      width: double.infinity,
                      height: AppSize.s48.h,
                      child: DefaultButtonWidget(
                        onPressed: state.canSubmit
                            ? () => context.read<QuizCubit>().submit()
                            : null,
                        text: AppStrings.quizSubmit.tr(),
                        isLoading: state.submitting,
                        color: ColorManager.navy,
                        textColor: ColorManager.white,
                        radius: AppRadius.rCapsule.r,
                        elevation: 0,
                        verticalPadding: 0,
                        fontSize: FontSize.s13.sp,
                        loadingColor: ColorManager.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _attempts(QuizState state) {
    final count = '${state.attemptsLeft}';
    if (state.attemptCount == 0) {
      return AppStrings.threeAttemptsOnly.tr(namedArgs: {'count': count});
    }
    return AppStrings.attemptsLeft.tr(namedArgs: {'count': count});
  }
}

class _StatementTile extends StatelessWidget {
  const _StatementTile({
    required this.index,
    required this.selected,
    required this.enabled,
    required this.onSelected,
  });

  final int index;
  final bool? selected;
  final bool enabled;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final statement = QuizScript.statements[index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${index + 1}. ${statement.textKey.tr()}',
          style: getRegularStyle(
            fontSize: FontSize.s13.sp,
            color: ColorManager.slate800,
            height: 1.45,
          ),
        ),
        SizedBox(height: AppPadding.p8.h),
        Row(
          children: [
            _ChoiceChip(
              label: AppStrings.quizTrue.tr(),
              chosen: selected == true,
              enabled: enabled,
              onTap: () => onSelected(true),
            ),
            SizedBox(width: AppPadding.p8.w),
            _ChoiceChip(
              label: AppStrings.quizFalse.tr(),
              chosen: selected == false,
              enabled: enabled,
              onTap: () => onSelected(false),
            ),
          ],
        ),
      ],
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.chosen,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool chosen;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: chosen ? ColorManager.navy : ColorManager.white,
      borderRadius: BorderRadius.circular(AppRadius.rCapsule.r),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppRadius.rCapsule.r),
        child: Container(
          height: AppSize.s36.h,
          padding: EdgeInsets.symmetric(horizontal: AppPadding.p16.w),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.rCapsule.r),
            border: Border.all(
              color: chosen ? ColorManager.navy : ColorManager.slate200,
            ),
          ),
          child: Text(
            label,
            style: getBoldStyle(
              fontSize: FontSize.s12.sp,
              color: chosen ? ColorManager.white : ColorManager.slate800,
            ),
          ),
        ),
      ),
    );
  }
}

class _FeedbackBanner extends StatelessWidget {
  const _FeedbackBanner({required this.tone});

  final QuizTone tone;

  @override
  Widget build(BuildContext context) {
    final correct = tone == QuizTone.correct;
    final review = tone == QuizTone.review;
    final background = correct ? ColorManager.mintSoft : ColorManager.roseSoft;
    final border = correct
        ? ColorManager.mintBorder
        : review
            ? ColorManager.roseDeep
            : ColorManager.roseBorder;
    final foreground = correct ? ColorManager.emerald : ColorManager.roseDeep;
    final key = switch (tone) {
      QuizTone.correct => AppStrings.quizFeedbackCorrect,
      QuizTone.review => AppStrings.quizFeedbackRetry,
      _ => AppStrings.quizFeedbackWrong,
    };
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppPadding.p12.w),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.r16.r),
        border: Border.all(color: border),
      ),
      child: Text(
        key.tr(),
        style: getRegularStyle(
          fontSize: FontSize.s13.sp,
          color: foreground,
          height: 1.45,
        ),
      ),
    );
  }
}
