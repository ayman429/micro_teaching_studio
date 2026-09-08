import 'dart:developer';
import 'dart:io';

import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/common/extensions/context_extension.dart';
import 'package:micro_teaching_studio/common/widgets/image_picker_helper.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../images_urls/assets.dart';
import 'default_image_widget.dart';

// ignore: must_be_immutable
class ViewImageAndChange extends StatefulWidget {
  ViewImageAndChange({
    super.key,
    required this.onImageSelected,
    this.personalNetworkImage,
  });

  final Function(File?) onImageSelected;

  String? personalNetworkImage;
  @override
  State<ViewImageAndChange> createState() => _ViewImageAndChangeState();
}

class _ViewImageAndChangeState extends State<ViewImageAndChange> {
  File? image;
  @override
  Widget build(BuildContext context) {
    log("image: $image");
    return GestureDetector(
      onTap: () {
        ImagePickerHelper.showImagePicker(context, (file) {
          setState(() {
            image = file;
            log("image: $image");
          });
          widget.onImageSelected(file);
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Center(
            child: Stack(
              alignment: Alignment.bottomLeft,
              clipBehavior: Clip.none,
              children: [
                image != null
                    ? Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: CircleAvatar(
                            radius: 70, backgroundImage: FileImage(image!)))
                    : Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),

                        clipBehavior:
                            Clip.hardEdge, // يجعل الحواف دائرية فعليًا

                        child: widget.personalNetworkImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(50.r),
                                ),
                                child: DefaultImageWidget(
                                  radius: 50.r,
                                  image: widget.personalNetworkImage ?? "",
                                  width: 150.r,
                                  height: 150.r,
                                ),
                                // CachedNetworkImage(
                                //   width: 150.r,
                                //   height: 150.r,
                                //   fit: BoxFit.cover,
                                //   imageUrl: widget.personalNetworkImage ?? "",
                                //   placeholder: (context, url) =>
                                //       Center(child: CircularProgressIndicator()),
                                //   errorWidget: (context, url, error) => Icon(
                                //     Icons.error,
                                //     size: 60.r,
                                //   ),
                                // ),
                              )
                            : ClipOval(
                                child: Image.asset(
                                  Assets.assetsImagesProfileUserImage,
                                  height: 150.h,
                                  width: 150.w,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                Positioned(
                  // left: 0,
                  right: -20,
                  bottom: -10,
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(
                        end: context.screenHeight * 0.1),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: ColorManager.primary,
                        shape: BoxShape.circle,
                      ),
                      padding: EdgeInsets.all(15.r),
                      child: SvgPicture.asset(
                        Assets.assetsIconsEditProfile,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
