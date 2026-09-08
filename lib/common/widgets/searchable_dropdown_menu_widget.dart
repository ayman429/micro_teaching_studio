import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/language_manager.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SearchableDropdownMenuWidget extends StatefulWidget {
  final void Function(dynamic) onSelected;
  final String? leadingIcon;
  final List items;
  final String hintText;
  final bool enabled;
  final bool withSuffixIcon;
  final double? width;
  final Color? fillColor;
  final TextEditingController? controller;
  final Widget? label;
  final bool isName;
  final dynamic selectedValue;
  const SearchableDropdownMenuWidget(
      {super.key,
      required this.onSelected,
      this.leadingIcon,
      required this.items,
      required this.hintText,
      this.enabled = true,
      this.controller,
      this.width,
      this.fillColor,
      this.withSuffixIcon = true,
      this.label,
      required this.selectedValue,
      this.isName = false});

  @override
  State<SearchableDropdownMenuWidget> createState() =>
      _SearchableDropdownMenuWidgetState();
}

class _SearchableDropdownMenuWidgetState
    extends State<SearchableDropdownMenuWidget> {
  final TextEditingController textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.enabled
        ? Center(
            child: DropdownButtonHideUnderline(
              child: DropdownButton2(
                // leadingIcon: widget.leadingIcon != null
                //     ? Padding(
                //         padding: EdgeInsets.only(right: 10.w),
                //         child: SvgPicture.asset(
                //           widget.leadingIcon!,
                //           height: 20.h,
                //           width: 20.w,
                //           fit: BoxFit.fill,
                //         ),
                //       )
                //     : null,
                iconStyleData: IconStyleData(
                  icon: widget.withSuffixIcon
                      ? Container(
                          decoration: const BoxDecoration(
                              color: ColorManager.primary,
                              shape: BoxShape.circle),
                          child: const Icon(
                            Icons.keyboard_arrow_down,
                            color: ColorManager.white,
                          ),
                        )
                      : const Text(''),
                ),
                isExpanded: true,
                hint: Text(
                  widget.hintText,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: ColorManager.grey),
                ),
                items: widget.items
                    .map((item) => DropdownMenuItem(
                          value: item,
                          child: Text(
                            language == 'en' ? item.titleEn : item.titleAr,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: ColorManager.black),
                          ),
                        ))
                    .toList(),
                value: widget.selectedValue,
                onChanged: widget.onSelected,
                buttonStyleData: ButtonStyleData(
                  padding:
                      EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
                  width: widget.width,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.sp),
                      color: widget.fillColor,
                      border: const Border.symmetric(
                        vertical: BorderSide(
                          color: ColorManager.grey,
                        ),
                        horizontal: BorderSide(color: ColorManager.grey),
                      )),
                ),
                dropdownStyleData: DropdownStyleData(
                  maxHeight: 200.h,
                ),
                menuItemStyleData: MenuItemStyleData(
                  height: 40.h,
                ),
                dropdownSearchData: DropdownSearchData(
                  searchController: textEditingController,
                  searchInnerWidgetHeight: 50.h,
                  searchInnerWidget: Container(
                    height: 50,
                    padding: EdgeInsets.only(
                      top: 8.h,
                      bottom: 4.h,
                      right: 8.w,
                      left: 8.w,
                    ),
                    child: TextFormField(
                      focusNode: _focusNode,
                      expands: true,
                      maxLines: null,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: ColorManager.black),
                      controller: textEditingController,
                      onTapOutside: (event) => _focusNode.unfocus(),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        hintText: language == "en"
                            ? 'Search for emirate...'
                            : "إبحث عن إمارة...",
                        hintStyle: TextStyle(
                            fontSize: 12.sp, color: ColorManager.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.sp),
                        ),
                      ),
                    ),
                  ),
                  searchMatchFn: (item, searchValue) {
                    return language == 'en'
                        ? (item.value as dynamic)
                            .titleEn
                            .toString()
                            .toLowerCase()
                            .contains(searchValue)
                        : (item.value as dynamic)
                            .titleAr
                            .toString()
                            .toLowerCase()
                            .contains(searchValue);
                  },
                ),

                //This to clear the search value when you close the menu
                onMenuStateChange: (isOpen) {
                  if (!isOpen) {
                    textEditingController.clear();
                  }
                },
              ),
            ),
          )
        : DropdownMenu(
            controller: widget.controller,
            textStyle: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: ColorManager.black),
            onSelected: widget.onSelected,
            width: widget.width,
            enabled: widget.enabled,
            hintText: widget.hintText,
            label: widget.label,
            menuHeight: 200.h,
            leadingIcon: widget.leadingIcon == null
                ? null
                : Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
                    child: SvgPicture.asset(
                      widget.leadingIcon!,
                      fit: BoxFit.fill,
                    )),
            trailingIcon: widget.withSuffixIcon
                ? Container(
                    decoration: const BoxDecoration(
                        color: ColorManager.primary, shape: BoxShape.circle),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: ColorManager.white,
                    ),
                  )
                : const Text(''),
            dropdownMenuEntries: widget.items
                .map((e) => DropdownMenuEntry(
                    value: e.courseId,
                    label: widget.isName ? (e.name ?? '') : e.nameAr))
                .toList(),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: widget.fillColor,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.sp),
                borderSide: const BorderSide(color: ColorManager.grey),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.sp),
                borderSide: const BorderSide(color: ColorManager.grey),
              ),
            ),
          );
  }
  // @override
  // Widget build(BuildContext context) {
  //   return DropdownMenu(
  //       controller: widget.controller,
  //       textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: ColorManager.blue),
  //       onSelected: widget.onSelected,
  //       width: widget.width.w,
  //       enabled: widget.enabled,
  //       hintText: widget.hintText,
  //       label: widget.label,
  //       menuHeight: 200.h,
  //       leadingIcon: widget.leadingIcon == null ? null :  Container(
  //           padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
  //           child: SvgPicture.asset(
  //             widget.leadingIcon!,
  //             fit: BoxFit.fill,
  //           )),
  //       trailingIcon: widget.withSuffixIcon ? Container(
  //           padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
  //           child: SvgPicture.asset(
  //             ImageAssets.downIc,
  //             fit: BoxFit.fill,
  //           )) : const Text(''),
  //       dropdownMenuEntries: widget.items.map((e) => DropdownMenuEntry(value: e.id, label: e.name)).toList(),
  //       inputDecorationTheme: InputDecorationTheme(
  //       filled: true,
  //       fillColor: widget.fillColor,
  //       enabledBorder: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(15.sp),
  //         borderSide: BorderSide(color: ColorManager.greyLightColor),
  //       ),
  //       disabledBorder: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(15.sp),
  //         borderSide: BorderSide(color: ColorManager.greyLightColor),
  //       ),
  //     ),
  //   );
  // }
}
