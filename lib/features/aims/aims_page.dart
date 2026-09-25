import 'dart:async';
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_teaching_studio/app/imports.dart';
import 'package:micro_teaching_studio/common/resources/app_router.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/common/widgets/default_button_widget.dart';
import 'package:micro_teaching_studio/features/aims/aims_metrics.dart';
import 'package:micro_teaching_studio/features/aims/widgets/aims_hero_card.dart';
import 'package:micro_teaching_studio/features/aims/widgets/aims_objectives_card.dart';
import 'package:micro_teaching_studio/features/course_audio/cubit/course_audio_cubit.dart';
import 'package:micro_teaching_studio/features/course_shell/widgets/course_scaffold.dart';

class AimsPage extends StatefulWidget {
  const AimsPage({super.key});

  @override
  State<AimsPage> createState() => _AimsPageState();
}

class _AimsPageState extends State<AimsPage> {
  @override
  void initState() {
    super.initState();
    unawaited(
      instance<CourseAudioCubit>().playSequence(AimsMetrics.audioSequence()),
    );
  }

  @override
  void dispose() {
    unawaited(instance<CourseAudioCubit>().stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: instance<CourseAudioCubit>(),
      child: CourseScaffold(
        title: AppStrings.aimsEnglishTitle.tr(),
        bodyGradient: ColorManager.gradientAimsSurface,
        showSkip: false,
        body: Directionality(
          textDirection: ui.TextDirection.ltr,
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              AppPadding.p16.w,
              AppPadding.p16.h,
              AppPadding.p16.w,
              AppPadding.p16.h,
            ),
            children: [
              const AimsHeroCard(),
              SizedBox(height: AppPadding.p16.h),
              const AimsObjectivesCard(),
              SizedBox(height: AppPadding.p16.h),
              SizedBox(
                height: AppSize.submitHeight.h,
                width: double.infinity,
                child: DefaultButtonWidget(
                  onPressed: () => _leave(context),
                  color: ColorManager.navy,
                  radius: AppRadius.r16.r,
                  elevation: 0,
                  child: Text(
                    AppStrings.mainMenuAction.tr(),
                    textAlign: TextAlign.center,
                    style: getBoldStyle(
                      fontSize: FontSize.s16.sp,
                      color: ColorManager.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _leave(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRouters.homeView);
  }
}

class AimsView extends AimsPage {
  const AimsView({super.key});
}
