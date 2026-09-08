import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/images_urls/assets.dart';

class AnimatedLoadingWidget extends StatefulWidget {
  final Widget backgroundWidget;
  const AnimatedLoadingWidget({super.key, required this.backgroundWidget});

  @override
  State<AnimatedLoadingWidget> createState() => _AnimatedLoadingWidgetState();
}

class _AnimatedLoadingWidgetState extends State<AnimatedLoadingWidget>
    with TickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat(reverse: true);

  late final Animation<double> _animation =
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn);

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorManager.white,
                // borderRadius: BorderRadius.circular(14),
                border: Border.all(color: ColorManager.green, width: 2)),
            child: FadeTransition(
              opacity: _animation,
              child: Image.asset(
                // ImageAssets.logo,
                // Assets.assetsImagesLogoPng,
                "",
                height: 60.h,
                width: 60.w,
              ),
            ),
          ),
        ),
      );
    });

    return widget.backgroundWidget;
  }
}
