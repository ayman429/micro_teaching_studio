import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_teaching_studio/app/app_functions.dart';
import 'package:micro_teaching_studio/common/resources/app_router.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/features/auth/cubit/auth_cubit.dart';
import 'package:micro_teaching_studio/features/auth/cubit/auth_state.dart';
import 'package:micro_teaching_studio/features/auth/widgets/auth_account_prompt.dart';
import 'package:micro_teaching_studio/features/auth/widgets/sign_in_form_card.dart';
import 'package:micro_teaching_studio/features/course_shell/course_constants.dart';
import 'package:micro_teaching_studio/features/course_shell/course_flow.dart';
import 'package:micro_teaching_studio/features/course_shell/widgets/course_scaffold.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class SignInView extends SignInPage {
  const SignInView({super.key});
}

class _SignInPageState extends State<SignInPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _userNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().signIn(
            userName: _userNameController.text,
            password: _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          context.go(AppRouters.homeView);
        } else if (state.status == AuthStatus.failure &&
            state.errorMessage != null) {
          AppFunctions.showsToast(
            state.errorMessage!.tr(),
            ColorManager.red,
            context,
          );
        }
      },
      builder: (context, state) {
        return CourseScaffold(
          voiceCode: CourseConstants.loginVoiceCode,
          title: AppStrings.loginEnglishTitle.tr(),
          currentIndex: CourseConstants.loginStepIndex,
          onBack: () => CourseFlow.back(context),
          onNext: state.isLoading ? null : _submit,
          backEnabled: CourseFlow.hasPrevious(context),
          body: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              AppPadding.p16.w,
              AppPadding.p8.h,
              AppPadding.p16.w,
              AppPadding.p16.h,
            ),
            child: Column(
              children: [
                Text(
                  AppStrings.welcomeBackTeacher.tr(),
                  textAlign: TextAlign.center,
                  style: getExtraBoldStyle(
                    fontSize: FontSize.s22.sp,
                    color: ColorManager.navy,
                  ).copyWith(letterSpacing: AppLetterSpacing.tight),
                ),
                SizedBox(height: AppPadding.p8.h),
                Text(
                  AppStrings.signInSubtitle.tr(),
                  textAlign: TextAlign.center,
                  style: getRegularStyle(
                    fontSize: FontSize.s12.sp,
                    color: ColorManager.slate,
                  ),
                ),
                SizedBox(height: AppPadding.p16.h),
                SignInFormCard(
                  formKey: _formKey,
                  userNameController: _userNameController,
                  passwordController: _passwordController,
                  isLoading: state.isLoading,
                  onSubmit: _submit,
                ),
                SizedBox(height: AppPadding.p16.h),
                AuthAccountPrompt(
                  message: AppStrings.noAccountYet.tr(),
                  actionLabel: AppStrings.createAccountAction.tr(),
                  onAction: () => context.go(AppRouters.loginView),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
