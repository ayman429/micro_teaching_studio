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
import 'package:micro_teaching_studio/features/auth/models/student_avatar.dart';
import 'package:micro_teaching_studio/features/auth/widgets/auth_account_prompt.dart';
import 'package:micro_teaching_studio/features/auth/widgets/login_form_card.dart';
import 'package:micro_teaching_studio/features/course_shell/widgets/course_scaffold.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class LoginView extends LoginPage {
  const LoginView({super.key});
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  StudentAvatar _selectedAvatar = StudentAvatar.girl1;

  @override
  void dispose() {
    _fullNameController.dispose();
    _userNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().createAccount(
            fullName: _fullNameController.text,
            userName: _userNameController.text,
            password: _passwordController.text,
            avatar: _selectedAvatar,
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
          title: AppStrings.createAccountEnglishTitle.tr(),
          showSkip: false,
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
                  AppStrings.welcomeFutureTeacher.tr(),
                  textAlign: TextAlign.center,
                  style: getExtraBoldStyle(
                    fontSize: FontSize.s22.sp,
                    color: ColorManager.navy,
                  ).copyWith(letterSpacing: AppLetterSpacing.tight),
                ),
                SizedBox(height: AppPadding.p16.h),
                LoginFormCard(
                  formKey: _formKey,
                  fullNameController: _fullNameController,
                  userNameController: _userNameController,
                  passwordController: _passwordController,
                  selectedAvatar: _selectedAvatar,
                  isLoading: state.isLoading,
                  onAvatarSelected: (avatar) {
                    setState(() => _selectedAvatar = avatar);
                  },
                  onSubmit: _submit,
                ),
                SizedBox(height: AppPadding.p16.h),
                AuthAccountPrompt(
                  message: AppStrings.alreadyHaveAccount.tr(),
                  actionLabel: AppStrings.loginAction.tr(),
                  onAction: () => context.go(AppRouters.signInView),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
