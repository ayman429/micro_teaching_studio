import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isBack;
  final bool isClose;
  final String title;
  final IconData? backIcon; // أيقونة مخصصة للرجوع (اختياري)
  final IconData? closeIcon; // أيقونة مخصصة للإغلاق (اختياري)
  final String? closeImagePath;
  final Widget? leading;
  final Color? backgroundColor;
  // مسار الصورة للإغلاق (اختياري)
  final void Function()? onPressed;
  const CustomAppBar({
    super.key,
    required this.title,
    required this.isBack,
    this.isClose = false,
    this.backIcon,
    this.closeIcon,
    this.closeImagePath,
    this.onPressed,
    this.leading,
    this.backgroundColor, // مسار الصورة الاختياري
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: true,
      leading: isBack
          ? IconButton(
              icon: Icon(backIcon ?? Icons.chevron_left),
              iconSize: 30,
              color: ColorManager.black,
              onPressed: () {
                Navigator.pop(context);
              },
            )
          : leading ?? const SizedBox.shrink(),
      actions: [
        if (isClose)
          IconButton(
            icon: closeImagePath != null
                ? SvgPicture.asset(closeImagePath!,
                    width: 20.w, height: 20.h, fit: BoxFit.cover)
                : Icon(closeIcon ?? Icons.close),
            iconSize: 20,
            color: ColorManager.black,
            onPressed: onPressed,
          ),
      ],
      title: Text(
        title,
        style: TextStyle(
          color: ColorManager.primary,
          fontWeight: FontWeight.w600,
          fontSize: 18.sp,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
