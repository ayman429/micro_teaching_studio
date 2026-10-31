import 'dart:async';
import 'dart:developer';

import 'package:flutter/scheduler.dart';
import 'package:micro_teaching_studio/app/imports.dart';
import 'package:micro_teaching_studio/features/course_audio/cubit/course_audio_cubit.dart';
import 'package:micro_teaching_studio/features/home/cubit/course_progress_cubit.dart';
import 'package:micro_teaching_studio/features/session_instructions/session_instructions_panel.dart';

/// Waits until lesson cubits from a restudy rebuild have finished disposing.
const Duration _restudyAudioDefer = Duration(milliseconds: 300);

typedef SessionInstructionPlayback = Future<void> Function(
  void Function() onFinished,
);

/// Plays session instructions after optional restudy deferral.
/// [setReady] runs when autoplay finishes, errors, times out, or after restudy.
Future<void> runSessionInstructionGate({
  required int module,
  required int session,
  required CourseProgressCubit progress,
  required void Function(bool ready) setReady,
  required bool Function() isMounted,
  SessionInstructionPlayback? play,
}) async {
  final afterRestudy = progress.isLessonReplayPending(module, session);

  if (afterRestudy) {
    setReady(true);
  } else {
    setReady(false);
  }

  if (afterRestudy) {
    await Future<void>.delayed(_restudyAudioDefer);
  }
  if (!isMounted()) return;

  await instance<CourseAudioCubit>().stop();
  if (!isMounted()) return;

  Timer? timeout;
  var finished = false;
  void complete() {
    if (finished || !isMounted()) return;
    finished = true;
    timeout?.cancel();
    setReady(true);
  }

  timeout = Timer(const Duration(seconds: 60), complete);
  try {
    if (play != null) {
      await play(complete);
    } else {
      await playSessionInstructions(
        module,
        session,
        onFinished: complete,
      );
    }
  } catch (error, stack) {
    log('session instruction gate: $error', stackTrace: stack);
    complete();
  } finally {
    timeout.cancel();
  }
}

void scheduleSessionInstructionGate({
  required int module,
  required int session,
  required CourseProgressCubit progress,
  required void Function(bool ready) setReady,
  required bool Function() isMounted,
  SessionInstructionPlayback? play,
}) {
  SchedulerBinding.instance.addPostFrameCallback((_) {
    unawaited(
      runSessionInstructionGate(
        module: module,
        session: session,
        progress: progress,
        setReady: setReady,
        isMounted: isMounted,
        play: play,
      ),
    );
  });
}
