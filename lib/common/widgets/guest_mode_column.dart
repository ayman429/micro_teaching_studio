// ignore_for_file: use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_teaching_studio/app/app_prefs.dart';
import 'package:micro_teaching_studio/app/imports.dart';
import 'package:micro_teaching_studio/common/extensions/context_extension.dart';
import 'package:micro_teaching_studio/common/resources/app_router.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/widgets/default_button_widget.dart';

class GuestModeColumn extends StatelessWidget {
  const GuestModeColumn({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.r, vertical: 5.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Text(
                  AppStrings.youAreInGuestMode.tr(), //'you_are_in_guest_mode'
                  style: context.textTheme.headlineMedium),
            ),
            Gap(40.h),
            DefaultButtonWidget(
              width: 0.8.sw,
              color: ColorManager.primary,
              textColor: ColorManager.yellow,
              text: AppStrings.login.tr(),
              onPressed: () async {
                final AppPreferences appPreferences =
                    instance<AppPreferences>();
                await appPreferences.logout();

                await instance.reset();
                await initAppModule();
                context.pushReplacement(AppRouters.loginView);
              },
            ),
            // InkWell(
            //   onTap: () async {
            //     Navigator.pop(context);

            //     final AppPreferences appPreferences =
            //         instance<AppPreferences>();
            //     await appPreferences.logout();

            //     await instance.reset();
            //     await initAppModule();
            //     context.pushReplacement(AppRouters.root);
            //   },
            //   borderRadius: BorderRadius.circular(32.r),
            //   child: Container(
            //     height: 56.h,
            //     width: double.infinity,
            //     decoration: BoxDecoration(
            //       color: ColorManager.primary,
            //       borderRadius: BorderRadius.circular(32.r),
            //       boxShadow: const [
            //         BoxShadow(
            //           color: Colors.black12,
            //           blurRadius: 4,
            //           offset: Offset(0, 2),
            //         ),
            //       ],
            //     ),
            //     child: Center(
            //         child: Text(AppStrings.login.tr(),
            //             style: context.textTheme.headlineLarge
            //                 ?.copyWith(color: Colors.white))),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
