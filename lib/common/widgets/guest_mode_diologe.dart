// ignore_for_file: use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_teaching_studio/app/app_prefs.dart';
import 'package:micro_teaching_studio/app/imports.dart';
import 'package:micro_teaching_studio/common/extensions/context_extension.dart';
import 'package:micro_teaching_studio/common/resources/app_router.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';

class GuestModeDiolge extends StatelessWidget {
  const GuestModeDiolge({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: Text(
          AppStrings.guest.tr(), //"Guest Mode"
          style: context.textTheme.headlineSmall,
        ),
      ),
      content: Text(
        AppStrings.loginToAccess
            .tr(), //"You need to login to access this feature."
        style: context.textTheme.bodyLarge,
        textAlign: TextAlign.center,
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppStrings.cancel.tr()), //"Cancel"
              ),
            ),
            // Spacer(),
            Expanded(
              flex: 3,
              child: TextButton(
                onPressed: () async {
                  Navigator.pop(context);

                  final AppPreferences appPreferences =
                      instance<AppPreferences>();
                  await appPreferences.logout();

                  await instance.reset();
                  await initAppModule();
                  context.pushReplacement(AppRouters.loginView);
                },
                child: Text(AppStrings.login.tr()), //"login"
              ),
            ),
          ],
        ),
      ],
    );
  }
}
