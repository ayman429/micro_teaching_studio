import 'package:micro_teaching_studio/common/resources/assets_manager.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GoLoginWidget extends StatefulWidget {
  final bool withTopHeight;
  const GoLoginWidget({super.key, this.withTopHeight = false});

  @override
  State<GoLoginWidget> createState() => _GoLoginWidgetState();
}

class _GoLoginWidgetState extends State<GoLoginWidget>
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.withTopHeight)
          SizedBox(
            height: 200.h,
          ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
              // borderRadius: BorderRadius.circular(14),
              border: Border.all(color: ColorManager.red, width: 2)),
          child: FadeTransition(
              opacity: _animation,
              child: Image.asset(
                ImageAssets.logo,
                height: 60.h,
                width: 60.w,
              )),
        ),
        SizedBox(
          height: 15.h,
        ),
        Text(
          AppStrings.loginFirst.tr(),
          textAlign: TextAlign.center,
          style: getMediumStyle(fontSize: 15.sp, color: ColorManager.textColor),
        ),
        InkWell(
          onTap: () {},
          // onTap: () => AppFunctions.navigateTo(context, const LoginPage()),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ColorManager.primary,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              AppStrings.login.tr(),
              style: getBoldStyle(fontSize: 15.sp, color: ColorManager.white),
            ),
          ),
        ),
      ],
    );
  }
}
