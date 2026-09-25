import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../resources/color_manager.dart';
import '../resources/language_manager.dart';
import '../resources/strings_manager.dart';
import '../resources/styles_manager.dart';

class DefaultFormField extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final String? redText;
  final String? title;
  final Widget? hintWidget;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final bool? enabled;
  final VoidCallback? onTap;
  final Function(String)? onChanged;
  final bool disableHelperText;
  final bool? inLeft;
  final int? maxLength;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool withInputFormatter;
  final bool withValidate;
  final bool withOnTapOutSide;
  final bool isUnderLine;
  final bool noBorder;
  final double? borderRadius;
  final String? prefixIconPath;
  final Color? borderColor;
  final Color? fillColor;
  final int? maxLines;
  final double? verticalPadding;
  final String? Function(String?)? validator;
  final String? labelText;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixWidget;

  const DefaultFormField({
    super.key,
    required this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.hintText,
    this.enabled,
    this.inputFormatters,
    this.onTap,
    this.disableHelperText = true,
    this.redText,
    this.onChanged,
    this.inLeft,
    this.maxLength,
    this.focusNode,
    this.autofocus = false,
    this.withInputFormatter = false,
    this.withValidate = true,
    this.withOnTapOutSide = false,
    this.borderRadius,
    this.prefixIconPath,
    this.isUnderLine = false,
    this.borderColor,
    this.fillColor,
    this.maxLines = 1,
    this.verticalPadding,
    this.validator,
    this.noBorder = false,
    this.title,
    this.labelText,
    this.hintWidget,
    this.readOnly = false,
    this.prefixWidget,
  });

  @override
  State<DefaultFormField> createState() => _DefaultFormFieldState();
}

class _DefaultFormFieldState extends State<DefaultFormField> {
  final FocusNode _focusNode = FocusNode();
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();

    _isVisible = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null)
          Text(
            "\t${widget.title!}",
            style:
                getRegularStyle(fontSize: 15.sp, color: ColorManager.greyText),
          ),
        if (widget.title != null)
          SizedBox(
            height: 5.h,
          ),
        TextFormField(
          focusNode: _focusNode,
          autofocus: widget.autofocus,
          maxLengthEnforcement:
              MaxLengthEnforcement.truncateAfterCompositionEnds,
          onTap: widget.onTap,
          enabled: widget.enabled,
          keyboardType: widget.keyboardType,
          readOnly: widget.readOnly,
          controller: widget.controller,
          onChanged: widget.onChanged,
          textDirection: widget.inLeft ?? (language == 'en')
              ? ui.TextDirection.ltr
              : ui.TextDirection.rtl,
          maxLines: widget.maxLines,
          inputFormatters: widget.withInputFormatter
              ? [
                  LengthLimitingTextInputFormatter(widget.maxLength),
                  FilteringTextInputFormatter.digitsOnly
                ]
              : null,
          // cursorHeight: 25.h,
          style: getMediumStyle(fontSize: 14.sp, color: ColorManager.textColor),
          validator: widget.withValidate
              ? (value) {
                  widget.validator?.call(value);
                  if (value?.isEmpty ?? false) {
                    return widget.redText ?? AppStrings.textFieldError.tr();
                  }
                  return null;
                }
              : widget.validator,
          obscureText: _isVisible,
          selectionHeightStyle: ui.BoxHeightStyle.includeLineSpacingMiddle,
          onTapOutside: (event) => _focusNode.unfocus(),
          decoration: InputDecoration(
            labelText: widget.labelText,
            labelStyle: TextStyle(
                color: ColorManager.grey,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold),
            contentPadding: widget.verticalPadding != null
                ? EdgeInsets.symmetric(
                    vertical: widget.verticalPadding!, horizontal: 15.w)
                : null,
            filled: true,
            errorMaxLines: 3,
            fillColor: widget.fillColor,
            helperText: widget.disableHelperText ? null : '',
            prefixIcon: widget.prefixWidget ??
                (widget.prefixIconPath != null
                    ? Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 12.h),
                        child: SvgPicture.asset(
                          widget.prefixIconPath ?? '',
                          width: 5.w,
                          height: 5.w,
                        ))
                    : null),
            suffixIcon: widget.obscureText
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        _isVisible = !_isVisible;
                      });
                    },
                    icon: Icon(
                      _isVisible ? Icons.visibility_off : Icons.visibility,
                      color: ColorManager.textColor,
                    ))
                : widget.suffixIcon,
            hintText: widget.hintText,
            hintStyle: getBoldStyle(
                color: ColorManager.hintTextColor, fontSize: 12.sp),
            focusedBorder: widget.noBorder
                ? InputBorder.none
                : widget.isUnderLine
                    ? UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: widget.borderColor ?? ColorManager.primary),
                      )
                    : OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(widget.borderRadius ?? 8.r),
                        borderSide: BorderSide(
                            color: widget.borderColor ?? ColorManager.primary),
                      ),
            enabledBorder: widget.noBorder
                ? InputBorder.none
                : widget.isUnderLine
                    ? UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: widget.borderColor ?? ColorManager.primary),
                      )
                    : OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(widget.borderRadius ?? 8.r),
                        borderSide: BorderSide(
                            color: widget.borderColor ?? ColorManager.primary),
                      ),
            errorBorder: widget.noBorder
                ? InputBorder.none
                : widget.isUnderLine
                    ? UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: widget.borderColor ?? ColorManager.red),
                      )
                    : OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(widget.borderRadius ?? 8.r),
                        borderSide: const BorderSide(color: ColorManager.red),
                      ),
            focusedErrorBorder: widget.noBorder
                ? InputBorder.none
                : widget.isUnderLine
                    ? UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: widget.borderColor ?? ColorManager.red),
                      )
                    : OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(widget.borderRadius ?? 8.r),
                        borderSide: const BorderSide(color: ColorManager.red),
                      ),
            disabledBorder: widget.noBorder
                ? InputBorder.none
                : widget.isUnderLine
                    ? UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: widget.borderColor ?? ColorManager.grey),
                      )
                    : OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(widget.borderRadius ?? 8.r),
                        borderSide:
                            const BorderSide(color: ColorManager.greyBorder),
                      ),
          ),
        ),
        if (widget.hintWidget != null)
          SizedBox(
            height: 5.h,
          ),
        if (widget.hintWidget != null) widget.hintWidget!,
      ],
    );
  }
}
