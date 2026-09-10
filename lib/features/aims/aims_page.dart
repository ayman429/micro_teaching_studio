import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_teaching_studio/common/resources/app_router.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/common/widgets/default_button_widget.dart';
import 'package:micro_teaching_studio/features/aims/aims_metrics.dart';
import 'package:micro_teaching_studio/features/aims/widgets/aims_hero_card.dart';
import 'package:micro_teaching_studio/features/aims/widgets/aims_stat_tile.dart';
import 'package:micro_teaching_studio/features/course_shell/course_constants.dart';
import 'package:micro_teaching_studio/features/course_shell/course_flow.dart';
import 'package:micro_teaching_studio/features/course_shell/widgets/course_scaffold.dart';

class AimsPage extends StatelessWidget {
  const AimsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CourseScaffold(
      voiceCode: CourseConstants.aimsVoiceCode,
      title: AppStrings.aimsEnglishTitle.tr(),
      titleAr: AppStrings.aimsArabicTitle.tr(),
      currentIndex: CourseConstants.aimsStepIndex,
      bodyGradient: ColorManager.gradientAimsSurface,
      onBack: () => CourseFlow.back(context),
      onNext: () => CourseFlow.next(context),
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
            Row(
              children: [
                for (var i = 0; i < AimsMetrics.stats.length; i++) ...[
                  if (i > 0) SizedBox(width: AppPadding.p8.w),
                  Expanded(child: AimsStatTile(stat: AimsMetrics.stats[i])),
                ],
              ],
            ),
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
