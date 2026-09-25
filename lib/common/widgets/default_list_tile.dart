import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DefaultListTile extends StatefulWidget {
  final String iconPath;
  final String text;
  final String actionButtonText;
  final void Function()? actionButtonOnPressed;
  final void Function()? onTap;
  final TextStyle? textStyle;
  final double? actionIconSize;
  final bool withUnderLine;
  final bool withTrailing;
  final Color? tileColor;
  final Color? itemsColor;
  final bool fromNetwork;
  final bool isLoading;

  const DefaultListTile(
      {super.key,
      required this.iconPath,
      required this.text,
      this.actionButtonText = '',
      this.actionButtonOnPressed,
      this.textStyle,
      this.onTap,
      this.actionIconSize,
      this.withUnderLine = false,
      this.withTrailing = true,
      this.tileColor,
      this.fromNetwork = false,
      this.itemsColor,
      this.isLoading = false});

  @override
  State<DefaultListTile> createState() => _DefaultListTileState();
}

class _DefaultListTileState extends State<DefaultListTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
      onTap: widget.onTap,
      tileColor: widget.tileColor,
      leading: widget.fromNetwork
          ? Image.network(
              widget.iconPath,
              height: 20.h,
              width: 20.w,
              errorBuilder: (context, error, stackTrace) => CircleAvatar(
                backgroundColor: ColorManager.green.withOpacity(.3),
                radius: 15.sp,
              ),
            )
          : SvgPicture.asset(
              widget.iconPath,
              height: 20.w,
              width: 20.w,
              color: widget.itemsColor ?? ColorManager.greyText,
            ),
      minLeadingWidth: 20.w,
      title: Text(
        widget.text,
        style: widget.textStyle ??
            getSemiBoldStyle(
                fontSize: 13.sp,
                color: widget.itemsColor ?? ColorManager.textColor,
                height: 2.h),
      ),
      trailing: _getTrailingWidget(),
    );
  }

  _getTrailingWidget() {
    if (widget.isLoading) {
      return SizedBox(
          height: 20.w,
          width: 20.w,
          child: Center(
              child: CircularProgressIndicator(
            color: widget.itemsColor ?? ColorManager.primary,
          )));
    }
    if (!widget.withTrailing) {
      return null;
    } else if (widget.actionButtonText.isNotEmpty) {
      return TextButton(
          style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 5.h),
              textStyle: TextStyle(
                  decoration:
                      widget.withUnderLine ? TextDecoration.underline : null),
              minimumSize: const Size(0, 0)),
          onPressed: widget.actionButtonOnPressed,
          child: Text(
            widget.actionButtonText,
            style: getBoldStyle(
                fontSize: 15.sp, color: ColorManager.primary, height: 1.5.h),
          ));
    } else {
      return Icon(
        Icons.arrow_forward_ios_outlined,
        color: widget.itemsColor ?? ColorManager.textColor,
        size: widget.actionIconSize ?? 15.r,
      );
    }
  }
}
