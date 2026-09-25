import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/features/auth/models/student_avatar.dart';
import 'package:micro_teaching_studio/features/auth/widgets/student_avatar_image.dart';
import 'package:micro_teaching_studio/features/greetings/cubit/greetings_state.dart';
import 'package:micro_teaching_studio/images_urls/assets.dart';

class GreetingsBubble extends StatelessWidget {
  const GreetingsBubble({
    super.key,
    required this.message,
    required this.avatar,
  });

  final GreetingsMessage message;
  final StudentAvatar avatar;

  bool get _isTwin => message.speaker == GreetingsSpeaker.twin;

  @override
  Widget build(BuildContext context) {
    final palette = _palette(message.tone);
    final body = message.localized ? message.text.tr() : message.text;
    return Padding(
      padding: EdgeInsets.only(bottom: AppPadding.p12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_isTwin) ...[
            _TwinAvatar(),
            SizedBox(width: AppPadding.p8.w),
          ],
          Flexible(
            child: Align(
              alignment: _isTwin ? Alignment.centerLeft : Alignment.centerRight,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppPadding.p12.w,
                  vertical: AppPadding.p12.h,
                ),
                decoration: BoxDecoration(
                  color: palette.background,
                  borderRadius: BorderRadius.circular(AppRadius.r18.r),
                  border: Border.all(color: palette.border),
                ),
                child: Column(
                  crossAxisAlignment: _isTwin
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.end,
                  children: [
                    if (_isTwin) ...[
                      Text(
                        AppStrings.aiTwinTitle.tr(),
                        style: getBoldStyle(
                          fontSize: FontSize.s11.sp,
                          color: palette.label,
                        ),
                      ),
                      SizedBox(height: AppPadding.p4.h),
                    ],
                    Text(
                      body,
                      style: getRegularStyle(
                        fontSize: FontSize.s13.sp,
                        color: palette.body,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (!_isTwin) ...[
            SizedBox(width: AppPadding.p8.w),
            ClipOval(
              child: StudentAvatarImage(
                avatar: avatar,
                width: AppSize.s40.w,
                height: AppSize.s40.w,
              ),
            ),
          ],
        ],
      ),
    );
  }

  _BubblePalette _palette(GreetingsTone tone) {
    if (!_isTwin) {
      return const _BubblePalette(
        background: ColorManager.navy,
        border: ColorManager.navy,
        label: ColorManager.white,
        body: ColorManager.white,
      );
    }
    switch (tone) {
      case GreetingsTone.correct:
        return const _BubblePalette(
          background: ColorManager.mintSoft,
          border: ColorManager.mintBorder,
          label: ColorManager.emerald,
          body: ColorManager.emerald,
        );
      case GreetingsTone.retry:
        return const _BubblePalette(
          background: ColorManager.amberWash,
          border: ColorManager.amberBorder,
          label: ColorManager.amberDeep,
          body: ColorManager.amberDeep,
        );
      case GreetingsTone.exhausted:
        return const _BubblePalette(
          background: ColorManager.roseSoft,
          border: ColorManager.roseDeep,
          label: ColorManager.roseDeep,
          body: ColorManager.roseDeep,
        );
      case GreetingsTone.speech:
        return const _BubblePalette(
          background: ColorManager.white,
          border: ColorManager.slate100,
          label: ColorManager.navy,
          body: ColorManager.slate800,
        );
    }
  }
}

class _TwinAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(
        Assets.assetsImagesAiTwinHead,
        width: AppSize.s40.w,
        height: AppSize.s40.w,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _BubblePalette {
  const _BubblePalette({
    required this.background,
    required this.border,
    required this.label,
    required this.body,
  });

  final Color background;
  final Color border;
  final Color label;
  final Color body;
}
