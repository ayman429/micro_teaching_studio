import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/common/widgets/default_button_widget.dart';
import 'package:micro_teaching_studio/features/course_shell/widgets/course_svg_icon.dart';
import 'package:micro_teaching_studio/images_urls/assets.dart';

class LogoutConfirmDialog extends StatelessWidget {
  const LogoutConfirmDialog({super.key});

  static Future<bool> show(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: ColorManager.navy.withValues(alpha: 0.45),
      builder: (dialogContext) => const LogoutConfirmDialog(),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManager.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: AppPadding.p24.w),
      child: Container(
        padding: EdgeInsets.all(AppPadding.p24.w),
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: BorderRadius.circular(AppRadius.r24.r),
          border: Border.all(color: ColorManager.slate200),
          boxShadow: [
            BoxShadow(
              color: ColorManager.navyGlow,
              blurRadius: AppPadding.p24.r,
              offset: Offset(0, AppPadding.p8.h),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppSize.s64.w,
              height: AppSize.s64.w,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: ColorManager.iceBlue,
                shape: BoxShape.circle,
              ),
              child: CourseSvgIcon(
                asset: Assets.assetsIconsLogout,
                size: AppSize.s28.w,
              ),
            ),
            SizedBox(height: AppPadding.p16.h),
            Text(
              AppStrings.logOut.tr(),
              textAlign: TextAlign.center,
              style: getExtraBoldStyle(
                fontSize: FontSize.s18.sp,
                color: ColorManager.navy,
              ),
            ),
            SizedBox(height: AppPadding.p8.h),
            Text(
              AppStrings.areYouLogout.tr(),
              textAlign: TextAlign.center,
              style: getRegularStyle(
                fontSize: FontSize.s13.sp,
                color: ColorManager.slate,
              ),
            ),
            SizedBox(height: AppPadding.p24.h),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: AppSize.s48.h,
                    child: DefaultButtonWidget(
                      text: AppStrings.cancel.tr(),
                      onPressed: () => Navigator.of(context).pop(false),
                      color: ColorManager.slate100,
                      textColor: ColorManager.navy,
                      radius: AppRadius.r16.r,
                      elevation: 0,
                      textStyle: getBoldStyle(
                        fontSize: FontSize.s13.sp,
                        color: ColorManager.navy,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppPadding.p12.w),
                Expanded(
                  child: SizedBox(
                    height: AppSize.s48.h,
                    child: DefaultButtonWidget(
                      text: AppStrings.logOut.tr(),
                      onPressed: () => Navigator.of(context).pop(true),
                      color: ColorManager.navy,
                      textColor: ColorManager.white,
                      radius: AppRadius.r16.r,
                      elevation: 0,
                      textStyle: getBoldStyle(
                        fontSize: FontSize.s13.sp,
                        color: ColorManager.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
