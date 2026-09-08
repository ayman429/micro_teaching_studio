import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/language_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerContainerWidget extends StatelessWidget {
  final double height;
  final double? width;
  final double? radios;
  const ShimmerContainerWidget(
      {super.key, required this.height, this.width, this.radios});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: ColorManager.shimmerBaseColor,
      highlightColor: ColorManager.shimmerHighlightColor,
      direction: language == "en" ? ShimmerDirection.ltr : ShimmerDirection.rtl,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
            color: ColorManager.white,
            borderRadius: BorderRadius.circular(radios ?? 10.sp)),
      ),
    );
  }
}
