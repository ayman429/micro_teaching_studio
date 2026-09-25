import 'dart:async';
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/app/app_functions.dart';
import 'package:micro_teaching_studio/app/app_prefs.dart';
import 'package:micro_teaching_studio/app/imports.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/features/auth/cubit/auth_cubit.dart';
import 'package:micro_teaching_studio/features/auth/models/student_avatar.dart';
import 'package:micro_teaching_studio/features/course_shell/course_flow.dart';
import 'package:micro_teaching_studio/features/course_shell/widgets/course_scaffold.dart';
import 'package:micro_teaching_studio/features/course_video/widgets/course_video_player.dart';
import 'package:micro_teaching_studio/features/greetings/cubit/greetings_cubit.dart';
import 'package:micro_teaching_studio/features/greetings/cubit/greetings_state.dart';
import 'package:micro_teaching_studio/features/greetings/widgets/greetings_bubble.dart';
import 'package:micro_teaching_studio/features/greetings/widgets/greetings_practice_bar.dart';

class GreetingsPage extends StatelessWidget {
  const GreetingsPage({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final body = _GreetingsBody(embedded: embedded);
    if (embedded) return body;
    return BlocProvider(
      create: (_) => instance<GreetingsCubit>()..start(),
      child: body,
    );
  }
}

class GreetingsView extends GreetingsPage {
  const GreetingsView({super.key});
}

class _GreetingsBody extends StatefulWidget {
  const _GreetingsBody({required this.embedded});

  final bool embedded;

  @override
  State<_GreetingsBody> createState() => _GreetingsBodyState();
}

class _GreetingsBodyState extends State<_GreetingsBody> {
  final _scroll = ScrollController();
  final _videoHandle = CourseVideoHandle();
  var _routeCurrent = true;
  var _lastMessageCount = 0;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final current = ModalRoute.of(context)?.isCurrent ?? true;
    if (current == _routeCurrent) return;
    _routeCurrent = current;
    final cubit = context.read<GreetingsCubit>();
    if (current) {
      unawaited(cubit.resumeFromOverlay());
      return;
    }
    _videoHandle.pause();
    unawaited(cubit.pauseForOverlay());
  }

  @override
  Widget build(BuildContext context) {
    final avatar = context.watch<AuthCubit>().state.user?.avatar ??
        StudentAvatar.fromName(instance<AppPreferences>().getUserImage());
    return BlocListener<GreetingsCubit, GreetingsState>(
      listenWhen: (previous, current) =>
          current.phase == GreetingsPhase.exit &&
          previous.phase != GreetingsPhase.exit,
      listener: (context, state) {
        _videoHandle.pause();
        CourseFlow.goHome(context);
      },
      child: BlocListener<GreetingsCubit, GreetingsState>(
        listenWhen: (previous, current) =>
            current.phase == GreetingsPhase.recording &&
            previous.phase != GreetingsPhase.recording,
        listener: (context, state) => _videoHandle.pause(),
        child: BlocListener<GreetingsCubit, GreetingsState>(
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
          child: BlocListener<GreetingsCubit, GreetingsState>(
            listenWhen: (previous, current) =>
                current.messages.length != previous.messages.length,
            listener: (context, state) => _scrollToEnd(state.messages.length),
            child: widget.embedded
                ? _lesson(avatar)
                : CourseScaffold(
                    title: AppStrings.session1Greetings.tr(),
                    showSkip: false,
                    body: _lesson(avatar),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _lesson(StudentAvatar avatar) {
    return SafeArea(
      top: false,
      child: Directionality(
        textDirection: ui.TextDirection.ltr,
        child: BlocBuilder<GreetingsCubit, GreetingsState>(
          builder: (context, state) {
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    controller: _scroll,
                    padding: EdgeInsets.fromLTRB(
                      AppPadding.p16.w,
                      AppPadding.p16.h,
                      AppPadding.p16.w,
                      AppPadding.p16.h,
                    ),
                    children: [
                      for (final message in state.messages)
                        if (!message.afterVideo)
                          GreetingsBubble(
                            message: message,
                            avatar: avatar,
                          ),
                      if (state.videoVisible) ...[
                        CourseVideoPlayer(
                          key: ValueKey(
                            context.read<GreetingsCubit>().plan.videoAsset,
                          ),
                          asset: context.read<GreetingsCubit>().plan.videoAsset,
                          introLabel: AppStrings.greetingsVideoIntro,
                          onCompleted: () =>
                              context.read<GreetingsCubit>().onVideoCompleted(),
                          onPlaybackStarted: () {
                            final cubit = context.read<GreetingsCubit>();
                            final phase = cubit.state.phase;
                            final intro = phase == GreetingsPhase.intro ||
                                phase == GreetingsPhase.watching;
                            if (!intro) {
                              _videoHandle.pause();
                              return;
                            }
                            unawaited(cubit.onVideoStarted());
                          },
                          handle: _videoHandle,
                        ),
                        SizedBox(height: AppPadding.p16.h),
                      ],
                      for (final message in state.messages)
                        if (message.afterVideo)
                          GreetingsBubble(
                            message: message,
                            avatar: avatar,
                          ),
                    ],
                  ),
                ),
                if (state.showPractice)
                  GreetingsPracticeBar(
                    state: state,
                    onPressed: () => context.read<GreetingsCubit>().toggleMic(),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _scrollToEnd(int count) {
    if (count == _lastMessageCount) return;
    _lastMessageCount = count;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }
}
