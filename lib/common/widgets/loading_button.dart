import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';

class LoadingButton extends StatelessWidget {
  const LoadingButton({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return LoadingAnimationWidget.staggeredDotsWave(
      color: color ?? ColorManager.primary,
      size: 50.sp,
    );
  }
}
