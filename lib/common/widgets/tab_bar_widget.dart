import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../resources/color_manager.dart';
import '../resources/styles_manager.dart';

class TabBarWidget extends StatelessWidget {
  final List<String> tabs;
  final int currentIndex;
  final void Function(int)? onTap;

  const TabBarWidget(
      {super.key, required this.tabs, required this.currentIndex, this.onTap});

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return TabBar(
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          dividerColor: Colors.transparent,
          indicatorColor: Colors.transparent,
          isScrollable: true,
          tabAlignment: TabAlignment.center,
          labelPadding: EdgeInsetsDirectional.symmetric(horizontal: 5.w),
          onTap: onTap,
          tabs: tabs.asMap().entries.map(
            (entry) {
              final index = entry.key;
              final value = entry.value;
              return _tabItem(
                isSelected: currentIndex == index,
                text: value.tr(),
              );
            },
          ).toList(),
        );
      },
    );
  }
}

Widget _tabItem({
  required String text,
  required bool isSelected,
}) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
    decoration: BoxDecoration(
      color: isSelected ? ColorManager.primary : ColorManager.secondary,
      borderRadius: BorderRadius.circular(10.r),
      // border: Border.all(
      //   color: ColorManager.primary,
      // ),
    ),
    child: Text(
      text,
      style: getBoldStyle(
          fontSize: 13.sp,
          color: isSelected ? ColorManager.white : ColorManager.textColor),
    ),
  );
}
