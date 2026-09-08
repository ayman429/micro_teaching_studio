import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/features/auth/models/student_avatar.dart';
import 'package:micro_teaching_studio/features/course_shell/course_constants.dart';

class HomeProfileCard extends StatelessWidget {
  const HomeProfileCard({
    super.key,
    required this.fullName,
    required this.userName,
    this.avatar = StudentAvatar.girl,
  });

  final String fullName;
  final String userName;
  final StudentAvatar avatar;

  @override
  Widget build(BuildContext context) {
    final percent = (CourseConstants.overallProgress * 100).round().toString();
    final greeting = fullName.trim().isEmpty
        ? AppStrings.ahlanFutureTeacher.tr()
        : AppStrings.ahlanNamed.tr(namedArgs: {'name': fullName.trim()});

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppPadding.p16.w),
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(AppRadius.r20.r),
        border: Border.all(color: ColorManager.slate200),
      ),
      child: Row(
        children: [
          Container(
            width: AppSize.avatarThumb.w,
            height: AppSize.avatarThumb.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: avatar == StudentAvatar.girl
                    ? ColorManager.gradientAvatarGirl
                    : ColorManager.gradientAvatarBoy,
              ),
            ),
            child: Text(
              avatar.glyph,
              style: getRegularStyle(
                fontSize: FontSize.s16.sp,
                color: ColorManager.white,
              ),
            ),
          ),
          SizedBox(width: AppPadding.p12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: getBoldStyle(
                    fontSize: FontSize.s13.sp,
                    color: ColorManager.slate800,
                  ),
                ),
                if (userName.trim().isNotEmpty) ...[
                  SizedBox(height: AppPadding.p4.h),
                  Text(
                    userName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: getMediumStyle(
                      fontSize: FontSize.s11.sp,
                      color: ColorManager.navy,
                    ),
                  ),
                ],
                SizedBox(height: AppPadding.p4.h),
                Text(
                  AppStrings.homeProgressLine.tr(
                    namedArgs: {
                      'percent': percent,
                      'count': '${CourseConstants.moduleCount}',
                    },
                  ),
                  style: getRegularStyle(
                    fontSize: FontSize.s11.sp,
                    color: ColorManager.slate,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: AppSize.avatarThumb.w,
            height: AppSize.avatarThumb.w,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: ColorManager.slate900,
              shape: BoxShape.circle,
            ),
            child: Text(
              CourseConstants.rating,
              style: getExtraBoldStyle(
                fontSize: FontSize.s11.sp,
                color: ColorManager.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
