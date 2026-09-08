import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:micro_teaching_studio/app/imports.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/styles_manager.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/data/speech_config_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class PronunciationAssessmentPage extends StatefulWidget {
  const PronunciationAssessmentPage({super.key});

  @override
  State<PronunciationAssessmentPage> createState() =>
      _PronunciationAssessmentPageState();
}

class PronunciationAssessmentView extends PronunciationAssessmentPage {
  const PronunciationAssessmentView({super.key});
}

class _PronunciationAssessmentPageState
    extends State<PronunciationAssessmentPage> {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  bool _isLoading = false;
  Map<String, dynamic>? _result;
  String _status = "جاهز للتسجيل";

  int? _httpStatus;
  int? _audioBytesSent;
  String? _heardText;
  String? _recognitionStatus;
  String? _wavInfo;
  String? _sendWarning;

  final String referenceText =
      "We had a great time taking a long walk in the morning.";

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  String _formatScore(dynamic value, {int digits = 1}) {
    if (value is num) return value.toStringAsFixed(digits);
    return "-";
  }

  List<String> _wordsOf(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r"[^a-z'\s]"), " ")
        .split(RegExp(r"\s+"))
        .where((w) => w.isNotEmpty)
        .toList();
  }

  Map<String, dynamic> _pronFromNBest(Map nBest) {
    if (nBest["PronunciationAssessment"] is Map) {
      return Map<String, dynamic>.from(nBest["PronunciationAssessment"] as Map);
    }
    return {
      "PronScore": nBest["PronScore"],
      "AccuracyScore": nBest["AccuracyScore"],
      "FluencyScore": nBest["FluencyScore"],
      "CompletenessScore": nBest["CompletenessScore"],
      "ProsodyScore": nBest["ProsodyScore"],
    };
  }

  Map<String, dynamic> _wordPron(Map word) {
    if (word["PronunciationAssessment"] is Map) {
      return Map<String, dynamic>.from(word["PronunciationAssessment"] as Map);
    }
    return {
      "AccuracyScore": word["AccuracyScore"],
      "ErrorType": word["ErrorType"],
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

    writeString("RIFF");
    write32(36 + pcm.length);
    writeString("WAVE");
    writeString("fmt ");
    write32(16);
    write16(1);
    write16(channels);
    write32(sampleRate);
    write32(byteRate);
    write16(blockAlign);
    write16(bits);
    writeString("data");
    write32(pcm.length);
    header.add(pcm);
    return Uint8List.fromList(header.takeBytes());
  }

  String _describeWav(Uint8List bytes) {
    if (bytes.length < 44) return "ملف قصير جداً (${bytes.length} بايت)";
    final riff = ascii.decode(bytes.sublist(0, 4), allowInvalid: true);
    final wave = ascii.decode(bytes.sublist(8, 12), allowInvalid: true);
    final format = bytes[20] | (bytes[21] << 8);
    final channels = bytes[22] | (bytes[23] << 8);
    final sampleRate =
        bytes[24] | (bytes[25] << 8) | (bytes[26] << 16) | (bytes[27] << 24);
    final bits = bytes[34] | (bytes[35] << 8);
    final pcmOk =
        format == 1 && channels == 1 && sampleRate == 16000 && bits == 16;
    return "$riff/$wave  format=$format  ${channels}ch  ${sampleRate}Hz  ${bits}bit"
        "  ${bytes.length}B${pcmOk ? "  ✓ PCM مطابق لـ Azure" : "  ⚠ الصيغة قد تُرفض أو تُقيَّم خطأ"}";
  }

  Future<void> _startRecording() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      if (!mounted) return;
      setState(() => _status = "يجب السماح بالوصول للمايكروفون");
      return;
    }

    final dir = await getTemporaryDirectory();
    final path =
        "${dir.path}/pronunciation_${DateTime.now().millisecondsSinceEpoch}.pcm";

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
        bitRate: 256000,
      ),
      path: path,
    );

    if (!mounted) return;
    setState(() {
      _isRecording = true;
      _status = "جاري التسجيل... اقرأ النص الآن";
      _result = null;
      _httpStatus = null;
      _audioBytesSent = null;
      _heardText = null;
      _recognitionStatus = null;
      _wavInfo = null;
      _sendWarning = null;
    });
  }

  Future<void> _stopRecording() async {
    final path = await _recorder.stop();
    if (!mounted) return;
    setState(() {
      _isRecording = false;
      _status = "تم إيقاف التسجيل. جاري التقييم...";
    });

    if (path != null) {
      await _assessPronunciation(File(path));
    } else {
      setState(() => _status = "لم يتم حفظ ملف التسجيل");
    }
  }

  Future<void> _assessPronunciation(File audioFile) async {
    setState(() => _isLoading = true);

    try {
      if (!await audioFile.exists()) {
        setState(() => _status = "ملف التسجيل غير موجود");
        return;
      }

      final rawBytes = await audioFile.readAsBytes();
      final isAlreadyWav = rawBytes.length >= 12 &&
          ascii.decode(rawBytes.sublist(0, 4), allowInvalid: true) == "RIFF";
      final wavBytes = isAlreadyWav ? rawBytes : _pcmToWav(rawBytes);
      final wavInfo = _describeWav(wavBytes);

      if (wavBytes.length < 4000) {
        setState(() {
          _audioBytesSent = wavBytes.length;
          _wavInfo = wavInfo;
          _status =
              "التسجيل قصير جداً (${wavBytes.length} بايت). سجّل ثانية واحدة على الأقل.";
        });
        return;
      }

      final config = await instance<SpeechConfigRepository>().load();
      final pronParams = {
        "ReferenceText": referenceText.trim(),
        "GradingSystem": "HundredMark",
        "Granularity": "Word",
        "Dimension": "Comprehensive",
        "EnableMiscue": "True",
        "EnableProsodyAssessment": "True",
      };

      final pronHeader = base64Encode(utf8.encode(jsonEncode(pronParams)));
      final url = Uri.parse(
        "https://${config.region}.stt.speech.microsoft.com/speech/recognition/conversation/cognitiveservices/v1"
        "?language=${config.language}&format=detailed",
      );

      log("Azure STT POST $url bytes=${wavBytes.length}");

      final client = http.Client();
      late http.Response response;
      try {
        final request = http.Request("POST", url);
        request.headers.addAll({
          "Ocp-Apim-Subscription-Key": config.speechKey,
          "Content-Type": "audio/wav; codecs=audio/pcm; samplerate=16000",
          "Accept": "application/json",
          "Pronunciation-Assessment": pronHeader,
          "Cache-Control": "no-cache, no-store",
          "Pragma": "no-cache",
        });
        request.bodyBytes = wavBytes;
        response = await http.Response.fromStream(await client.send(request));
      } finally {
        client.close();
      }

      log("Azure STT status=${response.statusCode} body=${response.body}");

      if (!mounted) return;
      setState(() {
        _httpStatus = response.statusCode;
        _audioBytesSent = wavBytes.length;
        _wavInfo = wavInfo;
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final heard = (data["DisplayText"] ??
                (data["NBest"] is List && (data["NBest"] as List).isNotEmpty
                    ? (data["NBest"] as List)[0]["Display"]
                    : null))
            ?.toString();
        final heardWords = _wordsOf(heard ?? "");
        final refWords = _wordsOf(referenceText);
        String? warning;
        if (heardWords.isEmpty) {
          warning = "الخدمة لم تسمع كلاماً واضحاً في الملف المُرسل.";
        } else if (heardWords.length < (refWords.length / 2).ceil()) {
          warning =
              "ما سمعته الخدمة أقصر من النص المطلوب. إذا ظهرت درجة 100 فالتقييم غير موثوق.";
        }

        setState(() {
          _result = data;
          _heardText = heard;
          _recognitionStatus = data["RecognitionStatus"]?.toString();
          _sendWarning = warning;
          _status = data["RecognitionStatus"] == "Success"
              ? "تم الاتصال بالخدمة وإرسال الصوت"
              : "استجابة من الخدمة: ${data["RecognitionStatus"]}";
        });
      } else {
        setState(() {
          _result = null;
          _heardText = null;
          _recognitionStatus = null;
          _status = "الخدمة ردّت بخطأ: ${response.statusCode}\n${response.body}";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _status = "فشل الاتصال بالخدمة: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _wordColor(String error, dynamic accuracy) {
    if (error != "None") return ColorManager.red;
    if (accuracy is num) {
      if (accuracy < 60) return ColorManager.red;
      if (accuracy < 80) return ColorManager.yellow;
    }
    return ColorManager.green;
  }

  Widget _buildDiagnostics() {
    if (_httpStatus == null && _audioBytesSent == null) {
      return const SizedBox.shrink();
    }

    final connected = _httpStatus == 200;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: connected
            ? ColorManager.containerColor1
            : ColorManager.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: connected ? ColorManager.lightPrimary : ColorManager.red,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            connected ? "متصل بخدمة Azure Speech" : "غير متصل / رفض من الخدمة",
            style: getBoldStyle(
              color: connected ? ColorManager.green : ColorManager.red,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            "HTTP: ${_httpStatus ?? "-"}   الحالة: ${_recognitionStatus ?? "-"}",
            style:
                getRegularStyle(color: ColorManager.textColor, fontSize: 13.sp),
          ),
          Text(
            "حجم الصوت المُرسل: ${_audioBytesSent ?? 0} بايت",
            style:
                getRegularStyle(color: ColorManager.textColor, fontSize: 13.sp),
          ),
          if (_wavInfo != null)
            Text(
              _wavInfo!,
              style:
                  getRegularStyle(color: ColorManager.greyText, fontSize: 12.sp),
            ),
          SizedBox(height: 8.h),
          Text(
            "ما سمعته الخدمة:",
            style: getBoldStyle(color: ColorManager.textColor, fontSize: 13.sp),
          ),
          Text(
            (_heardText == null || _heardText!.trim().isEmpty)
                ? "(لا يوجد نص مسموع)"
                : _heardText!,
            style: getMediumStyle(color: ColorManager.blue, fontSize: 14.sp),
          ),
          if (_sendWarning != null) ...[
            SizedBox(height: 8.h),
            Text(
              _sendWarning!,
              style: getRegularStyle(color: ColorManager.red, fontSize: 13.sp),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScores() {
    if (_result == null) return const SizedBox.shrink();

    final nBest = _result!["NBest"] is List &&
            (_result!["NBest"] as List).isNotEmpty
        ? (_result!["NBest"] as List)[0]
        : null;
    if (nBest is! Map) {
      return Text(
        "لا توجد نتائج تقييم. الحالة: ${_recognitionStatus ?? "-"}",
        style: getRegularStyle(color: ColorManager.red, fontSize: 14.sp),
      );
    }

    final pron = _pronFromNBest(nBest);
    final words = nBest["Words"] is List ? nBest["Words"] as List : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "الدرجة الكلية: ${_formatScore(pron["PronScore"])}",
          style: getBoldStyle(color: ColorManager.textColor, fontSize: 22.sp),
        ),
        SizedBox(height: 8.h),
        Text(
          "الدقة (Accuracy): ${_formatScore(pron["AccuracyScore"])}",
          style: getRegularStyle(color: ColorManager.textColor, fontSize: 14.sp),
        ),
        Text(
          "الطلاقة (Fluency): ${_formatScore(pron["FluencyScore"])}",
          style: getRegularStyle(color: ColorManager.textColor, fontSize: 14.sp),
        ),
        Text(
          "الاكتمال (Completeness): ${_formatScore(pron["CompletenessScore"])}",
          style: getRegularStyle(color: ColorManager.textColor, fontSize: 14.sp),
        ),
        if (pron["ProsodyScore"] != null)
          Text(
            "الإيقاع (Prosody): ${_formatScore(pron["ProsodyScore"])}",
            style:
                getRegularStyle(color: ColorManager.textColor, fontSize: 14.sp),
          ),
        SizedBox(height: 20.h),
        Text(
          "تفاصيل الكلمات:",
          style: getBoldStyle(color: ColorManager.textColor, fontSize: 16.sp),
        ),
        if (words.isEmpty)
          Text(
            "لا توجد كلمات في الاستجابة",
            style: getRegularStyle(color: ColorManager.red, fontSize: 14.sp),
          ),
        ...words.map((w) {
          if (w is! Map) return const SizedBox.shrink();
          final assessment = _wordPron(w);
          final error = (assessment["ErrorType"] ?? "None").toString();
          final acc = assessment["AccuracyScore"];
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 2.h),
            child: Text(
              "${w["Word"]}  →  ${_formatScore(acc, digits: 0)}  ${error == "None" ? "" : "[$error]"}",
              style: getRegularStyle(
                color: _wordColor(error, acc),
                fontSize: 14.sp,
              ),
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "تقييم النطق",
          style: getBoldStyle(color: ColorManager.textColor, fontSize: 18.sp),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: ColorManager.containerColor1,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                referenceText,
                style: getMediumStyle(
                  color: ColorManager.textColor,
                  fontSize: 18.sp,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              _status,
              style: getRegularStyle(
                color: ColorManager.greyText,
                fontSize: 16.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton.icon(
                onPressed: _isRecording ? _stopRecording : _startRecording,
                icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                label: Text(_isRecording ? "إيقاف التسجيل" : "ابدأ التسجيل"),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isRecording ? ColorManager.red : ColorManager.lightBlue,
                  foregroundColor: ColorManager.white,
                  padding:
                      EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                ),
              ),
            SizedBox(height: 20.h),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDiagnostics(),
                    _buildScores(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
