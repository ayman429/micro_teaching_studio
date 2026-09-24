import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/app/app_functions.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/common/widgets/default_button_widget.dart';
import 'package:micro_teaching_studio/features/quiz/quiz_script.dart';
import 'package:micro_teaching_studio/features/vocabulary/cubit/vocab_quiz_cubit.dart';
import 'package:micro_teaching_studio/features/vocabulary/cubit/vocab_quiz_state.dart';
import 'package:micro_teaching_studio/images_urls/assets.dart';

class VocabQuizCard extends StatefulWidget {
  const VocabQuizCard({super.key});

  @override
  State<VocabQuizCard> createState() => _VocabQuizCardState();
}

class _VocabQuizCardState extends State<VocabQuizCard> {
  late final TextEditingController _magnificent;
  late final TextEditingController _monument;
  var _seeded = false;

  @override
  void initState() {
    super.initState();
    _magnificent = TextEditingController();
    _monument = TextEditingController();
  }

  @override
  void dispose() {
    _magnificent.dispose();
    _monument.dispose();
    super.dispose();
  }

  void _seed(VocabQuizState state) {
    if (_seeded || !state.ready) return;
    _seeded = true;
    _magnificent.text = state.magnificent;
    _monument.text = state.monument;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: BlocListener<VocabQuizCubit, VocabQuizState>(
        listenWhen: (previous, current) => current.notice != previous.notice,
        listener: (context, state) {
          final message = state.noticeMessage;
          if (message == null || message.isEmpty) return;
          AppFunctions.showsToast(message.tr(), ColorManager.red, context);
        },
        child: BlocBuilder<VocabQuizCubit, VocabQuizState>(
          builder: (context, state) {
            _seed(state);
            final locked = !state.ready || state.settled || state.submitting;
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
                      _Blank(
                        index: 1,
                        prompt: AppStrings.vocabQuizQ1.tr(),
                        controller: _magnificent,
                        enabled: !locked,
                        onChanged: context.read<VocabQuizCubit>().setMagnificent,
                      ),
                      SizedBox(height: AppPadding.p16.h),
                      _Blank(
                        index: 2,
                        prompt: AppStrings.vocabQuizQ2.tr(),
                        controller: _monument,
                        enabled: !locked,
                        onChanged: context.read<VocabQuizCubit>().setMonument,
                      ),
                      SizedBox(height: AppPadding.p16.h),
                      Text(
                        '3. ${AppStrings.vocabQuizQ3.tr()}',
                        style: getBoldStyle(
                          fontSize: FontSize.s13.sp,
                          color: ColorManager.slate800,
                          height: 1.45,
                        ),
                      ),
                      SizedBox(height: AppPadding.p8.h),
                      SizedBox(
                        width: double.infinity,
                        height: AppSize.s48.h,
                        child: DefaultButtonWidget(
                          onPressed: locked || state.assessing
                              ? null
                              : () => context.read<VocabQuizCubit>().toggleMic(),
                          text: state.recording
                              ? AppStrings.greetingsStop.tr()
                              : AppStrings.vocabQuizSpeak.tr(),
                          isLoading: state.assessing,
                          isIcon: !state.assessing,
                          svgPath: Assets.assetsIconsSessionMic,
                          iconColor: ColorManager.white,
                          iconSize: AppSize.s16.w,
                          color: state.recording
                              ? ColorManager.red
                              : ColorManager.navy,
                          textColor: ColorManager.white,
                          radius: AppRadius.rCapsule.r,
                          elevation: 0,
                          verticalPadding: 0,
                          fontSize: FontSize.s13.sp,
                          loadingColor: ColorManager.white,
                        ),
                      ),
                      if (state.heard.trim().isNotEmpty) ...[
                        SizedBox(height: AppPadding.p8.h),
                        Text(
                          state.heard,
                          style: getRegularStyle(
                            fontSize: FontSize.s13.sp,
                            color: ColorManager.navy,
                            height: 1.4,
                          ),
                        ),
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
                              ? () => context.read<VocabQuizCubit>().submit()
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
      ),
    );
  }

  String _attempts(VocabQuizState state) {
    final count = '${state.attemptsLeft}';
    if (state.attemptCount == 0) {
      return AppStrings.threeAttemptsOnly.tr(namedArgs: {'count': count});
    }
    return AppStrings.attemptsLeft.tr(namedArgs: {'count': count});
  }
}

class _Blank extends StatelessWidget {
  const _Blank({
    required this.index,
    required this.prompt,
    required this.controller,
    required this.enabled,
    required this.onChanged,
  });

  final int index;
  final String prompt;
  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$index. $prompt',
          style: getBoldStyle(
            fontSize: FontSize.s13.sp,
            color: ColorManager.slate800,
            height: 1.45,
          ),
        ),
        SizedBox(height: AppPadding.p8.h),
        TextField(
          controller: controller,
          enabled: enabled,
          onChanged: onChanged,
          style: getRegularStyle(
            fontSize: FontSize.s13.sp,
            color: ColorManager.slate800,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: ColorManager.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppPadding.p12.w,
              vertical: AppPadding.p12.h,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.r16.r),
              borderSide: const BorderSide(color: ColorManager.slate200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.r16.r),
              borderSide: const BorderSide(color: ColorManager.navy),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.r16.r),
              borderSide: const BorderSide(color: ColorManager.slate200),
            ),
          ),
        ),
      ],
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
      QuizTone.correct => AppStrings.vocabQuizCorrect,
      QuizTone.review => AppStrings.vocabQuizRetry,
      _ => AppStrings.vocabQuizWrong,
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
