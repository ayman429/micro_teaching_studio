import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CustomShimmerWidget extends StatelessWidget {
  final double? height;
  final double? width;
  final Color? highlightColor;
  final BoxShape? shape;
  final bool? isCircular;
  final double? borderRadius;

  const CustomShimmerWidget({
    super.key,
    this.height,
    this.shape = BoxShape.rectangle,
    this.width = double.infinity,
    this.highlightColor = Colors.white,
    this.isCircular,
    this.borderRadius,
  });
  const CustomShimmerWidget.circular({
    super.key,
    this.borderRadius,
    this.highlightColor = Colors.white,
    this.isCircular,
  })  : height = 20,
        width = 20,
        shape = BoxShape.circle;
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: highlightColor!,
      child: isCircular ?? false
          ? Container(
              height: height,
              width: width,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
            )
          : Container(
              height: height ?? 20,
              width: width,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: shape!,
                borderRadius: BorderRadius.circular(borderRadius ?? 10),
              ),
            ),
    );
  }
}
