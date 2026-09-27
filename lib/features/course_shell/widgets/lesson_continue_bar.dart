import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/common/widgets/default_button_widget.dart';

class LessonContinueBar extends StatefulWidget {
  const LessonContinueBar({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<LessonContinueBar> createState() => _LessonContinueBarState();
}

class _LessonContinueBarState extends State<LessonContinueBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Material(
          color: ColorManager.white,
          elevation: 8,
          shadowColor: ColorManager.navyGlow,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppPadding.p16.w,
                AppPadding.p12.h,
                AppPadding.p16.w,
                AppPadding.p12.h,
              ),
              child: SizedBox(
                width: double.infinity,
                height: AppSize.s48.h,
                child: DefaultButtonWidget(
                  onPressed: widget.onPressed,
                  text: AppStrings.next.tr(),
                  color: ColorManager.navy,
                  textColor: ColorManager.white,
                  radius: AppRadius.rCapsule.r,
                  elevation: 0,
                  verticalPadding: 0,
                  fontSize: FontSize.s14.sp,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
