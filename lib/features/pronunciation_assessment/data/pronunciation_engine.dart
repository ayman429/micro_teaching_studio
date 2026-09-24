import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/models/pronunciation_result.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/pronunciation_constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class PronunciationEngine {
  PronunciationEngine({AudioRecorder? recorder})
      : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;

  Future<void> dispose() => _recorder.dispose();

  Future<void> startRecording() async {
    try {
      final status = await Permission.microphone.request();
      if (!status.isGranted || !await _recorder.hasPermission()) {
        throw StateError(AppStrings.pronunciationMicDenied);
      }
      if (await _recorder.isRecording()) {
        await _recorder.stop();
      }
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/pronunciation_${DateTime.now().millisecondsSinceEpoch}.wav';
      var encoder = AudioEncoder.wav;
      if (!await _recorder.isEncoderSupported(encoder)) {
        encoder = AudioEncoder.pcm16bits;
      }
      await _recorder.start(
        RecordConfig(
          encoder: encoder,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: path,
      );
    } catch (error, stack) {
      if (error is StateError) rethrow;
      log('startRecording failed: $error', stackTrace: stack);
      throw StateError(AppStrings.pronunciationMicDenied);
    }
  }

  Future<File> stopRecording() async {
    try {
      final path = await _recorder.stop();
      if (path == null) {
        throw StateError(AppStrings.pronunciationNoAudio);
      }
      return File(path);
    } catch (error, stack) {
      if (error is StateError) rethrow;
      log('stopRecording failed: $error', stackTrace: stack);
      throw StateError(AppStrings.pronunciationNoAudio);
    }
  }

  String sanitizeReference(String text) {
    return text
        .replaceAll('“', '')
        .replaceAll('”', '')
        .replaceAll('"', '')
        .trim();
  }

  Future<PronunciationResult> assess({
    required File audioFile,
    required String referenceText,
    required SpeechConfig config,
    bool enableProsody = true,
    bool phonics = false,
  }) async {
    try {
      if (!await audioFile.exists()) {
        throw StateError(AppStrings.pronunciationNoAudio);
      }
      final rawBytes = await audioFile.readAsBytes();
      final isAlreadyWav = rawBytes.length >= 12 &&
          ascii.decode(rawBytes.sublist(0, 4), allowInvalid: true) == 'RIFF';
      final wavBytes = isAlreadyWav ? rawBytes : _pcmToWav(rawBytes);
      if (wavBytes.length < 4000) {
        throw StateError(AppStrings.pronunciationTooShort);
      }

      http.Response? response;
      try {
        response = await _postAssessment(
          wavBytes: wavBytes,
          referenceText: referenceText,
          config: config,
          enableProsody: enableProsody,
          includePhonemeExtras: true,
        );
      } on http.ClientException catch (error) {
        log('Azure STT extras request failed: $error');
      }
      if (response == null || response.statusCode != 200) {
        log(
          'Azure STT retry without extras status=${response?.statusCode} body=${response?.body}',
        );
        response = await _postAssessment(
          wavBytes: wavBytes,
          referenceText: referenceText,
          config: config,
          enableProsody: enableProsody,
          includePhonemeExtras: false,
        );
      }

      log('Azure STT status=${response.statusCode} bytes=${wavBytes.length}');
      if (response.statusCode != 200) {
        log('Azure STT body=${response.body}');
        throw StateError(AppStrings.pronunciationServiceError);
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        log('Azure STT unexpected body=${response.body}');
        throw StateError(AppStrings.pronunciationNoResult);
      }
      return _parse(
        Map<String, dynamic>.from(decoded),
        response.statusCode,
        phonics: phonics,
        referenceText: referenceText,
      );
    } catch (error, stack) {
      if (error is StateError) rethrow;
      log('assess failed type=${error.runtimeType} error=$error',
          stackTrace: stack);
      throw StateError(AppStrings.pronunciationServiceError);
    }
  }

  Future<http.Response> _postAssessment({
    required Uint8List wavBytes,
    required String referenceText,
    required SpeechConfig config,
    required bool enableProsody,
    required bool includePhonemeExtras,
  }) async {
    final pronParams = {
      'ReferenceText': sanitizeReference(referenceText),
      'GradingSystem': 'HundredMark',
      'Granularity': 'Phoneme',
      'Dimension': 'Comprehensive',
      'EnableMiscue': 'True',
      'EnableProsodyAssessment': enableProsody ? 'True' : 'False',
      if (includePhonemeExtras) 'PhonemeAlphabet': 'IPA',
      if (includePhonemeExtras) 'NBestPhonemeCount': '3',
    };
    final url = Uri.parse(
      'https://${config.region}.stt.speech.microsoft.com/speech/recognition/conversation/cognitiveservices/v1'
      '?language=${config.language}&format=detailed',
    );
    final headers = {
      'Ocp-Apim-Subscription-Key': config.speechKey,
      'Content-Type': 'audio/wav; codecs=audio/pcm; samplerate=16000',
      'Accept': 'application/json',
      'Pronunciation-Assessment':
          base64Encode(utf8.encode(jsonEncode(pronParams))),
    };
    http.ClientException? lastClosed;
    for (var attempt = 0; attempt < 2; attempt++) {
      final client = http.Client();
      try {
        return await client
            .post(url, headers: headers, body: wavBytes)
            .timeout(PronunciationConstants.requestTimeout);
      } on http.ClientException catch (error, stack) {
        lastClosed = error;
        log(
          'Azure STT connection closed attempt=$attempt extras=$includePhonemeExtras error=$error',
          stackTrace: stack,
        );
        await Future<void>.delayed(PronunciationConstants.configRetryDelay);
      } finally {
        client.close();
      }
    }
    throw lastClosed ??
        http.ClientException('Connection closed while receiving data', url);
  }

  PronunciationResult _parse(
    Map<String, dynamic> data,
    int httpStatus, {
    bool phonics = false,
    required String referenceText,
  }) {
    final nBest = data['NBest'] is List && (data['NBest'] as List).isNotEmpty
        ? (data['NBest'] as List)[0]
        : null;
    if (nBest is! Map) {
      throw StateError(AppStrings.pronunciationNoResult);
    }
    final pron = _pronFromNBest(nBest);
    final rawWords = nBest['Words'] is List ? nBest['Words'] as List : [];
    final words = rawWords
        .whereType<Map>()
        .map((word) => _parseWord(word, phonics: phonics))
        .toList();

    var score = _asDouble(pron['PronScore']) ?? _asDouble(pron['AccuracyScore']);
    var pronScore = _asDouble(pron['PronScore']);
    var accuracyScore = _asDouble(pron['AccuracyScore']);
    var heard = (data['DisplayText'] ??
            (nBest['Display'] ?? nBest['Lexical']))
        ?.toString();
    var scoredWords = words;
    var phonicsMismatch = phonics &&
        PronunciationResult.phonicsWordMismatch(heard, referenceText);
    if (phonics && !phonicsMismatch) {
      for (final word in words) {
        if (!word.isInsertion) continue;
        if (!PronunciationResult.phonicsWordMismatch(word.word, referenceText)) {
          continue;
        }
        phonicsMismatch = true;
        heard = word.word;
        break;
      }
    }

    if (phonicsMismatch) {
      final heardWord = PronunciationResult.spokenWord(heard);
      score = PronunciationResult.capPhonicsWrongWordScore(score);
      pronScore = PronunciationResult.capPhonicsWrongWordScore(pronScore);
      accuracyScore = PronunciationResult.capPhonicsWrongWordScore(accuracyScore);
      scoredWords = words
          .map(
            (word) => word.isInsertion
                ? word
                : PronunciationWordScore(
                    word: word.word,
                    accuracy: PronunciationResult.capPhonicsWrongWordScore(
                      word.accuracy,
                    ),
                    errorType: word.errorType,
                    phonemes: word.phonemes,
                    phonics: word.phonics,
                    heardWord: heardWord,
                    wrongWord: true,
                  ),
          )
          .toList();
    }

    PronunciationWordScore? weakestWord;
    PronunciationPhonemeScore? weakestPhoneme;
    for (final word in scoredWords) {
      if (word.word.isEmpty || word.isInsertion) continue;
      if (weakestWord == null ||
          (word.accuracy ?? 100) < (weakestWord.accuracy ?? 100)) {
        weakestWord = word;
      }
      final phoneme = word.weakestPhoneme;
      if (phoneme == null) continue;
      if (weakestPhoneme == null ||
          (phoneme.accuracy ?? 100) < (weakestPhoneme.accuracy ?? 100)) {
        weakestPhoneme = phoneme;
      }
    }

    return PronunciationResult(
      raw: data,
      pronScore: pronScore,
      accuracyScore: accuracyScore,
      fluencyScore: _asDouble(pron['FluencyScore']),
      completenessScore: _asDouble(pron['CompletenessScore']),
      prosodyScore: _asDouble(pron['ProsodyScore']),
      words: scoredWords,
      band: PronunciationResult.bandFromScore(score, phonics: phonics),
      heardText: heard,
      recognitionStatus: data['RecognitionStatus']?.toString(),
      httpStatus: httpStatus,
      weakestWord: weakestWord?.word,
      weakestPhoneme: weakestPhoneme?.phoneme,
      heardPhoneme: weakestPhoneme?.heardPhoneme,
      phonics: phonics,
    );
  }

  PronunciationWordScore _parseWord(Map word, {bool phonics = false}) {
    final assessment = _wordPron(word);
    final rawPhonemes = word['Phonemes'] is List ? word['Phonemes'] as List : [];
    return PronunciationWordScore(
      word: (word['Word'] ?? '').toString(),
      accuracy: _asDouble(assessment['AccuracyScore']),
      errorType: (assessment['ErrorType'] ?? 'None').toString(),
      phonemes: rawPhonemes
          .whereType<Map>()
          .map((phoneme) => _parsePhoneme(phoneme, phonics: phonics))
          .toList(),
      phonics: phonics,
    );
  }

  PronunciationPhonemeScore _parsePhoneme(
    Map phoneme, {
    bool phonics = false,
  }) {
    final assessment = _wordPron(phoneme);
    final expected = (phoneme['Phoneme'] ?? '').toString();
    String? heard;
    final nBest = assessment['NBestPhonemes'] is List
        ? assessment['NBestPhonemes'] as List
        : phoneme['NBestPhonemes'] is List
            ? phoneme['NBestPhonemes'] as List
            : const [];
    if (nBest.isNotEmpty && nBest.first is Map) {
      heard = ((nBest.first as Map)['Phoneme'] ?? '').toString();
      if (heard.isEmpty || heard == expected) heard = null;
    }
    final candidates = <PronunciationPhonemeCandidate>[];
    for (final item in nBest) {
      if (item is! Map) continue;
      final symbol = (item['Phoneme'] ?? '').toString().trim();
      if (symbol.isEmpty) continue;
      candidates.add(
        PronunciationPhonemeCandidate(
          phoneme: symbol,
          accuracy: _asDouble(item['Score'] ?? item['AccuracyScore']),
        ),
      );
      if (candidates.length == 3) break;
    }
    return PronunciationPhonemeScore(
      phoneme: expected,
      accuracy: _asDouble(assessment['AccuracyScore']),
      heardPhoneme: heard,
      nBest: candidates,
      phonics: phonics,
    );
  }

  double? _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return null;
  }

  Map<String, dynamic> _pronFromNBest(Map nBest) {
    if (nBest['PronunciationAssessment'] is Map) {
      return Map<String, dynamic>.from(nBest['PronunciationAssessment'] as Map);
    }
    return {
      'PronScore': nBest['PronScore'],
      'AccuracyScore': nBest['AccuracyScore'],
      'FluencyScore': nBest['FluencyScore'],
      'CompletenessScore': nBest['CompletenessScore'],
      'ProsodyScore': nBest['ProsodyScore'],
    };
  }

  Map<String, dynamic> _wordPron(Map word) {
    if (word['PronunciationAssessment'] is Map) {
      return Map<String, dynamic>.from(word['PronunciationAssessment'] as Map);
    }
    return {
      'AccuracyScore': word['AccuracyScore'],
      'ErrorType': word['ErrorType'],
    };
  }

  Uint8List _pcmToWav(Uint8List pcm) {
    const sampleRate = 16000;
    const channels = 1;
    const bits = 16;
    final byteRate = sampleRate * channels * bits ~/ 8;
    final blockAlign = channels * bits ~/ 8;
    final header = BytesBuilder();

    void writeString(String value) => header.add(ascii.encode(value));
    void write32(int value) {
      header.add([
        value & 0xff,
        (value >> 8) & 0xff,
        (value >> 16) & 0xff,
        (value >> 24) & 0xff,
      ]);
    }

    void write16(int value) {
      header.add([value & 0xff, (value >> 8) & 0xff]);
    }

    writeString('RIFF');
    write32(36 + pcm.length);
    writeString('WAVE');
    writeString('fmt ');
    write32(16);
    write16(1);
    write16(channels);
    write32(sampleRate);
    write32(byteRate);
    write16(blockAlign);
    write16(bits);
    writeString('data');
    write32(pcm.length);
    header.add(pcm);
    return Uint8List.fromList(header.takeBytes());
  }
}
