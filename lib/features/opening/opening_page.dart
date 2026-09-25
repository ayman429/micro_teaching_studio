import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/features/course_shell/course_flow.dart';
import 'package:micro_teaching_studio/features/course_shell/widgets/course_scaffold.dart';
import 'package:micro_teaching_studio/features/opening/widgets/opening_actions.dart';
import 'package:micro_teaching_studio/features/opening/widgets/opening_hero_card.dart';
import 'package:micro_teaching_studio/features/opening/widgets/opening_info_card.dart';

class OpeningPage extends StatelessWidget {
  const OpeningPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CourseScaffold(
      title: AppStrings.openingEnglishTitle.tr(),
      showSkip: false,
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
            const OpeningHeroCard(),
            SizedBox(height: AppPadding.p16.h),
            const OpeningInfoCard(),
            SizedBox(height: AppPadding.p16.h),
            OpeningActions(
              onHelp: () => CourseScaffold.openHelp(context),
              onSkip: () => CourseFlow.next(context),
            ),
          ],
        ),
      ),
    );
  }
}

class OpeningView extends OpeningPage {
  const OpeningView({super.key});
}
