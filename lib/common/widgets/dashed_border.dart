import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DashedBorder extends StatefulWidget {
  final Widget child;
  const DashedBorder({super.key, required this.child});

  @override
  State<DashedBorder> createState() => _DashedBorderState();
}

class _DashedBorderState extends State<DashedBorder> {
  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      color: ColorManager.green,
      borderType: BorderType.RRect,
      radius: const Radius.circular(20),
      dashPattern: [10.w, 4.w],
      child: widget.child,
    );
  }
}
