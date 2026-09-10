import 'dart:async';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/features/course_audio/cubit/course_audio_state.dart';

class CourseAudioCubit extends Cubit<CourseAudioState> {
  CourseAudioCubit() : super(const CourseAudioState()) {
    _playerSub = _player.playerStateStream.listen(_onPlayerState);
  }

  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<PlayerState>? _playerSub;
  String? _activeAsset;

  Future<void> toggle(String asset) async {
    if (asset.isEmpty) return;
    if (state.isPlayingAsset(asset)) {
      await stop();
      return;
    }
    await play(asset);
  }

  Future<void> play(String asset) async {
    if (asset.isEmpty) return;
    _activeAsset = asset;
    emit(
      CourseAudioState(playingAsset: asset),
    );
    try {
      final resolved = await _resolveAsset(asset);
      if (_activeAsset != asset) return;
      try {
        await _player.setAsset(resolved);
      } catch (_) {
        final data = await rootBundle.load(resolved);
        await _player.setAudioSource(
          AudioSource.uri(
            Uri.dataFromBytes(
              data.buffer.asUint8List(
                data.offsetInBytes,
                data.lengthInBytes,
              ),
              mimeType: 'audio/mpeg',
            ),
          ),
        );
      }
      if (_activeAsset != asset) return;
      await _player.play();
    } catch (error, stack) {
      log('course audio: $error', stackTrace: stack);
      _activeAsset = null;
      if (!isClosed) {
        emit(
          const CourseAudioState(
            errorMessage: AppStrings.listenAudioError,
          ),
        );
      }
    }
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

  Future<void> stop() async {
    _activeAsset = null;
    try {
      await _player.stop();
    } catch (error, stack) {
      log('course audio stop: $error', stackTrace: stack);
    }
    if (!isClosed) emit(const CourseAudioState());
  }

  void _onPlayerState(PlayerState playerState) {
    if (playerState.processingState != ProcessingState.completed) return;
    _activeAsset = null;
    if (!isClosed) emit(const CourseAudioState());
  }

  @override
  Future<void> close() async {
    await _playerSub?.cancel();
    await _player.dispose();
    return super.close();
  }
}
