// ignore_for_file: deprecated_member_use

import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DefaultRadioButton extends StatefulWidget {
  final Color? borderColor;
  final Color? fillColor;
  final double? fillRadios;
  final String title;
  final TextStyle? titleStyle;
  final String iconPath;
  final Color? iconColor;
  final Color? containerBorderColor;
  final double? containerBorderRadius;
  final Color? backgroundColor;
  final Widget? titleWidget;
  final void Function()? onTap;
  final void Function()? iconOnTap;
  final bool selected;
  final bool moveToEnd;
  final bool moveIconToStart;
  final bool withMargin;
  final bool isExpanded;
  final double elevation;
  final MainAxisAlignment? radioButtonMainAxisAlignment;
  const DefaultRadioButton(
      {super.key,
      this.borderColor,
      this.fillColor,
      this.fillRadios,
      this.title = '',
      this.titleStyle,
      this.iconPath = '',
      this.titleWidget,
      this.iconColor,
      this.onTap,
      required this.selected,
      this.iconOnTap,
      this.containerBorderColor,
      this.moveToEnd = false,
      this.withMargin = false,
      this.moveIconToStart = false,
      this.isExpanded = true,
      this.backgroundColor,
      this.elevation = 0,
      this.radioButtonMainAxisAlignment,
      this.containerBorderRadius});

  @override
  State<DefaultRadioButton> createState() => _DefaultRadioButtonState();
}

class _DefaultRadioButtonState extends State<DefaultRadioButton> {
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: widget.elevation,
      color: ColorManager.white,
      borderRadius: BorderRadius.circular(10.r),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(widget.containerBorderRadius ?? 10.sp),
        overlayColor:
            MaterialStatePropertyAll(ColorManager.lightPrimary.withOpacity(.2)),
        onTap: widget.onTap,
        child: Container(
          margin: widget.withMargin
              ? EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w)
              : null,
          padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 10.w),
          decoration: BoxDecoration(
              color: widget.backgroundColor,
              border: widget.containerBorderColor != null
                  ? Border.all(color: widget.containerBorderColor!)
                  : null,
              borderRadius:
                  BorderRadius.circular(widget.containerBorderRadius ?? 10.sp)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!widget.moveToEnd) _radioButton(),
              if (!widget.moveToEnd)
                SizedBox(
                  width: 10.w,
                ),
              if (widget.iconPath.isNotEmpty && widget.moveIconToStart) _icon(),
              if (widget.iconPath.isNotEmpty && widget.moveIconToStart)
                SizedBox(
                  width: 10.w,
                ),
              if (widget.title.isNotEmpty)
                widget.isExpanded
                    ? Expanded(
                        child: Text(
                        widget.title,
                        style: widget.titleStyle,
                      ))
                    : Flexible(
                        child: Text(
                        widget.title,
                        style: widget.titleStyle,
                      )),
              if (widget.titleWidget != null) widget.titleWidget!,
              if (widget.iconPath.isNotEmpty && !widget.moveIconToStart)
                _icon(),
              if (widget.moveToEnd)
                SizedBox(
                  width: 10.w,
                ),
              if (widget.moveToEnd) _radioButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _icon() {
    return InkWell(
        onTap: widget.iconOnTap,
        child: widget.iconPath.endsWith('.svg')
            ? SvgPicture.asset(
                widget.iconPath,
                width: 60.w,
                height: 60.h,
                color: widget.iconColor,
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(15.r),
                child: Image.asset(
                  widget.iconPath,
                  width: 60.w,
                  height: 60.h,
                  color: widget.iconColor,
                  fit: BoxFit.cover,
                ),
              ));
  }

  Widget _radioButton() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
          border: Border.all(color: widget.borderColor ?? ColorManager.primary),
          color: Colors.transparent,
          shape: BoxShape.circle),
      child: AnimatedCrossFade(
        duration: const Duration(milliseconds: 500),
        crossFadeState: widget.selected
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond,
        firstChild: Container(
          height: widget.fillRadios ?? 15.h,
          width: widget.fillRadios ?? 15.w,
          decoration: BoxDecoration(
            color: widget.fillColor ?? ColorManager.primary,
            shape: BoxShape.circle,
          ),
        ),
        secondChild: Container(
          height: widget.fillRadios ?? 15.h,
          width: widget.fillRadios ?? 15.w,
          color: Colors.transparent,
        ),
      ),
    );
  }
}
