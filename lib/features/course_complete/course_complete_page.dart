import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/common/widgets/default_button_widget.dart';
import 'package:micro_teaching_studio/features/course_shell/course_flow.dart';
import 'package:micro_teaching_studio/features/course_shell/widgets/course_scaffold.dart';
import 'package:micro_teaching_studio/images_urls/assets.dart';

class CourseCompletePage extends StatefulWidget {
  const CourseCompletePage({super.key});

  @override
  State<CourseCompletePage> createState() => _CourseCompletePageState();
}

class CourseCompleteView extends CourseCompletePage {
  const CourseCompleteView({super.key});
}

class _CourseCompletePageState extends State<CourseCompletePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<double> _ring;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.55, curve: Curves.easeOut),
    );
    _scale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.15, 0.75, curve: Curves.easeOutBack),
    );
    _ring = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 1, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CourseScaffold(
      title: AppStrings.courseCompleteTitle.tr(),
      showSkip: false,
      bodyGradient: ColorManager.gradientLoginSurface,
      body: Directionality(
        textDirection: ui.TextDirection.ltr,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final verticalInset = AppPadding.p24.h * 2;
            final minHeight = constraints.maxHeight - verticalInset;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppPadding.p20.w,
                AppPadding.p24.h,
                AppPadding.p20.w,
                AppPadding.p24.h,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: minHeight < 0 ? 0 : minHeight,
                ),
                child: Center(
                  child: FadeTransition(
                    opacity: _fade,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _HeroMark(scale: _scale, ring: _ring),
                        SizedBox(height: AppPadding.p24.h),
                        Text(
                          AppStrings.courseCompleteHeadline.tr(),
                          textAlign: TextAlign.center,
                          style: getExtraBoldStyle(
                            fontSize: FontSize.s32.sp,
                            color: ColorManager.navy,
                            height: 1.15,
                          ),
                        ),
                        SizedBox(height: AppPadding.p12.h),
                        Text(
                          AppStrings.courseCompleteMessage.tr(),
                          textAlign: TextAlign.center,
                          style: getRegularStyle(
                            fontSize: FontSize.s16.sp,
                            color: ColorManager.slate700,
                            height: 1.45,
                          ),
                        ),
                        SizedBox(height: AppPadding.p24.h),
                        SizedBox(
                          width: double.infinity,
                          height: AppSize.submitHeight.h,
                          child: DefaultButtonWidget(
                            onPressed: () => CourseFlow.goHome(context),
                            text: AppStrings.mainMenuAction.tr(),
                            color: ColorManager.navy,
                            textColor: ColorManager.white,
                            radius: AppRadius.r16.r,
                            elevation: 0,
                            verticalPadding: 0,
                            fontSize: FontSize.s16.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HeroMark extends StatelessWidget {
  const _HeroMark({required this.scale, required this.ring});

  final Animation<double> scale;
  final Animation<double> ring;

  @override
  Widget build(BuildContext context) {
    final width = AppSize.s80.w + AppSize.s80.w;
    final height = width + AppSize.s64.h;
    return SizedBox(
      width: width + AppSize.s24.w,
      height: height + AppSize.s16.h,
      child: AnimatedBuilder(
        animation: ring,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: 0.92 + (ring.value * 0.12),
                child: Opacity(
                  opacity: (1 - ring.value) * 0.55,
                  child: Container(
                    width: width,
                    height: height,
                    decoration: BoxDecoration(
                      color: ColorManager.amberSoft,
                      borderRadius: BorderRadius.circular(AppRadius.r28.r),
                    ),
                  ),
                ),
              ),
              child!,
            ],
          );
        },
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1).animate(scale),
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    color: ColorManager.white,
                    borderRadius: BorderRadius.circular(AppRadius.r28.r),
                    border: Border.all(color: ColorManager.amberBorder),
                    boxShadow: [
                      BoxShadow(
                        color: ColorManager.navyGlow,
                        blurRadius: AppSize.s24.r,
                        offset: Offset(0, AppSize.s8.h),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    Assets.assetsImagesAiTwinFull,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return ColoredBox(
                        color: ColorManager.iceBlue,
                        child: Padding(
                          padding: EdgeInsets.all(AppPadding.p20.w),
                          child: SvgPicture.asset(
                            Assets.assetsIconsAiTwin,
                            fit: BoxFit.contain,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  right: AppPadding.p8.w,
                  bottom: AppPadding.p8.h,
                  child: Container(
                    width: AppSize.s36.w,
                    height: AppSize.s36.w,
                    decoration: BoxDecoration(
                      color: ColorManager.progressGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: ColorManager.white, width: 3.w),
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: ColorManager.white,
                      size: AppSize.s20.w,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
