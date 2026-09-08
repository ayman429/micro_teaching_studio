import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FlexibleText extends StatefulWidget {
  final String text;
  final int max;
  final TextStyle? textStyle;
  const FlexibleText(
      {super.key, required this.text, this.max = 130, this.textStyle});

  @override
  State<FlexibleText> createState() => _FlexibleTextState();
}

class _FlexibleTextState extends State<FlexibleText> {
  bool isExpand = false;

  @override
  Widget build(BuildContext context) {
    return _sectionText(widget.text);
  }

  Widget _sectionText(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
        child: Wrap(
          children: [
            Text(
              text,
              style: widget.textStyle ??
                  TextStyle(
                      color: ColorManager.black,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400),
              maxLines: isTextBigger(text) && !isExpand ? 2 : null,
              overflow: isTextBigger(text) && !isExpand
                  ? TextOverflow.ellipsis
                  : null,
            ),
            if (isTextBigger(text))
              InkWell(
                  onTap: () => setState(() {
                        isExpand = !isExpand;
                      }),
                  child: Text(
                      isTextBigger(text) && !isExpand
                          ? AppStrings.showMore.tr()
                          : AppStrings.showLess.tr(),
                      style: TextStyle(
                          color: ColorManager.green,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400))),
          ],
        ),
      ),
    );
  }

  bool isTextBigger(String text) {
    if (text.length > widget.max) {
      return true;
    } else {
      return false;
    }
  }
}
