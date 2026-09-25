import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DefaultAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String text;
  final bool withLeading;
  final Color? backgroundColor;
  final Color? titleColor;
  final double? titleFontSize;
  final PreferredSizeWidget? bottom;
  final double? height;
  final bool centerTitle;
  const DefaultAppBar(
      {super.key,
      required this.text,
      this.withLeading = true,
      this.backgroundColor,
      this.titleColor,
      this.bottom,
      this.height,
      this.titleFontSize,
      this.centerTitle = false});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: IconThemeData(
          color: titleColor ?? ColorManager.blackText, size: 20.r),
      backgroundColor: backgroundColor,
      centerTitle: centerTitle,
      title: Text(
        text,
        style: getBoldStyle(
            fontSize: titleFontSize ?? 18.sp,
            color: titleColor ?? ColorManager.black),
      ),
      leading: withLeading ? null : const SizedBox.shrink(),
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height ?? 50.h);
}
