import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/features/auth/auth_validators.dart';
import 'package:micro_teaching_studio/features/auth/models/student_avatar.dart';
import 'package:micro_teaching_studio/features/auth/widgets/auth_field_label.dart';
import 'package:micro_teaching_studio/features/auth/widgets/auth_form_surface.dart';
import 'package:micro_teaching_studio/features/auth/widgets/auth_primary_button.dart';
import 'package:micro_teaching_studio/features/auth/widgets/auth_text_field.dart';
import 'package:micro_teaching_studio/features/auth/widgets/avatar_choice_card.dart';

class LoginFormCard extends StatelessWidget {
  const LoginFormCard({
    super.key,
    required this.formKey,
    required this.fullNameController,
    required this.userNameController,
    required this.passwordController,
    required this.selectedAvatar,
    required this.onAvatarSelected,
    required this.onSubmit,
    this.isLoading = false,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController userNameController;
  final TextEditingController passwordController;
  final StudentAvatar selectedAvatar;
  final ValueChanged<StudentAvatar> onAvatarSelected;
  final VoidCallback onSubmit;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return AuthFormSurface(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AuthFieldLabel(text: AppStrings.fullNameLabel.tr()),
            SizedBox(height: AppPadding.p8.h),
            AuthTextField(
              controller: fullNameController,
              hintText: AppStrings.fullNameHint.tr(),
              textInputAction: TextInputAction.next,
              validator: authRequiredField,
            ),
            SizedBox(height: AppPadding.p16.h),
            AuthFieldLabel(text: AppStrings.userNameLabel.tr()),
            SizedBox(height: AppPadding.p8.h),
            AuthTextField(
              controller: userNameController,
              hintText: AppStrings.userNameHint.tr(),
              textInputAction: TextInputAction.next,
              validator: authUserNameField,
            ),
            SizedBox(height: AppPadding.p16.h),
            AuthFieldLabel(text: AppStrings.passwordLabel.tr()),
            SizedBox(height: AppPadding.p8.h),
            AuthTextField(
              controller: passwordController,
              hintText: AppStrings.passwordHint.tr(),
              obscureText: true,
              textInputAction: TextInputAction.done,
              validator: authPasswordField,
            ),
            SizedBox(height: AppPadding.p16.h),
            AuthFieldLabel(text: AppStrings.chooseAvatarLabel.tr()),
            SizedBox(height: AppPadding.p12.h),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: StudentAvatar.values.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: AppPadding.p12.h,
                crossAxisSpacing: AppPadding.p12.w,
                childAspectRatio: 0.82,
              ),
              itemBuilder: (context, index) {
                final avatar = StudentAvatar.values[index];
                return AvatarChoiceCard(
                  avatar: avatar,
                  isSelected: selectedAvatar == avatar,
                  onTap: () => onAvatarSelected(avatar),
                );
              },
            ),
            SizedBox(height: AppPadding.p16.h),
            AuthPrimaryButton(
              label: AppStrings.submitAndStart.tr(),
              onPressed: onSubmit,
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
