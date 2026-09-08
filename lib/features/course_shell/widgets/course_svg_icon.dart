import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';

class CourseSvgIcon extends StatelessWidget {
  const CourseSvgIcon({
    super.key,
    required this.asset,
    required this.size,
  });

  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.asset(
        asset,
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}

class CourseCircleIconButton extends StatelessWidget {
  const CourseCircleIconButton({
    super.key,
    required this.asset,
    required this.size,
    required this.iconSize,
    this.backgroundColor,
    this.borderColor,
    this.onPressed,
  });

  final String asset;
  final double size;
  final double iconSize;
  final Color? backgroundColor;
  final Color? borderColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppDuration.short,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? ColorManager.transparent,
        border: borderColor == null
            ? null
            : Border.all(color: borderColor!),
      ),
      child: Material(
        color: ColorManager.transparent,
        type: MaterialType.transparency,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Center(
            child: CourseSvgIcon(asset: asset, size: iconSize),
          ),
        ),
      ),
    );
  }
}
