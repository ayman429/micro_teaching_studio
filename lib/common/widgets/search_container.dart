// *************** واجهة البحث والفلاتر ***************
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../resources/color_manager.dart';
import 'default_form_field.dart';

class SearchContainer extends StatelessWidget {
  const SearchContainer(
      {super.key,
      required this.searchController,
      required this.text,
      this.onChanged,
      this.onSubmit});
  final TextEditingController searchController;
  final String text;
  final void Function(String)? onChanged;
  final void Function()? onSubmit;
  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10.w,
      children: [
        Expanded(
          child: DefaultFormField(
            noBorder: false,
            controller: searchController,
            fillColor: const Color.fromRGBO(255, 255, 255, 1),
            borderColor: ColorManager.greyBorder,
            hintText: text,
            prefixWidget: GestureDetector(
              onTap: onSubmit,
              child: Icon(
                Icons.search,
                color: ColorManager.grey,
                size: 30.r,
              ),
            ),
            onChanged: onChanged,
          ),
        ),
        // Container(
        //   padding: const EdgeInsets.all(10),
        //   decoration: BoxDecoration(
        //     border: Border.all(color: ColorManager.greyBorder),
        //     borderRadius: BorderRadius.all(Radius.circular(5.r)),
        //   ),
        //   child: SvgPicture.asset(
        //     Assets.assetsIconsFiltter,
        //   ),
        // ),
      ],
    );
  }
}
