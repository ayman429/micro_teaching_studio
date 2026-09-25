import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/pronunciation_constants.dart';

class SpeechConfigRepository {
  SpeechConfigRepository(this._firestore);

  final FirebaseFirestore _firestore;
  SpeechConfig? _cached;
  Future<SpeechConfig>? _inFlight;

  Future<SpeechConfig> load() {
    if (_cached != null) return Future.value(_cached);
    return _inFlight ??= _load().whenComplete(() => _inFlight = null);
  }

  Future<SpeechConfig> _load() async {
    Object? lastError;
    for (var attempt = 0;
        attempt < PronunciationConstants.configRetryCount;
        attempt++) {
      try {
        await _firestore.enableNetwork();
        final snapshot = await _firestore
            .collection(PronunciationConstants.configCollection)
            .doc(PronunciationConstants.speechDocument)
            .get()
            .timeout(PronunciationConstants.requestTimeout);
        _cached = _fromSnapshot(snapshot);
        return _cached!;
      } on FirebaseException catch (error, stack) {
        lastError = error;
        log(
          'speech config: ${error.code} ${error.message} attempt=$attempt',
          stackTrace: stack,
        );
        final cached = await _tryCache();
        if (cached != null) {
          _cached = cached;
          return cached;
        }
        if (_isOffline(error) &&
            attempt < PronunciationConstants.configRetryCount - 1) {
          await Future<void>.delayed(
            PronunciationConstants.configRetryDelay * (attempt + 1),
          );
          continue;
        }
        throw StateError(
          _isOffline(error)
              ? AppStrings.noInternetError
              : AppStrings.pronunciationConfigMissing,
        );
      } on TimeoutException catch (error, stack) {
        lastError = error;
        log('speech config timeout attempt=$attempt', stackTrace: stack);
        if (attempt < PronunciationConstants.configRetryCount - 1) {
          await Future<void>.delayed(
            PronunciationConstants.configRetryDelay * (attempt + 1),
          );
          continue;
        }
        throw StateError(AppStrings.noInternetError);
      } catch (error, stack) {
        if (error is StateError) rethrow;
        lastError = error;
        log('speech config failed: $error', stackTrace: stack);
        throw StateError(AppStrings.pronunciationConfigMissing);
      }
    }
    log('speech config exhausted retries: $lastError');
    throw StateError(AppStrings.noInternetError);
  }

  Future<SpeechConfig?> _tryCache() async {
    try {
      final snapshot = await _firestore
          .collection(PronunciationConstants.configCollection)
          .doc(PronunciationConstants.speechDocument)
          .get(const GetOptions(source: Source.cache));
      if (!snapshot.exists) return null;
      return _fromSnapshot(snapshot);
    } catch (_) {
      return null;
    }
  }

  bool _isOffline(FirebaseException error) {
    final message = error.message?.toLowerCase() ?? '';
    return error.code == 'unavailable' || message.contains('offline');
  }

  SpeechConfig _fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    final key = _asString(data?[PronunciationConstants.speechKeyField]);
    if (!snapshot.exists || key == null || key.isEmpty) {
      throw StateError(AppStrings.pronunciationConfigMissing);
    }
    final region = _asString(data?[PronunciationConstants.regionField]) ?? '';
    final language = _asString(data?[PronunciationConstants.languageField]) ?? '';
    return SpeechConfig(
      speechKey: key,
      region: region.isEmpty ? PronunciationConstants.defaultRegion : region,
      language:
          language.isEmpty ? PronunciationConstants.defaultLanguage : language,
    );
  }

  String? _asString(dynamic value) {
    if (value == null) return null;
    final text = value is String ? value.trim() : value.toString().trim();
    return text.isEmpty ? null : text;
  }
}
