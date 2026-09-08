import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/features/course_shell/widgets/course_svg_icon.dart';
import 'package:micro_teaching_studio/features/home/models/home_module.dart';
import 'package:micro_teaching_studio/features/home/models/home_session.dart';
import 'package:micro_teaching_studio/features/home/widgets/home_session_chip.dart';

class HomeModuleCard extends StatelessWidget {
  const HomeModuleCard({
    super.key,
    required this.module,
    this.onSessionTap,
  });

  final HomeModule module;
  final ValueChanged<HomeSession>? onSessionTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.r24.r);
    final percent = (module.progress * 100).round().toString();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: radius,
        border: Border.all(color: ColorManager.slate100),
        boxShadow: [
          BoxShadow(
            color: ColorManager.black.withValues(alpha: 0.06),
            blurRadius: AppPadding.p24.r,
            offset: Offset(0, AppPadding.p8.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Padding(
          padding: EdgeInsets.only(
            top: AppPadding.p16.h,
            bottom: AppPadding.p12.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppPadding.p16.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: AppSize.s44.w,
                      height: AppSize.s44.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: module.iconBackground,
                        borderRadius: BorderRadius.circular(AppRadius.r16.r),
                        boxShadow: [
                          BoxShadow(
                            color: ColorManager.black.withValues(alpha: 0.1),
                            blurRadius: AppPadding.p16.r,
                            offset: Offset(0, AppPadding.p4.h),
                          ),
                        ],
                      ),
                      child: CourseSvgIcon(
                        asset: module.iconAsset,
                        size: AppSize.s20.w,
                      ),
                    ),
                    SizedBox(width: AppPadding.p12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Directionality(
                            textDirection: ui.TextDirection.ltr,
                            child: Row(
                              children: [
                                Container(
                                  height: AppSize.s20.h,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppPadding.p8.w,
                                  ),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: ColorManager.slate100,
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.rCapsule.r,
                                    ),
                                  ),
                                  child: Text(
                                    AppStrings.moduleLabel.tr(
                                      namedArgs: {'n': '${module.number}'},
                                    ),
                                    style: getExtraBoldStyle(
                                      fontSize: FontSize.s10.sp,
                                      color: ColorManager.slate800,
                                    ).copyWith(
                                      letterSpacing: AppLetterSpacing.label,
                                    ),
                                  ),
                                ),
                                SizedBox(width: AppPadding.p8.w),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.rCapsule.r,
                                    ),
                                    child: SizedBox(
                                      height: AppSize.s6.h,
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          const ColoredBox(
                                            color: ColorManager.slate100,
                                          ),
                                          FractionallySizedBox(
                                            alignment: Alignment.centerLeft,
                                            widthFactor:
                                                module.progress.clamp(0, 1),
                                            child: const ColoredBox(
                                              color: ColorManager.progressGreen,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: AppPadding.p8.w),
                                Text(
                                  AppStrings.percentLabel.tr(
                                    namedArgs: {'value': percent},
                                  ),
                                  style: getBoldStyle(
                                    fontSize: FontSize.s10.sp,
                                    color: ColorManager.slate,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: AppPadding.p8.h),
                          Text(
                            module.titleKey.tr(),
                            style: getExtraBoldStyle(
                              fontSize: FontSize.s13.sp,
                              color: ColorManager.slate900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppPadding.p12.h),
              Directionality(
                textDirection: ui.TextDirection.ltr,
                child: SizedBox(
                  height: AppSize.s36.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppPadding.p12.w,
                    ),
                    itemCount: module.sessions.length,
                    separatorBuilder: (_, __) =>
                        SizedBox(width: AppPadding.p8.w),
                    itemBuilder: (context, index) {
                      final session = module.sessions[index];
                      return HomeSessionChip(
                        session: session,
                        onTap: onSessionTap == null
                            ? null
                            : () => onSessionTap!(session),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
