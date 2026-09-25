import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/widgets/custom_shimmer_widget.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../resources/color_manager.dart';
import '../resources/styles_manager.dart';

class DefaultDropdownMenuWidget<T> extends StatefulWidget {
  final void Function(T? value) onSelected;
  final String? leadingIcon;
  final List items;
  final String? title;
  final String hintText;
  final bool enabled;
  final bool withSuffixIcon;
  final double? width;
  final String Function(T? item) optionTitle;
  final String Function(T? item) searchOptionTitle;
  final Color? fillColor;
  final Color? borderColor;
  final TextEditingController? controller;
  final String? text;
  final T? selectedValue;
  final void Function(bool)? onMenuStateChange;
  const DefaultDropdownMenuWidget(
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
      this.text,
      required this.selectedValue,
      this.borderColor,
      this.title,
      required this.optionTitle,
      required this.searchOptionTitle,
      this.onMenuStateChange});

  @override
  State<DefaultDropdownMenuWidget<T>> createState() =>
      _DefaultDropdownMenuWidgetState<T>();
}

class _DefaultDropdownMenuWidgetState<T>
    extends State<DefaultDropdownMenuWidget<T>> {
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
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.title != null)
                Text(
                  widget.title!,
                  style: getMediumStyle(
                      fontSize: 13.sp, color: ColorManager.textColor),
                ),
              if (widget.title != null)
                SizedBox(
                  height: 5.h,
                ),
              DropdownButtonHideUnderline(
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
                            padding: EdgeInsets.symmetric(
                                vertical: 2.h, horizontal: 2.w),
                            child: const Icon(
                              Icons.keyboard_arrow_up,
                              color: ColorManager.grey,
                            ),
                          )
                        : Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 2.h, horizontal: 2.w),
                            child: const Icon(
                              Icons.keyboard_arrow_down,
                              color: ColorManager.grey,
                            ),
                          ),
                  ),
                  isExpanded: true,
                  hint: Text(
                    widget.hintText,
                    style:
                        getBoldStyle(color: ColorManager.grey, fontSize: 12.sp),
                  ),
                  items: widget.items
                      .map((item) => DropdownMenuItem<T>(
                            value: item,
                            child: Text(
                              widget.optionTitle(item),
                              style: getSemiBoldStyle(
                                  fontSize: 13.sp,
                                  color: ColorManager.textColor),
                            ),
                          ))
                      .toList(),
                  value: widget.selectedValue,
                  onChanged: widget.onSelected,

                  buttonStyleData: ButtonStyleData(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    width: widget.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.sp),
                      color: widget.fillColor ?? ColorManager.fillColor,
                      border: Border.all(
                          color: widget.borderColor ?? ColorManager.greyBorder),
                    ),
                  ),
                  dropdownStyleData: DropdownStyleData(
                    maxHeight: 200.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.sp),
                    ),
                  ),

                  // menuItemStyleData: MenuItemStyleData(
                  //   height: 40.h,
                  // ),
                  dropdownSearchData: DropdownSearchData<T>(
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
                          hintText: AppStrings.search.tr(),
                          hintStyle: TextStyle(fontSize: 12.sp),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: ColorManager.greyBorder),
                            borderRadius: BorderRadius.circular(8.sp),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: ColorManager.greyBorder),
                            borderRadius: BorderRadius.circular(8.sp),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: ColorManager.primary),
                            borderRadius: BorderRadius.circular(8.sp),
                          ),
                        ),
                      ),
                    ),
                    searchMatchFn: (item, searchValue) {
                      return widget
                          .searchOptionTitle(item.value)
                          .toString()
                          .toLowerCase()
                          .contains(searchValue);
                    },
                  ),

                  //This to clear the search value when you close the menu
                  onMenuStateChange: widget.onMenuStateChange,
                  //  (isOpen) {
                  //   if (!isOpen) {
                  //     textEditingController.clear();
                  //   }
                  // },
                ),
              ),
            ],
          )
        : CustomShimmerWidget(
            height: 50.h,
          );

    // Container(
    //     padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 10.w),
    //     decoration: BoxDecoration(
    //       color: ColorManager.white,
    //       borderRadius: BorderRadius.circular(15.r),
    //       border: Border.all(color: ColorManager.grey),
    //     ),
    //     child: Row(
    //       children: [
    //         if (widget.leadingIcon != null)
    //           Container(
    //               padding: EdgeInsets.symmetric(
    //                   vertical: 12.h, horizontal: 12.w),
    //               child: SvgPicture.asset(
    //                 widget.leadingIcon!,
    //                 fit: BoxFit.fill,
    //               )),
    //         Text(
    //           widget.text ?? widget.hintText,
    //           style: Theme.of(context).textTheme.bodySmall?.copyWith(
    //               color: widget.text == null
    //                   ? ColorManager.grey
    //                   : ColorManager.black),
    //         ),
    //         if (widget.withSuffixIcon) const Spacer(),
    //         if (widget.withSuffixIcon)
    //           Container(
    //             decoration: const BoxDecoration(
    //                 color: ColorManager.primary, shape: BoxShape.circle),
    //             child:
    //             const Icon(
    //               Icons.keyboard_arrow_down,
    //               color: ColorManager.white,
    //             ),
    //           ),
    //       ],
    //     ),
    //   );
  }
}
