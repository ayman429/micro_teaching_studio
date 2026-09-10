import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/app/app_functions.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/features/course_audio/cubit/course_audio_cubit.dart';
import 'package:micro_teaching_studio/features/course_audio/cubit/course_audio_state.dart';
import 'package:micro_teaching_studio/features/course_shell/widgets/course_svg_icon.dart';
import 'package:micro_teaching_studio/images_urls/assets.dart';

class CourseListenControl extends StatelessWidget {
  const CourseListenControl({
    super.key,
    required this.asset,
    required this.color,
    this.enabled = true,
  });

  final String asset;
  final Color color;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return BlocListener<CourseAudioCubit, CourseAudioState>(
      listenWhen: (previous, current) =>
          current.errorMessage != null &&
          current.errorMessage != previous.errorMessage,
      listener: (context, state) {
        AppFunctions.showsToast(
          state.errorMessage!.tr(),
          ColorManager.red,
          context,
        );
      },
      child: BlocBuilder<CourseAudioCubit, CourseAudioState>(
        builder: (context, audio) {
          final playing = audio.isPlayingAsset(asset);
          return Column(
            children: [
              CourseCircleIconButton(
                asset: playing
                    ? Assets.assetsIconsHelpPause
                    : Assets.assetsIconsHelpPlay,
                size: AppSize.s40.w,
                iconSize: AppSize.s16.w,
                backgroundColor: !enabled
                    ? ColorManager.slate200
                    : playing
                        ? ColorManager.actionBlue
                        : color,
                onPressed: !enabled
                    ? null
                    : () => context.read<CourseAudioCubit>().toggle(asset),
              ),
              SizedBox(height: AppPadding.p8.h),
              Text(
                playing
                    ? AppStrings.tapToStopListen.tr()
                    : AppStrings.listenAction.tr(),
                textAlign: TextAlign.center,
                style: getRegularStyle(
                  fontSize: FontSize.s11.sp,
                  color: playing ? ColorManager.actionBlue : ColorManager.slate,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
