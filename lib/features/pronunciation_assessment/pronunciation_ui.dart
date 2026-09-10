import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/cubit/pronunciation_state.dart';
import 'package:micro_teaching_studio/features/pronunciation_assessment/models/pronunciation_result.dart';

Color pronunciationMicColor(PronunciationState state, Color idle) {
  if (state.isRecording) return ColorManager.red;
  if (state.isAssessing) return ColorManager.accentAmber;
  return idle;
}

Color pronunciationMicGlow(PronunciationState state, Color idle) {
  if (state.isRecording) return ColorManager.softCoral;
  if (state.isAssessing) return ColorManager.accentAmber;
  return idle;
}

Color pronunciationBandColor(PronunciationBand? band, Color fallback) {
  switch (band) {
    case PronunciationBand.excellent:
      return ColorManager.emerald;
    case PronunciationBand.needsImprov:
      return ColorManager.amberDeep;
    case PronunciationBand.incorrect:
      return ColorManager.roseDeep;
    case null:
      return fallback;
  }
}

PronunciationBand? pronunciationBandForTitle(String titleKey) {
  if (titleKey == AppStrings.phonicsExcellent) {
    return PronunciationBand.excellent;
  }
  if (titleKey == AppStrings.phonicsNeedsImprov) {
    return PronunciationBand.needsImprov;
  }
  if (titleKey == AppStrings.phonicsIncorrect) {
    return PronunciationBand.incorrect;
  }
  return null;
}

bool pronunciationTileActive({
  required String titleKey,
  required PronunciationBand? band,
}) {
  if (band == null) return true;
  return pronunciationBandForTitle(titleKey) == band;
}

String pronunciationMicHint(PronunciationState state, String idleKey) {
  if (state.isRecording) return AppStrings.pronunciationRecording.tr();
  if (state.isAssessing) return AppStrings.pronunciationAssessing.tr();
  return idleKey.tr();
}

String pronunciationTwinTip(PronunciationState state, String fallbackKey) {
  final result = state.result;
  if (result == null) return fallbackKey.tr();
  final word = result.weakestWord ?? '';
  final sound = _slash(result.weakestPhoneme);
  final heard = _slash(result.heardPhoneme);
  if (heard != null && sound != null) {
    return AppStrings.pronunciationAiTwinHeardSound.tr(
      namedArgs: {'heard': heard, 'sound': sound, 'word': word},
    );
  }
  if (sound != null && result.band != PronunciationBand.excellent) {
    return AppStrings.pronunciationAiTwinSound.tr(
      namedArgs: {'sound': sound, 'word': word},
    );
  }
  switch (result.band) {
    case PronunciationBand.excellent:
      return AppStrings.pronunciationAiTwinExcellent.tr();
    case PronunciationBand.needsImprov:
      return AppStrings.pronunciationAiTwinNeedsImprov.tr(
        namedArgs: {'word': word},
      );
    case PronunciationBand.incorrect:
      return AppStrings.pronunciationAiTwinIncorrect.tr(
        namedArgs: {'word': word},
      );
  }
}

String phonicsTwinTip(PronunciationState state) {
  if (state.result == null) return AppStrings.phonicsAiTwinTip.tr();
  switch (state.result!.band) {
    case PronunciationBand.excellent:
      return AppStrings.phonicsAiTwinExcellent.tr();
    case PronunciationBand.needsImprov:
      return AppStrings.phonicsAiTwinNeedsImprov.tr();
    case PronunciationBand.incorrect:
      return AppStrings.phonicsAiTwinIncorrect.tr();
  }
}

List<InlineSpan> pronunciationPassageSpans({
  required String passage,
  required PronunciationResult? result,
  required TextStyle baseStyle,
}) {
  if (result == null || result.alignedWords.isEmpty) {
    return [TextSpan(text: passage, style: baseStyle)];
  }
  final aligned = result.alignedWords;
  var index = 0;
  return RegExp(r"[A-Za-z']+|[^A-Za-z']+")
      .allMatches(passage)
      .map((match) {
        final token = match.group(0)!;
        if (!_isWordToken(token)) {
          return TextSpan(text: token, style: baseStyle);
        }
        final scored = _takeAlignedWord(aligned, token, index);
        if (scored != null) index = scored.key + 1;
        final band = scored?.value.band;
        return TextSpan(
          text: token,
          style: baseStyle.copyWith(
            color: pronunciationBandColor(
              band,
              baseStyle.color ?? ColorManager.slate800,
            ),
          ),
        );
      })
      .toList();
}

List<InlineSpan> pronunciationIpaSpans({
  required String ipa,
  required PronunciationResult? result,
  required TextStyle baseStyle,
}) {
  final phonemes = result?.alignedWords
          .expand((word) => word.phonemes)
          .where((phoneme) => phoneme.phoneme.isNotEmpty)
          .toList() ??
      const <PronunciationPhonemeScore>[];
  if (phonemes.isEmpty) {
    return [
      TextSpan(
        text: ipa,
        style: baseStyle.copyWith(
          color: pronunciationBandColor(
            result?.band,
            baseStyle.color ?? ColorManager.slate,
          ),
        ),
      ),
    ];
  }

  final spans = <InlineSpan>[];
  var cursor = 0;
  var phonemeIndex = 0;
  while (cursor < ipa.length) {
    final current = ipa[cursor];
    if (_ipaMarks.contains(current)) {
      spans.add(TextSpan(text: current, style: baseStyle));
      cursor++;
      continue;
    }
    if (phonemeIndex >= phonemes.length) {
      spans.add(TextSpan(text: ipa.substring(cursor), style: baseStyle));
      break;
    }
    final phoneme = phonemes[phonemeIndex];
    final matched = _matchPhonemeAt(ipa, cursor, phoneme.phoneme);
    if (matched == null) {
      spans.add(TextSpan(text: current, style: baseStyle));
      cursor++;
      continue;
    }
    spans.add(
      TextSpan(
        text: matched,
        style: baseStyle.copyWith(
          color: pronunciationBandColor(
            phoneme.band,
            baseStyle.color ?? ColorManager.slate,
          ),
        ),
      ),
    );
    cursor += matched.length;
    phonemeIndex++;
  }
  return spans;
}

String? _slash(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return null;
  return text.startsWith('/') ? text : '/$text/';
}

bool _isWordToken(String token) => RegExp(r"[A-Za-z]").hasMatch(token);

String _normalizeWord(String value) {
  return value.toLowerCase().replaceAll(RegExp(r"[^a-z']"), '');
}

MapEntry<int, PronunciationWordScore>? _takeAlignedWord(
  List<PronunciationWordScore> words,
  String token,
  int start,
) {
  final needle = _normalizeWord(token);
  if (needle.isEmpty) return null;
  for (var i = start; i < words.length; i++) {
    if (_normalizeWord(words[i].word) == needle) {
      return MapEntry(i, words[i]);
    }
  }
  if (start < words.length) {
    return MapEntry(start, words[start]);
  }
  return null;
}

const Set<String> _ipaMarks = {
  '/',
  'ˈ',
  'ˌ',
  'ː',
  '.',
  ' ',
  '(',
  ')',
  '[',
  ']',
  '-',
};

const Map<String, String> _sapiToIpa = {
  'aa': 'ɑ',
  'ae': 'æ',
  'ah': 'ʌ',
  'ao': 'ɔ',
  'aw': 'aʊ',
  'ay': 'aɪ',
  'ch': 'tʃ',
  'dh': 'ð',
  'eh': 'ɛ',
  'er': 'ɜ',
  'ey': 'eɪ',
  'hh': 'h',
  'ih': 'ɪ',
  'iy': 'i',
  'jh': 'dʒ',
  'ng': 'ŋ',
  'ow': 'oʊ',
  'oy': 'ɔɪ',
  'sh': 'ʃ',
  'th': 'θ',
  'uh': 'ʊ',
  'uw': 'u',
  'y': 'j',
  'zh': 'ʒ',
  'ax': 'ə',
};

String? _matchPhonemeAt(String ipa, int start, String phoneme) {
  final candidates = <String>{
    phoneme,
    if (_sapiToIpa[phoneme.toLowerCase()] != null)
      _sapiToIpa[phoneme.toLowerCase()]!,
  };
  final sorted = candidates.toList()
    ..sort((a, b) => b.length.compareTo(a.length));
  for (final candidate in sorted) {
    if (candidate.isEmpty) continue;
    if (ipa.startsWith(candidate, start)) return candidate;
  }
  return null;
}
