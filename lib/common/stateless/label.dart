import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../common/resources/theme_manager.dart';

class Label extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow overflow;
  final TextDecoration? decoration;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final bool selectable;
  final bool? softWrap;
  final double? height;
  const Label({
    super.key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
    this.decoration,
    this.color,
    this.height,
    this.fontSize,
    this.fontWeight,
    this.selectable = false,
    this.softWrap,
  });

  @override
  Widget build(BuildContext context) {
    if (!selectable) {
      return Text(
        text,
        style: (style ?? ThemeManager.getTheme().textTheme.bodyLarge)?.copyWith(
            decoration: decoration,
            color: color,
            fontSize: fontSize?.spMax,
            fontWeight: fontWeight,
            height: height),
        softWrap: true,
        textAlign: textAlign,
        overflow: overflow,
        maxLines: maxLines,
      );
    }
    return SelectableText(
      text,
      style: (style ?? ThemeManager.getTheme().textTheme.bodyLarge)?.copyWith(
        decoration: decoration,
        color: color,
        fontSize: fontSize?.spMax,
        fontWeight: fontWeight,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
    );
  }
}

class LocalizedLabel extends Label {
  const LocalizedLabel({
    super.key,
    required super.text,
    super.style,
    super.textAlign,
    super.maxLines,
    super.overflow,
    super.decoration,
    super.color,
    super.fontSize,
    super.fontWeight,
    super.selectable,
    super.softWrap,
    super.height,
  });

  @override
  String get text => super.text.tr();
}
