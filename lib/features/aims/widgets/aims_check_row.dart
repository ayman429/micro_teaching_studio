import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/features/course_shell/widgets/course_svg_icon.dart';
import 'package:micro_teaching_studio/images_urls/assets.dart';

class AimsCheckRow extends StatelessWidget {
  const AimsCheckRow({super.key, required this.labelKey});

  final String labelKey;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: AppSize.s20.w,
          height: AppSize.s20.w,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: ColorManager.iceBlue,
            shape: BoxShape.circle,
          ),
          child: CourseSvgIcon(
            asset: Assets.assetsIconsCourseCheck,
            size: AppSize.s12.w,
          ),
        ),
        SizedBox(width: AppPadding.p8.w),
        Expanded(
          child: Text(
            labelKey.tr(),
            style: getRegularStyle(
              fontSize: FontSize.s12.sp,
              color: ColorManager.slate700,
              height: 1.375,
            ),
          ),
        ),
      ],
    );
  }
}
