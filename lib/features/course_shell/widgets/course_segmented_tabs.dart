import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';

class CourseSegmentedTabs extends StatelessWidget {
  const CourseSegmentedTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(labels.length, (index) {
        final isSelected = index == selectedIndex;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : AppPadding.p8.w,
            ),
            child: Material(
              color: isSelected ? ColorManager.navy : ColorManager.white,
              borderRadius: BorderRadius.circular(AppRadius.rCapsule.r),
              child: InkWell(
                onTap: () => onSelected(index),
                borderRadius: BorderRadius.circular(AppRadius.rCapsule.r),
                child: Container(
                  height: AppSize.s40.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.rCapsule.r),
                    border: Border.all(
                      color: isSelected
                          ? ColorManager.navy
                          : ColorManager.slate200,
                    ),
                  ),
                  child: Text(
                    labels[index],
                    style: getBoldStyle(
                      fontSize: FontSize.s11.sp,
                      color: isSelected
                          ? ColorManager.white
                          : ColorManager.slate800,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
