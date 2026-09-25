import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/features/home/models/home_session.dart';

class HomeSessionChip extends StatelessWidget {
  const HomeSessionChip({
    super.key,
    required this.session,
    this.onTap,
  });

  final HomeSession session;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColorManager.slate900,
      borderRadius: BorderRadius.circular(AppRadius.rCapsule.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.rCapsule.r),
        child: SizedBox(
          height: AppSize.s36.h,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppPadding.p16.w),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: AppSize.s20.w,
                  height: AppSize.s20.w,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: ColorManager.onDarkOverlay,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${session.number}',
                    style: getBoldStyle(
                      fontSize: FontSize.s10.sp,
                      color: ColorManager.white,
                    ),
                  ),
                ),
                SizedBox(width: AppPadding.p6.w),
                Text(
                  session.labelKey.tr(),
                  style: getBoldStyle(
                    fontSize: FontSize.s11.sp,
                    color: ColorManager.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
