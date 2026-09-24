import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/features/auth/models/student_avatar.dart';
import 'package:micro_teaching_studio/features/auth/widgets/student_avatar_image.dart';

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

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? ColorManager.selectedAvatarFill : ColorManager.white,
      borderRadius: BorderRadius.circular(AppRadius.r16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.r16.r),
        child: Container(
          padding: EdgeInsets.all(AppPadding.p8.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.r16.r),
            border: Border.all(
              color: isSelected ? ColorManager.navy : ColorManager.slate200,
              width: isSelected ? 2 : 1,
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.r12.r),
            child: StudentAvatarImage(
              avatar: avatar,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
