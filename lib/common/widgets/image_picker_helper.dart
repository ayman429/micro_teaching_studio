import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:micro_teaching_studio/common/extensions/context_extension.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';

import '../resources/strings_manager.dart';

class ImagePickerHelper {
  static Future<void> pickImage(
    BuildContext context,
    Function(File?) onImagePicked, {
    required ImageSource source,
  }) async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      onImagePicked(File(pickedFile.path));
    }
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  static void showImagePicker(
      BuildContext context, Function(File?) onImagePicked) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.chooseImage.tr(), //'لإختيار صورة'
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ListTile(
                leading:
                    const Icon(Icons.camera_alt, color: ColorManager.primary),
                title: Text(
                  AppStrings.takeImage.tr(), //"التقاط صوره",
                  style: context.textTheme.bodyLarge,
                ),
                onTap: () => pickImage(context, onImagePicked,
                    source: ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library,
                    color: ColorManager.primary),
                title: Text(
                  AppStrings.chooseFromGallry.tr(), //"اختيار من المعرض",
                  style: context.textTheme.bodyLarge,
                ),
                onTap: () => pickImage(context, onImagePicked,
                    source: ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );
  }
}
