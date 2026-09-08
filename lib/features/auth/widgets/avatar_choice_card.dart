import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/features/auth/models/student_avatar.dart';
import 'package:micro_teaching_studio/features/course_shell/widgets/course_svg_icon.dart';
import 'package:micro_teaching_studio/images_urls/assets.dart';

class AvatarChoiceCard extends StatelessWidget {
  const AvatarChoiceCard({
    super.key,
    required this.avatar,
    required this.isSelected,
    required this.onTap,
  });

  final StudentAvatar avatar;
  final bool isSelected;
  final VoidCallback onTap;

  bool get _isGirl => avatar == StudentAvatar.girl;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? ColorManager.selectedAvatarFill : ColorManager.white,
      borderRadius: BorderRadius.circular(AppRadius.r16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.r16.r),
        child: Container(
          height: AppSize.avatarCardHeight.h,
          padding: EdgeInsets.all(AppPadding.p12.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.r16.r),
            border: Border.all(
              color: isSelected ? ColorManager.navy : ColorManager.slate200,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: ColorManager.actionBlueGlow,
                      blurRadius: AppPadding.p4.r,
                      spreadRadius: AppPadding.p4.r,
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: AppSize.avatarThumb.w,
                height: AppSize.avatarThumb.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.r12.r),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _isGirl
                        ? ColorManager.gradientAvatarGirl
                        : ColorManager.gradientAvatarBoy,
                  ),
                ),
                child: Text(
                  avatar.glyph,
                  style: getRegularStyle(
                    fontSize: FontSize.s22.sp,
                    color: ColorManager.slate800,
                  ),
                ),
              ),
              SizedBox(height: AppPadding.p8.h),
              Text(
                _isGirl
                    ? AppStrings.studentAvatarGirl.tr()
                    : AppStrings.studentAvatarBoy.tr(),
                style: getBoldStyle(
                  fontSize: FontSize.s11.sp,
                  color: ColorManager.slate800,
                ),
              ),
              Text(
                _isGirl
                    ? AppStrings.aiTwinWillMatch.tr()
                    : AppStrings.teacherAvatar.tr(),
                style: getRegularStyle(
                  fontSize: FontSize.s9.sp,
                  color: ColorManager.slate,
                ),
              ),
              if (isSelected) ...[
                const Spacer(),
                Row(
                  children: [
                    CourseSvgIcon(
                      asset: Assets.assetsIconsCourseCheck,
                      size: AppSize.s12.w,
                    ),
                    SizedBox(width: AppPadding.p4.w),
                    Text(
                      AppStrings.selected.tr(),
                      style: getBoldStyle(
                        fontSize: FontSize.s10.sp,
                        color: ColorManager.navy,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
