import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/app/app_functions.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/features/course_shell/widgets/course_svg_icon.dart';
import 'package:micro_teaching_studio/features/course_video/cubit/course_video_cubit.dart';
import 'package:micro_teaching_studio/features/course_video/cubit/course_video_state.dart';
import 'package:micro_teaching_studio/features/splash/widgets/help_volume_icon.dart';
import 'package:micro_teaching_studio/images_urls/assets.dart';
import 'package:video_player/video_player.dart';

class CourseVideoPlayer extends StatelessWidget {
  const CourseVideoPlayer({
    super.key,
    required this.asset,
    this.introLabel = AppStrings.helpVideoIntro,
    this.qualityLabel = AppStrings.helpVideoQuality,
  });

  final String asset;
  final String introLabel;
  final String qualityLabel;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CourseVideoCubit()..load(asset),
      child: _CourseVideoCard(
        introLabel: introLabel,
        qualityLabel: qualityLabel,
      ),
    );
  }
}

class _CourseVideoCard extends StatefulWidget {
  const _CourseVideoCard({
    required this.introLabel,
    required this.qualityLabel,
  });

  final String introLabel;
  final String qualityLabel;

  @override
  State<_CourseVideoCard> createState() => _CourseVideoCardState();
}

class _CourseVideoCardState extends State<_CourseVideoCard>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) return;
    if (!mounted) return;
    context.read<CourseVideoCubit>().pause();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isCurrent = ModalRoute.of(context)?.isCurrent ?? true;
    if (isCurrent) return;
    context.read<CourseVideoCubit>().pause();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CourseVideoCubit, CourseVideoState>(
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
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppPadding.p8.w),
        decoration: BoxDecoration(
          color: ColorManager.slate900,
          borderRadius: BorderRadius.circular(AppRadius.r24.r),
          boxShadow: [
            BoxShadow(
              color: ColorManager.black.withValues(alpha: 0.1),
              blurRadius: AppPadding.p24.r,
              offset: Offset(0, AppPadding.p8.h),
            ),
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.r18.r),
              child: SizedBox(
                height: AppSize.videoPlayerHeight.h,
                width: double.infinity,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => context.read<CourseVideoCubit>().toggle(),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: ColorManager.gradientVideoPlayer,
                          ),
                        ),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: const Alignment(-0.4, -0.4),
                            radius: 0.9,
                            colors: [
                              ColorManager.actionBlue.withValues(alpha: 0.25),
                              ColorManager.transparent,
                            ],
                          ),
                        ),
                      ),
                      BlocBuilder<CourseVideoCubit, CourseVideoState>(
                        buildWhen: (previous, current) =>
                            previous.isReady != current.isReady,
                        builder: (context, video) {
                          final controller =
                              context.read<CourseVideoCubit>().controller;
                          if (!video.isReady || controller == null) {
                            return const SizedBox.shrink();
                          }
                          return _CoverVideo(controller: controller);
                        },
                      ),
                      BlocBuilder<CourseVideoCubit, CourseVideoState>(
                        buildWhen: (previous, current) =>
                            previous.isPlaying != current.isPlaying,
                        builder: (context, video) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipOval(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: AppPadding.p4.r,
                                    sigmaY: AppPadding.p4.r,
                                  ),
                                  child: Container(
                                    width: AppSize.s64.w,
                                    height: AppSize.s64.w,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: ColorManager.onDarkFill,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: ColorManager.onDarkStroke,
                                      ),
                                    ),
                                    child: CourseSvgIcon(
                                      asset: video.isPlaying
                                          ? Assets.assetsIconsHelpPause
                                          : Assets.assetsIconsHelpPlay,
                                      size: AppSize.s24.w,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: AppPadding.p12.h),
                              Text(
                                AppStrings.videoPlayerLabel.tr(),
                                style: getBoldStyle(
                                  fontSize: FontSize.s11.sp,
                                  color: ColorManager.onDarkSoft,
                                ).copyWith(
                                  letterSpacing: AppLetterSpacing.video,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      Positioned(
                        left: AppPadding.p12.w,
                        right: AppPadding.p12.w,
                        bottom: AppPadding.p12.h,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppRadius.rCapsule.r,
                          ),
                          child: SizedBox(
                            height: AppSize.s4.h,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                const ColoredBox(
                                  color: ColorManager.onDarkFill,
                                ),
                                BlocBuilder<CourseVideoCubit, CourseVideoState>(
                                  buildWhen: (previous, current) =>
                                      previous.progress != current.progress,
                                  builder: (context, video) {
                                    return FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: video.progress,
                                      child: const ColoredBox(
                                        color: ColorManager.accentAmber,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppPadding.p12.w,
                AppPadding.p12.h,
                AppPadding.p12.w,
                AppPadding.p4.h,
              ),
              child: Row(
                children: [
                  HelpVolumeIcon(size: AppSize.s12.w),
                  SizedBox(width: AppPadding.p6.w),
                  Expanded(
                    child: BlocBuilder<CourseVideoCubit, CourseVideoState>(
                      buildWhen: (previous, current) =>
                          previous.duration != current.duration,
                      builder: (context, video) {
                        return Text(
                          widget.introLabel.tr(
                            namedArgs: {
                              'duration': video.durationLabel,
                            },
                          ),
                          style: getBoldStyle(
                            fontSize: FontSize.s11.sp,
                            color: ColorManager.onDarkMuted,
                          ).copyWith(letterSpacing: AppLetterSpacing.video),
                        );
                      },
                    ),
                  ),
                  Text(
                    widget.qualityLabel.tr(),
                    style: getRegularStyle(
                      fontSize: FontSize.s10.sp,
                      color: ColorManager.onDarkFaint,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoverVideo extends StatelessWidget {
  const _CoverVideo({required this.controller});

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    final size = controller.value.size;
    if (size.isEmpty) return const SizedBox.expand();
    return RepaintBoundary(
      child: IgnorePointer(
        child: SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: VideoPlayer(controller),
            ),
          ),
        ),
      ),
    );
  }
}
