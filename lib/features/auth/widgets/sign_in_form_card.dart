import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/features/auth/auth_validators.dart';
import 'package:micro_teaching_studio/features/auth/widgets/auth_field_label.dart';
import 'package:micro_teaching_studio/features/auth/widgets/auth_form_surface.dart';
import 'package:micro_teaching_studio/features/auth/widgets/auth_primary_button.dart';
import 'package:micro_teaching_studio/features/auth/widgets/auth_text_field.dart';

class SignInFormCard extends StatelessWidget {
  const SignInFormCard({
    super.key,
    required this.formKey,
    required this.userNameController,
    required this.passwordController,
    required this.onSubmit,
    this.isLoading = false,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController userNameController;
  final TextEditingController passwordController;
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
            AuthPrimaryButton(
              label: AppStrings.loginAction.tr(),
              onPressed: onSubmit,
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
