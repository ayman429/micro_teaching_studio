import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/features/course_video/cubit/course_video_state.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class CourseVideoCubit extends Cubit<CourseVideoState> {
  CourseVideoCubit() : super(const CourseVideoState());

  VideoPlayerController? _controller;
  String? _asset;
  bool _playWhenReady = false;
  bool _handlingEnd = false;

  VideoPlayerController? get controller => _controller;

  Future<void> load(String asset) async {
    if (asset.isEmpty) return;
    _asset = asset;
    _playWhenReady = false;
    _handlingEnd = false;
    await _disposeController();
    emit(const CourseVideoState());
    try {
      final resolved = await _resolveAsset(asset);
      final controller = await _createController(resolved);
      if (isClosed || _asset != asset) {
        await controller.dispose();
        return;
      }
      controller.addListener(_onTick);
      _controller = controller;
      emit(
        CourseVideoState(
          status: CourseVideoStatus.ready,
          duration: controller.value.duration,
        ),
      );
      if (_playWhenReady) {
        _playWhenReady = false;
        await play();
      }
    } catch (error, stack) {
      log('course video: $error', stackTrace: stack);
      if (!isClosed && _asset == asset) {
        emit(
          const CourseVideoState(
            status: CourseVideoStatus.error,
            errorMessage: AppStrings.helpVideoError,
          ),
        );
      }
    }
  }

  Future<void> toggle() async {
    if (!state.isReady || _controller == null) {
      if (state.status == CourseVideoStatus.error && _asset != null) {
        await load(_asset!);
        return;
      }
      _playWhenReady = true;
      return;
    }
    if (state.isPlaying) {
      await pause();
      return;
    }
    await play();
  }

  Future<void> play() async {
    final controller = _controller;
    if (controller == null || !state.isReady) return;
    try {
      await controller.play();
    } catch (error, stack) {
      log('course video play: $error', stackTrace: stack);
    }
  }

  Future<void> pause() async {
    _playWhenReady = false;
    final controller = _controller;
    if (controller == null) return;
    try {
      if (controller.value.isPlaying) {
        await controller.pause();
      }
    } catch (error, stack) {
      log('course video pause: $error', stackTrace: stack);
    }
  }

  void _onTick() {
    final controller = _controller;
    if (controller == null || isClosed) return;
    final value = controller.value;
    if (value.hasError) {
      if (state.status == CourseVideoStatus.error) return;
      emit(
        state.copyWith(
          status: CourseVideoStatus.error,
          isPlaying: false,
          errorMessage: AppStrings.helpVideoError,
        ),
      );
      return;
    }
    if (!value.isInitialized) return;

    final duration = value.duration;
    final position = value.position;
    var progress = 0.0;
    if (duration.inMilliseconds > 0) {
      progress = ((position.inMilliseconds / duration.inMilliseconds) * 100)
              .round()
              .clamp(0, 100) /
          100;
    }

    if (_handlingEnd) {
      if (position.inMilliseconds > 80) return;
      _handlingEnd = false;
      emit(
        state.copyWith(
          isPlaying: false,
          progress: 0,
          position: Duration.zero,
          duration: duration,
        ),
      );
      return;
    }

    final ended = duration.inMilliseconds > 0 &&
        position.inMilliseconds >= duration.inMilliseconds - 80;
    if (ended) {
      unawaited(_onCompleted());
      return;
    }

    final next = state.copyWith(
      isPlaying: value.isPlaying,
      progress: progress,
      position: position,
      duration: duration,
      clearError: true,
    );
    if (next == state) return;
    emit(next);
  }

  Future<void> _onCompleted() async {
    if (_handlingEnd) return;
    _handlingEnd = true;
    if (!isClosed) {
      emit(
        state.copyWith(
          isPlaying: false,
          progress: 0,
          position: Duration.zero,
        ),
      );
    }
    try {
      await _controller?.pause();
      await _controller?.seekTo(Duration.zero);
    } catch (error, stack) {
      log('course video complete: $error', stackTrace: stack);
      _handlingEnd = false;
    }
  }

  Future<VideoPlayerController> _createController(String asset) async {
    if (!kIsWeb && Platform.isAndroid) {
      return _controllerFromCache(asset);
    }
    final fromAsset = VideoPlayerController.asset(asset);
    try {
      await fromAsset.initialize();
      return fromAsset;
    } catch (error, stack) {
      log('course video asset: $error', stackTrace: stack);
      await fromAsset.dispose();
      if (kIsWeb) rethrow;
      return _controllerFromCache(asset);
    }
  }

  Future<VideoPlayerController> _controllerFromCache(String asset) async {
    final file = await _cacheAssetFile(asset);
    final controller = VideoPlayerController.file(file);
    await controller.initialize();
    return controller;
  }

  Future<File> _cacheAssetFile(String asset) async {
    final data = await rootBundle.load(asset);
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${asset.replaceAll('/', '_')}');
    if (await file.exists() && await file.length() == bytes.length) {
      return file;
    }
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  Future<String> _resolveAsset(String asset) async {
    final wanted = asset.replaceAll('\\', '/');
    try {
      await rootBundle.load(wanted);
      return wanted;
    } catch (_) {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      for (final key in manifest.listAssets()) {
        if (key.replaceAll('\\', '/').toLowerCase() != wanted.toLowerCase()) {
          continue;
        }
        await rootBundle.load(key);
        return key;
      }
      rethrow;
    }
  }

  Future<void> _disposeController() async {
    final controller = _controller;
    _controller = null;
    if (controller == null) return;
    controller.removeListener(_onTick);
    try {
      await controller.pause();
    } catch (_) {}
    await controller.dispose();
  }

  @override
  Future<void> close() async {
    await _disposeController();
    return super.close();
  }
}
