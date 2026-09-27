import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/app/imports.dart';
import 'package:micro_teaching_studio/common/resources/assets_manager.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/common/widgets/default_button_widget.dart';
import 'package:micro_teaching_studio/features/course_audio/cubit/course_audio_cubit.dart';
import 'package:micro_teaching_studio/features/course_audio/widgets/course_listen_control.dart';
import 'package:micro_teaching_studio/features/course_shell/widgets/course_svg_icon.dart';
import 'package:micro_teaching_studio/features/session_instructions/session_instructions_copy.dart';
import 'package:micro_teaching_studio/images_urls/assets.dart';

Future<void> playSessionInstructions(int module, int session) {
  return instance<CourseAudioCubit>().playSequence(
    AudioAssets.sessionInstructionsSequence(module, session),
  );
}

class SessionInstructionsPanel extends StatefulWidget {
  const SessionInstructionsPanel({
    super.key,
    required this.module,
    required this.session,
    required this.sessionName,
    required this.onStart,
  });

  final int module;
  final int session;
  final String sessionName;
  final VoidCallback onStart;

  @override
  State<SessionInstructionsPanel> createState() =>
      _SessionInstructionsPanelState();
}

class _SessionInstructionsPanelState extends State<SessionInstructionsPanel> {
  late final Future<SessionInstructionsCopy> _copy = _load();

  Future<SessionInstructionsCopy> _load() async {
    final raw = await rootBundle.loadString(
      AudioAssets.sessionInstructionsText(widget.module, widget.session),
    );
    return parseSessionInstructions(raw);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: instance<CourseAudioCubit>(),
      child: FutureBuilder<SessionInstructionsCopy>(
        future: _copy,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: AppPadding.p24.h),
              child: const Center(child: CircularProgressIndicator()),
            );
          }
          final copy = snapshot.data;
          if (copy == null) {
            return const SizedBox.shrink();
          }
          return _SessionInstructionsCard(
            module: widget.module,
            session: widget.session,
            sessionName: widget.sessionName,
            copy: copy,
            objectivesAudio: AudioAssets.sessionInstructionsObjectives(
              widget.module,
              widget.session,
            ),
            howToApplyAudio: AudioAssets.sessionInstructionsHowToApply(
              widget.module,
              widget.session,
            ),
            onStart: widget.onStart,
          );
        },
      ),
    );
  }
}

class _SessionInstructionsCard extends StatelessWidget {
  const _SessionInstructionsCard({
    required this.module,
    required this.session,
    required this.sessionName,
    required this.copy,
    required this.objectivesAudio,
    required this.howToApplyAudio,
    required this.onStart,
  });

  final int module;
  final int session;
  final String sessionName;
  final SessionInstructionsCopy copy;
  final String objectivesAudio;
  final String howToApplyAudio;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final leadStyle = copy.objectivePoints.isEmpty
        ? getRegularStyle(
            fontSize: FontSize.s12.sp,
            color: ColorManager.slate700,
            height: 1.6,
          )
        : getBoldStyle(
            fontSize: FontSize.s12.sp,
            color: ColorManager.navy,
            height: 1.6,
          );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppPadding.p20.w),
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(AppRadius.r24.r),
        border: Border.all(color: ColorManager.slate100),
        boxShadow: [
          BoxShadow(
            color: ColorManager.black.withValues(alpha: 0.05),
            blurRadius: AppPadding.p4.r,
            offset: Offset(0, 1.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: AppSize.s32.w,
                height: AppSize.s32.w,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: ColorManager.onNavyBody,
                  shape: BoxShape.circle,
                ),
                child: CourseSvgIcon(
                  asset: Assets.assetsIconsSessionTarget,
                  size: AppSize.s16.w,
                ),
              ),
              SizedBox(width: AppPadding.p8.w),
              Expanded(
                child: Text(
                  AppStrings.moduleSessionTitle.tr(
                    namedArgs: {
                      'module': '$module',
                      'session': '$session',
                      'name': sessionName,
                    },
                  ),
                  style: getBoldStyle(
                    fontSize: FontSize.s14.sp,
                    color: ColorManager.slate800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppPadding.p16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(copy.objectivesLead, style: leadStyle),
              ),
              CourseListenControl(
                asset: objectivesAudio,
                color: ColorManager.navy,
                compact: true,
              ),
            ],
          ),
          if (copy.objectivePoints.isNotEmpty) ...[
            SizedBox(height: AppPadding.p8.h),
            for (final point in copy.objectivePoints)
              Padding(
                padding: EdgeInsets.only(top: AppPadding.p8.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 7.h),
                      child: Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: const BoxDecoration(
                          color: ColorManager.royalBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    SizedBox(width: AppPadding.p8.w),
                    Expanded(
                      child: Text(
                        point,
                        style: getRegularStyle(
                          fontSize: FontSize.s12.sp,
                          color: ColorManager.slate700,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
          if (copy.howToApply.isNotEmpty) ...[
            SizedBox(height: AppPadding.p16.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppPadding.p12.w),
              decoration: BoxDecoration(
                color: ColorManager.iceBlue,
                borderRadius: BorderRadius.circular(AppRadius.r16.r),
                border: Border.all(color: ColorManager.onNavyBody),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppStrings.howToApply.tr(),
                          style: getBoldStyle(
                            fontSize: FontSize.s10.sp,
                            color: ColorManager.royalBlue,
                          ).copyWith(letterSpacing: AppLetterSpacing.label),
                        ),
                      ),
                      CourseListenControl(
                        asset: howToApplyAudio,
                        color: ColorManager.navy,
                        compact: true,
                      ),
                    ],
                  ),
                  SizedBox(height: AppPadding.p8.h),
                  Text(
                    copy.howToApply,
                    style: getRegularStyle(
                      fontSize: FontSize.s12.sp,
                      color: ColorManager.slate700,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: AppPadding.p16.h),
          SizedBox(
            height: AppSize.inputHeight.h,
            width: double.infinity,
            child: DefaultButtonWidget(
              onPressed: onStart,
              color: ColorManager.navy,
              radius: AppRadius.r16.r,
              elevation: 0,
              child: Text(
                AppStrings.startSession.tr(),
                textAlign: TextAlign.center,
                style: getBoldStyle(
                  fontSize: FontSize.s16.sp,
                  color: ColorManager.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
